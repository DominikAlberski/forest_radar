# frozen_string_literal: true

require_relative '../../test_helper'
require 'assembler/facts'
require 'json'

class FactsTest < Minitest::Test
  def test_summarizes_stands_for_displayed_range
    facts = Assembler::Facts.new.build(linked_search, linked_walk)
    assert_summaries(facts)
    assert_fact_lines(facts)
  end

  def linked_search
    stands = JSON.parse(File.read(File.expand_path('../../fixtures/model/linked-stands.json', __dir__)))
    { stands: stands, districts: [], box_stand_count: 3, radius_stand_count: 2, missing_identifier_count: 0 }
  end

  def linked_walk
    { areas: [{ 'id' => 1, 'distance_km' => 1.2, trails: [{ id: 8 }], 'properties' => {},
                ban: { status: 'unknown' } }],
      trail_source: 'OpenStreetMap', attribution: 'OSM', attribution_url: 'https://example.org' }
  end

  def assert_summaries(facts)
    assert_equal 1, facts[:areas].first[:stand_count]
    assert_equal({ 'SO' => 1 }, facts[:areas].first[:species])
    assert_equal({ 2024 => 1 }, facts[:areas].first[:years])
    assert_equal 3, facts[:box_stand_count]
  end

  def assert_fact_lines(facts)
    assert(Assembler::Facts.new.lines(facts).values.any? { |value| value.include?('distance_km=1.2') })
    refute facts[:areas].first.key?(:ban)
    assert_no_ban_fact_line(facts)
  end

  def assert_no_ban_fact_line(facts)
    refute(Assembler::Facts.new.lines(facts).values.any? do |value|
      value.split('=').first.split(/[.\[\]]/).include?('ban')
    end)
  end

  def test_uses_live_range_and_district_names
    facts = Assembler::Facts.new.build(live_name_search, live_name_walk)
    assert_equal 'Bagno', facts[:areas].first[:name]
    assert_equal 'Jabłonna', facts[:districts].first[:name]
  end

  def test_model_input_includes_bdl_ranges_without_trail_evidence
    search = linked_search.merge(ranges: linked_walk.fetch(:areas).map { |area| area.except(:trails) })
    values = Assembler::Facts.new.model_lines(search).values
    assert_includes values, 'areas[0].stand_count=1'
    assert_includes values, 'areas[0].species.SO=1'
    refute(values.any? { |value| value.start_with?('trail_source=') })
  end

  def live_name_search
    { stands: [], districts: [{ 'id' => 2, 'properties' => { 'inspectorate_name' => 'Jabłonna' } }],
      box_stand_count: 0, radius_stand_count: 0, missing_identifier_count: 0 }
  end

  def live_name_walk
    { areas: [{ 'id' => 1, 'distance_km' => 1, 'properties' => { 'forest_range_name' => 'Bagno' },
                trails: [] }], trail_source: 'OpenStreetMap',
      attribution: 'OSM', attribution_url: 'https://example.org' }
  end
end
