require_relative '../test_helper'
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

  def test_m2_search_names_region_and_district_for_the_point
    assert_operator result.fetch(:districts).size, :>=, 1
    assert_operator result.fetch(:ranges).size, :>=, 1
  end

  def test_m2_card_facts_carry_the_live_range_and_district_names
    range = result.fetch(:ranges).first.merge(trails: [], ban: { status: :unknown })
    walk = { areas: [range], trail_source: 'OpenStreetMap', attribution: 'x', attribution_url: 'x' }
    facts = Assembler::Facts.new.build(result, walk)
    refute_equal 'brak danych', facts[:areas].first[:name], 'range name is not read from the live property'
    refute_equal 'brak danych', facts[:districts].first[:name], 'district name is not read from the live property'
  end

  def test_m3_search_returns_stands_with_the_attribute_keys
    stands = result.fetch(:stands)
    assert_operator stands.size, :>=, 1
    assert_equal result.fetch(:box_stand_count), result.fetch(:box_stand_count).to_i
    assert_includes stands.first.keys, 'species_cd'
    assert_includes stands.first.keys, 'site_type'
    assert_includes stands.first.keys, 'spec_age'
    assert_includes stands.first.keys, 'sub_area'
  end

  def test_m4_ban_layer_answers_with_a_known_status_for_a_live_district
    district = result.fetch(:districts).first
    answer = WMS::BanClient.new.sample(district, session_id: 'live-contract')
    assert_includes %i[ban no_known_ban], answer.fetch(:status), "ban layer answer: #{answer.inspect}"
  end
end
