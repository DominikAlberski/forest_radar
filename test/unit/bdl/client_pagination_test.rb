# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientPaginationTest < Minitest::Test
  FIXTURES = File.expand_path('../../fixtures/ogc', __dir__)

  class Replay
    attr_reader :calls

    def initialize(*bodies)
      @bodies = bodies
      @calls = []
    end

    def get(path, params:, deadline:)
      @calls << [path, params, deadline]
      @bodies.shift or raise 'unexpected extra request'
    end
  end

  def fixture(name)
    File.read(File.join(FIXTURES, name))
  end

  def read(*bodies, **)
    transport = Replay.new(*bodies)
    [BDL::Client.new(transport: transport).features('rdlp', bbox: [0, 0, 1, 1], **), transport]
  end

  def assert_deadlines(transport)
    assert(transport.calls.all? { |_, _, deadline| deadline.is_a?(Numeric) && deadline.positive? })
  end

  def test_follows_next_link_and_keeps_order
    items, transport = read(fixture('rdlp-page1.json'), fixture('rdlp-page2.json'))
    assert_equal([1, 2], items.map { |item| item['id'] })
    assert_equal '/collections/rdlp/items', transport.calls.last.first
    assert_equal '1', transport.calls.last[1]['offset']
    assert_deadlines(transport)
  end

  def test_empty_collection_is_complete
    body = '{"numberMatched":0,"features":[],"links":[]}'
    items, = read(body)
    assert_equal [], items
  end

  def test_repeated_next_link_is_incomplete
    looping = JSON.parse(fixture('rdlp-page1.json'))
    transport = Replay.new(looping.to_json, looping.to_json, looping.to_json, looping.to_json)
    client = BDL::Client.new(transport: transport)
    assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
    assert_operator transport.calls.length, :<=, 3
  end

  def test_malformed_page_is_incomplete
    assert_raises(BDL::Incomplete) { read(fixture('malformed-page.json')) }
  end

  def test_truncated_json_is_incomplete
    assert_raises(BDL::Incomplete) { read(fixture('truncated-page.json')) }
  end

  def test_missing_count_is_incomplete
    assert_raises(BDL::Incomplete) { read('{"features":[],"links":[]}') }
  end

  def test_foreign_host_next_link_is_incomplete
    assert_raises(BDL::Incomplete) { read(fixture('rdlp-page1-foreign.json'), fixture('rdlp-page2.json')) }
  end

  def test_count_changing_between_pages_is_incomplete
    assert_raises(BDL::Incomplete) { read(fixture('rdlp-page1.json'), fixture('rdlp-page2-count-changed.json')) }
  end

  def test_count_mismatch_at_end_is_incomplete
    body = '{"numberMatched":3,"features":[{"id":1,"properties":{}}],"links":[]}'
    assert_raises(BDL::Incomplete) { read(body) }
  end

  def test_feature_limit_is_incomplete
    assert_raises(BDL::Incomplete) { read(fixture('rdlp-page1.json'), fixture('rdlp-page2.json'), limit: 1) }
  end

  def test_feature_limit_allows_exact_count
    items, = read(fixture('rdlp-page1.json'), fixture('rdlp-page2.json'), limit: 2)
    assert_equal 2, items.length
  end
end
