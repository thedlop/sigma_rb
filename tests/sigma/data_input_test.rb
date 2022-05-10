
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
    # create
    data_inputs = assert_nothing_raised do
      Sigma::DataInputs.create
    end
    # len
    assert_equal(0, data_inputs.len)
    # get
    assert_equal(nil, data_inputs.get(0))
    assert_equal(nil, data_inputs.get(1))
    # add
    str = "e56847ed19b3dc6b72828fcfb992fdf7310828cf291221269b7ffc72fd66706e"
    box_id = Sigma::BoxId.with_string(str)
    data_input = Sigma::DataInput.with_box_id(box_id) 
    data_inputs.add(data_input)
    assert_equal(1, data_inputs.len)
    # no eq method for DataInput
    assert_equal(box_id, data_inputs.get(0).get_box_id)
    assert_equal(nil, data_inputs.get(1))
  end
end
