require_relative '../test_helper'
require 'json'
require 'bdl/client'
require 'assembler/facts'

# Live contracts for the public BDL services. These tests need the network.
# They prove the recorded fixtures still match the live shape (M2, M3, M4).
# There is no live Overpass contract on purpose: the public Overpass API rejects automated test traffic.
class BdlLiveTest < Minitest::Test
  KAMPINOS = { lat: 52.30, lon: 20.70, radius_km: 3 }.freeze

  def self.result
    @result ||= BDL::Client.new.search(**KAMPINOS)
  end

  def result
    self.class.result
  end

  def test_m2_search_returns_the_warszawa_region_code_and_live_districts
    codes = result.fetch(:regions).map { |item| item.dig('properties', 'region_cd').to_s }
    assert_includes codes, '17', "region codes: #{codes.inspect}"
    assert_operator result.fetch(:districts).size, :>=, 1
    assert_operator result.fetch(:ranges).size, :>=, 1
  end

  def test_m2_card_facts_carry_the_live_range_and_district_names
    range = result.fetch(:ranges).first
    district = result.fetch(:districts).first
    walk = { areas: [range.merge(trails: [])], trail_source: 'OpenStreetMap',
             attribution: 'x', attribution_url: 'x' }
    facts = Assembler::Facts.new.build(result, walk)
    expected_range = range.dig('properties', 'forest_range_name')
    expected_district = district.dig('properties', 'inspectorate_name')
    refute_nil expected_range
    refute_nil expected_district
    refute_empty expected_range.to_s.strip
    refute_empty expected_district.to_s.strip
    assert_equal expected_range, facts[:areas].first[:name]
    assert_equal expected_district, facts[:districts].first[:name]
  end

  def test_m3_stands_carry_attribute_keys_and_counts_match_the_returned_stands
    stands = result.fetch(:stands)
    assert_operator stands.size, :>=, 1
    %w[species_cd site_type spec_age sub_area].each { |key| assert_includes stands.first.keys, key }
    assert_equal stands.size, result.fetch(:box_stand_count)
    assert_equal stands.count { |item| item['in_radius'] }, result.fetch(:radius_stand_count)
    assert_equal stands.count { |item| item['missing_identifier'] }, result.fetch(:missing_identifier_count)
  end

end
