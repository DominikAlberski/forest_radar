require_relative '../../test_helper'
require 'assembler/facts'
require 'json'

class FactsTest < Minitest::Test
  def test_summarizes_stands_for_displayed_range
    stands = JSON.parse(File.read(File.expand_path('../../fixtures/model/linked-stands.json', __dir__)))
    search = { stands: stands, districts: [], box_stand_count: 3,
               radius_stand_count: 2, missing_identifier_count: 0 }
    walk = { areas: [{ 'id' => 1, 'distance_km' => 1.2, trails: [{ id: 8 }],
                       ban: { status: :no_known_ban }, 'properties' => {} }],
             trail_source: 'OpenStreetMap', attribution: 'OSM', attribution_url: 'https://example.org' }
    facts = Assembler::Facts.new.build(search, walk)
    assert_equal 1, facts[:areas].first[:stand_count]
    assert_equal({ 'SO' => 1 }, facts[:areas].first[:species])
    assert_equal({ 2024 => 1 }, facts[:areas].first[:years])
    assert_equal 3, facts[:box_stand_count]
    assert Assembler::Facts.new.lines(facts).values.any? { |value| value.include?('distance_km=1.2') }
  end

  def test_uses_live_range_and_district_names
    search = { stands: [], districts: [{ 'id' => 2, 'properties' => { 'inspectorate_name' => 'Jabłonna' } }],
               box_stand_count: 0, radius_stand_count: 0, missing_identifier_count: 0 }
    walk = { areas: [{ 'id' => 1, 'distance_km' => 1, 'properties' => { 'forest_range_name' => 'Bagno' },
                       trails: [], ban: { status: :unknown } }], trail_source: 'OpenStreetMap',
             attribution: 'OSM', attribution_url: 'https://example.org' }
    facts = Assembler::Facts.new.build(search, walk)
    assert_equal 'Bagno', facts[:areas].first[:name]
    assert_equal 'Jabłonna', facts[:districts].first[:name]
  end
end
