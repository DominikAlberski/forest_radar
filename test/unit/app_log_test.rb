# frozen_string_literal: true

require_relative '../test_helper'
require 'rack/test'
require 'stringio'
require 'app'
require_relative '../../lib/source_log' if File.file?(File.expand_path('../../lib/source_log.rb', __dir__))

module AppLogConfigured
  LOG = ForestRadar::App.settings.source_log if ForestRadar::App.settings.respond_to?(:source_log)
  SELECTOR = ForestRadar::App.settings.selector
end

module AppLogSupport
  class Clock
    attr_reader :now

    def initialize
      @now = 100.0
    end

    def call
      @now
    end

    def advance_ms(value)
      @now += value / 1000.0
    end
  end

  class Recorder
    attr_reader :events

    def initialize
      @events = []
    end

    def write(source:, error:, elapsed_ms:)
      @events << [source, error.class.name, error.message, elapsed_ms]
    end
  end

  class Search
    def initialize(clock, error: nil)
      @clock = clock
      @error = error
    end

    def search(**)
      @clock.advance_ms(125)
      raise @error if @error

      { ranges: [], districts: [], stands: [], box_stand_count: 0,
        radius_stand_count: 0, missing_identifier_count: 0 }
    end
  end

  class Selector
    def select(**)
      { areas: [], excluded: [], trail_source: 'OpenStreetMap',
        attribution: OSM::Client::ATTRIBUTION, attribution_url: OSM::Client::COPYRIGHT_URL }
    end
  end

  class Model
    def initialize(clock, error: nil)
      @clock = clock
      @error = error
    end

    def generate(*, **)
      @clock.advance_ms(125)
      raise @error if @error

      'Sprawdź warunki w terenie.'
    end
  end
end

module AppLogFailureTests
  def test_incomplete_search_returns_502_and_logs_one_bdl_record
    app.set :search_client, failing_search(BDL::Incomplete.new('count changed'))
    card
    assert_equal 502, last_response.status
    assert_one_record('bdl', BDL::Incomplete, 'count changed', 125)
  end

  def test_deadline_model_error_returns_504_and_logs_one_model_record
    app.set :model_client, failing_model(Model::Deadline.new('model deadline'))
    card
    assert_equal 504, last_response.status
    assert_one_record('model', Model::Deadline, 'model deadline', 125)
  end

  def test_invalid_model_error_returns_502_and_logs_one_model_record
    app.set :model_client, failing_model(Model::Invalid.new('invalid response'))
    card
    assert_equal 502, last_response.status
    assert_one_record('model', Model::Invalid, 'invalid response', 125)
  end

  def test_system_error_returns_502_and_logs_one_model_record
    error = SystemCallError.new('offline')
    app.set :model_client, failing_model(error)
    card
    assert_equal 502, last_response.status
    assert_one_record('model', SystemCallError, error.message, 125)
  end

  def test_no_coverage_returns_422_without_a_log_record
    app.set :search_client, failing_search(BDL::NoCoverage.new('outside'))
    card
    assert_equal 422, last_response.status
    assert_no_records
  end
end

module AppLogSuccessTests
  def test_configured_osm_client_uses_the_app_source_log
    assert @configured_log
    assert_same @configured_log, configured_osm_log
  end

  def test_successful_card_writes_no_log_record
    card
    assert_equal 200, last_response.status
    assert_no_records
  end

  def test_session_and_coordinate_data_do_not_enter_the_log_record
    message = private_error_message
    app.set :search_client, failing_search(BDL::Incomplete.new(message))
    card(cookie: "#{Cache::SessionId::COOKIE}=#{AppLogTest::SESSION}")
    assert_equal 502, last_response.status
    assert_private_record(message)
  end
end

