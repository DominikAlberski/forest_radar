# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'result_builder_support'

class ResultBuilderLinksTest < Minitest::Test
  include ResultBuilderSupport

  def test_links_stand_to_range_and_district_by_prefix_and_geometry
    result = linked_result
    assert_equal 3, result[:stands].first['district_id']
    assert_equal 13, result[:stands].first['range_id']
  end

  def linked_result
    here = square(0, 0, 0.02, 0.02)
    elsewhere = square(5, 5, 6, 6)
    build([stand({ 'a_i_num' => 1, 'adr_for' => '17-02-1-05-123' })],
          districts: linked_districts(here, elsewhere), ranges: linked_ranges(here, elsewhere))
  end

  def linked_districts(here, elsewhere)
    [feature(1, '17-03- -', here), feature(2, '17-02- -', elsewhere), feature(3, '17-02- -', here)]
  end

  def linked_ranges(here, elsewhere)
    [feature(11, '17-02-1-06-', here), feature(12, '17-02-1-05-', elsewhere), feature(13, '17-02-1-05-', here)]
  end

  def test_stand_without_matching_range_has_nil_links
    result = unlinked_result
    assert_nil result[:stands].first['district_id']
    assert_nil result[:stands].first['range_id']
  end

  def unlinked_result
    here = square(0, 0, 0.02, 0.02)
    build([stand({ 'a_i_num' => 1, 'adr_for' => '99-99-1-05-1' })],
          districts: [feature(1, '17-02- -', here)], ranges: [feature(2, '17-02-1-05-', here)])
  end

  def test_range_links_district_and_reports_distance
    range = range_result[:ranges].first
    assert_equal 2, range['district_id']
    assert_in_delta 11.12, range['distance_km'], 0.02
  end

  def range_result
    here = square(0.1, -0.01, 0.2, 0.01)
    districts = [feature(1, '17-03- -', here), feature(2, '17-02- -', here)]
    build([], districts: districts, ranges: [feature(5, '17-02-1-05-', here)])
  end

  # B1-R8
  def test_ambiguous_stand_district_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    districts = [feature(21, '17-02- -', here), feature(23, '17-02- -', here)]
    assert_ambiguous('21', '23') { build([stand(known_address)], districts: districts) }
  end

  # B1-R8
  def test_ambiguous_stand_range_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    ranges = [feature(31, '17-02-1-05-', here), feature(33, '17-02-1-05-', here)]
    assert_ambiguous('31', '33') { build([stand(known_address)], ranges: ranges) }
  end

  # B1-R8
  def test_ambiguous_range_district_names_the_candidates
    here = square(0, 0, 0.02, 0.02)
    districts = [feature(41, '17-02- -', here), feature(43, '17-02- -', here)]
    assert_ambiguous('41', '43') { build([], districts: districts, ranges: [feature(5, '17-02-1-05-', here)]) }
  end

  def known_address
    { 'a_i_num' => 1, 'adr_for' => '17-02-1-05-1' }
  end

  def assert_ambiguous(first, second, &)
    error = assert_raises(BDL::Incomplete, &)
    assert_includes error.message, first
    assert_includes error.message, second
  end

  # B1-R1 effect: disjoint collinear neighbours with one prefix are not ambiguous.
  def test_disjoint_collinear_districts_with_one_prefix_are_not_ambiguous
    result = build([stand(known_address, square(0.005, 0, 0.015, 0.01))], districts: disjoint_districts)
    assert_equal 1, result[:stands].first['district_id']
  end

  def disjoint_districts
    [feature(1, '17-02- -', square(0, 0, 0.02, 0.02)),
     feature(2, '17-02- -', square(0.04, 0, 0.06, 0.02))]
  end
end
