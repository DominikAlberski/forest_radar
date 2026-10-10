# frozen_string_literal: true

require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'
require_relative 'support/browser_behavior_helpers'
require_relative 'support/browser_card_helpers'
require_relative 'support/browser_fact_helpers'
require_relative 'support/browser_print_data_helpers'
class PrintTest < BrowserTestCase
  include BrowserCoreHelpers
  include BrowserBehaviorHelpers
  include BrowserCardHelpers
  include BrowserFactHelpers
  include BrowserPrintDataHelpers

  def test_m7_phone_viewport_has_no_horizontal_overflow
    render_card
    assert_phone_viewport
  end

  def test_m7_card_prints_on_one_a4_page_with_attribution
    render_card
    assert_standard_print(print_and_read('three-areas'))
  end

  def test_print_hides_fifth_entry_and_shows_remaining_count
    trails = (1..5).map { |i| { id: i, name: "SYNTHETIC entry #{i}" } }
    use(F::Walk.new([walk_area(1, trails: trails)]))
    render_card
    assert_fifth_entry_screen
    assert_fifth_entry_print
  end

  def test_print_bounds_long_text_and_preserves_safety_text
    assert_equal 3000, long_advice.length
    use(long_text_walk, model: F::Model.new(long_advice), search: F::Search.new(long_search))
    render_card
    assert_long_screen_text
    assert_long_print_text(print_and_read('long-text'))
  end

  def test_m7_maximum_content_card_prints_on_one_a4_page
    print_maximum_card
    assert_maximum_card_print
  end

  def assert_maximum_card_print
    assert_equal 3, @page.evaluate("document.querySelectorAll('.area').length")
    text = print_and_read('maximum')
    assert_includes text, 'OpenStreetMap'
    assert_includes text, 'nie zbieraj grzyba'
  end
end
