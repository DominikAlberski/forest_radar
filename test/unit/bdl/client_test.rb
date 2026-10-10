# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientTest < Minitest::Test
  class FakeTransport
    attr_reader :paths

    def initialize(pages)
      @pages = pages
      @paths = []
    end

    def get(path, params:, **)
      @paths << [path, params]
      @pages.fetch(path).shift.to_json
    end
  end

  def feature(identifier, properties = {})
    { 'id' => identifier, 'type' => 'Feature', 'geometry' => nil, 'properties' => properties }
  end

  def page(items, matched:, next_url: nil)
    links = next_url ? [{ 'rel' => 'next', 'href' => next_url }] : []
    { 'features' => items, 'numberMatched' => matched, 'links' => links }
  end

  def test_follows_pages_and_detects_mismatch
    path = '/collections/rdlp/items'
    pages = { path => [page([feature(1)], matched: 2, next_url: "https://ogcapi.bdl.lasy.gov.pl#{path}?offset=1"),
                       page([feature(2)], matched: 2)] }
    client = BDL::Client.new(transport: FakeTransport.new(pages))
    assert_equal([1, 2], client.features('rdlp', bbox: [0, 0, 1, 1]).map { |item| item['id'] })
  end

  def test_rejects_incomplete_count
    path = '/collections/rdlp/items'
    client = BDL::Client.new(transport: FakeTransport.new(path => [page([feature(1)], matched: 2)]))
    assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
  end

  def test_compact_links_range_and_counts_circle_intersections
    result = linked_result
    assert_equal 1, result[:radius_stand_count]
    assert_equal 5, result[:stands].first['range_id']
    assert_equal 4, result[:ranges].first['district_id']
    assert_nil result[:stands].first['species_cd']
  end

  def linked_result
    district, range, stand = linked_features
    input = BDL::BuildInput.new(regions: [], districts: [district], ranges: [range],
                                stands: [['RDLP_Warszawa_wydzielenia', stand]])
    BDL::ResultBuilder.new.build(0, 0, 1, input)
  end

  def linked_features
    geometry = { 'type' => 'Polygon', 'coordinates' => [[[0, 0], [0.01, 0], [0.01, 0.01], [0, 0.01], [0, 0]]] }
    [feature(4, 'adress_forest' => '17-02- -'), feature(5, 'adress_forest' => '17-02-1-05-'),
     feature(6, 'a_i_num' => 10, 'adr_for' => '17-02-1-05-123', 'species_cd' => nil)].map do |item|
      item.merge('geometry' => geometry)
    end
  end
end