class AppLogTest < Minitest::Test
  include Rack::Test::Methods
  include AppLogFailureTests
  include AppLogSuccessTests

  HOST = { 'CONTENT_TYPE' => 'application/json', 'HTTP_HOST' => 'localhost' }.freeze
  REQUEST = JSON.generate(lat: 52.078247, lon: 21.040624, radius_km: 5).freeze
  SESSION = '0123456789abcdef0123456789abcdef'

  def app
    ForestRadar::App
  end

  def setup
    save_configuration
    configure_test_dependencies
  end

  def save_configuration
    @saved = %i[search_client selector model_client search_cache].to_h do |key|
      [key, app.settings.public_send(key)]
    end
    @configured_log = AppLogConfigured::LOG if AppLogConfigured.const_defined?(:LOG)
  end

  def configure_test_dependencies
    configure_logger
    configure_app_services
  end

  def configure_logger
    @clock = AppLogSupport::Clock.new
    clock = @clock
    app.set :clock, -> { clock.call }
    configure_output
  end

  def configure_output
    @output = StringIO.new
    @log = build_log
    app.set :source_log, @log
  end
  private :configure_output

  def configure_app_services
    app.set :search_cache, Cache::SearchCache.new
    app.set :selector, AppLogSupport::Selector.new
    app.set :search_client, AppLogSupport::Search.new(@clock)
    app.set :model_client, AppLogSupport::Model.new(@clock)
  end

  def build_log
    return SourceLog.new(io: @output) if defined?(SourceLog)

    AppLogSupport::Recorder.new
  end

  def teardown
    @saved.each { |key, value| app.set key, value }
    app.set :source_log, AppLogConfigured::LOG if AppLogConfigured.const_defined?(:LOG)
    app.set :clock, -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
  end

  def card(cookie: nil)
    headers = cookie ? HOST.merge('HTTP_COOKIE' => cookie) : HOST
    post '/api/card', REQUEST, headers
  end

  def failing_search(error)
    AppLogSupport::Search.new(@clock, error: error)
  end

  def failing_model(error)
    AppLogSupport::Model.new(@clock, error: error)
  end

  def assert_one_record(source, error_class, message, elapsed_ms)
    if @log.respond_to?(:events)
      assert_event_record(source, error_class, message, elapsed_ms)
    else
      assert_line_record(source, error_class, message, elapsed_ms)
    end
  end

  def assert_event_record(source, error_class, message, elapsed_ms)
    assert_equal [[source.to_sym, error_class.name, message, elapsed_ms]], @log.events
  end

  def assert_line_record(source, error_class, message, elapsed_ms)
    expected = "source=#{source} error=#{error_class} message=\"#{message}\" elapsed_ms=#{elapsed_ms}\n"
    assert_equal expected, @output.string
  end

  def assert_no_records
    return assert_empty(@log.events) if @log.respond_to?(:events)

    assert_empty @output.string
  end

  def assert_private_record(message)
    assert_one_record(:bdl, BDL::Incomplete, message, 125) if @log.respond_to?(:events)
    assert_scrubbed_line unless @log.respond_to?(:events)
    refute_includes @log.events.first[2], AppLogTest::SESSION if @log.respond_to?(:events)
  end

  def assert_scrubbed_line
    line = @output.string
    assert_equal 1, line.lines.length
    assert_includes line, 'source=bdl error=BDL::Incomplete'
    assert_includes line, 'elapsed_ms=125'
    assert_scrubbed_secrets(line)
  end

  def assert_scrubbed_secrets(line)
    secrets = %w[52.078247 21.040624 https://host.test bbox=52.1 query=52.078247,21.040624]
    (secrets + [AppLogTest::SESSION]).each do |secret|
      refute_includes line, secret
    end
  end

  def configured_osm_log
    client = AppLogConfigured::SELECTOR.instance_variable_get(:@trails)
    client.instance_variable_get(:@log)
  end

  def private_error_message
    'coords 52.078247 21.040624 https://host.test/?bbox=52.1,21.2 query=52.078247,21.040624'
  end
end
