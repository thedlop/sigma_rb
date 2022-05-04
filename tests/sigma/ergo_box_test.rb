require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::ErgoBox::Test < Test::Unit::TestCase
  def test_box_id
    str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_id = Sigma::BoxId.with_string(str)
    new_str = box_id.to_s
    assert_equal(str, new_str)
    new_bytes = box_id.to_bytes
    expected_bytes = [229, 104, 71, 237, 25, 179, 220, 107, 114, 130, 143, 207, 185, 146, 253, 247, 49, 8, 40, 207, 41, 18, 33, 38, 155, 127, 252, 114, 253, 102, 112, 110]
    assert_equal(expected_bytes, new_bytes)
  end

  def test_box_value
    amount = 12345678
    box_value = Sigma::BoxValue.from_i64(amount)
    assert_equal(box_value.to_i64, amount)
  end

  def test_box_value_units_per_ergo
    units_per_ergo = Sigma::BoxValue.units_per_ergo
    expected_units_per_ergo = 1000000000
    assert_equal(expected_units_per_ergo, units_per_ergo)
  end

  def test_box_value_sum_of
    amount_one = 12345678
    amount_two = 12345679
    sum = amount_one + amount_two
    bv_one = Sigma::BoxValue.from_i64(amount_one)
    bv_two = Sigma::BoxValue.from_i64(amount_two)
    bv_three = Sigma::BoxValue.sum_of(bv_one, bv_two)
    assert_equal(bv_three.to_i64, sum)
  end

  def test_box_value_safe_user_min
    bv = Sigma::BoxValue.safe_user_min
    expected_safe_user_min = 1000000
    assert_equal(expected_safe_user_min, bv.to_i64)
  end

  def test_ergo_box_initializer
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

    assert_equal(creation_height, ergo_box.get_creation_height)
    assert_equal(box_id, ergo_box.get_box_id)
    assert_equal(box_value, ergo_box.get_box_value)
    assert_equal(ergo_tree, ergo_box.get_ergo_tree)
  end

  def test_ergo_box_json
    box_id_str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_value_int = 67500000000
    ergo_tree_encoded_str = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tx_id_str = "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9"
    creation_height = 284761
    index = 1

    box_id = Sigma::BoxId.with_string(box_id_str)
    box_value = Sigma::BoxValue.from_i64(box_value_int)
    ergo_tree = Sigma::ErgoTree.from_base16_encoded_string(ergo_tree_encoded_str)

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
    # EIP-12 Value can be a number or a string, in this case it is a string
    payload_eip12 = payload.merge({'value' => box_value_int.to_s})

    json_str = payload.to_json

    ergo_box = Sigma::ErgoBox.with_json(json_str)

    assert_equal(creation_height, ergo_box.get_creation_height)
    assert_equal(box_id, ergo_box.get_box_id)
    assert_equal(box_value, ergo_box.get_box_value)
    assert_equal(ergo_tree, ergo_box.get_ergo_tree)
    assert_equal(payload, JSON.parse(ergo_box.to_json))
    assert_equal(payload_eip12, JSON.parse(ergo_box.to_json_eip12))
  end

end
