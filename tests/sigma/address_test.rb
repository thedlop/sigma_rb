
require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Address::Test < Test::Unit::TestCase
  def test_testnet_addresses
    p2pk_addr_str = "3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN"
    p2pk_addr = Sigma::Address.with_testnet_address(p2pk_addr_str)
    assert_equal(p2pk_addr_str, p2pk_addr.to_base58(Sigma::NETWORK_PREFIX_ENUM[:testnet]))
    assert_equal(Sigma::ADDRESS_TYPE_PREFIX_ENUM[:p2pk], p2pk_addr.type_prefix)

    p2sh_addr_str = "rbcrmKEYduUvADj9Ts3dSVSG27h54pgrq5fPuwB"
    p2sh_addr = Sigma::Address.with_testnet_address(p2sh_addr_str)
    assert_equal(p2sh_addr_str, p2sh_addr.to_base58(Sigma::NETWORK_PREFIX_ENUM[:testnet]))
    assert_equal(Sigma::ADDRESS_TYPE_PREFIX_ENUM[:pay2sh], p2sh_addr.type_prefix)
  end

  def test_mainnet_addresses
    p2pk_addr_str = "9fRAWhdxEsTcdb8PhGNrZfwqa65zfkuYHAMmkQLcic1gdLSV5vA"
    p2pk_addr = Sigma::Address.with_mainnet_address(p2pk_addr_str)
    assert_equal(p2pk_addr_str, p2pk_addr.to_base58(Sigma::NETWORK_PREFIX_ENUM[:mainnet]))
    assert_equal(Sigma::ADDRESS_TYPE_PREFIX_ENUM[:p2pk], p2pk_addr.type_prefix)

    p2sh_addr_str = "8UApt8czfFVuTgQmMwtsRBZ4nfWquNiSwCWUjMg"
    p2sh_addr = Sigma::Address.with_mainnet_address(p2sh_addr_str)
    assert_equal(p2sh_addr_str, p2sh_addr.to_base58(Sigma::NETWORK_PREFIX_ENUM[:mainnet]))
    assert_equal(Sigma::ADDRESS_TYPE_PREFIX_ENUM[:pay2sh], p2sh_addr.type_prefix)
  end

  def test_base58_address
    addr_str = "9fRAWhdxEsTcdb8PhGNrZfwqa65zfkuYHAMmkQLcic1gdLSV5vA"
    address = Sigma::Address.with_base58_address(addr_str)
    assert_equal(addr_str, address.to_base58(Sigma::NETWORK_PREFIX_ENUM[:mainnet]))
  end

  def test_invalid_address
    assert_raises do
      Sigma::Address.with_mainnet_address("sss")
    end
  end
end
