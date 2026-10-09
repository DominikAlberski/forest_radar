require_relative '../test_helper'
require 'json'
require 'bdl/client'
require 'wms/ban_client'
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
    walk = { areas: [range.merge(trails: [], ban: { status: :unknown })], trail_source: 'OpenStreetMap',
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

  # The live ban source returns HTTP 400 today (task fb7a8d81). The client maps that failure to
  # "unknown". This test accepts "unknown" and records it as source-failure evidence.
  # An "unknown" answer is NOT a pass of a known ban status (see docs/plans/m1-m7-evidence.md, L2).
  def test_m4_ban_layer_answer_is_recorded_and_never_invented
    district = result.fetch(:districts).first
    answer = WMS::BanClient.new.sample(district, session_id: 'live-contract')
    status = answer.fetch(:status)
    assert_includes %i[ban no_known_ban unknown], status, "ban layer answer: #{answer.inspect}"
    verdict = status == :unknown ? 'SOURCE-UNAVAILABLE (known ban status NOT proven)' : 'KNOWN-STATUS'
    puts "EVIDENCE #{JSON.generate(check: 'm4_ban', verdict: verdict, status: status, point: answer[:point])}"
  end
end
