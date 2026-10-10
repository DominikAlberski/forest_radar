# frozen_string_literal: true

require_relative '../../test_helper'
require 'geo/geometry'

# Tests geometry bounds and box overlap.
class GeometryBBoxTest < Minitest::Test
  G = Geo::Geometry

  def test_bounds_include_all_multipolygon_parts
    geometry = { 'type' => 'MultiPolygon', 'coordinates' => [
      [[[0, 0], [1, 0], [1, 1], [0, 0]]],
      [[[4, 5], [6, 5], [6, 7], [4, 5]]]
    ] }
    assert_equal [0, 0, 6, 7], Geo::Geometry.bounds(geometry)
  end

  def test_bounds_of_nil_geometry
    assert_nil G.bounds(nil)
  end

  def test_one_point_ring_is_outside
    geometry = polygon([[0, 0]])
    assert_nil G.bounds(geometry)
    refute G.prepared_intersects?(G.prepare(geometry), G.prepare(polygon(square(0, 0, 1, 1))))
  end

  def test_boxes_touching_an_edge_overlap
    assert Geo::Geometry.boxes_overlap?([0, 0, 1, 1], [1, 0, 2, 1])
    refute Geo::Geometry.boxes_overlap?([0, 0, 1, 1], [2, 0, 3, 1])
  end

  def test_prepared_intersection_matches_regular_intersection
    outer = polygon(square(0, 0, 10, 10), square(2, 2, 8, 8))
    prepared_cases.each { |shape| assert_same_intersection(outer, shape) }
  end

  def prepared_cases
    [polygon(square(10, 1, 11, 2)), polygon(square(0, 0, 1, 1)),
     polygon(square(1, 4, 5, 5)), polygon(square(20, 20, 21, 21)),
     polygon(square(4, 4, 5, 5)), polygon(square(2, 3, 5, 5))]
  end

  def assert_same_intersection(first, second)
    assert_equal G.intersects?(first, second), G.prepared_intersects?(G.prepare(first), G.prepare(second))
  end

  def polygon(*rings)
    { 'type' => 'Polygon', 'coordinates' => rings }
  end

  def square(left, bottom, right, top)
    [[left, bottom], [right, bottom], [right, top], [left, top], [left, bottom]]
  end
end
