# frozen_string_literal: true

require_relative '../../test_helper'
require 'osm/client'
require 'cache/session_cache'
require_relative '../http/fake_net'
require_relative 'client_support'

class OSMClientTest < Minitest::Test
  include OSMTestSupport

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
      @body.tap { |body| raise body if body.is_a?(Exception) }
    end
  end

  def fixture(name)
    File.read(File.expand_path("../../fixtures/osm/#{name}", __dir__))
  end

  def overpass_transport(**)
    HTTP::Transport.new(base_url: OSM::Client::ENDPOINT, user_agent: 'forest_radar/1.0',
                        timeout: 25, retries: 1, **)
  end

  def test_parses_recorded_relations_and_reuses_cached_result
    fake = Fake.new(fixture('range-sample.json'))
    client = OSM::Client.new(transport: fake, cache: Cache::SessionCache.new)
    first = client.relations(bbox: BOX)
    assert_recorded_relations(first)
    assert_cached_result(client, fake, first)
  end

  def assert_recorded_relations(first)
    assert_equal 15, first.length
    assert_includes first.map { |item| item[:id] }, 120_876
  end

  def assert_cached_result(client, fake, first)
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
     fixture('overpass-500.html')].each { |body| assert_unknown_uncached(body, cache) }
  end

  def assert_unknown_uncached(body, cache)
    fake = Fake.new(body)
    client = OSM::Client.new(transport: fake, cache: cache)
    assert_nil client.relations(bbox: BOX)
    assert_nil client.relations(bbox: BOX)
    assert_equal 2, fake.calls
  end

  def test_client_does_not_retry_rate_limit
    clock = FakeNet::Clock.new
    script = StatusScript.new('busy', fixture('no-relations.json'), clock: clock)
    FakeNet.with(script, clock) { assert_nil OSM::Client.new(transport: overpass_transport).relations(bbox: BOX) }
    assert_equal 1, script.calls
  end

  def test_transport_rejects_response_over_sixteen_mebibytes
    clock = FakeNet::Clock.new
    body = %({"elements":[],"padding":"#{'x' * (16 * 1024 * 1024)}"})
    script = FakeNet::Script.new(body, clock: clock)
    FakeNet.with(script, clock) { assert_nil OSM::Client.new(transport: overpass_transport).relations(bbox: BOX) }
  end

  def test_overpass_cutoff_and_earlier_caller_deadline
    clock = FakeNet::Clock.new
    fake = Fake.new(fixture('no-relations.json'))
    FakeNet.with(FakeNet::Script.new(clock: clock), clock) { check_deadlines(fake, clock) }
  end

  def check_deadlines(fake, clock)
    OSM::Client.new(transport: fake).relations(bbox: BOX)
    assert_equal clock.now + 25, fake.deadline
    assert_deadline(fake, clock, 10)
  end

  def assert_deadline(fake, clock, seconds)
    OSM::Client.new(transport: fake).relations(bbox: BOX, deadline: clock.now + seconds)
    assert_equal clock.now + seconds, fake.deadline
  end

  def test_transport_retry_stays_within_overpass_budget
    clock = FakeNet::Clock.new
    script = FakeNet::Script.new(Timeout::Error.new('slow'), fixture('no-relations.json'), clock: clock)
    transport = overpass_transport(sleeper: clock)
    FakeNet.with(script, clock) { assert_empty OSM::Client.new(transport: transport).relations(bbox: BOX) }
    assert_retry_budget(script, clock)
  end

  def assert_retry_budget(script, clock)
    assert_equal 2, script.calls
    assert_operator clock.now, :<=, 1025
  end

  def test_malformed_overpass_structures_are_unknown
    invalid_elements.each { |element| assert_invalid_element(element) }
  end

  def valid_relation
    { 'type' => 'relation', 'id' => 1, 'tags' => { 'route' => 'hiking' },
      'members' => [{ 'type' => 'way', 'geometry' => [{ 'lon' => 1, 'lat' => 2 }] }] }
  end

  def invalid_elements
    relation = valid_relation
    [nil, 3, relation.merge('tags' => nil), relation.merge('tags' => 3)] +
      invalid_members(relation) + invalid_geometry(relation)
  end

  def invalid_members(relation)
    [nil, 3, [nil], [3]].map { |members| relation.merge('members' => members) }
  end

  def invalid_geometry(relation)
    [nil, 3, [3]].map { |geometry| relation.merge('members' => [{ 'type' => 'way', 'geometry' => geometry }]) }
  end

  def assert_invalid_element(element)
    body = { elements: [element] }.to_json
    assert_nil OSM::Client.new(transport: Fake.new(body)).relations(bbox: BOX)
  end
end
