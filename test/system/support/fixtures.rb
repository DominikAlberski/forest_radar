# frozen_string_literal: true

# Deterministic service fixtures for the browser checks.
#
# FIXTURE EVIDENCE IS LABELED. The recorded S2 Overpass responses and the recorded BDL responses
# (test/fixtures/osm, test/fixtures/ogc) hold fewer than three qualifying walk areas for one point,
# so the geometry below is SYNTHETIC. Area names start with "SYNTHETIC". No fixture speaks for a
# live source. Live source checks live in test/live.
require 'json'
$LOAD_PATH.unshift(File.expand_path('../../../lib', __dir__))
require 'app'

module SystemFixtures
  LAT = 0.005
  LON = 0.005

  def self.square(x)
    { 'type' => 'Polygon', 'coordinates' => [[[x, 0], [x + 0.01, 0], [x + 0.01, 0.01], [x, 0.01], [x, 0]]] }
  end

  def self.stand(range, attrs = {})
    { 'range_id' => range, 'in_radius' => true, 'district_id' => 1, 'species_cd' => 'SO', 'site_type' => 'BMśw',
      'spec_age' => 70, 'a_year' => 2024, 'sub_area' => 1.5 }.merge(attrs)
  end

  def self.range(identifier, x, distance, name)
    { 'id' => identifier, 'geometry' => square(x), 'district_id' => 1, 'distance_km' => distance,
      'properties' => { 'name' => name } }
  end

  def self.search(count: 4, stands: nil)
    ranges = (1..count).map { |i| range(i, 0.01 * i, i.to_f, "SYNTHETIC las #{i}") }
    { ranges: ranges,
      districts: [{ 'id' => 1, 'properties' => { 'name' => 'SYNTHETIC nadleśnictwo', 'adress_forest' => 'x' } }],
      stands: stands || ranges.map { |r| stand(r['id']) }, box_stand_count: count, radius_stand_count: count,
      missing_identifier_count: 0 }
  end

  def self.trail(x)
    { id: x, name: "SYNTHETIC szlak #{x}", ref: 'T', route: 'hiking', ways: [[[x - 0.001, 0.005], [x + 0.011, 0.005]]] }
  end

  class Search
    attr_reader :requests

    def initialize(data = nil, error: nil)
      @data = data
      @error = error
      @requests = []
    end

    def search(**args)
      @requests << args
      raise @error if @error

      @data
    end
  end

  class Trails
    def initialize(relations)
      @relations = relations
    end

    def relations(bbox:, deadline:)
      @bbox = bbox
      @deadline = deadline
      @relations
    end
  end

  # Returns a prepared walk result, to show evidence that the real selector would exclude.
  class Walk
    def initialize(areas)
      @areas = areas
    end

    def select(search:, area:, deadline:)
      raise ArgumentError, 'search data is required' unless search
      raise ArgumentError, 'area and deadline are required' unless area && deadline

      { areas: @areas.map { |area| area.merge('distance_km' => area['distance_km']) }, excluded: [],
        trail_source: 'OpenStreetMap', attribution: OSM::Client::ATTRIBUTION,
        attribution_url: OSM::Client::COPYRIGHT_URL }
    end
  end

  class Model
    def initialize(text = 'Sprawdź szlak przed wyjściem.', error: nil)
      @text = text
      @error = error
    end

    def generate(*, **)
      raise @error if @error

      @text
    end
  end

  def self.real_selector(count)
    ::WalkAreas::Selector.new(trails: Trails.new((1..count).map { |i| trail(0.01 * i) }))
  end

  def self.apply(search:, selector:, model: Model.new)
    app = ForestRadar::App
    app.set :search_cache, ::Cache::SearchCache.new
    app.set :search_client, search
    app.set :selector, selector
    app.set :model_client, model
  end
end
