require_relative '../../test_helper'
require 'wms/ban_client'
require 'cache/search_cache'
require_relative '../http/fake_net'

class BanClientTest < Minitest::Test
  class Fake
    attr_reader :calls, :params

    def initialize(body)
      @body, @calls = body, 0
    end

    def get(_path, params:, deadline:)
      @calls += 1
      @params = params
      raise @body if @body.is_a?(Exception)
      @body
    end
  end

  class AddressScript < FakeNet::Script
    attr_reader :request_path

    def start(*args, **options)
      super(*args, **options) do |connection|
        original = connection.method(:request)
        capture = self
        connection.define_singleton_method(:request) do |request, &block|
          capture.instance_variable_set(:@request_path, request.path)
          original.call(request, &block)
        end
        yield connection
      end
    end
  end

  def district
    { 'geometry' => { 'type' => 'Polygon', 'coordinates' => [
      [[20.6, 52.2], [20.8, 52.2], [20.8, 52.4], [20.6, 52.4], [20.6, 52.2]]
    ] } }
  end

  def test_live_query_error_means_unknown
    body = File.read(File.expand_path('../../fixtures/sources/bans-query-error.json', __dir__))
    assert_equal :unknown, WMS::BanClient.new(transport: Fake.new(body)).sample(district, session_id: 's')[:status]
  end

  def test_empty_synthetic_features_mean_no_known_ban_and_are_cached
    body = File.read(File.expand_path('../../fixtures/sources/bans-query-empty.json', __dir__))
    fake = Fake.new(body)
    client = WMS::BanClient.new(transport: fake, cache: Cache::SearchCache.new)
    first = client.sample(district, session_id: 's', sampled_at: Time.utc(2026, 10, 8, 12))
    second = client.sample(district, session_id: 's', sampled_at: Time.utc(2026, 10, 8, 13))
    assert_equal :no_known_ban, first[:status]
    assert_equal first[:sampled_at], second[:sampled_at]
    assert_equal 1, fake.calls
    assert_equal 4326, fake.params[:inSR]
    assert_equal 'esriGeometryPoint', fake.params[:geometryType]
    assert_equal 'esriSpatialRelIntersects', fake.params[:spatialRel]
    assert_equal '*', fake.params[:outFields]
    assert_equal false, fake.params[:returnGeometry]
    assert_equal 'json', fake.params[:f]
    assert_in_delta 20.7, fake.params[:geometry].split(',').first.to_f, 0.000001
    assert_in_delta 52.3, fake.params[:geometry].split(',').last.to_f, 0.000001
  end

  def test_named_ban_is_preserved
    body = File.read(File.expand_path('../../fixtures/sources/bans-query-feature.json', __dir__))
    fake = Fake.new(body)
    result = WMS::BanClient.new(transport: fake).sample(district, session_id: 's')
    assert_equal :ban, result[:status]
    assert_equal 'Zakaz', result[:bans].first['name']
  end

  def test_failure_and_malformed_response_are_unknown
    [HTTP::ResponseError.new('500'), '<table>broken</table>',
     '{"features":[{"attributes":{}}]}'].each do |body|
      assert_equal :unknown, WMS::BanClient.new(transport: Fake.new(body)).sample(district, session_id: 's')[:status]
    end
  end

  def test_real_transport_keeps_the_full_ban_service_path
    clock = FakeNet::Clock.new
    script = AddressScript.new('{"features":[]}', clock: clock)
    FakeNet.with(script, clock) do
      assert_equal :no_known_ban, WMS::BanClient.new.sample(district, session_id: 's')[:status]
    end
    assert_equal 1, script.calls
    assert_match %r{\A/ArcGIS/rest/services/WMS_zakazy_wstepu_do_lasu/MapServer/0/query\?}, script.request_path
  end

  def test_null_and_scalar_features_are_unknown
    [nil, 7, 'bad'].each do |feature|
      body = { features: [feature] }.to_json
      assert_equal :unknown, WMS::BanClient.new(transport: Fake.new(body)).sample(district, session_id: 's')[:status]
    end
  end

  def test_reports_centre_outside_concave_district
    shape = district
    shape['geometry']['coordinates'] = [[[0, 0], [4, 0], [4, 1], [1, 1], [1, 4], [0, 4], [0, 0]]]
    result = WMS::BanClient.new(transport: Fake.new('{"features":[]}'))
                           .sample(shape, session_id: 's')
    assert result[:centre_outside]
  end

  def test_geometric_centre_accounts_for_hole
    shape = district
    shape['geometry']['coordinates'] = [
      [[0, 0], [4, 0], [4, 4], [0, 4], [0, 0]],
      [[2, 0], [4, 0], [4, 2], [2, 2], [2, 0]]
    ]
    result = WMS::BanClient.new(transport: Fake.new('{"features":[]}'))
                           .sample(shape, session_id: 's')
    assert_in_delta 1.667, result[:point][0], 0.001
    assert_in_delta 2.333, result[:point][1], 0.001
  end
end
