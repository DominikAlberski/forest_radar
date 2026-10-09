# frozen_string_literal: true

require_relative '../../test_helper'
require 'openssl'
require 'bdl/client'
require_relative '../http/fake_net'
require_relative 'client_search_support'

# Review findings B1-R2, B1-R4 (client part), B1-R5, B1-R12.
class ClientSearchTest < Minitest::Test
  include ClientSearchSupport

  # R2
  def test_ssl_error_from_transport_becomes_incomplete
    pages = base_pages.merge(collection('rdlp') => OpenSSL::SSL::SSLError.new('certificate has expired'))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  # R2
  def test_ssl_error_after_last_retry_becomes_incomplete
    clock = FakeNet::Clock.new
    assert_ssl_incomplete(ssl_client(clock), ssl_script(clock), clock)
  end

  def ssl_script(clock)
    FakeNet::Script.new(OpenSSL::SSL::SSLError.new('handshake'), OpenSSL::SSL::SSLError.new('handshake'),
                        OpenSSL::SSL::SSLError.new('handshake'), clock: clock)
  end

  def ssl_client(clock)
    transport = HTTP::Transport.new(base_url: 'https://ogcapi.bdl.lasy.gov.pl', user_agent: 't', retries: 2,
                                    sleeper: clock)
    BDL::Client.new(transport: transport)
  end

  def assert_ssl_incomplete(client, script, clock)
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
end
