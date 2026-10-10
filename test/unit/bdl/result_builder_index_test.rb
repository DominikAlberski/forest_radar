# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'result_builder_support'

# Tests candidate selection and spatial filtering.
class ResultBuilderIndexTest < Minitest::Test
  include ResultBuilderSupport

  def test_short_prefix_candidate_matches
    result = build([stand({ 'adr_for' => '17-02-1' })], districts: [feature(1, '17', square(0, 0, 1, 1))])
    assert_equal 1, result[:stands].first['district_id']
  end

  def test_missing_address_candidate_matches_empty_source_address
    result = build([stand({ 'a_i_num' => 1 })], districts: [feature(2, nil, square(0, 0, 1, 1))])
    assert_equal 2, result[:stands].first['district_id']
  end

  def test_disjoint_box_does_not_intersect
    result = build([stand({ 'adr_for' => '17-02' })], districts: [feature(3, '17-02', square(2, 2, 3, 3))])
    assert_nil result[:stands].first['district_id']
  end

  def test_candidate_without_geometry_does_not_match
    result = build([stand({ 'adr_for' => '17-02' })], districts: [feature(3, '17-02', nil)])
    assert_nil result[:stands].first['district_id']
  end

  def test_candidate_with_one_point_ring_does_not_match
    geometry = { 'type' => 'Polygon', 'coordinates' => [[[0, 0]]] }
    result = build([stand({ 'adr_for' => '17-02' })], districts: [feature(3, '17-02', geometry)])
    assert_nil result[:stands].first['district_id']
  end

  def test_ambiguous_candidates_keep_original_order
    geometry = square(0, 0, 1, 1)
    districts = [feature(3, '17-02', geometry), feature(9, nil, geometry)]
    error = assert_raises(BDL::Incomplete) { build([stand({ 'adr_for' => '17-02' })], districts: districts) }
    assert_equal 'ambiguous stand district for : 3, 9', error.message
  end
end
