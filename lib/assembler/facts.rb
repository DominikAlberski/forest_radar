module Assembler
  class Facts
    def build(search, walk)
      areas = walk.fetch(:areas).map { |range| area(range, search.fetch(:stands)) }
      { areas: areas, box_stand_count: search.fetch(:box_stand_count),
        radius_stand_count: search.fetch(:radius_stand_count),
        missing_identifier_count: search.fetch(:missing_identifier_count),
        districts: search.fetch(:districts).map { |item| district(item, search.fetch(:stands)) },
        trail_source: walk.fetch(:trail_source), attribution: walk.fetch(:attribution),
        attribution_url: walk.fetch(:attribution_url) }
    end

    def lines(facts)
      flatten(facts).each_with_index.to_h { |(key, value), index| ["F#{index + 1}", "#{key}=#{value}"] }
    end

    private

    def area(range, stands)
      relevant = stands.select { |stand| stand['range_id'] == range['id'] && stand['in_radius'] == true }
      { id: range['id'], name: range.dig('properties', 'name') || 'brak danych',
        distance_km: range.fetch('distance_km').round(2), district_id: range['district_id'],
        trails: range.fetch(:trails).map { |trail| trail.slice(:id, :name, :ref, :route) },
        ban: range[:ban], stand_count: relevant.size,
        species: summary(relevant, 'species_cd'), sites: summary(relevant, 'site_type'),
        ages: summary(relevant, 'spec_age'), years: summary(relevant, 'a_year'),
        total_area: relevant.sum { |stand| stand['sub_area'].to_f }.round(2), missing_attributes: missing(relevant) }
    end

    def summary(stands, key)
      stands.map { |stand| stand[key] || 'brak danych' }.tally.sort_by { |value, count| [-count, value.to_s] }.to_h
    end

    def missing(stands)
      %w[species_cd site_type spec_age sub_area a_year].to_h do |key|
        [key, stands.count { |stand| stand[key].nil? }]
      end
    end

    def district(item, stands)
      { id: item['id'], name: item.dig('properties', 'name') || 'brak danych',
        address: item.dig('properties', 'adress_forest') || 'brak danych',
        stand_count: stands.count { |stand| stand['district_id'] == item['id'] } }
    end

    def flatten(value, path = '')
      case value
      when Hash then value.flat_map { |key, item| flatten(item, "#{path}.#{key}") }
      when Array then value.each_with_index.flat_map { |item, index| flatten(item, "#{path}[#{index}]") }
      else [[path.delete_prefix('.'), value.nil? ? 'brak danych' : value.to_s]]
      end
    end
  end
end
