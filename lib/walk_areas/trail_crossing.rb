# frozen_string_literal: true

require_relative '../geo/geometry'

module WalkAreas
  # Tests trail segments against a forest range polygon.
  class TrailCrossing
    def initialize(polygon)
      rings = Geo::Geometry.polygons(polygon).flat_map(&:itself)
      @polygon = polygon
      @edges = rings.flat_map { |ring| ring.each_cons(2).to_a }
      x_values, y_values = rings.flatten(1).transpose
      @bounds = [x_values.minmax, y_values.minmax]
    end

    def matching(relations)
      relations.select { |relation| crosses?(relation) }
    end

    private

    def crosses?(relation)
      relation[:ways].any? { |way| way_crosses?(way) }
    end

    def way_crosses?(way)
      way.each_cons(2).any? { |segment| segment_crosses?(segment) }
    end

    def segment_crosses?(segment)
      return false if outside_bounds?(segment)

      start_point, end_point = segment
      Geo::Geometry.contains?(@polygon, start_point) || Geo::Geometry.contains?(@polygon, end_point) ||
        @edges.any? { |edge| Geo::Geometry.crossing?(*segment, *edge) }
    end

    def outside_bounds?(segment)
      @bounds.zip(segment.transpose).any? do |bounds, values|
        low, high = bounds
        minimum, maximum = values.minmax
        maximum < low || minimum > high
      end
    end
  end
end
