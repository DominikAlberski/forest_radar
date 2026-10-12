# frozen_string_literal: true

require_relative '../../test_helper'
require 'app'

class TrailEvidenceTest < Minitest::Test
  class CapturingModel
    def initialize(captured)
      @captured = captured
    end

    def generate(lines, **)
      @captured << lines.values.join("\n")
      'Opis'
    end
  end

  def trail
    { id: 10, name: 'Szlak sosnowy', ref: 'S', route: 'hiking', ways: [[[21, 52], [22, 53]]] }
  end

  def walk
    { evidence: [{ 'id' => 1, trails: [trail] },
                 { 'id' => 2, trails: [], exclusion_reason: :no_mapped_trail },
                 { 'id' => 3, trails: [], exclusion_reason: :trail_unavailable }] }
  end

  def test_trail_evidence_belongs_to_the_matching_forest
    result = Card::TrailEvidence.new(walk).for({ 'id' => 1 })
    assert_equal 'mapped_crossing', result[:status]
    assert_equal [trail.except(:ways)], result[:trails]
    assert_equal 'OpenStreetMap / Overpass', result[:source]
  end

  def test_empty_unavailable_and_unchecked_evidence_have_distinct_statuses
    evidence = Card::TrailEvidence.new(walk)
    assert_equal 'no_mapped_trail', evidence.for({ 'id' => 2 })[:status]
    assert_equal 'trail_unavailable', evidence.for({ 'id' => 3 })[:status]
    assert_equal 'not_checked', evidence.for({ 'id' => 4 })[:status]
    assert_empty evidence.for({ 'id' => 2 })[:trails]
  end

  def test_collection_sends_only_each_forests_trails_to_the_model
    captured = []
    collection = Card::Collection.new(model: CapturingModel.new(captured), clock: -> { 100 })
    cards = collection.build(search, { lat: 52, lon: 21 }, walk: walk)
    assert_model_inputs(captured)
    assert_equal(%w[mapped_crossing no_mapped_trail], cards.map { |card| card[:walking][:status] })
  end

  def assert_model_inputs(captured)
    assert_includes captured.first, 'walking.trails[0].name=Szlak sosnowy'
    refute_includes captured.last, 'Szlak sosnowy'
    assert_includes captured.last, 'walking.status=no_mapped_trail'
  end

  def search
    { ranges: [range(1), range(2)], stands: [], districts: [],
      box_stand_count: 0, radius_stand_count: 0, missing_identifier_count: 0 }
  end

  def range(identifier)
    { 'id' => identifier, 'distance_km' => identifier, 'properties' => { 'name' => "Las #{identifier}" } }
  end
end
