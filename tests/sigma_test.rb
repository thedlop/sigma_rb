require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../lib/sigma.rb'
require_relative 'test_utils.rb'

class Sigma::Test < Test::Unit::TestCase
  def test_non_mandator_register_ids
    assert_equal(Sigma::REGISTER_ID_ENUM[:r4], 4)
    assert_equal(Sigma::REGISTER_ID_ENUM[:r5], 5)
    assert_equal(Sigma::REGISTER_ID_ENUM[:r6], 6)
    assert_equal(Sigma::REGISTER_ID_ENUM[:r7], 7)
    assert_equal(Sigma::REGISTER_ID_ENUM[:r8], 8)
    assert_equal(Sigma::REGISTER_ID_ENUM[:r9], 9)
  end
end

