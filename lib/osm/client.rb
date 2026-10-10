# frozen_string_literal: true

require 'json'
require 'digest'
require_relative '../http/transport'

module OSM
  # Reads relations and logs failed reads.
  module LoggedRelations
    def relations(bbox:, deadline: nil)
      started = @clock.call
      read_relations(bbox, deadline)
    rescue JSON::ParserError, HTTP::Error, ArgumentError, KeyError, TypeError => error
      log_failure(error, started)
    end

    private

    def read_relations(bbox, deadline)
      query = self.class.query_for(bbox)
      key = Digest::SHA256.hexdigest([Client::ENDPOINT, query].join('\0'))
      @cache&.read(key) || fetch_relations(query, key, deadline)
    end

    def log_failure(error, started)
      return unless @log

      elapsed = ((@clock.call - started) * 1000).round
      write_log(error, elapsed)
    end

    def write_log(error, elapsed)
      @log.write(source: :osm, error: error, elapsed_ms: elapsed)
      nil
    rescue StandardError
      nil
    end
  end

  # Reads and validates hiking route relations from Overpass.
  class Client
    include LoggedRelations

    ENDPOINT = ENV.fetch('FOREST_RADAR_OVERPASS_URL', 'https://overpass-api.de')
    ATTRIBUTION = '© OpenStreetMap contributors'
    COPYRIGHT_URL = 'https://www.openstreetmap.org/copyright'

    def initialize(transport: HTTP::Transport.new(base_url: ENDPOINT, user_agent: 'forest_radar/1.0',
                                                  timeout: 25, retries: 1), cache: nil, log: nil,
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @transport = transport
      @cache = cache
      @log = log
      @clock = clock
    end

    def self.query_for(box)
      west, south, east, north = box
      bounds = [south, west, north, east].join(',')
      '[out:json][timeout:25];rel["type"="route"]["route"~"^(hiking|foot|walking)$"]' \
        "(#{bounds});out geom(#{bounds});"
    end

    def self.valid_point?(point)
      point.all? { |value| value.is_a?(Numeric) && value.finite? }
    end

    def self.segment_pairs(points)
      points.each_cons(2).filter_map { |first, second| [first, second] if first && second }
    end

    def self.parse_coordinate(coordinate)
      raise ArgumentError, 'invalid point' unless coordinate.is_a?(Hash)

      coordinate.fetch_values('lon', 'lat')
    end

    private

    def fetch_relations(query, key, deadline)
      relations = load_relations(query, deadline)
      @cache&.write(key, relations, ttl: 1800)
      relations
    end

    def load_relations(query, deadline)
      cutoff = @clock.call + 25
      body = @transport.get('/api/interpreter', params: { data: query },
                                                deadline: deadline ? [deadline, cutoff].min : cutoff)
      parse_elements(body).map { |item| parse_relation(item) }
    end

    def parse_elements(body)
      case JSON.parse(body)
      in Hash => data then array_elements(data['elements'])
      else raise ArgumentError, 'malformed Overpass response'
      end
    end

    def array_elements(elements)
      raise ArgumentError, 'malformed Overpass response' unless elements.is_a?(Array)

      elements
    end

    def parse_relation(item)
      tags = relation_tags(item)
      ways = relation_members(item).flat_map { |member| way_segments(member) }
      { id: item['id'], name: tags['name'], ref: tags['ref'], route: tags['route'], ways: ways }
    end

    def relation_tags(item)
      raise ArgumentError, 'invalid relation' unless item.is_a?(Hash)

      tags = item.fetch('tags')
      raise ArgumentError, 'invalid tags' unless tags.is_a?(Hash)

      validate_relation_header(item, tags)
      tags
    end

    def validate_relation_header(item, tags)
      relation_type, relation_id = item.values_at('type', 'id')
      raise ArgumentError, 'invalid relation' unless relation_type == 'relation' && relation_id.is_a?(Integer)

      raise ArgumentError, 'invalid route' unless %w[hiking foot walking].include?(tags['route'])
    end

    def relation_members(item)
      members = item.fetch('members')
      raise ArgumentError, 'invalid members' unless members.is_a?(Array)

      members
    end

    def way_segments(member)
      raise ArgumentError, 'invalid member' unless member.is_a?(Hash)

      member_type, geometry = member.values_at('type', 'geometry')
      return [] unless member_type == 'way'

      self.class.segment_pairs(way_points(geometry))
    end

    def way_points(geometry)
      raise ArgumentError, 'invalid geometry' unless geometry.is_a?(Array)

      points = geometry.map(&method(:parse_point))
      raise ArgumentError, 'invalid way' unless valid_way_points?(points)

      points
    end

    def valid_way_points?(points)
      points.compact.all? { |point| self.class.valid_point?(point) }
    end

    def parse_point(point)
      point&.then { |coordinate| self.class.parse_coordinate(coordinate) }
    end
  end
end
