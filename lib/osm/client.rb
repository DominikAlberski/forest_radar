require 'json'
require 'digest'
require_relative '../http/transport'

module OSM
  class Client
    ENDPOINT = ENV.fetch('FOREST_RADAR_OVERPASS_URL', 'https://overpass-api.de')
    ATTRIBUTION = '© OpenStreetMap contributors'
    COPYRIGHT_URL = 'https://www.openstreetmap.org/copyright'

    def initialize(transport: HTTP::Transport.new(base_url: ENDPOINT, user_agent: 'forest_radar/1.0',
                                                   timeout: 25, retries: 1), cache: nil)
      @transport, @cache = transport, cache
    end

    def relations(bbox:, deadline: nil)
      query = query_for(bbox)
      key = Digest::SHA256.hexdigest([ENDPOINT, query].join('\0'))
      cached = @cache&.read(key)
      return cached if cached
      cutoff = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 25
      data = JSON.parse(@transport.get('/api/interpreter', params: { data: query },
                                                    deadline: deadline ? [deadline, cutoff].min : cutoff))
      raise ArgumentError, 'malformed Overpass response' unless data.is_a?(Hash) && data['elements'].is_a?(Array)
      relations = data['elements'].map { |item| parse_relation(item) }
      @cache&.write(key, relations, ttl: 1800)
      relations
    rescue JSON::ParserError, HTTP::Error, ArgumentError, KeyError, TypeError
      nil
    end

    private

    def query_for(box)
      west, south, east, north = box
      bounds = [south, west, north, east].join(',')
      '[out:json][timeout:25];rel["type"="route"]["route"~"^(hiking|foot|walking)$"]' \
        "(#{bounds});out geom(#{bounds});"
    end

    def parse_relation(item)
      raise ArgumentError, 'invalid relation' unless item.is_a?(Hash)
      tags = item.fetch('tags')
      raise ArgumentError, 'invalid tags' unless tags.is_a?(Hash)
      raise ArgumentError, 'invalid relation' unless item['type'] == 'relation' && item['id'].is_a?(Integer)
      raise ArgumentError, 'invalid route' unless %w[hiking foot walking].include?(tags['route'])
      members = item.fetch('members')
      raise ArgumentError, 'invalid members' unless members.is_a?(Array)
      ways = members.flat_map do |member|
        raise ArgumentError, 'invalid member' unless member.is_a?(Hash)
        next [] unless member['type'] == 'way'
        geometry = member.fetch('geometry')
        raise ArgumentError, 'invalid geometry' unless geometry.is_a?(Array)
        points = geometry.map do |point|
          next if point.nil? # Overpass clips member ways with null placeholders.
          raise ArgumentError, 'invalid point' unless point.is_a?(Hash)
          [point.fetch('lon'), point.fetch('lat')]
        end
        raise ArgumentError, 'invalid way' unless points.compact.all? do |point|
          point.all? { |value| value.is_a?(Numeric) && value.finite? }
        end
        points.each_cons(2).filter_map { |a, b| [a, b] if a && b }
      end
      { id: item['id'], name: tags['name'], ref: tags['ref'], route: tags['route'], ways: ways }
    end
  end
end
