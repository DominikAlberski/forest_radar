# frozen_string_literal: true

require_relative '../test_helper'
require 'sanepid'

class SanepidTest < Minitest::Test
  def test_formats_negative_coordinates_and_limits
    template = 'https://example.org/@%<lat>s,%<lon>s'
    assert_equal 'https://example.org/@-90.000000,180.000000', Sanepid.url(-90, 180, template: template)
    assert_raises(ArgumentError) { Sanepid.url(91, 0, template: template) }
  end
end
