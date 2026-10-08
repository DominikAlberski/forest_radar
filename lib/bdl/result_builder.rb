require 'json'
require 'digest'
require_relative '../geo/geometry'

module BDL
  class ResultBuilder
    def build(lat, lon, radius, regions, districts, ranges, stands)
      ids = {}
      items = stands.filter_map do |collection, stand|
        props = stand.fetch('properties')
        raise Incomplete, 'stand geometry missing' unless stand['geometry']
        id = props['a_i_num'] || props['adr_for'] || Digest::SHA256.hexdigest(
          JSON.generate(canonical(stand.slice('geometry', 'properties'))))
        key = [collection, id]
        next if ids[key]
        ids[key] = true
        district = unique_match(districts, 'stand district', stand) do |item|
          props['adr_for'].to_s.start_with?(item.dig('properties', 'adress_forest').to_s[0, 5]) &&
            Geo::Geometry.intersects?(stand['geometry'], item['geometry'])
        end
        range = unique_match(ranges, 'stand range', stand) do |item|
          props['adr_for'].to_s.start_with?(item.dig('properties', 'adress_forest').to_s[0, 10]) &&
            Geo::Geometry.intersects?(stand['geometry'], item['geometry'])
        end
        props.slice('species_cd', 'site_type', 'spec_age', 'sub_area', 'a_year', 'adr_for', 'a_i_num').merge(
          'collection' => collection, 'district_id' => district&.fetch('id'),
          'range_id' => range&.fetch('id'), 'missing_identifier' => props['a_i_num'].nil? && props['adr_for'].nil?,
          'in_radius' => Geo::Geometry.intersects_circle?(stand['geometry'], lat, lon, radius))
      end
      linked_ranges = ranges.map do |range|
        district = unique_match(districts, 'range district', range) do |item|
          range.dig('properties', 'adress_forest').to_s.start_with?(
            item.dig('properties', 'adress_forest').to_s[0, 5]) &&
            Geo::Geometry.intersects?(range['geometry'], item['geometry'])
        end
        range.merge('district_id' => district&.fetch('id'),
                    'distance_km' => Geo::Geometry.distance(range['geometry'], lat, lon))
      end
      { regions: regions, districts: districts, ranges: linked_ranges, stands: items,
        box_stand_count: items.length, radius_stand_count: items.count { |item| item['in_radius'] },
        missing_identifier_count: items.count { |item| item['missing_identifier'] } }
    end

    private

    def canonical(value)
      case value
      when Hash then value.keys.sort.to_h { |key| [key, canonical(value[key])] }
      when Array then value.map { |item| canonical(item) }
      else value
      end
    end

    def unique_match(items, link, feature)
      matches = items.select { |item| yield item }
      ids = matches.map { |item| item['id'] }
      raise Incomplete, "ambiguous #{link} for #{feature['id']}: #{ids.join(', ')}" if matches.length > 1
      matches.first
    end
  end
end
