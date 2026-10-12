# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'client_search_support'

class ClientSearchCoverageTest < Minitest::Test
  include ClientSearchSupport

  # R12
  def test_successful_search_with_two_intersecting_regions_and_one_containing_region
    fake = Fake.new(success_pages)
    result = BDL::Client.new(transport: fake).search(lat: LAT, lon: LON, radius_km: 5)
    assert_search_result(result, fake)
  end

  def assert_search_result(result, fake)
    assert_paths(fake)
    assert_counts(result)
    assert_stands(result)
    assert_ranges(result)
  end

  def success_pages
    pages = base_pages
    pages[collection('rdlp')] = page(success_regions)
    pages.merge(success_stand_pages)
  end

  def success_regions
    [feature(1, { 'region_cd' => '17' }, square(20.9, 51.9, 21.03, 52.1)),
     feature(4, { 'region_cd' => '06' }, square(21.03, 51.9, 21.2, 52.1))]
  end

  def success_stand_pages
    near = square(20.999, 51.999, 21.001, 52.001)
    far = square(21.06, 52.04, 21.065, 52.044) # Inside the box, about 6 km away.
    { collection('RDLP_Warszawa_wydzielenia') => warsaw_page(near),
      collection('RDLP_Lodz_wydzielenia') => lodz_page(far) }
  end

  def warsaw_page(geometry)
    page([feature(10, { 'a_i_num' => 111, 'adr_for' => '17-02-1-05-1', 'species_cd' => 'SO' }, geometry)])
  end

  def lodz_page(geometry)
    page([feature(11, { 'a_i_num' => 222, 'adr_for' => '17-02-1-05-2', 'species_cd' => nil }, geometry)])
  end

  def assert_paths(fake)
    expected = %w[rdlp nadlesnictwa lesnictwa RDLP_Warszawa_wydzielenia RDLP_Lodz_wydzielenia]
               .map { |name| collection(name) }
    assert_equal expected.sort, fake.paths.sort
  end

  def assert_counts(result)
    assert_equal 2, result[:box_stand_count]
    assert_equal 1, result[:radius_stand_count]
    assert_equal 0, result[:missing_identifier_count]
  end

  def assert_stands(result)
    assert_equal([111, 222], result[:stands].map { |item| item['a_i_num'] })
    assert_equal([true, false], result[:stands].map { |item| item['in_radius'] })
    assert_stand_links(result)
    assert_stand_fields(result)
  end

  def assert_stand_links(result)
    assert_equal([2, 2], result[:stands].map { |item| item['district_id'] })
    assert_equal([3, 3], result[:stands].map { |item| item['range_id'] })
  end

  def assert_stand_fields(result)
    assert_nil result[:stands].last['species_cd']
    assert(result[:stands].none? { |item| item.key?('geometry') })
  end

  def assert_ranges(result)
    assert_equal([3], result[:ranges].map { |item| item['id'] })
    assert_equal 2, result[:ranges].first['district_id']
    assert_equal 0.0, result[:ranges].first['distance_km']
  end

  def test_search_uses_one_shared_feature_limit
    pages = base_pages
    pages[collection('RDLP_Warszawa_wydzielenia')] = page(stand_batch(99_998))
    assert_raises(BDL::Incomplete) { search(pages) }
  end

  def stand_batch(count)
    Array.new(count) { |identifier| feature(identifier, { 'a_i_num' => identifier }, stand_geometry) }
  end

  def stand_geometry
    square(20.99, 51.99, 21.01, 52.01)
  end

  def test_search_detects_limit_overflow_across_collections
    assert_raises(BDL::Incomplete) { search(overflow_pages) }
  end

  def overflow_pages
    pages = base_pages
    pages[collection('rdlp')] = page(overflow_regions)
    pages[collection('RDLP_Warszawa_wydzielenia')] = page(stand_batch(99_996))
    pages[collection('RDLP_Lodz_wydzielenia')] = page([feature(999_999, { 'a_i_num' => 999_999 }, stand_geometry)])
    pages
  end

  def overflow_regions
    region = square(20.5, 51.5, 21.5, 52.5)
    [feature(1, { 'region_cd' => '17' }, region), feature(4, { 'region_cd' => '06' }, region)]
  end
end
