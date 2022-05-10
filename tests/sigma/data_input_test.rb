
require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::DataInput::Test < Test::Unit::TestCase
  def test_data_input
    str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_id = Sigma::BoxId.with_string(str)
    data_input = Sigma::DataInput.with_box_id(box_id) 
    assert_equal(box_id, data_input.get_box_id)
  end

  def test_data_inputs
  end
end
