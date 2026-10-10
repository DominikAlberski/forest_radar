# frozen_string_literal: true

require_relative '../../test_helper'
require 'osm/client'
require 'cache/session_cache'

module OSMClientLogSupport
  class Clock
    attr_reader :now

    def initialize
      @now = 10.0
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

  class Transport
    def initialize(body, clock)
      @body = body
      @clock = clock
    end

    def get(*)
      @clock.advance_ms(125)
      raise @body if @body.is_a?(Exception)

      @body
    end
  end
end

class OSMClientLogTest < Minitest::Test
  BOX = [20.6, 52.25, 20.8, 52.35].freeze

  def setup
    @clock = OSMClientLogSupport::Clock.new
    @log = OSMClientLogSupport::Recorder.new
  end

  def client(body)
    transport = OSMClientLogSupport::Transport.new(body, @clock)
    OSM::Client.new(transport: transport, log: @log, clock: -> { @clock.call },
                    cache: Cache::SessionCache.new)
  end

  def test_transport_error_returns_nil_and_logs_one_osm_record
    relations = client(HTTP::ResponseError.new('overpass failed')).relations(bbox: BOX)
    assert_nil relations
    assert_equal [[:osm, 'HTTP::ResponseError', 'overpass failed', 125]], @log.events
  end

  def test_good_response_returns_relations_without_a_log_record
    relations = client('{"elements":[]}').relations(bbox: BOX)
    assert_empty relations
    assert_empty @log.events
  end
end
