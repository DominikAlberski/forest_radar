# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'
require_relative 'result_builder_support'

class ResultBuilderTest < Minitest::Test
  include ResultBuilderSupport

  def test_duplicate_a_i_num_in_one_collection_counts_once
    result = build([stand('a_i_num' => 7, 'adr_for' => 'x'), stand('a_i_num' => 7, 'adr_for' => 'y')])
    assert_equal 1, result[:stands].length
    assert_equal 1, result[:box_stand_count]
  end

  def test_missing_identifier_digest_ignores_property_key_order
    left = stand('species_cd' => 'SO', 'site_type' => 'BM')
    right = stand('site_type' => 'BM', 'species_cd' => 'SO')
    assert_equal 1, build([left, right])[:stands].length
  end

  def test_missing_identifier_digest_ignores_top_level_id
    left = stand('species_cd' => 'SO')
    right = left.merge('id' => 999)
    left['id'] = 1
    assert_equal 1, build([left, right])[:stands].length
  end

  def test_same_a_i_num_in_two_collections_is_kept
    pairs = [[COLLECTION, stand('a_i_num' => 7)], ['RDLP_Lodz_wydzielenia', stand('a_i_num' => 7)]]
    input = BDL::BuildInput.new(regions: [], districts: [], ranges: [], stands: pairs)
    result = BDL::ResultBuilder.new.build(0, 0, 1, input)
    assert_equal 2, result[:stands].length
  end

  def test_falls_back_to_adr_for_when_a_i_num_is_missing
    result = build([stand('adr_for' => '17-02-1-05-1'), stand('adr_for' => '17-02-1-05-1'),
                    stand('adr_for' => '17-02-1-05-2')])
    assert_equal 2, result[:stands].length
    assert_equal 0, result[:missing_identifier_count]
    refute result[:stands].first['missing_identifier']
  end

  def test_missing_identifiers_are_kept_and_counted
    result = build([stand('species_cd' => 'SO'), stand('species_cd' => 'BK')])
    assert_equal 2, result[:stands].length
    assert_equal 2, result[:missing_identifier_count]
    assert(result[:stands].all? { |item| item['missing_identifier'] })
  end

  def test_null_attributes_stay_nil
    result = build([stand('a_i_num' => 1, 'species_cd' => nil, 'spec_age' => nil, 'sub_area' => nil)])
    item = result[:stands].first
    assert_nil item['species_cd']
    assert_nil item['spec_age']
    assert_nil item['sub_area']
  end

  def test_stand_without_geometry_is_incomplete
    assert_raises(BDL::Incomplete) { build([stand({ 'a_i_num' => 1 }, nil)]) }
  end

  def test_empty_input
    result = build([])
    assert_equal 0, result[:box_stand_count]
    assert_equal 0, result[:radius_stand_count]
    assert_equal 0, result[:missing_identifier_count]
  end

  def test_in_radius_flag_follows_distance
    far = square(0.1, -0.01, 0.2, 0.01) # western edge 0.1 degree east, about 11.12 km
    assert_inside_radius(far)
    assert_outside_radius(far)
  end

  def assert_inside_radius(far)
    result = build([stand({ 'a_i_num' => 1 }, far)], radius: 12)
    assert result[:stands].first['in_radius']
    assert_equal 1, result[:radius_stand_count]
  end

  def assert_outside_radius(far)
    result = build([stand({ 'a_i_num' => 1 }, far)], radius: 10)
    refute result[:stands].first['in_radius']
    assert_equal 1, result[:box_stand_count]
    assert_equal 0, result[:radius_stand_count]
  end

  def test_stand_containing_the_point_is_in_radius
    result = build([stand({ 'a_i_num' => 1 }, square(-1, -1, 1, 1))], radius: 0.1)
    assert result[:stands].first['in_radius']
  end
end
