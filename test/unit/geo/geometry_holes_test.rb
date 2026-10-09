# frozen_string_literal: true

require_relative '../../test_helper'
require 'geo/geometry'

class GeometryHolesTest < Minitest::Test
  G = Geo::Geometry
  KM_PER_DEGREE = Math::PI * 6371.0088 / 180 # 111.1949 km

  def square(x0, y0, x1, y1)
    [[x0, y0], [x1, y0], [x1, y1], [x0, y1], [x0, y0]]
  end

  def polygon(*rings)
    { 'type' => 'Polygon', 'coordinates' => rings }
  end

  def test_point_in_hole_is_outside
    shape = polygon(square(0, 0, 4, 4), square(1, 1, 2, 2))
    refute G.contains?(shape, [1.5, 1.5])
    assert G.contains?(shape, [3, 3])
  end

  def test_hole_boundary_belongs_to_the_polygon
    shape = polygon(square(0, 0, 4, 4), square(1, 1, 2, 2))
    assert G.contains?(shape, [1, 1.5])
    assert G.contains?(shape, [2, 2])
  end

  def test_outer_corner_and_edge_are_inside
    shape = polygon(square(0, 0, 4, 4))
    assert G.contains?(shape, [0, 0])
    assert G.contains?(shape, [4, 2])
    refute G.contains?(shape, [4.0001, 2])
  end

  def test_two_holes
    shape = polygon(square(0, 0, 10, 10), square(1, 1, 2, 2), square(5, 5, 6, 6))
    refute G.contains?(shape, [1.5, 1.5])
    refute G.contains?(shape, [5.5, 5.5])
    assert G.contains?(shape, [3, 3])
  end

  def test_multipolygon_matches_any_part_and_respects_holes
    shape = { 'type' => 'MultiPolygon',
              'coordinates' => [[square(0, 0, 1, 1)], [square(10, 10, 14, 14), square(11, 11, 12, 12)]] }
    assert G.contains?(shape, [0.5, 0.5])
    assert G.contains?(shape, [13, 13])
    refute G.contains?(shape, [11.5, 11.5])
    refute G.contains?(shape, [5, 5])
  end

  def test_distance_inside_is_zero
    assert_equal 0.0, G.distance(polygon(square(0, 0, 4, 4)), 2, 2)
  end

  def test_distance_to_east_edge_at_equator
    shape = polygon(square(0.1, -0.1, 0.2, 0.1))
    assert_in_delta 0.1 * KM_PER_DEGREE, G.distance(shape, 0, 0), 0.02 # 11.1195 km
  end

  def test_distance_to_north_edge
    shape = polygon(square(0, 0.1, 1, 1))
    assert_in_delta 0.1 * KM_PER_DEGREE, G.distance(shape, 0, 0.5), 0.02
  end

  def test_distance_at_sixty_degrees_scales_longitude_by_cosine
    shape = polygon(square(0.1, 59.9, 0.2, 60.1))
    assert_in_delta 0.1 * 0.5 * KM_PER_DEGREE, G.distance(shape, 60, 0), 0.02 # 5.5597 km
  end

  def test_distance_from_inside_a_hole_goes_to_the_hole_edge
    shape = polygon(square(0, 0, 4, 4), square(1, 1, 2, 2))
    expected = 0.5 * Math.cos(1.5 * Math::PI / 180) * KM_PER_DEGREE # 55.578 km
    assert_in_delta expected, G.distance(shape, 1.5, 1.5), 0.02
  end

  def test_distance_picks_nearest_multipolygon_part
    shape = { 'type' => 'MultiPolygon', 'coordinates' => [[square(1, -0.1, 2, 0.1)], [square(0.1, -0.1, 0.2, 0.1)]] }
    assert_in_delta 0.1 * KM_PER_DEGREE, G.distance(shape, 0, 0), 0.02
  end

  def test_circle_includes_stand_exactly_inside_radius_and_excludes_outside
    shape = polygon(square(0.1, -0.1, 0.2, 0.1))
    assert G.intersects_circle?(shape, 0, 0, 11.2)
    refute G.intersects_circle?(shape, 0, 0, 11.0)
  end

  def test_circle_around_point_inside_hole_with_small_radius_misses
    shape = polygon(square(0, 0, 4, 4), square(1, 1, 2, 2))
    refute G.intersects_circle?(shape, 1.5, 1.5, 10)
    assert G.intersects_circle?(shape, 1.5, 1.5, 60)
  end

  def test_bbox_is_west_south_east_north_and_contains_the_circle
    west, south, east, north = G.bbox(50, 20, 10)
    assert_operator west, :<, 20
    assert_operator east, :>, 20
    assert_in_delta 10 / KM_PER_DEGREE, north - 50, 0.001
    assert_in_delta 50 - south, north - 50, 1e-9
  end

  def test_missing_geometry_has_no_polygons
    assert_equal [], G.polygons(nil)
    refute G.contains?(nil, [0, 0])
  end

  def test_unsupported_geometry_type_raises
    assert_raises(ArgumentError) { G.contains?({ 'type' => 'Point', 'coordinates' => [0, 0] }, [0, 0]) }
  end

  def test_polygons_intersect_when_overlapping_or_nested_but_not_when_apart
    a = polygon(square(0, 0, 2, 2))
    assert G.intersects?(a, polygon(square(1, 1, 3, 3)))
    assert G.intersects?(a, polygon(square(0.5, 0.5, 1, 1)))
    refute G.intersects?(a, polygon(square(5, 5, 6, 6)))
  end
end
