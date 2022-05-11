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
end
