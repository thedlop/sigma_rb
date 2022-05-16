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

    token_id_two = Sigma::TokenId.with_box_id(box_id)
    assert_equal(token_id, token_id_two)
  end

  def test_token_id_from_string
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.from_base16_encoded_string(str)
    assert_equal(str, token_id.to_base16_encoded_string)

    token_id_two = Sigma::TokenId.from_base16_encoded_string(str)
    assert_equal(token_id, token_id_two)
  end

  def test_token_amount_from_int
    amount = 12345678
    token_amount = Sigma::TokenAmount.with_i64(amount)
    assert_equal(amount, token_amount.to_i)

    token_amount_two = Sigma::TokenAmount.with_i64(amount)
    assert_equal(token_amount, token_amount_two)
  end

  def test_token
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.from_base16_encoded_string(str)
    amount = 12345678
    token_amount = Sigma::TokenAmount.with_i64(amount)
    token = Sigma::Token.create(token_id: token_id, token_amount: token_amount)
    new_token_id = token.get_id
    new_token_amount = token.get_amount
    assert_equal(str, new_token_id.to_base16_encoded_string)
    assert_equal(token_id, new_token_id)
    assert_equal(token_amount, new_token_amount)

    token_two = Sigma::Token.create(token_id: token_id, token_amount: token_amount)
    assert_equal(token, token_two)
  end

  def test_token_json
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.from_base16_encoded_string(str)
    amount = 12345678
    token_amount = Sigma::TokenAmount.with_i64(amount)
    token = Sigma::Token.create(token_id: token_id, token_amount: token_amount)
    assert_nothing_raised do
      token.to_json_eip12
    end
  end

  def test_tokens
    tokens = Sigma::Tokens.create
    assert_equal(0, tokens.len)
    assert_equal(nil, tokens.get(3))
    str = "19475d9a78377ff0f36e9826cec439727bea522f6ffa3bda32e20d2f8b3103ac"
    token_id = Sigma::TokenId.from_base16_encoded_string(str)
    amount = 12345678
    token_amount = Sigma::TokenAmount.with_i64(amount)
    token = Sigma::Token.create(token_id: token_id, token_amount: token_amount)

    255.times do |i|
      tokens.add(token)
    end
    assert_equal(255, tokens.len)
    assert_equal(tokens.get(254), token)

    # 256 raises error
    assert_raise do
      tokens.add(token)
    end
  end
end
