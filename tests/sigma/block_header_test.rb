require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::BlockHeader::Test < Test::Unit::TestCase
  def test_block_header
    header_json = TestSeeds.block_header_json 
    block_header = Sigma::BlockHeader.with_json(header_json)
    assert_nothing_raised do
      Sigma::PreHeader.with_block_header(block_header)
    end
    assert_raises do
      Sigma::BlockHeader.from_json("")
    end
    headers = Sigma::BlockHeaders.create
    assert_equal(nil, headers.get(0))
    assert_equal(0, headers.len)
    assert_nothing_raised do
      headers.add(block_header)
    end
    assert_equal(1, headers.len)
    assert_equal(block_header, headers.get(0))
    assert_equal(nil, headers.get(1))
    assert_nothing_raised do
      headers.add(block_header)
    end
    assert_equal(2, headers.len)
    assert_equal(block_header, headers.get(1))
    assert_equal(nil, headers.get(2))
  end
end
