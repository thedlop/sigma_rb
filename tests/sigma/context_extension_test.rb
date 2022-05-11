require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

class Sigma::ContextExtension::Test < Test::Unit::TestCase
  def test_context_extension
    # create
    ce = Sigma::ContextExtension.create
    # get_keys
    assert_equal([], ce.get_keys)
  end
end
