require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Transaction::Test < Test::Unit::TestCase
  def test_tx_id
    str = '93d344aa527e18e5a221db060ea1a868f46b61e4537e6e5f69ecc40334c15e38'
    tx_id = Sigma::TxId.with_string(str)
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

    recipient = Sigma::Address.with_testnet_address(tn_address)
    unspent_boxes = Sigma::ErgoBoxes.from_json([json_str])
    contract = Sigma::Contract.pay_to_address(recipient)
    outbox_value = Sigma::BoxValue.safe_user_min
    outbox = Sigma::ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: 0).build
    tx_outputs = Sigma::ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    fee = Sigma::TxBuilder.suggested_tx_fee
    change_address = Sigma::Address.with_testnet_address(tn_address)
    min_change_value = Sigma::BoxValue.safe_user_min
    data_inputs = Sigma::DataInputs.create
    box_selector = Sigma::SimpleBoxSelector.create
    target_balance = Sigma::BoxValue.sum_of(outbox_value, fee)
    tokens = Sigma::Tokens.create
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: tokens)
    tx_builder = Sigma::TxBuilder.create( 
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
    sk = Sigma::SecretKey.create
    input_contract = Sigma::Contract.pay_to_address(sk.get_address)
    str = "93d344aa527e18e5a221db060ea1a868f46b61e4537e6e5f69ecc40334c15e38"
    tx_id = Sigma::TxId.with_string(str)
    bv = Sigma::BoxValue.from_i64(1000000000)
    creation_height = 0
    index = 0
    tokens = Sigma::Tokens.create
    input_box = Sigma::ErgoBox.create(box_value: bv, creation_height: creation_height, contract: input_contract, tx_id: tx_id, index: index, tokens: tokens)

    # Create transaction that spends the 'simulated' box
    tn_address_str = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    recipient = Sigma::Address.with_testnet_address(tn_address_str)
    unspent_boxes = Sigma::ErgoBoxes.create
    unspent_boxes.add(input_box)
    contract = Sigma::Contract.pay_to_address(recipient)
    outbox_value = Sigma::BoxValue.safe_user_min
    outbox = Sigma::ErgoBoxCandidateBuilder.create(box_value: outbox_value, contract: contract, creation_height: creation_height).build
    tx_outputs = Sigma::ErgoBoxCandidates.create
    tx_outputs.add(outbox)
    fee = Sigma::TxBuilder.suggested_tx_fee
    change_address = Sigma::Address.with_testnet_address(tn_address_str)
    min_change_value = Sigma::BoxValue.safe_user_min
    data_inputs = Sigma::DataInputs.create
    box_selector = Sigma::SimpleBoxSelector.create
    target_balance = Sigma::BoxValue.sum_of(outbox_value, fee)
    empty_tokens = Sigma::Tokens.create
    box_selection = box_selector.select(inputs: unspent_boxes, target_balance: target_balance, target_tokens: empty_tokens)
    tx_builder = Sigma::TxBuilder.create(
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
    tx_data_inputs = Sigma::ErgoBoxes.from_json([])
    block_headers = []
    header = {
      extensionId: "d16f25b14457186df4c5f6355579cc769261ce1aebc8209949ca6feadbac5a3f",
      difficulty: "626412390187008",
      votes: "040000",
      timestamp: 1618929697400,
      size: 221,
      stateRoot: "8ad868627ea4f7de6e2a2fe3f98fafe57f914e0f2ef3331c006def36c697f92713",
      height: 471746,
      nBits: 117586360,
      version: 2,
      id: "4caa17e62fe66ba7bd69597afdc996ae35b1ff12e0ba90c22ff288a4de10e91b",
      adProofsRoot: "d882aaf42e0a95eb95fcce5c3705adf758e591532f733efe790ac3c404730c39",
      transactionsRoot: "63eaa9aff76a1de3d71c81e4b2d92e8d97ae572a8e9ab9e66599ed0912dd2f8b",
      extensionHash: "3f91f3c680beb26615fdec251aee3f81aaf5a02740806c167c0f3c929471df44",
      powSolutions: {
        pk: "02b3a06d6eaa8671431ba1db4dd427a77f75a5c2acbd71bfb725d38adc2b55f669",
        w: "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        n: "5939ecfee6b0d7f4",
        d: 0
      },
      adProofsId: "86eaa41f328bee598e33e52c9e515952ad3b7874102f762847f17318a776a7ae",
      transactionsId: "ac80245714f25aa2fafe5494ad02a26d46e7955b8f5709f3659f1b9440797b3e",
      parentId: "6481752bace5fa5acba5d5ef7124d48826664742d46c974c98a2d60ace229a34"
    }
    header_json = header.to_json
    headers_json = Array.new(10) { header_json } 
    block_headers = Sigma::BlockHeaders.from_json(headers_json)
    pre_header = Sigma::PreHeader.with_block_header(block_headers.get(0))
    # TODO ErgoStateContext
    ctx = Sigma::ErgoStateContext.create(pre_header: pre_header, headers: block_headers)
    # TODO SecretKeys
    secret_keys = Sigma::SecretKeys.create
    secret_keys.add(sk)
    # TODO Wallet
    wallet = Sigma::Wallet.create(secrets)
    signed_tx = wallet.sign_transaction(state_context: ctx, unsigned_tx: tx, boxes_to_spend: unspent_boxes, data_boxes: tx_data_inputs)
    assert_nothing_raised do
      signed_tx.to_json_eip12
    end
  end

  # TODO
  def test_mint_token
  end

  def test_burn_token
  end

  def test_using_signed_tx_as_input_in_new_tx
  end

  def test_tx_from_unsigned_tx
  end

  def test_wallet_mnemonic
  end

  def test_multi_sig_tx
  end
end
