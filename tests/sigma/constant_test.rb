require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma/constant.rb'

class Sigma::Constant::Test < Test::Unit::TestCase
  def test_i32
    c = Sigma::Constant.with_int(9999)
    encoded = c.to_base16_string
    decoded = Sigma::Constant.with_base_16(encoded)
    assert_equal(c, decoded)
  end

  def test_i64
    c = Sigma::Constant.with_int(9223372036854775807)
    encoded = c.to_base16_string
    decoded = Sigma::Constant.with_base_16(encoded)
    assert_equal(c, decoded)
  end

  #def test_byte_array
  #  bytes = [1,1,2,255]
  #  c = Constant.with_bytes(bytes)
  #  encoded = c.to_base_16_string
  #  decoded = Constant.with_base_16(encoded)
  #  assert_equal(c, decoded)
  #end

  #def test_ec_point_bytes
  #  str = "02d6b2141c21e4f337e9b065a031a6269fb5a49253094fc6243d38662eb765db00"
  #end

  #def test_ergo_box
  #end
end

