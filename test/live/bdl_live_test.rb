# frozen_string_literal: true

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
    assert_facts_for_live_area
  end

  def assert_facts_for_live_area
    range = result.fetch(:ranges).first
    district = result.fetch(:districts).first
    facts = facts_for_range(range)
    assert_facts_have_live_names(range, district, facts)
  end

  def facts_for_range(range)
    walk = { areas: [range.merge(trails: [])], trail_source: 'OpenStreetMap', attribution: 'x', attribution_url: 'x' }
    Assembler::Facts.new.build(result, walk)
  end

  def assert_facts_have_live_names(range, district, facts)
    range_name = range.dig('properties', 'forest_range_name')
    district_name = district.dig('properties', 'inspectorate_name')
    assert_live_names(range_name, district_name)
    assert_equal range_name, facts[:areas].first[:name]
    assert_equal district_name, facts[:districts].first[:name]
  end

  def assert_live_name(name)
    refute_nil name
    refute_empty name.to_s.strip
  end

  def assert_live_names(range_name, district_name)
    assert_live_name(range_name)
    assert_live_name(district_name)
  end

  def test_m3_stands_carry_attribute_keys_and_counts_match_the_returned_stands
    assert_stand_contract
  end

  def assert_stand_contract
    stands = result.fetch(:stands)
    assert_operator stands.size, :>=, 1
    assert_stand_keys(stands)
    assert_stand_counts(stands)
  end

  def assert_stand_counts(stands)
    assert_equal stands.size, result.fetch(:box_stand_count)
    assert_equal stands.count { |item| item['in_radius'] }, result.fetch(:radius_stand_count)
    assert_equal stands.count { |item| item['missing_identifier'] }, result.fetch(:missing_identifier_count)
  end

  def assert_stand_keys(stands)
    %w[species_cd site_type spec_age sub_area].each { |key| assert_includes stands.first.keys, key }
  end
end
