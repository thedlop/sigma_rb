require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::BoxSelection::Test < Test::Unit::TestCase
  def test_box_selection
    # create ergo boxes
    box_id_str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_value_int = 67500000000
    ergo_tree_encoded_str = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tx_id_str = "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9"
    creation_height = 284761
    index = 1

    box_id = Sigma::BoxId.with_string(box_id_str)
    box_value = Sigma::BoxValue.from_i64(box_value_int)
    ergo_tree = Sigma::ErgoTree.from_base16_encoded_string(ergo_tree_encoded_str)
    contract = Sigma::Contract.from_ergo_tree(ergo_tree)
    tx_id = Sigma::TxId.with_string(tx_id_str)
    tokens = Sigma::Tokens.create
    ergo_box = Sigma::ErgoBox.create(box_value: box_value, creation_height: creation_height, 
      contract: contract, tx_id: tx_id, index: index, tokens: tokens)
    ergo_boxes = Sigma::ErgoBoxes.create
    ergo_boxes.add(ergo_box)

    # create change boxes
    amount = 12345678
    box_value = Sigma::BoxValue.from_i64(amount)
    tokens = Sigma::Tokens.create
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.from_base16_encoded_string(str)
    amount = 12345678
    token_amount = Sigma::TokenAmount.with_i64(amount)
    token = Sigma::Token.create(token_id: token_id, token_amount: token_amount)
    tokens.add(token)
    ergo_box_assets_data = Sigma::ErgoBoxAssetsData.create(box_value: box_value, tokens: tokens)
    change_boxes = Sigma::ErgoBoxAssetsDataList.create
    change_boxes.add(ergo_box_assets_data)

    selection = Sigma::BoxSelection.create(ergo_boxes: ergo_boxes, change_ergo_boxes: change_boxes)
    retrieved_boxes = selection.get_boxes
    assert_equal(ergo_boxes.len, retrieved_boxes.len)
    assert_equal(ergo_boxes.get(0), retrieved_boxes.get(0))
    assert_equal(ergo_boxes.get(1), retrieved_boxes.get(1))

    retrieved_change_boxes = selection.get_change_boxes
    assert_equal(change_boxes.len, retrieved_change_boxes.len)
    assert_equal(change_boxes.get(0), retrieved_change_boxes.get(0))
    assert_equal(change_boxes.get(1), retrieved_change_boxes.get(1))
  end

  def test_simple_box_selector
    box_attrs = {
      boxId: "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e",
      value: 67500000000,
      ergoTree: "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301",
      assets: [],                                                                                                                                        
      creationHeight: 284761,
      additionalRegisters: {},
      transactionId: "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9",
      index: 1
    }

    json = box_attrs.to_json
    boxes = Sigma::ErgoBoxes.from_json([json])
    sbs = Sigma::SimpleBoxSelector.create
    value = Sigma::BoxValue.from_i64(10000000)
    tokens = Sigma::Tokens.create
    selection = sbs.select(inputs: boxes, target_balance: value, target_tokens: tokens)
    expected_box_id = boxes.get(0).get_box_id
    selected_box_id = selection.get_boxes.get(0).get_box_id
    assert_equal(expected_box_id, selected_box_id)
  end
end
