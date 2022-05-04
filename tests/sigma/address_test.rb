
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

#        let p2shAddrStr = "rbcrmKEYduUvADj9Ts3dSVSG27h54pgrq5fPuwB"
#        let p2shAddr = try ErgoLib.Address(withTestnetAddress: p2shAddrStr)
#        XCTAssertEqual(p2shAddr.toBase58(networkPrefix: NetworkPrefix.Testnet), p2shAddrStr)
#        XCTAssertEqual(p2shAddr.typePrefix(), AddressTypePrefix.Pay2Sh)

  end

  def test_mainnet_addresses
  end
end
