require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Transaction::Test < Test::Unit::TestCase
  def test_tx_id
    str = '93d344aa527e18e5a221db060ea1a868f46b61e4537e6e5f69ecc40334c15e38'
    tx_id = Sigma::TxId.with_string(str)
    assert_equal(str, tx_id.to_s)
  end
end
