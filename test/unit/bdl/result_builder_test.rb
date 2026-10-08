require_relative '../../test_helper'
require 'bdl/client'

class ResultBuilderTest < Minitest::Test
  COLLECTION = 'RDLP_Warszawa_wydzielenia'

  def square(x0, y0, x1, y1)
    { 'type' => 'Polygon', 'coordinates' => [[[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]]] }
  end

  def feature(id, address, geometry)
    { 'id' => id, 'type' => 'Feature', 'geometry' => geometry, 'properties' => { 'adress_forest' => address } }
  end

  def stand(properties, geometry = square(0, 0, 0.01, 0.01))
    { 'type' => 'Feature', 'geometry' => geometry, 'properties' => properties }
  end

  def build(stands, districts: [], ranges: [], lat: 0, lon: 0, radius: 1)
    BDL::ResultBuilder.new.build(lat, lon, radius, [], districts, ranges, stands.map { |item| [COLLECTION, item] })
  end

  def test_duplicate_a_i_num_in_one_collection_counts_once
    result = build([stand('a_i_num' => 7, 'adr_for' => 'x'), stand('a_i_num' => 7, 'adr_for' => 'y')])
    assert_equal 1, result[:stands].length
    assert_equal 1, result[:box_stand_count]
  end

  def test_same_a_i_num_in_two_collections_is_kept
    pairs = [[COLLECTION, stand('a_i_num' => 7)], ['RDLP_Lodz_wydzielenia', stand('a_i_num' => 7)]]
    result = BDL::ResultBuilder.new.build(0, 0, 1, [], [], [], pairs)
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
    assert result[:stands].all? { |item| item['missing_identifier'] }
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
    result = build([stand({ 'a_i_num' => 1 }, far)], radius: 12)
    assert result[:stands].first['in_radius']
    assert_equal 1, result[:radius_stand_count]
    result = build([stand({ 'a_i_num' => 1 }, far)], radius: 10)
    refute result[:stands].first['in_radius']
    assert_equal 1, result[:box_stand_count]
    assert_equal 0, result[:radius_stand_count]
  end

  def test_stand_containing_the_point_is_in_radius
    result = build([stand({ 'a_i_num' => 1 }, square(-1, -1, 1, 1))], radius: 0.1)
    assert result[:stands].first['in_radius']
  end

  def test_links_stand_to_range_and_district_by_prefix_and_geometry
    here = square(0, 0, 0.02, 0.02)
    elsewhere = square(5, 5, 6, 6)
    districts = [feature(1, '17-03- -', here), feature(2, '17-02- -', elsewhere), feature(3, '17-02- -', here)]
    ranges = [feature(11, '17-02-1-06-', here), feature(12, '17-02-1-05-', elsewhere), feature(13, '17-02-1-05-', here)]
    result = build([stand({ 'a_i_num' => 1, 'adr_for' => '17-02-1-05-123' })], districts: districts, ranges: ranges)
    assert_equal 3, result[:stands].first['district_id']
    assert_equal 13, result[:stands].first['range_id']
  end

  def test_stand_without_matching_range_has_nil_links
    here = square(0, 0, 0.02, 0.02)
    result = build([stand({ 'a_i_num' => 1, 'adr_for' => '99-99-1-05-1' })],
                   districts: [feature(1, '17-02- -', here)], ranges: [feature(2, '17-02-1-05-', here)])
    assert_nil result[:stands].first['district_id']
    assert_nil result[:stands].first['range_id']
  end

  def test_range_links_district_and_reports_distance
    here = square(0.1, -0.01, 0.2, 0.01)
    districts = [feature(1, '17-03- -', here), feature(2, '17-02- -', here)]
    result = build([], districts: districts, ranges: [feature(5, '17-02-1-05-', here)])
    range = result[:ranges].first
    assert_equal 2, range['district_id']
    assert_in_delta 11.12, range['distance_km'], 0.02
  end

  # B1-R8
  def test_ambiguous_stand_district_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    districts = [feature(21, '17-02- -', here), feature(23, '17-02- -', here)]
    error = assert_raises(BDL::Incomplete) do
      build([stand({ 'a_i_num' => 1, 'adr_for' => '17-02-1-05-1' })], districts: districts)
    end
    assert_includes error.message, '21'
    assert_includes error.message, '23'
  end

  # B1-R8
  def test_ambiguous_stand_range_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    ranges = [feature(31, '17-02-1-05-', here), feature(33, '17-02-1-05-', here)]
    error = assert_raises(BDL::Incomplete) do
      build([stand({ 'a_i_num' => 1, 'adr_for' => '17-02-1-05-1' })], ranges: ranges)
    end
    assert_includes error.message, '31'
    assert_includes error.message, '33'
  end

  # B1-R8
  def test_ambiguous_range_district_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    districts = [feature(41, '17-02- -', here), feature(43, '17-02- -', here)]
    error = assert_raises(BDL::Incomplete) do
      build([], districts: districts, ranges: [feature(5, '17-02-1-05-', here)])
    end
    assert_includes error.message, '41'
    assert_includes error.message, '43'
  end

  # B1-R1 effect: disjoint collinear neighbours with one prefix are not ambiguous.
  def test_disjoint_collinear_districts_with_one_prefix_are_not_ambiguous
    districts = [feature(1, '17-02- -', square(0, 0, 0.02, 0.02)), feature(2, '17-02- -', square(0.04, 0, 0.06, 0.02))]
    result = build([stand({ 'a_i_num' => 1, 'adr_for' => '17-02-1-05-1' }, square(0.005, 0, 0.015, 0.01))],
                   districts: districts)
    assert_equal 1, result[:stands].first['district_id']
  end
end
