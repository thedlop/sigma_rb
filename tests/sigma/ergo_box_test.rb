require 'rubygems'
require 'bundler/setup'
require 'test/unit'

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
    box_id = Sigma::BoxId.with_string("e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e")
    box_value = Sigma::BoxValue.from_i64(67500000000)
    ergo_tree = Sigma::ErgoTree.from_base16_encoded_string("100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301")
    contract = Sigma::Contract.from_ergo_tree(ergo_tree)
    # TODO TxId
  end

end
