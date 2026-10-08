require 'json'
require 'digest'
require 'uri'
require 'openssl'
require_relative '../geo/geometry'
require_relative '../http/transport'
require_relative 'result_builder'

module BDL
  class Incomplete < StandardError; end
  class NoCoverage < StandardError; end

  class Client
    REGIONS = %w[Bialystok Katowice Krakow Krosno Lublin Lodz Olsztyn Pila Poznan Szczecin
                 Szczecinek Torun Wroclaw Zielona_Gora Gdansk Radom Warszawa].freeze
    # This code mapping is unverified against the live BDL collection metadata.
    REGION_CODES = { '01' => 'Bialystok', '02' => 'Katowice', '03' => 'Krakow', '04' => 'Krosno',
                     '05' => 'Lublin', '06' => 'Lodz', '07' => 'Olsztyn', '08' => 'Pila',
                     '09' => 'Poznan', '10' => 'Szczecin', '11' => 'Szczecinek', '12' => 'Torun',
                     '13' => 'Wroclaw', '14' => 'Zielona_Gora', '15' => 'Gdansk',
                     '16' => 'Radom', '17' => 'Warszawa' }.freeze
    PAGE_SIZE = 1000

    def initialize(transport: HTTP::Transport.new(base_url: 'https://ogcapi.bdl.lasy.gov.pl',
                                                    user_agent: 'ForestRadar/1.0', retries: 2),
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @transport, @clock = transport, clock
    end

    def features(collection, bbox:, deadline: @clock.call + 60, limit: 100_000)
      path = "/collections/#{collection}/items"
      params = { bbox: bbox.join(','), limit: PAGE_SIZE, f: 'json' }
      seen, features, matched = {}, [], nil
      loop do
        key = [path, params.sort].inspect
        raise Incomplete, 'repeated page' if seen[key]
        seen[key] = true
        page = parse(@transport.get(path, params: params, deadline: deadline))
        check_deadline(deadline)
        raise Incomplete, 'missing count' unless page['numberMatched'].is_a?(Integer)
        matched ||= page['numberMatched']
        raise Incomplete, 'count changed' unless matched == page['numberMatched']
        raise Incomplete, 'feature limit' if features.size + page.fetch('features').size > limit
        features.concat(page.fetch('features'))
        link = page.fetch('links').find { |entry| entry['rel'] == 'next' }
        break unless link
        uri = URI(link.fetch('href'))
        raise Incomplete, 'foreign page' unless uri.host == 'ogcapi.bdl.lasy.gov.pl'
        path, params = uri.path, URI.decode_www_form(uri.query || '').to_h
      end
      raise Incomplete, 'count mismatch' if matched && matched != features.length
      features
    rescue JSON::ParserError, KeyError, TypeError, ArgumentError, HTTP::Error, URI::InvalidURIError,
           Timeout::Error, IOError, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
      raise Incomplete, error.message
    end

    def search(lat:, lon:, radius_km:)
      deadline = @clock.call + 60
      bbox = Geo::Geometry.bbox(lat, lon, radius_km)
      remaining = 100_000
      regions = features('rdlp', bbox: bbox, deadline: deadline, limit: remaining)
      validate_geometries(regions)
      remaining -= regions.size
      districts = features('nadlesnictwa', bbox: bbox, deadline: deadline, limit: remaining)
      validate_geometries(districts)
      remaining -= districts.size
      ranges = features('lesnictwa', bbox: bbox, deadline: deadline, limit: remaining)
      validate_geometries(ranges)
      remaining -= ranges.size
      check_deadline(deadline)
      raise NoCoverage, 'no region coverage' unless regions.any? do |item|
        Geo::Geometry.contains?(item['geometry'], [lon, lat])
      end
      raise NoCoverage, 'no district coverage' unless districts.any? do |item|
        Geo::Geometry.contains?(item['geometry'], [lon, lat])
      end
      selected = regions.filter_map { |item| region_collection(item) }.uniq
      raise Incomplete, 'unknown region code' if selected.size != regions.size
      stands = selected.flat_map do |name|
        page_items = features(name, bbox: bbox, deadline: deadline, limit: remaining)
        validate_geometries(page_items)
        remaining -= page_items.size
        page_items.map { |item| [name, item] }
      end
      check_deadline(deadline)
      result = ResultBuilder.new.build(lat, lon, radius_km, regions, districts, ranges, stands)
      check_deadline(deadline)
      result
    end

    private

    def parse(body)
      page = JSON.parse(body)
      valid = page.is_a?(Hash) && page['features'].is_a?(Array) && page['links'].is_a?(Array)
      valid &&= page['links'].all? do |link|
        link.is_a?(Hash) && link['rel'].is_a?(String) && link['href'].is_a?(String)
      end
      valid &&= page['features'].all? { |feature| feature.is_a?(Hash) && feature['properties'].is_a?(Hash) }
      raise Incomplete, 'malformed page' unless valid
      page
    end

    def valid_feature?(feature)
      return false unless feature.is_a?(Hash) && feature['properties'].is_a?(Hash)
      return false unless feature['geometry'].is_a?(Hash)
      polygons = Geo::Geometry.polygons(feature['geometry'])
      polygons.is_a?(Array) && polygons.any? && polygons.all? do |rings|
        rings.is_a?(Array) && rings.any? && rings.all? do |ring|
          ring.is_a?(Array) && ring.length >= 4 && ring.first == ring.last && ring.all? do |point|
            point.is_a?(Array) && point.length >= 2 && point.first(2).all? { |value| value.is_a?(Numeric) }
          end
        end
      end
    rescue ArgumentError, KeyError, TypeError
      false
    end

    def validate_geometries(items)
      raise Incomplete, 'malformed geometry' unless items.all? { |item| valid_feature?(item) }
    end

    def check_deadline(deadline)
      raise Incomplete, 'deadline exceeded' if @clock.call >= deadline
    end

    def region_collection(item)
      props = item.fetch('properties')
      name = REGION_CODES[props['region_cd'].to_s.rjust(2, '0')]
      "RDLP_#{name}_wydzielenia" if name
    end

  end
end
