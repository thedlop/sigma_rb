require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::SecretKey::Test < Test::Unit::TestCase
  def test_secret_key 
    sk = Sigma::SecretKey.create
    assert_nothing_raised do
      address = sk.get_address
    end
    bytes = sk.to_bytes
    sk_2 = Sigma::SecretKey.from_bytes(bytes)
    assert_equal(bytes, sk_2.to_bytes)
  end

end
