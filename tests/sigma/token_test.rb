require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Token::Test < Test::Unit::TestCase
  def test_token_id_from_box_id
    str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_id = Sigma::BoxId.with_string(str)
    token_id = Sigma::TokenId.with_box_id(box_id)
    assert_nothing_raised do
      token_id.to_base16_encoded_string
    end
  end

  def test_token_id_from_string
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.with_string(str)
    assert_equal(str, token_id.to_base16_encoded_string)
  end

  def test_token_amount
  end

  def test_token
  end

  def test_tokens
  end
end
