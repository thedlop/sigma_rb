require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Contract::Test < Test::Unit::TestCase
  def test_from_ergo_tree
    base_16 = "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301"
    tree = Sigma::ErgoTree.from_base16_encoded_string(base_16)
    contract = Sigma::Contract.from_ergo_tree(tree)
    assert_equal(tree, contract.get_ergo_tree)
  end

  def test_pay_to_address
    p2pk_addr_str = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    p2pk_addr = Sigma::Address.with_testnet_address(p2pk_addr_str)
    assert_nothing_raised do
      contract = Sigma::Contract.pay_to_address(p2pk_addr)
    end

    p2pk_addr_str = "9fRAWhdxEsTcdb8PhGNrZfwqa65zfkuYHAMmkQLcic1gdLSV5vA"
    p2pk_addr = Sigma::Address.with_mainnet_address(p2pk_addr_str)
    assert_nothing_raised do
      contract = Sigma::Contract.pay_to_address(p2pk_addr)
    end
  end

  # TODO
  def test_compile_from_string
script = <<-SCRIPT.chomp
SCRIPT
puts script
    assert_nothing_raised do
      contract = Sigma::Contract.compile_from_string(script)
    end
  end
end
