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

  def test_secret_keys
    sk = Sigma::SecretKey.create
    sks = Sigma::SecretKeys.create
    assert_equal(0, sks.len)
    assert_equal(nil, sks.get(0))
    sks.add(sk)
    assert_equal(1, sks.len)
    assert_equal(sk.to_bytes, sks.get(0).to_bytes)
    assert_equal(nil, sks.get(1))
  end

end
