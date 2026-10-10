# frozen_string_literal: true

require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'

class M2M7FactsTest < BrowserTestCase
  include BrowserCoreHelpers

  def test_card_shows_full_response_and_disclaimer
    text = "  **Las**\nLas jest otwarty. Ten grzyb jest jadalny.\n"
    use(F.real_selector(4), model: F::Model.new(text))
    render_card
    assert_equal text, @page.evaluate("document.querySelector('.model-description').textContent")
    assert_card_warnings
  end

  def assert_card_warnings
    assert_includes card_text, 'halucynacje'
    assert_includes card_text, 'nie zbieraj grzyba'
    assert_equal 0, @page.evaluate("document.querySelectorAll('.area').length")
    assert_no_js_errors
  end

  def test_model_markup_renders_as_text
    markup = '<img src=x onerror="window.pwned=1"><script>window.pwned=2</script>'
    use(F.real_selector(4), model: F::Model.new(markup))
    render_card
    assert_markup_is_text(markup)
  end

  def assert_markup_is_text(markup)
    assert_includes card_text, markup
    assert_equal 0, @page.evaluate("document.querySelectorAll('#card-content img, #card-content script').length")
    assert_nil @page.evaluate('window.pwned')
  end

  def test_card_shows_google_maps_links_for_bdl_forests
    render_card
    assert_includes card_text, 'Otwórz w Google Maps: SYNTHETIC las 1'
    links = @page.evaluate("[...document.querySelectorAll('#card-content li a')].map(link => link.href)")
    assert_equal 4, links.size
    assert_includes links.first, 'api=1&query=0%2C0.01'
  end

  def test_each_forest_has_its_own_card_and_description
    render_card
    names = @page.evaluate("[...document.querySelectorAll('.forest-card > h3')].map(title => title.textContent)")
    assert_equal (1..4).map { |number| "SYNTHETIC las #{number}" }, names
    assert_equal 4, @page.evaluate("document.querySelectorAll('.forest-card .model-description').length")
    assert_equal 4, @page.evaluate("document.querySelectorAll('.forest-card .disclaimer').length")
  end
end
