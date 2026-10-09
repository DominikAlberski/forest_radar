# frozen_string_literal: true

require_relative '../geo/geometry'
require_relative '../osm/client'
require_relative 'trail_crossing'

# Selects nearby forest ranges from mapped trail evidence.
module WalkAreas
  # Holds the search center and radius for range selection.
  Area = Struct.new(:lat, :lon, :radius_km, keyword_init: true) do
    def bbox
      Geo::Geometry.bbox(lat, lon, radius_km)
    end

    def selection_arguments
      [bbox, radius_km]
    end
  end

  # Builds one candidate range from source data and mapped trails.
  Candidate = Struct.new(:range, :relations, :radius) do
    def selected
      return unless within_radius?

      paths = relations && TrailCrossing.new(range.fetch('geometry')).matching(relations)
      range.merge(trails: paths || [], exclusion_reason: exclusion(paths))
    end

    private

    def within_radius?
      range.fetch('distance_km') <= radius
    end

    def exclusion(paths)
      return :trail_unavailable unless relations

      :no_mapped_trail if paths.empty?
    end
  end
  private_constant :Candidate

  # Provides the stable ordering key for one selected range.
  AreaOrder = Struct.new(:area) do
    def key
      distance, identifier = area.values_at('distance_km', 'id')
      [distance, identifier.to_s]
    end
  end
  private_constant :AreaOrder

  # Partitions and orders candidate forest ranges for the response.
  SelectionResult = Struct.new(:selected) do
    def to_h
      eligible, excluded = selected.partition { |range| !range[:exclusion_reason] }
      areas = eligible.sort_by { |item| AreaOrder.new(item).key }.first(3)
      { areas: areas, excluded: excluded, trail_source: 'OpenStreetMap', attribution: OSM::Client::ATTRIBUTION,
        attribution_url: OSM::Client::COPYRIGHT_URL }
    end
  end
  private_constant :SelectionResult

  # Chooses nearby forest ranges crossed by mapped walking trails.
  class Selector
    def initialize(trails:)
      @trails = trails
    end

    def select(search:, area:, deadline: nil)
      box, radius = area.selection_arguments
      relations = @trails.relations(bbox: box, deadline: deadline)
      selected = search.fetch(:ranges).filter_map { |range| Candidate.new(range, relations, radius).selected }
      SelectionResult.new(selected).to_h
    end
  end
end
