# frozen_string_literal: true

require 'bdl/client'

# Builds recorded collection pages for BDL search tests.
module ClientSearchSupport
  LAT = 52.0
  LON = 21.0

  def square(left, bottom, right, top)
    { 'type' => 'Polygon',
      'coordinates' => [[[left, bottom], [right, bottom], [right, top], [left, top], [left, bottom]]] }
  end

  def feature(identifier, properties, geometry)
    { 'type' => 'Feature', 'id' => identifier, 'properties' => properties, 'geometry' => geometry }
  end

  def page(items, links: [])
    { 'type' => 'FeatureCollection', 'numberMatched' => items.length, 'features' => items, 'links' => links }
  end

  # Serves one page per collection path and advances a fake clock per request.
  class Fake
    attr_reader :paths

    def initialize(pages, clock: nil, seconds: 0)
      @pages = pages
      @clock = clock
      @seconds = seconds
      @paths = []
    end

    def get(path, **)
      @paths << path
      @clock&.advance(@seconds)
      body = @pages.fetch(path)
      raise body if body.is_a?(Exception)

      body.is_a?(String) ? body : body.to_json
    end
  end

  def collection(name)
    "/collections/#{name}/items"
  end

  def base_pages
    big = square(20.5, 51.5, 21.5, 52.5)
    { collection('rdlp') => page([feature(1, { 'region_cd' => '17' }, big)]),
      collection('nadlesnictwa') => page([feature(2, { 'adress_forest' => '17-02- -' }, big)]),
      collection('lesnictwa') => page([feature(3, { 'adress_forest' => '17-02-1-05-' }, big)]),
      collection('RDLP_Warszawa_wydzielenia') => page([]) }
  end

  def search(pages, **)
    BDL::Client.new(transport: Fake.new(pages), **).search(lat: LAT, lon: LON, radius_km: 5)
  end
end
