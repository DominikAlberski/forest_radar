# frozen_string_literal: true

require_relative '../test_helper'
require 'yaml'
require 'model/validator'

class LocalesTest < Minitest::Test
  ROOT = File.expand_path('../../config/locales', __dir__)

  def pl
    YAML.safe_load_file("#{ROOT}/pl.yml").fetch('pl')
  end

  def en
    YAML.safe_load_file("#{ROOT}/en.yml").fetch('en')
  end

  def leaves(value, path = [])
    return value.flat_map { |key, item| leaves(item, path + [key]) } if value.is_a?(Hash)

    [[path.join('.'), value]]
  end

  def test_all_nested_locale_keys_match
    assert_equal leaves(pl).map(&:first).sort, leaves(en).map(&:first).sort
  end

  def test_polish_values_are_filled_and_english_values_are_empty
    assert(leaves(pl).none? { |_, value| value.to_s.strip.empty? })
    assert(leaves(en).all? { |_, value| value.to_s.empty? })
  end

  def test_errors_keys_exist_for_every_route_failure
    assert_equal %w[deadline invalid_input model no_coverage source], pl.fetch('errors').keys.sort
  end

  def test_mushroom_warning_is_fixed
    assert_includes pl.fetch('card').fetch('mushroom_warning'), 'nie zbieraj grzyba'
  end

  def test_fixed_text_makes_no_access_or_edibility_promise
    leaves(pl).each do |path, value|
      refute_match Model::Validator::ACCESS, value.to_s, path
      refute_match Model::Validator::PROHIBITED, value.to_s, path
    end
  end
end
