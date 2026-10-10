# frozen_string_literal: true

module BrowserCoreHelpers
  F = BrowserTestCase::F
  BASE = BrowserTestCase::BASE

  def setup
    @search = F::Search.new(F.search)
    use(F.real_selector(4))
    @page = Cdp::Page.new(browser)
    @page.phone!
  end

  def teardown
    @page&.close
  end

  def use(selector, model: F::Model.new, search: @search)
    F.apply(search: search, selector: selector, model: model)
  end

  def open_page
    @page.goto("#{BASE}/")
  end

  def submit(lat: F::LAT, lon: F::LON, radius: 5)
    @page.evaluate(<<~JS)
      (() => { const f = document.getElementById('search-form');
        f.elements.lat.value = '#{lat}'; f.elements.lon.value = '#{lon}'; f.elements.radius_km.value = '#{radius}';
        f.requestSubmit(); })()
    JS
  end

  def status
    @page.evaluate("document.getElementById('status').textContent")
  end

  def card_text
    @page.evaluate("document.getElementById('card-content').innerText")
  end

  def render_card
    open_page
    submit
    @page.wait_for("!document.getElementById('result').hidden")
  end

  def assert_no_js_errors
    assert_empty @page.js_errors
  end
end
