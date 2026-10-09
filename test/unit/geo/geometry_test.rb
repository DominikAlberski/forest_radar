# frozen_string_literal: true

require_relative '../../test_helper'
require 'geo/geometry'

class GeometryTest < Minitest::Test
  def square(x0, y0, x1, y1)
    [[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]]
  end

  def test_hole_and_boundary
    shape = { 'type' => 'Polygon', 'coordinates' => [square(0, 0, 4, 4), square(1, 1, 2, 2)] }
    assert Geo::Geometry.contains?(shape, [0, 2])
    refute Geo::Geometry.contains?(shape, [1.5, 1.5])
    assert_in_delta 0, Geo::Geometry.distance(shape, 0, 2), 0.001
  end

  def test_distance_and_circle
    shape = { 'type' => 'MultiPolygon', 'coordinates' => [[square(0, 0, 1, 1)]] }
    assert_in_delta 11.12, Geo::Geometry.distance(shape, 0, 1.1), 0.02
    assert Geo::Geometry.intersects_circle?(shape, 0, 1.1, 12)
    refute Geo::Geometry.intersects_circle?(shape, 0, 1.1, 10)
  end
end
