require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::ErgoTree::Test < Test::Unit::TestCase

  def test_encoding
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_equal(base_16, tree.to_base16_encoded_string)
    bytes = assert_nothing_raised do
      tree.to_bytes
    end
    tree_from_bytes = Sigma::ErgoTree.from_bytes(bytes)
    assert_equal(tree_from_bytes, tree)
    assert_nothing_raised do
      tree.to_template_bytes
    end
  end

  def test_constant_length
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_equal(2, tree.constants_length)
  end

  def test_get_constant
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_not_nil(tree.get_constant(0))
    assert_not_nil(tree.get_constant(1))
    assert_equal(nil, tree.get_constant(2))
  end

  def test_with_constant
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_equal(2, tree.constants_length)
    constant = Sigma::Constant.with_i32(99)
    tree.replace_constant(index: 0, constant: constant)
    assert_equal(99, tree.get_constant(0).to_i32) 
    assert_equal(2, tree.constants_length) 
  end

  def test_with_constant_out_of_bounds
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_equal(2, tree.constants_length)
    constant = Sigma::Constant.with_i32(99)
    assert_raise do
      tree.replace_constant(index: 3, constant: constant)
    end
  end

  def test_with_constant_type_mismatch
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    assert_equal(2, tree.constants_length)
    constant = Sigma::Constant.with_i64(342423)
    assert_raise do
      tree.replace_constant(index: 0, constant: constant)
    end
  end
end

