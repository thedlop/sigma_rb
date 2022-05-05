require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Constant::Test < Test::Unit::TestCase
  def test_i32
    c = Sigma::Constant.with_i32(9999)
    encoded = c.to_base16_string
    decoded = Sigma::Constant.with_base_16(encoded)
    assert_equal(c, decoded)
  end

  def test_i64
    c = Sigma::Constant.with_i64(9223372036854775807)
    encoded = c.to_base16_string
    decoded = Sigma::Constant.with_base_16(encoded)
    assert_equal(c, decoded)
  end

  def test_byte_array
    bytes = [1,1,2,255]
    c = Sigma::Constant.with_bytes(bytes)
    encoded = c.to_base16_string
    decoded = Sigma::Constant.with_base_16(encoded)
    assert_equal(c, decoded)
  end

  def test_ec_point_bytes
    str = "02d6b2141c21e4f337e9b065a031a6269fb5a49253094fc6243d38662eb765db00"
    assert_nothing_raised do
      Sigma::Constant.with_ecpoint_bytes(TestUtils.base16_string_to_bytes(str))
    end
  end

  def test_ergo_box
   json = {
       "boxId": "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e",
       "value": 67500000000,
       "ergoTree": "100204a00b08cd021dde34603426402615658f1d970cfa7c7bd92ac81a8b16eeebff264d59ce4604ea02d192a39a8cc7a70173007301",
       "assets": [],
       "creationHeight": 284761,
       "additionalRegisters": {},
       "transactionId": "9148408c04c2e38a6402a7950d6157730fa7d49e9ab3b9cadec481d7769918e9",
       "index": 1
   }.to_json
   ergo_box = Sigma::ErgoBox.with_json(json)
   c = Sigma::Constant.with_ergo_box(ergo_box)
   encoded = c.to_base16_string
   decoded = Sigma::Constant.with_base_16(encoded)
   assert_equal(c, decoded)
  end
end

