# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientGeometryValidationTest < Minitest::Test
  class Transport
    def initialize(geometry)
      @geometry = geometry
    end

    def get(path, **)
      items = path.include?('wydzielenia') ? [] : [region]
      { 'numberMatched' => items.length, 'features' => items, 'links' => [] }.to_json
    end

    def region
      { 'type' => 'Feature', 'id' => 1, 'properties' => { 'region_cd' => '17' }, 'geometry' => @geometry }
    end
  end

  def polygon
    { 'type' => 'Polygon', 'coordinates' => [[[20, 51], [22, 51], [22, 53], [20, 53], [20, 51]]] }
  end

  def search(geometry)
    BDL::Client.new(transport: Transport.new(geometry)).search(lat: 52, lon: 21, radius_km: 5)
  end

  def test_null_multipolygon_coordinates_raise_incomplete
    geometry = { 'type' => 'MultiPolygon', 'coordinates' => nil }
    assert_raises(BDL::Incomplete) { search(geometry) }
  end

  def test_scalar_geometry_raises_incomplete
    assert_raises(BDL::Incomplete) { search(42) }
  end

  def test_non_hash_geometry_raises_incomplete
    assert_raises(BDL::Incomplete) { search(['Polygon']) }
  end

  def test_unclosed_ring_raises_incomplete
    geometry = polygon
    geometry['coordinates'].first.pop
    assert_raises(BDL::Incomplete) { search(geometry) }
  end

  def test_closed_polygon_search_succeeds
    assert_equal 0, search(polygon)[:box_stand_count]
  end
end
