# frozen_string_literal: true

require_relative '../geo/geometry'

module BDL
  # Validates polygon coordinates before a BDL search uses them.
  module GeometryValidation
    module_function

    def validate(items)
      raise Incomplete, 'malformed geometry' unless items.all? { |item| valid_feature?(item) }
    end

    def valid_feature?(feature)
      valid_feature_geometry?(feature)
    rescue ArgumentError, KeyError, TypeError
      false
    end

    def valid_feature_geometry?(feature)
      return false unless valid_header?(feature)

      geometry = feature['geometry']
      geometry.is_a?(Hash) && valid_polygons?(Geo::Geometry.polygons(geometry))
    end

    def valid_header?(feature)
      feature.is_a?(Hash) && feature['properties'].is_a?(Hash)
    end

    def valid_polygons?(polygons)
      polygons.is_a?(Array) && polygons.any? && polygons.all? { |rings| valid_rings?(rings) }
    end

    def valid_rings?(rings)
      rings.is_a?(Array) && rings.any? && rings.all? { |ring| valid_ring?(ring) }
    end

    def valid_ring?(ring)
      ring.is_a?(Array) && ring.length >= 4 && ring.first == ring.last && ring.all? { |point| valid_point?(point) }
    end

    def valid_point?(point)
      point.is_a?(Array) && point.length >= 2 && point.first(2).all?(Numeric)
    end
  end
end
