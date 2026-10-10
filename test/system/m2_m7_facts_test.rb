# frozen_string_literal: true

require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'
require_relative 'support/browser_behavior_helpers'
require_relative 'support/browser_card_helpers'
require_relative 'support/browser_fact_helpers'
require_relative 'support/browser_print_data_helpers'
class M2M7FactsTest < BrowserTestCase
  include BrowserCoreHelpers
  include BrowserBehaviorHelpers
  include BrowserCardHelpers
  include BrowserFactHelpers
  include BrowserPrintDataHelpers

  def test_m7_card_shows_three_nearest_areas_with_distances_and_years
    render_card
    assert_card_facts
    assert_no_js_errors
  end

  def test_m4_crossing_trail_selects_ranges
    use(F.real_selector(2), search: F::Search.new(F.search(count: 2)))
    render_card
    assert_equal 2, @page.evaluate("document.querySelectorAll('.area').length")
  end

  def test_unknown_trail_evidence_is_labeled_unavailable
    walk = F::Walk.new([walk_area(1, trails: [])])
    use(walk)
    render_card
    assert_includes card_text, 'Brak potwierdzonych danych o szlakach'
    assert_openstreetmap_attribution
  end

  def test_trail_source_failure_shows_zero_areas_message_and_attribution
    use(::WalkAreas::Selector.new(trails: F::Trails.new(nil)))
    render_card
    assert_includes card_text, 'Brak wybranych obszarów leśnych.'
    assert_openstreetmap_attribution
  end

  def test_external_text_renders_as_text
    markup = '<img src=x onerror="window.pwned=1"><b>x</b>'
    prepare_external_markup(markup)
    assert_external_markup(markup)
  end

  def test_m6_card_holds_fixed_warning_and_sanepid_link
    render_card
    assert_m6_warnings
    assert_station_link
  end
end
