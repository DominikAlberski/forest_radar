# frozen_string_literal: true

require 'json'
require 'digest'
require_relative '../geo/geometry'
require_relative 'canonical'

module BDL
  # Groups BDL collections for one result build.
  BuildInput = Data.define(:regions, :districts, :ranges, :stands)

  # Selects address candidates and caches geometry bounds for one build.
  class MatchIndex
    def initialize
      @indexes = {}
      @boxes = {}.compare_by_identity
      @prepared = @boxes.dup
    end

    def candidates(items, width, address)
      index = (@indexes[[items.object_id, width]] ||= self.class.index(items, width))
      positions = (0..[width, address.length].min).flat_map { |size| index[address[0, size]] }
      positions.sort.map { |position| items[position] }
    end

    def self.index(items, width)
      items.each_with_index.with_object(Hash.new { |hash, key| hash[key] = [] }) do |(item, position), index|
        prefix = item.dig('properties', 'adress_forest').to_s[0, width]
        index[prefix] << position
      end
    end

    def spatial_match?(source, candidate)
      source_box = box(source)
      candidate_box = box(candidate)
      return false unless source_box && candidate_box
      return false unless Geo::Geometry.boxes_overlap?(source_box, candidate_box)

      Geo::Geometry.prepared_intersects?(prepared(source), prepared(candidate))
    end

    def box(feature)
      @boxes[feature] ||= Geo::Geometry::PreparedGeometry.merge_boxes(prepared(feature).map(&:first))
    end

    def prepared(feature)
      @prepared[feature] ||= Geo::Geometry.prepare(feature['geometry'])
    end
  end

  # Links BDL stands, ranges, and districts into one search result.
  # :reek:InstanceVariableAssumption
  class ResultBuilder
    # Holds the search point and source collections.
    Context = Data.define(:lat, :lon, :radius, :input)
    # Names a stand and its source collection.
    StandEntry = Data.define(:collection, :feature)
    STAND_FIELDS = %w[species_cd site_type spec_age sub_area a_year adr_for a_i_num].freeze

    def build(lat, lon, radius, input)
      @match_index = MatchIndex.new
      context = Context.new(lat: lat, lon: lon, radius: radius, input: input)
      self.class.result(context, build_stands(context), build_ranges(context))
    end

    def self.matching_feature?(source, candidate, address, width)
      prefix = candidate.dig('properties', 'adress_forest').to_s[0, width]
      address.start_with?(prefix) && Geo::Geometry.intersects?(source['geometry'], candidate['geometry'])
    end

    def self.full_prefix?(item, address, width)
      prefix = item.dig('properties', 'adress_forest').to_s
      prefix.length >= width && address.length >= width && address.start_with?(prefix[0, width])
    end

    def self.in_radius?(context, stand)
      Geo::Geometry.intersects_circle?(stand['geometry'], context.lat, context.lon, context.radius)
    end

    def self.ambiguous_message(matches, link, feature)
      ids = matches.map { |item| item['id'] }
      "ambiguous #{link} for #{feature['id']}: #{ids.join(', ')}"
    end

    def self.result(context, items, linked_ranges)
      input = context.input
      { regions: input.regions, districts: input.districts, ranges: linked_ranges, stands: items,
        box_stand_count: items.length, radius_stand_count: radius_count(items),
        missing_identifier_count: missing_count(items) }
    end

    def self.radius_count(items)
      items.count { |item| item['in_radius'] }
    end

    def self.missing_count(items)
      items.count { |item| item['missing_identifier'] }
    end

    def self.stand_identifier(stand, props)
      identifier, address = props.values_at('a_i_num', 'adr_for')
      identifier || address || Digest::SHA256.hexdigest(
        JSON.generate(Canonical.call(stand.slice('geometry', 'properties')))
      )
    end

    private

    def build_stands(context)
      seen = Set.new
      context.input.stands.filter_map do |collection, stand|
        stand_item(context, seen, StandEntry.new(collection: collection, feature: stand))
      end
    end

    def stand_item(context, seen, source)
      stand = source.feature
      props = stand.fetch('properties')
      raise Incomplete, 'stand geometry missing' unless stand['geometry']
      return unless seen.add?([source.collection, self.class.stand_identifier(stand, props)])

      linked_stand(context, source, props)
    end

    def linked_stand(context, entry, props)
      input = context.input
      feature = entry.feature
      district = stand_match(input.districts, 'stand district', feature, 5)
      range = stand_match(input.ranges, 'stand range', feature, 10)
      props.slice(*STAND_FIELDS).merge(stand_attributes(context, entry, district, range))
    end

    def stand_match(collection, label, stand, prefix_width)
      address = stand.dig('properties', 'adr_for').to_s
      matches = @match_index.candidates(collection, prefix_width, address)
      exact = exact_stand_match(matches, address, prefix_width)
      return exact if exact

      spatial_stand_match(matches, label, stand)
    end

    def spatial_stand_match(matches, label, stand)
      unique_match(matches, label, stand) { |item| @match_index.spatial_match?(stand, item) }
    end

    def exact_stand_match(matches, address, width)
      exact = matches.select { |item| self.class.full_prefix?(item, address, width) }
      exact.first if exact.one?
    end

    def stand_attributes(context, stand_entry, district, range)
      feature = stand_entry.feature
      props = feature.fetch('properties')
      { 'collection' => stand_entry.collection, 'district_id' => district&.fetch('id'),
        'range_id' => range&.fetch('id'), 'missing_identifier' => props.values_at('a_i_num', 'adr_for').compact.empty?,
        'in_radius' => self.class.in_radius?(context, feature) }
    end

    def build_ranges(context)
      context.input.ranges.map { |range| linked_range(context, range) }
    end

    def linked_range(context, range)
      address = range.dig('properties', 'adress_forest').to_s
      candidates = @match_index.candidates(context.input.districts, 5, address)
      district = unique_match(candidates, 'range district', range) { |item| @match_index.spatial_match?(range, item) }
      range.merge('district_id' => district&.fetch('id'),
                  'distance_km' => Geo::Geometry.distance(range['geometry'], context.lat, context.lon))
    end

    def unique_match(items, link, feature, &)
      matches = items.select(&)
      raise Incomplete, self.class.ambiguous_message(matches, link, feature) if matches.length > 1

      matches.first
    end
  end
end
