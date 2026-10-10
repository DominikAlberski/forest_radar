# frozen_string_literal: true

require_relative '../../test_helper'
require 'app'

class CardCollectionTest < Minitest::Test
  class WaitingQueue
    def initialize(wait)
      @wait = wait
    end

    def run
      @wait.call
      yield
    end
  end

  class Model
    attr_reader :requests

    def initialize
      @requests = []
    end

    def generate(lines, deadline:)
      @requests << [lines.values.join("\n"), deadline]
      "  Odpowiedź #{@requests.size}\n"
    end
  end

  def ranges
    [range(2, 'Dębowy', 2), range(1, 'Sosnowy', 1)]
  end

  def range(identifier, name, distance)
    { 'id' => identifier, 'distance_km' => distance, 'district_id' => identifier,
      'properties' => { 'name' => name }, 'geometry' => GEOMETRY }
  end

  GEOMETRY = { 'type' => 'Polygon', 'coordinates' => [[[21, 52], [22, 52], [22, 53], [21, 52]]] }.freeze

  def search
    { ranges: ranges, districts: [], stands: stands,
      box_stand_count: 2, radius_stand_count: 2, missing_identifier_count: 0 }
  end

  def stands
    [{ 'range_id' => 1, 'in_radius' => true, 'species_cd' => 'SO', 'sub_area' => 1.5 },
     { 'range_id' => 2, 'in_radius' => true, 'species_cd' => 'DB', 'sub_area' => 7.0 }]
  end

  def setup
    @model = Model.new
    @collection = Card::Collection.new(model: @model, clock: -> { 100 })
  end

  def test_one_response_and_map_link_per_forest
    cards = @collection.build(search, { lat: 52, lon: 21 })
    assert_equal(%w[Sosnowy Dębowy], cards.map { |card| card[:name] })
    assert_equal(["  Odpowiedź 1\n", "  Odpowiedź 2\n"], cards.map { |card| card[:advice] })
    assert_equal([%w[Sosnowy], %w[Dębowy]], cards.map { |card| card[:forests].map { |forest| forest[:name] } })
    assert_separate_inputs
  end

  def assert_separate_inputs
    first, second = @model.requests.map(&:first)
    assert_forest_input(first, 'Sosnowy', 'Dębowy', 'SO')
    assert_forest_input(second, 'Dębowy', 'Sosnowy', 'DB')
    assert_equal [189, 189], @model.requests.map(&:last)
    refute_includes first, 'species.DB'
  end

  def assert_forest_input(input, name, other_name, species)
    assert_includes input, "name=#{name}"
    refute_includes input, "name=#{other_name}"
    assert_includes input, "species.#{species}=1"
  end

  def test_no_forests_does_not_call_the_model
    assert_empty @collection.build(search.merge(ranges: []), { lat: 52, lon: 21 })
    assert_empty @model.requests
  end

  def test_timeout_starts_after_waiting_for_the_queue
    delayed_collection.build(search, { lat: 52, lon: 21 })
    assert_equal [289, 289], @model.requests.map(&:last)
  end

  def delayed_collection
    @now = 100
    queue = WaitingQueue.new(-> { @now = 200 })
    Card::Collection.new(model: @model, clock: -> { @now }, queue: queue)
  end
end
