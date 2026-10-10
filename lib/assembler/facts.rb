# frozen_string_literal: true

require_relative 'fact_node'

# Builds ordered card facts and model input lines.
module Assembler
  # Builds facts for one selected forest range.
  AreaFacts = Struct.new(:range, :relevant) do
    def to_h
      identity.merge(trail_data).merge(stand_count: relevant.size).merge(summaries)
              .merge(total_area: total_area, missing_attributes: missing)
    end

    private

    def identity
      { id: range['id'], name: name, distance_km: range.fetch('distance_km').round(2),
        district_id: range['district_id'] }
    end

    def name
      properties = range['properties'] || {}
      properties.values_at('forest_range_name', 'name').find(&:itself) || 'brak danych'
    end

    def trail_data
      { trails: range.fetch(:trails).map { |trail| trail.slice(:id, :name, :ref, :route) } }
    end

    def summaries
      { species: summary('species_cd'), sites: summary('site_type'), ages: summary('spec_age'),
        years: summary('a_year') }
    end

    def summary(key)
      relevant.map { |stand| stand[key] || 'brak danych' }.tally.sort_by { |value, count| [-count, value.to_s] }.to_h
    end

    def total_area
      relevant.sum { |stand| stand['sub_area'].to_f }.round(2)
    end

    def missing
      %w[species_cd site_type spec_age sub_area a_year].to_h { |key| [key, missing_count(key)] }
    end

    def missing_count(key)
      relevant.count { |stand| stand.values_at(key).compact.empty? }
    end
  end
  private_constant :AreaFacts

  # Builds facts for one forest district.
  DistrictFacts = Struct.new(:item, :stands) do
    def to_h
      { id: item['id'], name: name, address: address, stand_count: stand_count }
    end

    private

    def name
      properties = item['properties'] || {}
      properties.values_at('inspectorate_name', 'name').find(&:itself) || 'brak danych'
    end

    def address
      item.dig('properties', 'adress_forest') || 'brak danych'
    end

    def stand_count
      identifier = item['id']
      stands.count { |stand| stand['district_id'] == identifier }
    end
  end
  private_constant :DistrictFacts

  # Collects source counts and selected range facts in response order.
  FactBuild = Struct.new(:search, :walk) do
    def to_h
      { areas: areas }.merge(counts).merge(districts: districts).merge(trail_data)
    end

    private

    def areas
      walk.fetch(:areas).map { |range| AreaFacts.new(range, relevant(range)).to_h }
    end

    def relevant(range)
      identifier = range['id']
      search.fetch(:stands).select { |stand| stand.values_at('range_id', 'in_radius') == [identifier, true] }
    end

    def counts
      { box_stand_count: count(:box_stand_count), radius_stand_count: count(:radius_stand_count),
        missing_identifier_count: count(:missing_identifier_count) }
    end

    def count(key)
      search.fetch(key)
    end

    def districts
      search.fetch(:districts).map { |item| DistrictFacts.new(item, search.fetch(:stands)).to_h }
    end

    def trail(key)
      walk.fetch(key)
    end

    def trail_data
      { trail_source: trail(:trail_source), attribution: trail(:attribution),
        attribution_url: trail(:attribution_url) }
    end
  end
  private_constant :FactBuild

  # Builds the card facts and numbered model input lines.
  class Facts
    def initialize(builder: FactBuild, node: FactNode)
      @builder = builder
      @node = node
    end

    def build(search, walk)
      @builder.new(search, walk).to_h
    end

    def lines(facts)
      @node.new(facts, '').entries.each_with_index.to_h { |(key, value), index| ["F#{index + 1}", "#{key}=#{value}"] }
    end

    def model_lines(search)
      walk = { areas: search.fetch(:ranges).map { |range| range.merge(trails: []) },
               trail_source: nil, attribution: nil, attribution_url: nil }
      lines(build(search, walk).slice(:areas, :districts, :radius_stand_count))
    end
  end
end
