require_relative '../test_helper'
require 'yaml'

class LocalesTest < Minitest::Test
  def test_locale_keys_match_and_warning_is_fixed
    root = File.expand_path('../../config/locales', __dir__)
    pl = YAML.safe_load_file("#{root}/pl.yml").fetch('pl')
    en = YAML.safe_load_file("#{root}/en.yml").fetch('en')
    assert_equal pl.keys, en.keys
    assert_equal pl.fetch('card').keys, en.fetch('card').keys
    assert_includes pl.fetch('card').fetch('mushroom_warning'), 'nie zbieraj grzyba'
  end
end
