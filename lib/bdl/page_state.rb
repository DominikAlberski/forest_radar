# frozen_string_literal: true

require 'uri'
require_relative 'page_payload'

module BDL
  # Tracks pagination requests, collected features, and count limits.
  class PageState < Struct.new(:path, :params, :seen, :features, :matched, :deadline, :limit, keyword_init: true)
    PAGE_SIZE = 1000

    def self.start(collection, bbox, deadline, limit)
      new(path: "/collections/#{collection}/items", params: { bbox: bbox.join(','), limit: PAGE_SIZE, f: 'json' },
          seen: {}, features: [], matched: nil, deadline: deadline, limit: limit)
    end

    def record_request
      key = [path, params.sort].inspect
      raise Incomplete, 'repeated page' if seen[key]

      seen[key] = true
    end

    def fetch(transport, clock)
      record_request
      page = PagePayload.parse(transport.get(path, params: params, deadline: deadline))
      raise Incomplete, 'deadline exceeded' if clock.call >= deadline

      page
    end

    def add(page)
      update_count(page['numberMatched'])
      append_features(page.fetch('features'))
    end

    def update_count(count)
      raise Incomplete, 'missing count' unless count.is_a?(Integer)

      self.matched ||= count
      raise Incomplete, 'count changed' unless matched == count
    end

    def append_features(items)
      raise Incomplete, 'feature limit' if features.size + items.size > limit

      features.concat(items)
    end

    def follow_link?(page)
      link = page.fetch('links').find { |entry| entry['rel'] == 'next' }
      return false unless link

      update_request(URI(link.fetch('href')))
      true
    end

    def update_request(uri)
      raise Incomplete, 'foreign page' unless uri.host == 'ogcapi.bdl.lasy.gov.pl'

      self.path = uri.path
      self.params = URI.decode_www_form(uri.query || '').to_h
    end

    def finish
      current_features = features
      raise Incomplete, 'count mismatch' if matched && matched != current_features.length

      current_features
    end
  end
end
