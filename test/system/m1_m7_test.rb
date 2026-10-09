# frozen_string_literal: true

require 'minitest/autorun'
require 'puma'
require 'tmpdir'
require 'open3'
require_relative 'support/cdp'
require_relative 'support/fixtures'

# Browser acceptance for M1 to M7 (docs/plans/mvp.md). One headless Chrome, one in-process server,
# deterministic fixtures from support/fixtures.rb. Prerequisites: README.md, "Browser checks".
class M1M7Test < Minitest::Test
  F = SystemFixtures
  PORT = Integer(ENV.fetch('PORT') { 9300 + ENV.fetch('COORD_SLOT', '0').to_i })
  BASE = "http://localhost:#{PORT}".freeze
  PDFINFO = Cdp.which(ENV.fetch('PDFINFO_PATH', 'pdfinfo'))
  PDFTOTEXT = Cdp.which(ENV.fetch('PDFTOTEXT_PATH', 'pdftotext'))

  @@browser = Cdp::Browser.new
  @@server = Puma::Server.new(ForestRadar::App, nil, min_threads: 0, max_threads: 4, log_writer: Puma::LogWriter.strings)
  @@server.add_tcp_listener('127.0.0.1', PORT)
  @@server.run
  Minitest.after_run do
    @@server.stop(true)
    @@browser.close
  end

  def setup
    @search = F::Search.new(F.search)
    use(F.real_selector(4))
    @page = Cdp::Page.new(@@browser)
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
    @page.eval(<<~JS)
      (() => { const f = document.getElementById('search-form');
        f.elements.lat.value = '#{lat}'; f.elements.lon.value = '#{lon}'; f.elements.radius_km.value = '#{radius}';
        f.requestSubmit(); })()
    JS
  end

  def status
    @page.eval("document.getElementById('status').textContent")
  end

  def card_text
    @page.eval("document.getElementById('card-content').innerText")
  end

  def render_card
    open_page
    submit
    @page.wait_for("!document.getElementById('result').hidden")
  end

  def assert_no_js_errors
    assert_empty @page.js_errors
  end

  # ---- M1 ----

  def test_m1_page_loads_without_javascript_error
    open_page
    assert_equal 'Leśny Radar', @page.eval('document.title')
    assert_equal 'pl', @page.eval('document.documentElement.lang')
    assert_no_js_errors
  end

  def test_m1_typed_coordinates_and_radius_reach_the_service
    render_card
    request = @search.requests.last
    assert_in_delta F::LAT, request[:lat]
    assert_in_delta F::LON, request[:lon]
    assert_equal 5, request[:radius_km]
    assert_no_js_errors
  end

  def test_m1_radius_limits_are_enforced_before_any_request
    open_page
    [0, 21].each do |radius|
      submit(radius: radius)
      assert_equal false, @page.eval("document.getElementById('search-form').checkValidity()")
    end
    submit(radius: 20)
    @page.wait_for("!document.getElementById('result').hidden")
    assert_equal([20], @search.requests.map { |r| r[:radius_km] })
  end

  def test_m1_geolocation_fills_the_fields_after_a_click
    origin = BASE
    @@browser.call('Browser.grantPermissions', permissions: ['geolocation'], origin: origin)
    @page.cmd('Emulation.setGeolocationOverride', latitude: 52.25, longitude: 21.5, accuracy: 10)
    open_page
    assert_equal '', @page.eval("document.getElementById('lat').value")
    @page.eval("document.getElementById('locate').click()")
    @page.wait_for("document.getElementById('lat').value !== ''")
    assert_equal '52.25', @page.eval("document.getElementById('lat').value")
    assert_equal '21.5', @page.eval("document.getElementById('lon').value")
    assert_equal 'Współrzędne zostały wpisane.', status
    assert_no_js_errors
  end

  def test_m1_geolocation_denial_keeps_typed_coordinates
    @@browser.call('Browser.setPermission', permission: { name: 'geolocation' }, setting: 'denied', origin: BASE)
    open_page
    @page.eval("document.getElementById('lat').value = '50.1'; document.getElementById('lon').value = '19.9'")
    @page.eval("document.getElementById('locate').click()")
    @page.wait_for("document.getElementById('status').textContent.includes('wpisać współrzędne ręcznie')")
    assert_equal 'Nie udało się pobrać lokalizacji. Możesz wpisać współrzędne ręcznie.', status
    assert_equal '50.1', @page.eval("document.getElementById('lat').value")
    assert_equal '19.9', @page.eval("document.getElementById('lon').value")
    assert_equal false, @page.eval("document.getElementById('locate').disabled")
  end

  # ---- M2, M3, M4, M7: facts on the card ----

  def test_m7_card_shows_three_nearest_areas_with_distances_and_years
    render_card
    names = @page.eval("[...document.querySelectorAll('.area h4')].map(e => e.innerText)")
    assert_equal ['SYNTHETIC las 1', 'SYNTHETIC las 2', 'SYNTHETIC las 3'], names
    distances = @page.eval("[...document.querySelectorAll('.area .distance')].map(e => e.textContent)")
    assert_equal ['1 km', '2 km', '3 km'], distances
    assert_includes card_text, 'Lata danych: 2024: 1'
    assert_includes card_text, 'Typy siedlisk'
    assert_includes card_text, 'Liczba wydzieleń'
    assert_no_js_errors
  end

  def test_m7_fewer_than_three_areas_show_only_those_areas
    use(F.real_selector(2), search: F::Search.new(F.search(count: 2)))
    render_card
    assert_equal 2, @page.eval("document.querySelectorAll('.area').length")
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

  def assert_openstreetmap_attribution
    assert_includes card_text, 'Źródło szlaków: OpenStreetMap'
    link = @page.eval("(() => { const a = [...document.querySelectorAll('#card-content a')].find(a => " \
                      "a.href.includes('openstreetmap')); return a && [a.href, a.textContent]; })()")
    assert_equal ['https://www.openstreetmap.org/copyright', OSM::Client::ATTRIBUTION], link
  end

  def test_external_text_renders_as_text
    markup = '<img src=x onerror="window.pwned=1"><b>x</b>'
    walk = F::Walk.new([walk_area(1, name: markup,
                                     trails: [{ id: 1, name: '<script>window.pwned=2</script>' }])])
    use(walk, model: F::Model.new(markup))
    render_card
    assert_includes card_text, markup
    assert_equal 0,
                 @page.eval("document.querySelectorAll('#card-content img, " \
                            "#card-content script, #card-content b').length")
    assert_nil @page.eval('window.pwned')
    assert_includes card_text, '<script>window.pwned=2</script>'
  end

  # ---- M5, M6 ----

  def test_m6_card_holds_fixed_warning_and_sanepid_link
    render_card
    assert_includes card_text, 'nie zbieraj grzyba'
    assert_includes card_text, 'Przed spacerem sprawdź aktualne zasady wstępu do lasu.'
    assert_includes card_text, 'Wskazówki modelu'
    link = @page.eval("(() => { const a = document.querySelector('#card-content a[target=_blank]'); " \
                      'return [a.href, a.rel]; })()')
    assert_match %r{\Ahttps://www\.google\.com/maps/search/stacja\+sanitarno-epidemiologiczna/@0\.005000,0\.005000,11z},
                 link[0].sub('%2C', ',')
    assert_includes link[1], 'noopener'
  end

  def test_error_responses_show_polish_messages_and_no_card
    {
      'Brak danych leśnych dla tej lokalizacji.' => { search: F::Search.new(nil, error: BDL::NoCoverage.new('x')) },
      'Nie można pobrać kompletnych danych źródłowych.' => { search: F::Search.new(nil,
                                                                                   error: BDL::Incomplete.new('x')) },
      'Nie można przygotować karty. Spróbuj ponownie.' => { model: F::Model.new(error: ::Model::Invalid.new('x')) },
      'Model nie odpowiedział w wyznaczonym czasie.' => { model: F::Model.new(error: ::Model::Deadline.new('x')) }
    }.each do |message, options|
      use(F.real_selector(4), **options)
      open_page
      submit
      @page.wait_for("document.getElementById('status').textContent === #{message.to_json}")
      assert_equal true, @page.eval("document.getElementById('result').hidden")
      assert_equal false, @page.eval("document.getElementById('search-form').querySelector('[type=submit]').disabled")
    end
  end

  def test_request_failures_show_polish_text
    [
      "Promise.reject(new TypeError('Failed to fetch'))",
      "Promise.resolve(new Response('{broken', { status: 200 }))"
    ].each do |reply|
      open_page
      @page.eval("window.fetch = () => #{reply}")
      submit
      expected = 'Nie udało się przygotować karty. Spróbuj ponownie.'
      @page.wait_for("document.getElementById('status').textContent === #{expected.to_json}")
      assert_equal true, @page.eval("document.getElementById('result').hidden")
      assert_equal false, @page.eval("document.querySelector('#search-form [type=submit]').disabled")
    end
  end

  # ---- M7 layout ----

  def test_m7_phone_viewport_has_no_horizontal_overflow
    render_card
    assert_equal true, @page.eval('document.documentElement.scrollWidth <= window.innerWidth')
    assert_equal 1, @page.eval('window.visualViewport.scale')
  end

  def test_m7_card_prints_on_one_a4_page_with_attribution
    render_card
    text = print_and_read('three-areas')
    assert_includes text, 'OpenStreetMap'
    assert_includes text, 'nie zbieraj grzyba'
    assert_includes text, 'Przed spacerem sprawdź aktualne zasady wstępu do lasu.'
    assert_includes text, 'Lata danych'
  end

  def test_print_hides_fifth_entry_and_shows_remaining_count
    trails = (1..5).map { |i| { id: i, name: "SYNTHETIC entry #{i}" } }
    use(F::Walk.new([walk_area(1, trails: trails)]))
    render_card
    assert_fifth_entry_screen
    assert_fifth_entry_print
  end

  def test_print_bounds_long_text_and_preserves_safety_text
    use(long_text_walk, model: F::Model.new(long_advice), search: F::Search.new(long_search))
    render_card
    assert_long_screen_text
    assert_long_print_text(print_and_read('long-text'))
  end

  def assert_fifth_entry_screen
    assert_includes card_text, 'SYNTHETIC entry 5'
    assert_equal 'none', @page.eval("getComputedStyle(document.querySelector('.print-more')).display")
  end

  def assert_fifth_entry_print
    text = print_and_read('fifth-entry')
    refute_includes text, 'SYNTHETIC entry 5'
    assert_includes text, 'i jeszcze 1'
  end

  def assert_long_screen_text
    %w[AFTERADVICE AFTERTRAIL AFTERAREA AFTERDISTRICT AFTERSUMMARY].each do |marker|
      assert_includes card_text, marker
    end
  end

  def assert_long_print_text(text)
    %w[BEFOREADVICE BEFORETRAIL BEFOREAREA BEFOREDISTRICT BEFORESUMMARY].each { |marker| assert_includes text, marker }
    %w[AFTERADVICE AFTERTRAIL AFTERAREA AFTERDISTRICT AFTERSUMMARY].each { |marker| refute_includes text, marker }
    assert_includes text, 'i jeszcze 2'
    assert_includes text, '[pominięto dalszą część]'
    ['OpenStreetMap', 'nie zbieraj grzyba'].each { |marker| assert_includes text, marker }
  end

  def long_advice
    "BEFOREADVICE #{"ż\n" * 340} AFTERADVICE"
  end

  def long_text_walk
    areas = (1..3).map do |i|
      trails = (1..4).map { |n| { id: n, name: "BEFORETRAIL #{'ź' * 180} AFTERTRAIL #{i}-#{n}" } }
      walk_area(i, name: "BEFOREAREA #{'ą' * 180} AFTERAREA", trails: trails)
    end
    F::Walk.new(areas)
  end

  def long_search
    data = F.search(count: 3)
    data[:stands] = (1..3).map { |i| F.stand(i, 'species_cd' => "BEFORESUMMARY #{'ś' * 180} AFTERSUMMARY") }
    data[:districts] = (1..5).map do |i|
      { 'id' => i, 'properties' => { 'name' => "BEFOREDISTRICT #{'ł' * 80} AFTERDISTRICT #{i}" } }
    end
    data
  end

  def test_m7_maximum_content_card_prints_on_one_a4_page
    use(F::Walk.new((1..3).map { |i| maximal_area(i) }), search: F::Search.new(maximal_search))
    render_card
    assert_equal 3, @page.eval("document.querySelectorAll('.area').length")
    text = print_and_read('maximum')
    assert_includes text, 'OpenStreetMap'
    assert_includes text, 'nie zbieraj grzyba'
  end

  def print_and_read(name)
    Dir.mktmpdir('forest-radar-pdf') do |dir|
      path = File.join(dir, "#{name}.pdf")
      @page.print_pdf(path)
      info, status = Open3.capture2e(PDFINFO, path)
      assert status.success?, info
      assert_match(/^Pages:\s+1$/, info)
      width, height = info[/^Page size:\s+([\d.]+) x ([\d.]+) pts/, 0].scan(/[\d.]+/).map(&:to_f)
      assert_in_delta 595, width, 3
      assert_in_delta 842, height, 3
      Open3.capture2(PDFTOTEXT, path, '-').first.gsub(/\s+/, ' ')
    end
  end

  def walk_area(id, name: "SYNTHETIC las #{id}", trails: [F.trail(0.01)])
    { 'id' => id, 'distance_km' => id.to_f, 'district_id' => 1, 'properties' => { 'name' => name }, trails: trails }
  end

  # Worst case for C-R2: many distinct ages, years, species and sites, and many long trail names.
  def maximal_search
    stands = (1..3).flat_map do |id|
      (1..60).map do |n|
        F.stand(id, 'spec_age' => n, 'a_year' => 1990 + (n % 35),
                    'species_cd' => "GAT#{n % 25}", 'site_type' => "SIEDLISKO#{n % 20}",
                    'sub_area' => nil.then { n.odd? ? 1.5 : nil })
      end
    end
    F.search(count: 3, stands: stands)
  end

  def maximal_area(id)
    trails = (1..12).map do |n|
      { id: n, name: "SYNTHETIC bardzo długa nazwa szlaku turystycznego numer #{n} #{'x' * 40}" }
    end
    walk_area(id, name: "SYNTHETIC las #{id} #{'długa nazwa ' * 6}", trails: trails)
  end
end
