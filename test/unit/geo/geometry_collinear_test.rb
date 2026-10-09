# frozen_string_literal: true

require_relative '../../test_helper'
require 'geo/geometry'

# Review findings B1-R1 and B1-R8 (geometry part).
class GeometryCollinearTest < Minitest::Test
  G = Geo::Geometry

  def square(x0, y0, x1, y1)
    [[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]]
  end

  def polygon(*rings)
    { 'type' => 'Polygon', 'coordinates' => rings }
  end

  def test_separated_boxes_with_collinear_edges_do_not_intersect
    left = polygon(square(0, 0, 1, 1))
    right = polygon(square(2, 0, 3, 1))
    refute G.intersects?(left, right)
    refute G.intersects?(right, left)
  end

  def test_separated_boxes_with_vertical_collinear_edges_do_not_intersect
    refute G.intersects?(polygon(square(0, 0, 1, 1)), polygon(square(0, 2, 1, 3)))
  end

  def test_boxes_sharing_an_edge_intersect
    assert G.intersects?(polygon(square(0, 0, 1, 1)), polygon(square(1, 0, 2, 1)))
  end

  def test_boxes_sharing_a_partial_collinear_edge_intersect
    assert G.intersects?(polygon(square(0, 0, 2, 1)), polygon(square(1, 1, 3, 2)))
  end

  def test_boxes_sharing_one_corner_intersect
    assert G.intersects?(polygon(square(0, 0, 1, 1)), polygon(square(1, 1, 2, 2)))
  end

  def test_polygon_wholly_inside_a_hole_does_not_intersect
    ring = polygon(square(0, 0, 10, 10), square(2, 2, 8, 8))
    inner = polygon(square(4, 4, 5, 5))
    refute G.intersects?(ring, inner)
    refute G.intersects?(inner, ring)
  end

  def test_polygon_touching_the_hole_edge_intersects
    ring = polygon(square(0, 0, 10, 10), square(2, 2, 8, 8))
    assert G.intersects?(ring, polygon(square(2, 3, 5, 5)))
  end

  def test_polygon_crossing_the_hole_edge_intersects
    ring = polygon(square(0, 0, 10, 10), square(2, 2, 8, 8))
    assert G.intersects?(ring, polygon(square(1, 4, 5, 5)))
  end

  def test_polygon_filling_the_hole_exactly_intersects_by_shared_edge
    ring = polygon(square(0, 0, 10, 10), square(2, 2, 8, 8))
    assert G.intersects?(ring, polygon(square(2, 2, 8, 8)))
  end
end
