require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

include Sigma

class ErgoStateContext::Test < Test::Unit::TestCase
  def test_ergo_state_context
    block_header = BlockHeader.with_json(TestSeeds.block_header_json)
    pre_header = PreHeader.with_block_header(block_header)
    block_headers = TestSeeds.block_headers_from_json
    assert_nothing_raised do 
      ctx = ErgoStateContext.create(pre_header: pre_header, headers: block_headers)
    end 
    # invalid # of headers
    invalid_headers_json = Array.new(8) { TestSeeds.block_header_json } 
    invalid_block_headers = BlockHeaders.from_json(invalid_headers_json)
    assert_raises do
      ctx = ErgoStateContext.create(pre_header: pre_header, headers: invalid_block_headers)
    end
  end
end
