require_relative '../../test_helper'
require 'openssl'
require 'bdl/client'
require_relative '../http/fake_net'

# Review findings B1-R2, B1-R4 (client part), B1-R5, B1-R12.
class ClientSearchTest < Minitest::Test
  LAT = 52.0
  LON = 21.0

  def square(x0, y0, x1, y1)
    { 'type' => 'Polygon', 'coordinates' => [[[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]]] }
  end

  def feature(id, properties, geometry)
    { 'type' => 'Feature', 'id' => id, 'properties' => properties, 'geometry' => geometry }
  end

  def page(items, links: [])
    { 'type' => 'FeatureCollection', 'numberMatched' => items.length, 'features' => items, 'links' => links }
  end

  # Serves one page per collection path, records each request, and advances a fake clock per request.
  class Fake
    attr_reader :paths

    def initialize(pages, clock: nil, seconds: 0)
      @pages, @clock, @seconds, @paths = pages, clock, seconds, []
    end

    def get(path, params:, deadline:)
      @paths << path
      @clock&.advance(@seconds)
      body = @pages.fetch(path)
      raise body if body.is_a?(Exception)
      body.is_a?(String) ? body : body.to_json
    end
  end

  def collection(name)
    "/collections/#{name}/items"
  end

  def base_pages
    big = square(20.5, 51.5, 21.5, 52.5)
    { collection('rdlp') => page([feature(1, { 'region_cd' => '17' }, big)]),
      collection('nadlesnictwa') => page([feature(2, { 'adress_forest' => '17-02- -' }, big)]),
      collection('lesnictwa') => page([feature(3, { 'adress_forest' => '17-02-1-05-' }, big)]),
      collection('RDLP_Warszawa_wydzielenia') => page([]) }
  end

  def search(pages, **options)
    BDL::Client.new(transport: Fake.new(pages), **options).search(lat: LAT, lon: LON, radius_km: 5)
  end

  # R2
  def test_ssl_error_from_transport_becomes_incomplete
    pages = base_pages.merge(collection('rdlp') => OpenSSL::SSL::SSLError.new('certificate has expired'))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R2
  def test_ssl_error_after_last_retry_becomes_incomplete
    clock = FakeNet::Clock.new
    script = FakeNet::Script.new(*Array.new(3) { OpenSSL::SSL::SSLError.new('handshake') }, clock: clock)
    transport = HTTP::Transport.new(base_url: 'https://ogcapi.bdl.lasy.gov.pl', user_agent: 't', retries: 2,
                                    sleeper: clock)
    client = BDL::Client.new(transport: transport)
    FakeNet.with(script, clock) do
      assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
    end
  end

  # R4
  def test_search_stops_when_the_sixty_second_budget_runs_out
    clock = FakeNet::Clock.new(0.0)
    fake = Fake.new(base_pages, clock: clock, seconds: 25)
    client = BDL::Client.new(transport: fake, clock: -> { clock.now })
    assert_raises(BDL::Incomplete) { client.search(lat: LAT, lon: LON, radius_km: 5) }
    assert_operator fake.paths.length, :<=, 3
  end

  # R4
  def test_search_within_budget_succeeds_on_the_same_fake_clock
    clock = FakeNet::Clock.new(0.0)
    fake = Fake.new(base_pages, clock: clock, seconds: 5)
    client = BDL::Client.new(transport: fake, clock: -> { clock.now })
    assert_equal 0, client.search(lat: LAT, lon: LON, radius_km: 5)[:box_stand_count]
  end

  # R5
  def test_page_with_null_links_is_incomplete
    body = File.read(File.expand_path('../../fixtures/ogc/rdlp-links-null.json', __dir__))
    client = BDL::Client.new(transport: Fake.new({ collection('rdlp') => body }))
    assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
  end

  # R5
  def test_feature_with_unsupported_geometry_is_incomplete
    point = { 'type' => 'Point', 'coordinates' => [LON, LAT] }
    pages = base_pages.merge(collection('rdlp') => page([feature(1, { 'region_cd' => '17' }, point)]))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R5
  def test_unsupported_stand_geometry_is_incomplete
    point = { 'type' => 'Point', 'coordinates' => [LON, LAT] }
    pages = base_pages.merge(collection('RDLP_Warszawa_wydzielenia') => page([feature(9, { 'a_i_num' => 1 }, point)]))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R5
  def test_region_without_geometry_is_incomplete_not_no_coverage
    pages = base_pages.merge(collection('rdlp') => page([feature(1, { 'region_cd' => '17' }, nil)]))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R5
  def test_district_without_geometry_is_incomplete_not_no_coverage
    pages = base_pages.merge(collection('nadlesnictwa') => page([feature(2, { 'adress_forest' => '17-02- -' }, nil)]))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R5
  def test_complete_empty_coverage_is_no_coverage
    pages = base_pages.merge(collection('rdlp') => page([]))
    assert_raises(BDL::NoCoverage) { search(pages) }
  end

  # R12
  def test_successful_search_with_two_intersecting_regions_and_one_containing_region
    here = square(20.9, 51.9, 21.03, 52.1)
    east = square(21.03, 51.9, 21.2, 52.1)
    everything = square(20.5, 51.5, 21.5, 52.5)
    near = square(20.999, 51.999, 21.001, 52.001)
    far = square(21.06, 52.04, 21.065, 52.044) # inside the box, about 6 km away
    pages = {
      collection('rdlp') => page([feature(1, { 'region_cd' => '17' }, here),
                                  feature(4, { 'region_cd' => '06' }, east)]),
      collection('nadlesnictwa') => page([feature(2, { 'adress_forest' => '17-02- -' }, everything)]),
      collection('lesnictwa') => page([feature(3, { 'adress_forest' => '17-02-1-05-' }, everything)]),
      collection('RDLP_Warszawa_wydzielenia') =>
        page([feature(10, { 'a_i_num' => 111, 'adr_for' => '17-02-1-05-1', 'species_cd' => 'SO' }, near)]),
      collection('RDLP_Lodz_wydzielenia') =>
        page([feature(11, { 'a_i_num' => 222, 'adr_for' => '17-02-1-05-2', 'species_cd' => nil }, far)])
    }
    fake = Fake.new(pages)
    result = BDL::Client.new(transport: fake).search(lat: LAT, lon: LON, radius_km: 5)
    expected_paths = %w[rdlp nadlesnictwa lesnictwa RDLP_Warszawa_wydzielenia RDLP_Lodz_wydzielenia]
                     .map { |name| collection(name) }
    assert_equal expected_paths, fake.paths
    assert_equal 2, result[:box_stand_count]
    assert_equal 1, result[:radius_stand_count]
    assert_equal 0, result[:missing_identifier_count]
    assert_equal [111, 222], result[:stands].map { |item| item['a_i_num'] }
    assert_equal [true, false], result[:stands].map { |item| item['in_radius'] }
    assert_equal [2, 2], result[:stands].map { |item| item['district_id'] }
    assert_equal [3, 3], result[:stands].map { |item| item['range_id'] }
    assert_nil result[:stands].last['species_cd']
    assert result[:stands].none? { |item| item.key?('geometry') }
    assert_equal [3], result[:ranges].map { |item| item['id'] }
    assert_equal 2, result[:ranges].first['district_id']
    assert_equal 0.0, result[:ranges].first['distance_km']
  end

  def test_search_uses_one_shared_feature_limit
    pages = base_pages
    pages[collection('RDLP_Warszawa_wydzielenia')] = page(Array.new(99_998) do |id|
      feature(id, { 'a_i_num' => id }, square(20.99, 51.99, 21.01, 52.01))
    end)
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  def test_search_detects_limit_overflow_across_collections
    pages = base_pages
    pages[collection('rdlp')] = page([feature(1, { 'region_cd' => '17' }, square(20.5, 51.5, 21.5, 52.5)),
                                      feature(4, { 'region_cd' => '06' }, square(20.5, 51.5, 21.5, 52.5))])
    pages[collection('RDLP_Warszawa_wydzielenia')] = page(Array.new(99_996) do |id|
      feature(id, { 'a_i_num' => id }, square(20.99, 51.99, 21.01, 52.01))
    end)
    pages[collection('RDLP_Lodz_wydzielenia')] = page([feature(999_999, { 'a_i_num' => 999_999 },
                                                              square(20.99, 51.99, 21.01, 52.01))])
    assert_raises(BDL::Incomplete) { search(pages) }
  end
end
