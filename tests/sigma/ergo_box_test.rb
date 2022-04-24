require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require_relative '../../lib/sigma/ergo_box.rb'
require_relative '../test_utils.rb'

class Sigma::ErgoBox::Test < Test::Unit::TestCase
  #def test_box_id
  #  str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
  #  box_id = BoxId.with_string(str)
  #  new_str = box_id.to_s
  #  assert_equal(str, new_str)
  #end

  #def test_box_value
  #  amount = 12345678
  #  box_value = BoxValue.with_int(amount)
  #  assert_equal(box_value.to_i, amount)
  #end

end
