# frozen_string_literal: true

require_relative '../test_helper'
require 'rack/test'
require 'app'

module AppTestHelpers
  def assert_trail_keyword_names
    expected = keyword_names(OSM::Client, :relations)
    actual = keyword_names(AppTest::Trails, :relations)
    assert_equal expected, actual
  end

  def assert_deadline_bounds(before, after)
    deadline = @trails.deadline
    assert(deadline && before + 29 <= deadline && deadline <= after + 29)
  end

  def request_card_between_times
    before = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    card
    after = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    assert_equal 200, last_response.status
    [before, after]
  end

  def keyword_names(klass, method_name)
    klass.instance_method(method_name).parameters.filter_map do |kind, name|
      name if %i[key keyreq keyrest].include?(kind)
    end
  end

  def save_settings
    @saved = %i[search_client selector model_client search_cache].to_h do |key|
      [key, app.settings.public_send(key)]
    end
  end

  def configure_clock
    @clock = AppTestClock.new(Process.clock_gettime(Process::CLOCK_MONOTONIC))
    clock = @clock
    app.set :clock, -> { clock.call }
  end

  def configure_dependencies
    app.set :search_cache, Cache::SearchCache.new
    app.set :selector, WalkAreas::Selector.new(trails: (@trails = AppTest::Trails.new))
    use_model(AppTest::EchoHTTP.new('Sprawdź szlak przed wyjściem.'), 'configured.example')
    app.set :search_client, AppTest::Search.new
  end
end

class AppTestClock
  attr_reader :now

  def initialize(now)
    @now = now
  end

  def call
    @now
  end

  def advance(seconds)
    @now += seconds
  end
end

class AppTest < Minitest::Test
  include Rack::Test::Methods
  include AppTestHelpers

  HOST = { 'CONTENT_TYPE' => 'application/json', 'HTTP_HOST' => 'localhost' }.freeze
  SQUARE = { 'type' => 'Polygon', 'coordinates' => [[[0, 0], [0.01, 0], [0.01, 0.01], [0, 0.01], [0, 0]]] }.freeze

  # Recorded Ollama stand-in: echoes the received fact lines, then appends the given advice.
  class EchoHTTP
    Response = Struct.new(:code, :body)
    attr_reader :hosts, :bodies

    def initialize(advice)
      @advice = advice
      @hosts = []
      @bodies = []
    end

    def start(host, _port, **_options)
      @hosts << host
      yield self
    end

    def post(_path, body, _headers)
      @bodies << body
      facts = JSON.parse(body)['messages'].last['content'].delete_prefix("FAKTY\n")
      Response.new('200', JSON.generate(message: { content: "FAKTY\n#{facts}\nWNIOSKI\n#{@advice}" }))
    end
  end

  class Search
    def initialize(error = nil, clock: nil)
      @error = error
      @clock = clock
    end

    def search(**)
      @clock&.advance(11)
      raise @error if @error

      { ranges: ranges, districts: districts, stands: stands,
        box_stand_count: 1, radius_stand_count: 1, missing_identifier_count: 0 }
    end

    def ranges
      [{ 'id' => 1, 'geometry' => SQUARE, 'district_id' => 1, 'distance_km' => 1.0,
         'properties' => { 'name' => 'Las testowy' } }]
    end

    def districts
      [{ 'id' => 1, 'properties' => { 'name' => 'Nadleśnictwo' } }]
    end

    def stands
      [{ 'range_id' => 1, 'in_radius' => true, 'species_cd' => 'SO', 'a_year' => 2024, 'sub_area' => 1.5 }]
    end
  end

  class Trails
    attr_reader :bbox, :deadline

    def relations(bbox:, deadline:)
      @bbox = bbox
      @deadline = deadline
      [{ id: 1, name: 'Szlak', ref: 'T', route: 'hiking', ways: [[[-0.001, 0.005], [0.011, 0.005]]] }]
    end
  end

  class Expired
    def generate(*, **)
      raise Model::Deadline, 'model deadline'
    end
  end

  def app
    ForestRadar::App
  end

  def setup
    save_settings
    configure_clock
    configure_dependencies
  end

  def teardown
    @saved.each { |key, value| app.set key, value }
    app.set :clock, -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
  end

  def use_model(http, host)
    app.set :model_client, Model::Client.new("http://#{host}:11434", 'bielik', http: http)
  end

  def card(extra = {})
    post '/api/card', JSON.generate({ lat: 0.005, lon: 0.005, radius_km: 5 }.merge(extra)), HOST
  end

  def test_home_page
    get '/', {}, 'HTTP_HOST' => 'localhost'
    assert_equal 200, last_response.status
  end

  def test_invalid_boundary_values
    [{ lat: 'NaN', lon: 0, radius_km: 1 }, { lat: 91, lon: 0, radius_km: 1 },
     { lat: 0, lon: -181, radius_km: 1 }, { lat: 0, lon: 0, radius_km: 21 }]
      .each { |input| assert_invalid_input(input) }
  end

  def assert_invalid_input(input)
    post '/api/card', JSON.generate(input), HOST
    assert_equal 422, last_response.status
    refute_includes JSON.parse(last_response.body), 'card'
  end

  def test_model_host_is_not_read_from_request
    http = EchoHTTP.new('Sprawdź szlak.')
    use_model(http, 'configured.example')
    card(ollama_url: 'http://evil.example', model_url: 'http://evil.example', host: 'evil.example')
    assert_equal 200, last_response.status
    assert_equal ['configured.example'], http.hosts
  end

  def test_successful_card_has_facts_advice_and_warnings
    card
    body = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_card_body(body)
  end

  def test_card_passes_its_deadline_to_the_selector
    assert_trail_keyword_names
    assert_deadline_bounds(*request_card_between_times)
  end

  def assert_card_body(body)
    assert_equal(['Las testowy'], body['facts']['areas'].map { |area| area['name'] })
    assert_equal 'Sprawdź szlak przed wyjściem.', body['card']['advice']
    assert_includes body['card']['warning'], 'nie zbieraj grzyba'
    assert_includes body['sanepid_url'], '0.005'
  end

  def test_error_responses_hold_no_card
    cases = { 'no_coverage' => [BDL::NoCoverage, 422], 'source' => [BDL::Incomplete, 502] }
    cases.each { |key, (klass, status)| assert_search_error(key, klass, status) }
  end

  def assert_search_error(key, klass, status)
    app.set :search_client, Search.new(klass.new('x'))
    card
    assert_equal status, last_response.status
    assert_error key
  end

  def test_invalid_model_output_returns_model_error_without_card
    use_model(EchoHTTP.new('Ten grzyb jest jadalny.'), 'configured.example')
    card
    assert_equal 502, last_response.status
    assert_error 'model'
  end

  def test_expired_model_deadline_returns_504_without_card
    app.set :model_client, Expired.new
    card
    assert_equal 504, last_response.status
    assert_error 'deadline'
  end

  def assert_error(key)
    body = JSON.parse(last_response.body)
    assert_equal key, body['error']
    refute_includes body, 'card'
    refute_includes body, 'facts'
  end
end

class AppDeadlineTest < AppTest
  def test_selector_deadline_starts_after_the_search
    app.set :search_client, Search.new(nil, clock: @clock)
    card
    assert_equal @clock.call + 29, @trails.deadline
  end
end
