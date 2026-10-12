# frozen_string_literal: true

require_relative '../geo/geometry'
require 'i18n'
require 'uri'

module Card
  # Builds map links from the BDL forest locations.
  class ForestLinks
    def build(search)
      search.fetch(:ranges).sort_by { |range| range.fetch('distance_km') }.filter_map { |range| link(range) }
    end

    private

    def link(range)
      point = Geo::Geometry.polygons(range['geometry']).first&.first&.first
      return unless point

      { name: name(range), url: url(point) }
    end

    def name(range)
      properties = range.fetch('properties', {})
      properties['forest_range_name'] || properties['name'] || I18n.t('ui.forest')
    end

    def url(point)
      lon, lat = point
      "https://www.google.com/maps/search/?#{URI.encode_www_form(api: 1, query: "#{lat},#{lon}")}"
    end
  end
end
