require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::ErgoBoxCandidateBuilder::Test < Test::Unit::TestCase
  def test_create
    amount = 12345678
    box_value = Sigma::BoxValue.from_i64(amount)
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    contract = Sigma::Contract.from_ergo_tree(tree)
    ebcb = Sigma::ErgoBoxCandidateBuilder.create(box_value: box_value, contract: contract, creation_height: 0)
  end

  def test_box_value
    amount = 12345678
    box_value = Sigma::BoxValue.from_i64(amount)
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    contract = Sigma::Contract.from_ergo_tree(tree)
    ebcb = Sigma::ErgoBoxCandidateBuilder.create(box_value: box_value, contract: contract, creation_height: 0)
    min_per_byte = 100
    ebcb.set_min_box_value_per_byte(min_per_byte)
    assert_equal(min_per_byte, ebcb.get_min_box_value_per_byte)
    new_amount = 123456789
    # TODO
    bytes = ebcb.calc_box_size_bytes
    assert_equal(bytes * min_per_byte, ebcb.calc_min_box_value) 

    #new_box_value = Sigma::BoxValue.from_i64(new_amount)
    #ebcb.set_value(new_box_value)
  end

  # TODO
  def test_register_value
  end
end
