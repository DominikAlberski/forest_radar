# frozen_string_literal: true

require_relative 'geometry_validation'
require_relative 'result_builder'

module BDL
  # Holds the shared deadline, item budget, and collections for one search.
  SearchState = Struct.new(:lat, :lon, :radius, :bbox, :deadline, :remaining,
                           :regions, :districts, :ranges, :stands, keyword_init: true) do
    def self.start(lat, lon, radius, clock)
      new(lat: lat, lon: lon, radius: radius, bbox: Geo::Geometry.bbox(lat, lon, radius),
          deadline: clock.call + 60, remaining: 100_000)
    end

    def search(client, clock)
      load_area(client)
      verify_coverage(clock)
      self.stands = selected_collections.flat_map { |name| stand_pairs(client, name) }
      finish(clock)
    end

    def load_area(client)
      self.regions = read(client, 'rdlp')
      self.districts = read(client, 'nadlesnictwa')
      self.ranges = read(client, 'lesnictwa')
    end

    def read(client, collection)
      items = client.features(collection, bbox: bbox, deadline: deadline, limit: remaining)
      GeometryValidation.validate(items)
      self.remaining -= items.size
      items
    end

    def verify_coverage(clock)
      check_deadline(clock)
      raise NoCoverage, 'no region coverage' unless covers?(regions)
      raise NoCoverage, 'no district coverage' unless covers?(districts)
    end

    def covers?(items)
      point = [lon, lat]
      items.any? { |item| Geo::Geometry.contains?(item['geometry'], point) }
    end

    def selected_collections
      current_regions = regions
      selected = current_regions.filter_map { |item| self.class.region_collection(item) }.uniq
      raise Incomplete, 'unknown region code' if selected.size != current_regions.size

      selected
    end

    def self.region_collection(item)
      props = item.fetch('properties')
      name = Client::REGION_CODES[props['region_cd'].to_s.rjust(2, '0')]
      "RDLP_#{name}_wydzielenia" if name
    end

    def stand_pairs(client, name)
      read(client, name).map { |item| [name, item] }
    end

    def finish(clock)
      check_deadline(clock)
      build_result(clock)
    end

    def build_result(clock)
      input = BuildInput.new(regions: regions, districts: districts, ranges: ranges, stands: stands)
      result = ResultBuilder.new.build(lat, lon, radius, input)
      check_deadline(clock)
      result
    end

    def check_deadline(clock)
      raise Incomplete, 'deadline exceeded' if clock.call >= deadline
    end
  end
end
