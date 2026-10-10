# frozen_string_literal: true

module BrowserBehaviorHelpers
  F = BrowserTestCase::F
  BASE = BrowserTestCase::BASE

  def assert_search_coordinates
    request = @search.requests.last
    assert_in_delta F::LAT, request[:lat]
    assert_in_delta F::LON, request[:lon]
    assert_equal 5, request[:radius_km]
  end

  def assert_invalid_radius(radius)
    submit(radius: radius)
    assert_equal false, @page.evaluate("document.getElementById('search-form').checkValidity()")
  end

  def assert_requested_radius(radius)
    @page.wait_for("!document.getElementById('result').hidden")
    requested = @search.requests.map { |request| request[:radius_km] }
    assert_equal [radius], requested
  end

  def assert_geolocation_filled
    assert_equal '52.25', @page.evaluate("document.getElementById('lat').value")
    assert_equal '21.5', @page.evaluate("document.getElementById('lon').value")
    assert_equal 'Współrzędne zostały wpisane.', status
  end

  def assert_empty_coordinates
    assert_equal '', @page.evaluate("document.getElementById('lat').value")
  end

  def assert_coordinates_preserved
    assert_equal '50.1', @page.evaluate("document.getElementById('lat').value")
    assert_equal '19.9', @page.evaluate("document.getElementById('lon').value")
    assert_equal false, @page.evaluate("document.getElementById('locate').disabled")
  end

  def set_typed_coordinates
    @page.evaluate("document.getElementById('lat').value = '50.1'; document.getElementById('lon').value = '19.9'")
  end

  def assert_failed_request
    assert_equal true, @page.evaluate("document.getElementById('result').hidden")
    assert_equal false, @page.evaluate("document.querySelector('#search-form [type=submit]').disabled")
  end

  def wait_for_status(message)
    @page.wait_for("document.getElementById('status').textContent === #{message.to_json}")
  end

  def prepare_geolocation
    browser.call('Browser.grantPermissions', permissions: ['geolocation'], origin: BASE)
    @page.cmd('Emulation.setGeolocationOverride', latitude: 52.25, longitude: 21.5, accuracy: 10)
    open_page
    assert_empty_coordinates
  end

  def activate_geolocation
    click_location
    @page.wait_for("document.getElementById('lat').value !== ''")
    assert_geolocation_filled
    assert_no_js_errors
  end

  def prepare_denied_geolocation
    browser.call('Browser.setPermission', permission: { name: 'geolocation' }, setting: 'denied', origin: BASE)
    open_page
    set_typed_coordinates
  end

  def assert_denied_geolocation
    click_location
    @page.wait_for("document.getElementById('status').textContent.includes('wpisać współrzędne ręcznie')")
    assert_equal 'Nie udało się pobrać lokalizacji. Możesz wpisać współrzędne ręcznie.', status
  end

  def click_location
    @page.evaluate("document.getElementById('locate').click()")
  end

  def assert_page_error(message, options)
    use(F.real_selector(4), **options)
    open_page
    submit
    wait_for_status(message)
    assert_failed_request
  end

  def assert_request_failure(reply)
    open_page
    @page.evaluate("window.fetch = () => #{reply}")
    submit
    wait_for_status('Nie udało się przygotować karty. Spróbuj ponownie.')
    assert_failed_request
  end
end
