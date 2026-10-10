# frozen_string_literal: true

module Geo
  # Computes containment, intersections, and distances for polygon geometry.
  module Geometry
    EARTH_KM = 6371.0088

    module_function

    def bbox(lat, lon, radius_km)
      delta_lat = radius_km.fdiv(EARTH_KM) * 180 / Math::PI
      delta_lon = delta_lat / Math.cos(lat * Math::PI / 180)
      [lon - delta_lon, lat - delta_lat, lon + delta_lon, lat + delta_lat]
    end

    def bounds(geometry) = PreparedGeometry.merge_boxes(prepare(geometry).map(&:first))

    def boxes_overlap?(first_box, second_box)
      return false unless first_box && second_box

      first_box[0] <= second_box[2] && second_box[0] <= first_box[2] &&
        first_box[1] <= second_box[3] && second_box[1] <= first_box[3]
    end

    def prepare(geometry) = PreparedGeometry.prepare(geometry)

    def prepared_intersects?(first, second) = PreparedGeometry.intersects?(first, second)

    def project(point, origin)
      lat, lon = origin
      scale = Math::PI * EARTH_KM / 180
      [(point[0] - lon) * Math.cos(lat * Math::PI / 180) * scale,
       (point[1] - lat) * scale]
    end

    def polygons(geometry)
      return [] unless geometry

      raise ArgumentError, 'invalid geometry' unless geometry.is_a?(Hash)

      geometry_polygons(geometry)
    end

    def geometry_polygons(geometry)
      coordinates = validated_coordinates(geometry)
      geometry_type = geometry['type']
      return [coordinates] if geometry_type == 'Polygon'
      return coordinates if geometry_type == 'MultiPolygon'

      raise ArgumentError, 'unsupported geometry'
    end

    def validated_coordinates(geometry)
      raise ArgumentError, 'invalid coordinates' unless geometry['coordinates'].is_a?(Array)

      geometry.fetch('coordinates')
    end

    def inside_ring?(point, ring)
      segments = ring.each_cons(2).to_a
      return true if segments.any? { |start_point, end_point| on_segment?(point, start_point, end_point) }

      segments.count { |start_point, end_point| ray_crosses?(point, start_point, end_point) }.odd?
    end

    def ray_crosses?(point, ray_start, ray_end)
      point_y = point[1]
      above_start = ray_start[1] > point_y
      above_end = ray_end[1] > point_y
      above_start != above_end && point[0] < ray_intersection_x(point, ray_start, ray_end)
    end

    def ray_intersection_x(point, line_start, line_end)
      start_x, start_y = line_start
      rise = point[1] - start_y
      run = line_end[0] - start_x
      start_x + (run * rise / (line_end[1] - start_y))
    end

    def on_segment?(point, start_point, end_point)
      side(start_point, end_point, point).abs < 1e-10 && within_bounds?(point, start_point, end_point)
    end

    def within_bounds?(point, boundary_start, boundary_end)
      point[0].between?(*[boundary_start[0], boundary_end[0]].minmax) &&
        point[1].between?(*[boundary_start[1], boundary_end[1]].minmax)
    end

    def contains?(geometry, point)
      polygons(geometry).any? { |rings| contains_rings?(rings, point) }
    end

    def contains_rings?(rings, point)
      return true if rings.any? { |ring| ring_boundary?(ring, point) }

      inside_ring?(point, rings.first) && rings.drop(1).none? { |ring| inside_ring?(point, ring) }
    end

    def ring_boundary?(ring, point)
      ring.each_cons(2).any? { |start_point, end_point| on_segment?(point, start_point, end_point) }
    end

    def distance(geometry, lat, lon)
      return 0.0 if contains?(geometry, [lon, lat])

      polygons(geometry).flat_map { |rings| ring_distances(rings, [lat, lon]) }.min || Float::INFINITY
    end

    def ring_distances(rings, origin)
      rings.flat_map { |ring| edge_distances(ring, origin) }
    end

    def edge_distances(ring, origin)
      ring.each_cons(2).map do |start_point, end_point|
        segment_distance([0, 0], project(start_point, origin), project(end_point, origin))
      end
    end

    def intersects_circle?(geometry, latitude, longitude, radius_km)
      distance(geometry, latitude, longitude) <= radius_km
    end

    def intersects?(left, right)
      polygons(left).any? { |rings| intersects_rings?(rings, right) }
    end

    def intersects_rings?(rings, other_geometry)
      polygons(other_geometry).any? { |other_rings| rings_intersect?(rings, other_rings, other_geometry) }
    end

    def rings_intersect?(rings, other_rings, other_geometry)
      rings.first.any? { |point| contains?(other_geometry, point) } ||
        other_rings.first.any? { |point| contains_rings?(rings, point) } ||
        rings.any? { |ring| crosses_any_ring?(ring, other_rings) }
    end

    def crosses_any_ring?(ring, other_rings)
      other_rings.any? { |other| edges_cross?(ring, other) }
    end

    # Stores polygon rings and edges for repeated intersection checks.
    # :reek:NestedIterators
    # :reek:DataClump
    # :reek:TooManyStatements
    module PreparedGeometry
      module_function

      def prepare(geometry)
        Geometry.polygons(geometry).map { |rings| prepare_polygon(rings) }
      end

      def prepare_polygon(rings)
        prepared = rings.map { |ring| prepare_ring(ring) }
        [merge_boxes(prepared.map(&:first)), prepared]
      end

      def prepare_ring(points)
        edges = points.each_cons(2).map { |first, last| [edge_box(first, last), first, last] }
        [merge_boxes(edges.map(&:first)), points, edges]
      end

      def edge_box(first, last)
        first_x, first_y = first
        last_x, last_y = last
        [[first_x, last_x].min, [first_y, last_y].min,
         [first_x, last_x].max, [first_y, last_y].max]
      end

      def merge_boxes(boxes)
        boxes = boxes.compact
        return nil if boxes.empty?

        columns = boxes.transpose
        [columns[0].min, columns[1].min, columns[2].max, columns[3].max]
      end

      def intersects?(first, second)
        first.any? do |left_polygon|
          second.any? { |right_polygon| polygon_intersects?(left_polygon, right_polygon) }
        end
      end

      def polygon_intersects?(first, second)
        return false unless Geometry.boxes_overlap?(first[0], second[0])

        first[1][0][1].any? { |point| contains?(second, point) } ||
          second[1][0][1].any? { |point| contains?(first, point) } || edges_intersect?(first, second)
      end

      def contains?(polygon, point)
        rings = polygon[1]
        positions = rings.map { |ring| ring_position(ring, point) }
        return true if positions.include?(:boundary)

        positions.first == :inside && positions.drop(1).none?(:inside)
      end

      def ring_position(ring, point)
        return :outside unless point_in_box?(point, ring[0])

        crossings = catch(:boundary) { ring[2].count { |edge| ray_crossing?(edge, point) } }
        return :boundary if crossings == :boundary

        crossings.odd? ? :inside : :outside
      end

      def ray_crossing?(edge, point)
        box, first, last = edge
        throw :boundary, :boundary if point_in_box?(point, box) && Geometry.on_segment?(point, first, last)

        Geometry.ray_crosses?(point, first, last)
      end

      def point_in_box?(point, box)
        return false unless box

        point[0].between?(box[0], box[2]) && point[1].between?(box[1], box[3])
      end

      def edges_intersect?(first, second)
        first[1].any? do |left_ring|
          second[1].any? { |right_ring| rings_cross?(left_ring, right_ring) }
        end
      end

      def rings_cross?(first_ring, second_ring)
        return false unless Geometry.boxes_overlap?(first_ring[0], second_ring[0])

        first_ring[2].any? { |edge| second_ring[2].any? { |other| edge_cross?(edge, other) } }
      end

      def edge_cross?(first, second)
        Geometry.boxes_overlap?(first[0], second[0]) &&
          Geometry.crossing?(first[1], first[2], second[1], second[2])
      end
    end
  end
end

require_relative 'geometry/segments'
