# frozen_string_literal: true

require_relative '../../test_helper'
require 'puma'
require 'puma/configuration'

class PumaTest < Minitest::Test
  def test_configuration_loads_with_one_process
    configuration = Puma::Configuration.new
    configuration.load
    configuration.clamp
    assert_equal 0, configuration.options[:workers]
  end
end
