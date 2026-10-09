# frozen_string_literal: true

require_relative '../../test_helper'
require 'osm/client'
require 'cache/session_cache'
require_relative '../http/fake_net'

class OSMClientTest < Minitest::Test
  BOX = [20.6, 52.25, 20.8, 52.35].freeze

  class Fake
    attr_reader :calls, :params, :deadline

    def initialize(body)
      @body = body
      @calls = 0
    end

    def get(_path, params:, deadline:)
      @calls += 1
      @params = params
      @deadline = deadline
      raise @body if @body.is_a?(Exception)

      @body
    end
  end

  class StatusScript < FakeNet::Script
    def start(*, **)
      super do |connection|
        connection.define_singleton_method(:request) do |_request, &block|
          block.call(Net::HTTPTooManyRequests.new('1.1', '429', 'busy'))
        end
        yield connection
      end
    end
  end

  def fixture(name)
    File.read(File.expand_path("../../fixtures/osm/#{name}", __dir__))
  end

  def test_parses_recorded_relations_and_reuses_cached_result
    fake = Fake.new(fixture('range-sample.json'))
    client = OSM::Client.new(transport: fake, cache: Cache::SessionCache.new)
    first = client.relations(bbox: BOX)
    assert_equal 15, first.length
    assert_includes first.map { |item| item[:id] }, 120_876
    assert_equal first, client.relations(bbox: BOX)
    assert_equal 1, fake.calls
    assert_includes fake.params[:data], '52.25,20.6,52.35,20.8'
  end

  def test_empty_response_is_valid_evidence
    assert_empty OSM::Client.new(transport: Fake.new(fixture('no-relations.json'))).relations(bbox: BOX)
  end

  def test_failed_and_malformed_responses_are_unknown_and_uncached
    cache = Cache::SessionCache.new
    [HTTP::ResponseError.new('429'), HTTP::LimitError.new('response too large'),
     fixture('overpass-500.html')].each do |body|
      fake = Fake.new(body)
      client = OSM::Client.new(transport: fake, cache: cache)
      assert_nil client.relations(bbox: BOX)
      assert_nil client.relations(bbox: BOX)
      assert_equal 2, fake.calls
    end
  end

  def test_client_does_not_retry_http_429
    clock = FakeNet::Clock.new
    script = StatusScript.new('busy', fixture('no-relations.json'), clock: clock)
    transport = HTTP::Transport.new(base_url: OSM::Client::ENDPOINT, user_agent: 'forest_radar/1.0',
                                    timeout: 25, retries: 1)
    FakeNet.with(script, clock) { assert_nil OSM::Client.new(transport: transport).relations(bbox: BOX) }
    assert_equal 1, script.calls
  end

  def test_transport_rejects_response_over_sixteen_mib
    clock = FakeNet::Clock.new
    body = '{"elements":[],"padding":"' + ('x' * (16 * 1024 * 1024)) + '"}'
    script = FakeNet::Script.new(body, clock: clock)
    transport = HTTP::Transport.new(base_url: OSM::Client::ENDPOINT, user_agent: 'forest_radar/1.0',
                                    timeout: 25, retries: 1)
    FakeNet.with(script, clock) do
      assert_nil OSM::Client.new(transport: transport).relations(bbox: BOX)
    end
  end

  def test_overpass_cutoff_and_earlier_caller_deadline
    clock = FakeNet::Clock.new
    fake = Fake.new(fixture('no-relations.json'))
    FakeNet.with(FakeNet::Script.new(clock: clock), clock) do
      OSM::Client.new(transport: fake).relations(bbox: BOX)
      assert_equal clock.now + 25, fake.deadline
      OSM::Client.new(transport: fake).relations(bbox: BOX, deadline: clock.now + 10)
      assert_equal clock.now + 10, fake.deadline
    end
  end

  def test_transport_retry_stays_within_overpass_budget
    clock = FakeNet::Clock.new
    script = FakeNet::Script.new(Timeout::Error.new('slow'), fixture('no-relations.json'), clock: clock)
    transport = HTTP::Transport.new(base_url: OSM::Client::ENDPOINT, user_agent: 'forest_radar/1.0',
                                    timeout: 25, retries: 1, sleeper: clock)
    FakeNet.with(script, clock) { assert_empty OSM::Client.new(transport: transport).relations(bbox: BOX) }
    assert_equal 2, script.calls
    assert_operator clock.now, :<=, 1025
  end

  def test_malformed_overpass_structures_are_unknown
    relation = { 'type' => 'relation', 'id' => 1, 'tags' => { 'route' => 'hiking' },
                 'members' => [{ 'type' => 'way', 'geometry' => [{ 'lon' => 1, 'lat' => 2 }] }] }
    [nil, 3, relation.merge('tags' => nil), relation.merge('tags' => 3),
     relation.merge('members' => nil), relation.merge('members' => 3),
     relation.merge('members' => [nil]), relation.merge('members' => [3]),
     relation.merge('members' => [{ 'type' => 'way', 'geometry' => nil }]),
     relation.merge('members' => [{ 'type' => 'way', 'geometry' => 3 }]),
     relation.merge('members' => [{ 'type' => 'way', 'geometry' => [3] }])].each do |element|
      body = { elements: [element] }.to_json
      assert_nil OSM::Client.new(transport: Fake.new(body)).relations(bbox: BOX)
    end
  end
end
