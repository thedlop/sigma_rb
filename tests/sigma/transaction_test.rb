require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'
include Sigma

class Transaction::Test < Test::Unit::TestCase
  def test_tx_id
    str = '93d344aa527e18e5a221db060ea1a868f46b61e4537e6e5f69ecc40334c15e38'
    tx_id = TxId.with_string(str)
    assert_equal(str, tx_id.to_s)
  end

  def test_tx_builder
    tn_address = '3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN'
    box_id_str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_value_int = 67500000000
    ergo_tree_encoded_str = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    creation_height = 284761
    tx_id_str = "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9"
    index = 1
    payload = { 
      'boxId' => box_id_str,
      'value' => box_value_int,
      'ergoTree' => ergo_tree_encoded_str,
      'assets' => [],
      'creationHeight' => creation_height,
      'additionalRegisters' => {},
      'transactionId' => tx_id_str,
      'index' => index
    }
    json_str = payload.to_json

    recipient = Address.with_testnet_address(tn_address)
    unspent_boxes = ErgoBoxes.from_json([json_str])
    contract = Contract.pay_to_address(recipient)
    outbox_value = BoxValue.safe_user_min
    outbox = ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: 0).build
    tx_outputs = ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    fee = TxBuilder.suggested_tx_fee
    change_address = Address.with_testnet_address(tn_address)
    min_change_value = BoxValue.safe_user_min
    data_inputs = DataInputs.create
    box_selector = SimpleBoxSelector.create
    target_balance = BoxValue.sum_of(outbox_value, fee)
    tokens = Tokens.create
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: tokens)
    tx_builder = TxBuilder.create( 
      box_selection: box_selection,
      output_candidates: tx_outputs,
      current_height: 0,
      fee_amount: fee,
      change_address: change_address,
      min_change_value: min_change_value
    )
    tx_builder.set_data_inputs(data_inputs)
    tx = tx_builder.build
    assert_nothing_raised do
      tx.to_json_eip12
    end
  end

  def test_sign_transaction
    sk = SecretKey.create
    input_contract = Contract.pay_to_address(sk.get_address)
    str = "93d344aa527e18e5a221db060ea1a868f46b61e4537e6e5f69ecc40334c15e38"
    tx_id = TxId.with_string(str)
    bv = BoxValue.from_i64(1000000000)
    creation_height = 0
    index = 0
    tokens = Tokens.create
    input_box = ErgoBox.create(box_value: bv, creation_height: creation_height, contract: input_contract, tx_id: tx_id, index: index, tokens: tokens)

    # Create transaction that spends the 'simulated' box
    tn_address_str = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    recipient = Address.with_testnet_address(tn_address_str)
    unspent_boxes = ErgoBoxes.create
    unspent_boxes.add(input_box)
    contract = Contract.pay_to_address(recipient)
    outbox_value = BoxValue.safe_user_min
    outbox = ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: creation_height).build
    tx_outputs = ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    fee = TxBuilder.suggested_tx_fee
    change_address = Address.with_testnet_address(tn_address_str)
    min_change_value = BoxValue.safe_user_min
    data_inputs = DataInputs.create
    box_selector = SimpleBoxSelector.create
    target_balance = BoxValue.sum_of(outbox_value, fee)
    empty_tokens = Tokens.create
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: empty_tokens)
    tx_builder = TxBuilder.create(
      box_selection: box_selection,
      output_candidates: tx_outputs,
      current_height: creation_height,
      fee_amount: fee,
      change_address: change_address,
      min_change_value: min_change_value)
    tx_builder.set_data_inputs(data_inputs)
    tx = tx_builder.build
    assert_nothing_raised do
      tx.to_json_eip12
    end
    tx_data_inputs = ErgoBoxes.from_json([])
    block_headers = TestSeeds.block_headers_from_json
    pre_header = PreHeader.with_block_header(block_headers.get(0))
    ctx = ErgoStateContext.create(pre_header: pre_header, headers: block_headers)
    secret_keys = SecretKeys.create
    secret_keys.add(sk)
    wallet = Wallet.create_from_secrets(secret_keys)
    signed_tx = wallet.sign_transaction(state_context: ctx, unsigned_tx: tx, boxes_to_spend: unspent_boxes, data_boxes: tx_data_inputs)
    assert_nothing_raised do
      signed_tx.to_json_eip12
    end
  end

  def test_mint_token
    tn_addr = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    recipient = Address.with_testnet_address(tn_addr)
    eb_json = {
      boxId: "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e",
      value: 67500000000,
      ergoTree: "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301",
      assets: [],
      creationHeight: 284761,
      additionalRegisters: {},
      transactionId: "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9",
      index: 1
    }.to_json
    unspent_boxes = ErgoBoxes.from_json([eb_json])
    contract = Contract.pay_to_address(recipient)
    outbox_value = BoxValue.safe_user_min
    fee = TxBuilder.suggested_tx_fee
    box_selector = SimpleBoxSelector.create
    target_balance = BoxValue.sum_of(outbox_value, fee)
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance:  target_balance, target_tokens: Tokens.create)
    # mint token
    token_id = TokenId.with_box_id(box_selection.get_boxes.get(0).get_box_id)
    token = Token.create(token_id: token_id, token_amount: TokenAmount.with_i64(1))
    box_builder = ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: 0).mint_token(token: token, name: "TKN", description: "token desc", num_decimals: 2)
    outbox = box_builder.build
    tx_outputs = ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    change_address = Address.with_testnet_address(tn_addr)
    min_change_value = BoxValue.safe_user_min
    data_inputs = DataInputs.create
    tx_builder = TxBuilder.create(box_selection: box_selection, output_candidates: tx_outputs, current_height: 0, fee_amount: fee, change_address: change_address, min_change_value: min_change_value)
    tx_builder.set_data_inputs(data_inputs)
    tx = tx_builder.build
    assert_nothing_raised do
      tx.to_json_eip12
    end
  end

  def test_burn_token
    eb_json =
      {
        boxId: "0cf7b9e71961cc473242de389c8e594a4e5d630ddd2e4e590083fb0afb386341",
        value: 11491500000,
        ergoTree: "100f040005c801056404000e2019719268d230fd9093e4db0e2e42a07883ffe976e77c7419efc1bb218a05d4ba04000500043c040204c096b10204020101040205c096b1020400d805d601b2a5730000d602e4c6a70405d6039c9d720273017302d604b5db6501fed9010463ededed93e4c67204050ec5a7938cb2db6308720473030001730492e4c672040605997202720390e4c6720406059a72027203d605b17204ea02d1edededededed93cbc27201e4c6a7060e917205730593db63087201db6308a793e4c6720104059db072047306d9010641639a8c720601e4c68c72060206057e72050593e4c6720105049ae4c6a70504730792c1720199c1a77e9c9a720573087309058cb072048602730a730bd901063c400163d802d6088c720601d6098c72080186029a7209730ceded8c72080293c2b2a5720900d0cde4c68c720602040792c1b2a5720900730d02b2ad7204d9010663cde4c672060407730e00",
        assets: [
          {
            tokenId: "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac",
            amount: 1
          }
        ],
        creationHeight: 348198,
        additionalRegisters: {
          R4: "059acd9109",
          R5: "04f2c02a",
          R6: "0e20277c78751ff6f68d4dcd082eeea9506324911a875b6b9cd4d177d4fcab061327"
        },
        transactionId: "5ed0e572a8c097b053965519a696f413f7be02754345e8ed650377e29a6dedb3",
        index: 0
      }.to_json
      unspent_boxes = ErgoBoxes.from_json([eb_json])
      tn_address = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
      recipient = Address.with_testnet_address(tn_address)
      token_id = TokenId.from_base16_encoded_string("19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac")
      token = Token.create(token_id: token_id, token_amount: TokenAmount.with_i64(1))
      box_selector = SimpleBoxSelector.create
      tokens = Tokens.create 
      tokens.add(token)
      outbox_value = BoxValue.safe_user_min
      fee = TxBuilder.suggested_tx_fee
      target_balance = BoxValue.sum_of(outbox_value, fee)
      box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: tokens) 
      # Select tokens from inputs
      contract = Contract.pay_to_address(recipient)
      # but don't put selected tokens in the output box (burn them)
      box_builder = ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: 0)
      outbox = box_builder.build
      tx_outputs = ErgoBoxCandidates.create
      tx_outputs.add(outbox)
      change_address = Address.with_testnet_address(tn_address)
      min_change_value = BoxValue.safe_user_min
      data_inputs = DataInputs.create
      tx_builder = TxBuilder.create(box_selection: box_selection, output_candidates: tx_outputs, current_height: 0, fee_amount: fee, change_address: change_address, min_change_value: min_change_value)
      tx_builder.set_data_inputs(data_inputs)
      assert_nothing_raised do
        tx_builder.build()
      end
  end

  def test_using_signed_tx_as_input_in_new_tx
    sk = SecretKey.create
    input_contract = Contract.pay_to_address(sk.get_address)
    str = "0000000000000000000000000000000000000000000000000000000000000000"
    tx_id = TxId.with_string(str)
    input_box_bv = BoxValue.from_i64(100000000000)
    input_box_tokens = Tokens.create
    input_box = ErgoBox.create(box_value: input_box_bv, creation_height: 0, contract: input_contract, tx_id: tx_id, index: 0, tokens: input_box_tokens)
    # Create transaction that spends the 'simulated' box
    tn_address = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    recipient = Address.with_testnet_address(tn_address)
    unspent_boxes = ErgoBoxes.create
    unspent_boxes.add(input_box)
    contract = Contract.pay_to_address(recipient)
    outbox_value = BoxValue.from_i64(10000000000)
    outbox = ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: 0).build
    tx_outputs = ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    fee = TxBuilder.suggested_tx_fee
    change_address = Address.with_testnet_address(tn_address)
    min_change_value = BoxValue.safe_user_min
    data_inputs = DataInputs.create
    box_selector = SimpleBoxSelector.create
    target_balance = BoxValue.sum_of(outbox_value, fee)
    target_tokens = Tokens.create
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: target_tokens)
    tx_builder = TxBuilder.create(box_selection: box_selection, output_candidates: tx_outputs, current_height: 0, fee_amount: fee, change_address: change_address, min_change_value: min_change_value)
    tx_builder.set_data_inputs(data_inputs)
    tx = tx_builder.build
    assert_nothing_raised do
      tx.to_json_eip12
    end
    tx_data_inputs = ErgoBoxes.from_json([])
    block_headers = TestSeeds.block_headers_from_json
    pre_header = PreHeader.with_block_header(block_headers.get(0))
    ctx = ErgoStateContext.create(pre_header: pre_header, headers: block_headers)
    secret_keys = SecretKeys.create
    secret_keys.add(sk)
    wallet = Wallet.create_from_secrets(secret_keys)
    signed_tx = wallet.sign_transaction(state_context: ctx, unsigned_tx: tx, boxes_to_spend: unspent_boxes, data_boxes: tx_data_inputs)
    assert_equal(10000000000, signed_tx.get_outputs.get(0).get_box_value.to_i64)
    assert_nothing_raised do
      signed_tx.to_json_eip12
    end
    # New tx
    new_outbox_value = BoxValue.from_i64(1000000000)
    new_outbox = ErgoBoxCandidateBuilder.create(box_value: new_outbox_value, contract: contract, creation_height: 0).build
    new_tx_outputs = ErgoBoxCandidates.create
    new_tx_outputs.add(new_outbox)
    new_box_selector = SimpleBoxSelector.create
    new_target_balance = BoxValue.sum_of(new_outbox_value, fee)      
    new_box_selection = new_box_selector.select(inputs: signed_tx.get_outputs, target_balance: new_target_balance, target_tokens: Tokens.create)
    new_tx_builder = TxBuilder.create(
        box_selection: new_box_selection,
        output_candidates: new_tx_outputs, 
        current_height: 0,
        fee_amount: fee,
        change_address: change_address,
        min_change_value: min_change_value
      )

    assert_nothing_raised do
      new_tx_builder.build
    end
  end

  def test_tx_from_unsigned_tx
  end

  def test_wallet_mnemonic
  end

  def test_multi_sig_tx
  end
end
