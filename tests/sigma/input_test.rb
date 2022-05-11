require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::Input::Test < Test::Unit::TestCase
  # TODO
  def test_input
    # get_box_id
    # get_spending_proof
  end

  def test_inputs
    # create
    # len
    # get
    # add
  end

  def test_prover_result
    # to_bytes
    # get_context_extension
    # to_json
  end

  def test_unsigned_input
    # get_box_id
    # get_context_extension
  end

  def test_unsigned_inputs
    # create
    # len
    # get
    # add
  end
end

