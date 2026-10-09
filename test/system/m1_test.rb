# frozen_string_literal: true

require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'
require_relative 'support/browser_behavior_helpers'
require_relative 'support/browser_card_helpers'
require_relative 'support/browser_fact_helpers'
class M1TestTest < BrowserTestCase
  include BrowserCoreHelpers
  include BrowserBehaviorHelpers
  include BrowserCardHelpers

  def test_m1_page_loads_without_javascript_error
    open_page
    assert_equal 'Leśny Radar', @page.evaluate('document.title')
    assert_equal 'pl', @page.evaluate('document.documentElement.lang')
    assert_no_js_errors
  end

  def test_m1_typed_coordinates_and_radius_reach_the_service
    render_card
    assert_search_coordinates
    assert_no_js_errors
  end

  def test_m1_radius_limits_are_enforced_before_any_request
    open_page
    [0, 21].each { |radius| assert_invalid_radius(radius) }
    submit(radius: 20)
    assert_requested_radius(20)
  end

  def test_m1_geolocation_fills_the_fields_after_a_click
    prepare_geolocation
    activate_geolocation
  end

  def test_m1_geolocation_denial_keeps_typed_coordinates
    prepare_denied_geolocation
    assert_denied_geolocation
    assert_coordinates_preserved
  end
end
