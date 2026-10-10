# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientPaginationTest < Minitest::Test
  FIXTURES = File.expand_path('../../fixtures/ogc', __dir__)

  class OffsetReplay
    attr_reader :calls

    def initialize(pages)
      @pages = pages
      @calls = []
    end

    def get(path, params:, deadline:)
      @calls << [path, params.dup, deadline]
      body = @pages.fetch(params.fetch('offset', '0').to_i) { raise 'unexpected offset' }
      raise body if body.is_a?(Exception)

      body
    end
  end

  def fixture(name) = File.read(File.join(FIXTURES, name))

  def page(count, identifier, links: [])
    { numberMatched: count, features: [{ id: identifier, properties: {} }], links: links }.to_json
  end

  def read(pages, page_size: 1, limit: 100_000)
    transport = OffsetReplay.new(pages)
    options = { transport: transport, clock: -> { 100 } }
    options[:page_size] = page_size if page_size
    items = BDL::Client.new(**options).features('rdlp', bbox: [0, 0, 1, 1], limit: limit)
    [items, transport]
  end

  def ids(items) = items.map { |item| item['id'] }

  def offsets(transport) = transport.calls.map { |call| call[1].fetch('offset') }

  def deadlines(transport) = transport.calls.map { |call| call[2] }

  def test_reads_three_pages_by_offset_and_keeps_order
    pages = { 0 => page(3, 1), 1 => page(2, 2), 2 => page(1, 3) }
    items, transport = read(pages)
    assert_equal [1, 2, 3], ids(items)
    assert_equal %w[0 1 2], offsets(transport)
    assert_equal [160, 160, 160], deadlines(transport)
  end

  def test_live_shape_decreasing_counts_succeeds_without_next_link
    pages = { 0 => fixture('rdlp-page1.json'), 1 => fixture('rdlp-page2.json'),
              2 => fixture('rdlp-page3.json') }
    items, transport = read(pages)
    assert_equal [1, 2, 3], ids(items)
    assert_equal %w[0 1 2], offsets(transport)
  end

  def test_repeated_next_link_does_not_change_offset_progression
    repeated = [{ rel: 'next', href: 'https://evil.example/items?offset=1' }]
    pages = { 0 => page(3, 1, links: repeated), 1 => page(2, 2, links: repeated), 2 => page(1, 3) }
    items, transport = read(pages)
    assert_equal [1, 2, 3], ids(items)
    assert_equal %w[0 1 2], offsets(transport)
  end

  def test_later_count_must_equal_total_minus_offset
    error = assert_raises(BDL::Incomplete) do
      read({ 0 => fixture('rdlp-page1.json'), 1 => fixture('rdlp-page2-count-changed.json'), 2 => page(1, 3) })
    end
    assert_equal 'count changed', error.message
  end

  def test_short_page_is_a_count_mismatch
    pages = { 0 => page(3, 1), 1 => { numberMatched: 2, features: [], links: [] }.to_json, 2 => page(1, 3) }
    error = assert_raises(BDL::Incomplete) { read(pages) }
    assert_equal 'count mismatch', error.message
  end

  def test_feature_limit_stops_after_first_page
    transport = OffsetReplay.new(0 => page(3, 1))
    error = assert_raises(BDL::Incomplete) { read_limited(transport, 2) }
    assert_equal 'feature limit', error.message
    assert_equal 1, transport.calls.length
  end

  def read_limited(transport, limit)
    client = BDL::Client.new(transport: transport, page_size: 1)
    client.features('rdlp', bbox: [0, 0, 1, 1], limit: limit)
  end

  def test_next_link_to_another_host_is_ignored
    foreign = page(2, 1, links: [{ rel: 'next', href: 'https://evil.example/items?offset=9' }])
    pages = { 0 => foreign, 1 => page(1, 2) }
    items, transport = read(pages)
    assert_equal [1, 2], ids(items)
    assert_foreign_link_was_ignored(transport)
  end

  def assert_foreign_link_was_ignored(transport)
    assert_equal '/collections/rdlp/items', transport.calls.last.first
    assert_equal '1', transport.calls.last[1].fetch('offset')
  end

  def test_empty_collection_is_complete
    items, transport = read({ 0 => '{"numberMatched":0,"features":[],"links":[]}' }, page_size: nil)
    assert_empty items
    assert_equal 1, transport.calls.length
  end

  def test_malformed_page_is_incomplete
    error = assert_raises(BDL::Incomplete) do
      read({ 0 => fixture('malformed-page.json') }, page_size: nil)
    end
    assert_equal 'malformed page', error.message
  end

  def test_truncated_json_is_incomplete
    assert_raises(BDL::Incomplete) do
      read({ 0 => fixture('truncated-page.json') }, page_size: nil)
    end
  end

  def test_missing_count_is_incomplete
    error = assert_raises(BDL::Incomplete) do
      read({ 0 => '{"features":[],"links":[]}' }, page_size: nil)
    end
    assert_equal 'missing count', error.message
  end

  def test_count_mismatch_at_end_is_incomplete
    error = assert_raises(BDL::Incomplete) { read({ 0 => page(3, 1) }, page_size: nil) }
    assert_equal 'count mismatch', error.message
  end

  def test_feature_limit_allows_exact_count
    pages = { 0 => page(2, 1), 1 => page(1, 2) }
    items, = read(pages, limit: 2)
    assert_equal 2, items.length
  end
end
