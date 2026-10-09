require 'json'
require 'time'
require_relative '../http/transport'
require_relative '../geo/geometry'

module WMS
  class BanClient
    ENDPOINT = 'https://mapserver.bdl.lasy.gov.pl/ArcGIS/services/WMS_zakazy_wstepu_do_lasu/MapServer'

    def initialize(transport: HTTP::Transport.new(base_url: ENDPOINT, user_agent: 'forest_radar/1.0'), cache: nil)
      @transport, @cache = transport, cache
    end

    def sample(district, session_id:, deadline: nil, sampled_at: Time.now.utc)
      point = centre(district.fetch('geometry'))
      result = if @cache
                 @cache.wms_fetch(session_id: session_id, layer: 'rest-0', point: point) do
                   query(point, deadline).merge(sampled_at: sampled_at.iso8601)
                 end
               else
                 query(point, deadline).merge(sampled_at: sampled_at.iso8601)
               end
      result.merge(point: point, centre_outside: !Geo::Geometry.contains?(district['geometry'], point))
    rescue HTTP::Error, JSON::ParserError, ArgumentError, KeyError, TypeError
      { status: :unknown, point: point, sampled_at: sampled_at.iso8601, centre_outside: false }
    end

    private

    def centre(geometry)
      parts = Geo::Geometry.polygons(geometry).flat_map do |rings|
        rings.each_with_index.map do |ring, index|
          edges = ring.each_cons(2).map do |a, b|
            cross = a[0] * b[1] - b[0] * a[1]
            [cross, (a[0] + b[0]) * cross, (a[1] + b[1]) * cross]
          end
          area = edges.sum { |edge| edge[0] }
          raise ArgumentError, 'zero-area district' if area.zero?
          weight = index.zero? ? area.abs : -area.abs
          [weight, edges.sum { |edge| edge[1] }.fdiv(3 * area),
           edges.sum { |edge| edge[2] }.fdiv(3 * area)]
        end
      end
      total = parts.sum { |part| part[0] }
      raise ArgumentError, 'zero-area district' if total <= 0
      [parts.sum { |part| part[0] * part[1] } / total, parts.sum { |part| part[0] * part[2] } / total]
    end

    def query(point, deadline)
      params = { geometry: point.join(','), geometryType: 'esriGeometryPoint', inSR: 4326,
                 spatialRel: 'esriSpatialRelIntersects', outFields: '*',
                 returnGeometry: false, f: 'json' }
      data = JSON.parse(@transport.get('/ArcGIS/rest/services/WMS_zakazy_wstepu_do_lasu/MapServer/0/query',
                                       params: params, deadline: deadline))
      raise ArgumentError, 'malformed ban response' unless data.is_a?(Hash) && data['features'].is_a?(Array)
      names = data['features'].map do |feature|
        raise ArgumentError, 'malformed ban feature' unless feature.is_a?(Hash)
        feature.fetch('attributes')
      end
      raise ArgumentError, 'malformed ban attributes' unless names.all? { |item| item.is_a?(Hash) && !item.empty? }
      { status: names.empty? ? :no_known_ban : :ban, bans: names }
    end
  end
end
