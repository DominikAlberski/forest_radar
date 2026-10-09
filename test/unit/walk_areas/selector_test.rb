# frozen_string_literal: true

require_relative '../../test_helper'
require 'walk_areas/selector'

class WalkAreaSelectorTest < Minitest::Test
  class Trails
    def initialize(relations)
      @relations = relations
    end

    def relations(bbox:, deadline:)
      @relations
    end
  end

  def square(x)
    { 'type' => 'Polygon', 'coordinates' => [[[x, 0], [x + 0.01, 0], [x + 0.01, 0.01],
                                              [x, 0.01], [x, 0]]] }
  end

  def range(id, x, distance)
    { 'id' => id, 'geometry' => square(x), 'district_id' => 1, 'distance_km' => distance }
  end

  def relation(x)
    { id: x, name: 'Trail', ref: 'T', route: 'hiking', ways: [[[x - 0.001, 0.005], [x + 0.011, 0.005]]] }
  end

  def select(ranges, relations:, districts: [])
    search = { ranges: ranges, districts: districts }
    WalkAreas::Selector.new(trails: Trails.new(relations))
                       .select(search: search, lat: 0, lon: 0, radius_km: 20, session_id: 's')
  end

  def test_crossing_trails_select_at_most_three_in_stable_distance_order
    ranges = [range(4, 0.04, 3), range(2, 0.02, 1), range(1, 0.01, 1), range(3, 0.03, 2)]
    result = select(ranges, relations: [0.01, 0.02, 0.03, 0.04].map { |x| relation(x) })
    assert_equal([1, 2, 3], result[:areas].map { |item| item['id'] })
    assert_equal 'OpenStreetMap', result[:trail_source]
    assert_equal OSM::Client::ATTRIBUTION, result[:attribution]
    assert(result[:areas].all? { |item| item[:trails].any? })
  end

  def test_range_is_selected_when_district_has_no_access_data
    result = select([range(1, 0.01, 1)], relations: [relation(0.01)], districts: [{ 'id' => 1 }])
    assert_equal([1], result[:areas].map { |item| item['id'] })
    assert_empty result[:excluded]
  end

  def test_disjoint_trail_excludes_range_with_no_mapped_trail
    result = select([range(1, 0.01, 1)], relations: [relation(0.1)])
    assert_empty result[:areas]
    assert_equal :no_mapped_trail, result[:excluded].first[:exclusion_reason]
  end

  def test_unavailable_trail_excludes_range
    assert_equal :trail_unavailable, select([range(1, 0.01, 1)], relations: nil)[:excluded].first[:exclusion_reason]
  end

  def test_zero_to_two_eligible_areas
    assert_empty select([], relations: [])[:areas]
    assert_equal 1, select([range(1, 0.01, 1)], relations: [relation(0.01)])[:areas].length
    assert_equal 2, select([range(1, 0.01, 1), range(2, 0.02, 2)],
                           relations: [relation(0.01), relation(0.02)])[:areas].length
  end

  def test_recorded_relations_cross_both_recorded_ranges
    root = File.expand_path('../../fixtures', __dir__)
    first = JSON.parse(File.read("#{root}/sources/range-sample.json")).fetch('features').first
    second = JSON.parse(File.read("#{root}/osm/bdl-range-box-page2.json")).fetch('features').first
    relations = OSM::Client.new(transport: FixtureTransport.new(File.read("#{root}/osm/range-sample.json")))
                           .relations(bbox: [20.6, 52.25, 20.8, 52.35])
    ranges = [first, second].map { |item| item.merge('district_id' => 398, 'distance_km' => 1) }
    search = { ranges: ranges, districts: [{ 'id' => 398 }] }
    result = WalkAreas::Selector.new(trails: Trails.new(relations))
                                .select(search: search, lat: 52.3, lon: 20.7, radius_km: 20, session_id: 's')
    assert_equal([5157, 5172], result[:areas].map { |item| item['id'] })
    assert_includes result[:areas].first[:trails].map { |item| item[:id] }, 120_876
    assert_includes result[:areas].last[:trails].map { |item| item[:id] }, 120_876
  end

  class FixtureTransport
    def initialize(body)
      @body = body
    end

    def get(_path, params:, deadline:)
      @body
    end
  end
end
