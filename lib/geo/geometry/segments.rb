# frozen_string_literal: true

module Geo
  # Computes distances and crossings between polygon edges.
  module Geometry
    module_function

    def segment_distance(point, start_point, end_point)
      fraction = projection_fraction(point, start_point, end_point).clamp(0, 1)
      foot = interpolate(start_point, end_point, fraction)
      Math.hypot(point[0] - foot[0], point[1] - foot[1])
    end

    def projection_fraction(point, vector_start, vector_end)
      direction = difference(vector_end, vector_start)
      return 0 if direction.all?(&:zero?)

      dot(difference(point, vector_start), direction) / dot(direction, direction)
    end

    def difference(first_point, second_point)
      [first_point[0] - second_point[0], first_point[1] - second_point[1]]
    end

    def dot(first_vector, second_vector)
      (first_vector[0] * second_vector[0]) + (first_vector[1] * second_vector[1])
    end

    def interpolate(base_point, tip_point, fraction)
      direction = difference(tip_point, base_point)
      [base_point[0] + (fraction * direction[0]), base_point[1] + (fraction * direction[1])]
    end

    def edges_cross?(first_ring, second_ring)
      first_ring.each_cons(2).any? do |start_point, end_point|
        segment_crosses_ring?(start_point, end_point, second_ring)
      end
    end

    def segment_crosses_ring?(segment_start, segment_end, ring)
      ring.each_cons(2).any? { |other_start, other_end| crossing?(segment_start, segment_end, other_start, other_end) }
    end

    def crossing?(first_start, first_end, other_start, other_end)
      first_side = side(first_start, first_end, other_start)
      second_side = side(first_start, first_end, other_end)
      return collinear_overlap?(first_start, first_end, other_start, other_end) if first_side.zero? && second_side.zero?

      first_side * second_side <= 0 && straddles?(other_start, other_end, first_start, first_end)
    end

    def straddles?(line_start, line_end, first_point, second_point)
      side(line_start, line_end, first_point) * side(line_start, line_end, second_point) <= 0
    end

    def collinear_overlap?(left_start, left_end, right_start, right_end)
      on_segment?(right_start, left_start, left_end) || on_segment?(right_end, left_start, left_end) ||
        on_segment?(left_start, right_start, right_end) || on_segment?(left_end, right_start, right_end)
    end

    def side(origin, endpoint, point)
      start_x, start_y = origin
      dx = endpoint[0] - start_x
      dy = endpoint[1] - start_y
      (dx * (point[1] - start_y)) - (dy * (point[0] - start_x))
    end
  end
end
