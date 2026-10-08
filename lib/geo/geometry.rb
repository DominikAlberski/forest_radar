module Geo
  module Geometry
    EARTH_KM = 6371.0088
    module_function

    def bbox(lat, lon, radius_km)
      delta_lat = radius_km.fdiv(EARTH_KM) * 180 / Math::PI
      delta_lon = delta_lat / Math.cos(lat * Math::PI / 180)
      [lon - delta_lon, lat - delta_lat, lon + delta_lon, lat + delta_lat]
    end

    def project(point, origin)
      lat, lon = origin
      scale = Math::PI * EARTH_KM / 180
      [(point[0] - lon) * Math.cos(lat * Math::PI / 180) * scale,
       (point[1] - lat) * scale]
    end

    def polygons(geometry)
      return [] unless geometry
      raise ArgumentError, 'invalid geometry' unless geometry.is_a?(Hash)
      raise ArgumentError, 'invalid coordinates' unless geometry['coordinates'].is_a?(Array)
      case geometry['type']
      when 'Polygon' then [geometry.fetch('coordinates')]
      when 'MultiPolygon' then geometry.fetch('coordinates')
      else raise ArgumentError, 'unsupported geometry'
      end
    end

    def inside_ring?(point, ring)
      return true if ring.each_cons(2).any? { |a, b| on_segment?(point, a, b) }
      ring.each_cons(2).count do |a, b|
        (a[1] > point[1]) != (b[1] > point[1]) &&
          point[0] < (b[0] - a[0]) * (point[1] - a[1]) / (b[1] - a[1]) + a[0]
      end.odd?
    end

    def on_segment?(point, a, b)
      cross = (point[0] - a[0]) * (b[1] - a[1]) - (point[1] - a[1]) * (b[0] - a[0])
      cross.abs < 1e-10 && point[0].between?(*[a[0], b[0]].minmax) &&
        point[1].between?(*[a[1], b[1]].minmax)
    end

    def contains?(geometry, point)
      polygons(geometry).any? do |rings|
        boundary = rings.any? { |ring| ring.each_cons(2).any? { |a, b| on_segment?(point, a, b) } }
        boundary || (inside_ring?(point, rings.first) && rings.drop(1).none? { |ring| inside_ring?(point, ring) })
      end
    end

    def segment_distance(point, a, b)
      dx, dy = b[0] - a[0], b[1] - a[1]
      t = dx.zero? && dy.zero? ? 0 : ((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / (dx * dx + dy * dy)
      t = [[t, 0].max, 1].min
      Math.hypot(point[0] - a[0] - t * dx, point[1] - a[1] - t * dy)
    end

    def distance(geometry, lat, lon)
      point = [lon, lat]
      return 0.0 if contains?(geometry, point)
      polygons(geometry).flat_map do |rings|
        rings.flat_map do |ring|
          ring.each_cons(2).map { |a, b| segment_distance([0, 0], project(a, [lat, lon]), project(b, [lat, lon])) }
        end
      end.min || Float::INFINITY
    end

    def intersects_circle?(geometry, lat, lon, radius_km)
      distance(geometry, lat, lon) <= radius_km
    end

    def intersects?(left, right)
      polygons(left).any? do |a|
        polygons(right).any? do |b|
          a.first.any? { |point| contains?(right, point) } ||
            b.first.any? { |point| contains?(left, point) } ||
            a.any? { |ring| b.any? { |other| edges_cross?(ring, other) } }
        end
      end
    end

    def edges_cross?(a, b)
      a.each_cons(2).any? { |x, y| b.each_cons(2).any? { |u, v| crossing?(x, y, u, v) } }
    end

    def crossing?(a, b, c, d)
      return on_segment?(c, a, b) || on_segment?(d, a, b) ||
             on_segment?(a, c, d) || on_segment?(b, c, d) if side(a, b, c).zero? && side(a, b, d).zero?
      side(a, b, c) * side(a, b, d) <= 0 && side(c, d, a) * side(c, d, b) <= 0
    end

    def side(a, b, p)
      (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0])
    end
  end
end
