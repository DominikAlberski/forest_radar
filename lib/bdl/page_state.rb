# frozen_string_literal: true

require_relative 'page_payload'

module BDL
  # Tracks page counts and collected features.
  class PageState < Struct.new(:path, :params, :features, :matched, :deadline, :limit, :page_size, keyword_init: true)
    PAGE_SIZE = 1000

    def self.start(collection, bbox, deadline, options)
      limit = options.fetch(:limit)
      page_size = options.fetch(:page_size, PAGE_SIZE)
      new(path: "/collections/#{collection}/items",
          params: { bbox: bbox.join(','), limit: page_size, f: 'json', 'offset' => '0' },
          features: [], matched: nil, deadline: deadline, limit: limit, page_size: page_size)
    end

    def fetch(transport, clock, offset)
      page = PagePayload.parse(transport.get(path, params: params.merge('offset' => offset.to_s), deadline: deadline))
      raise Incomplete, 'deadline exceeded' if clock.call >= deadline

      page
    end

    def add(page, offset)
      validate(page, offset)
      features.concat(page.fetch('features'))
    end

    def validate(page, offset)
      count = page['numberMatched']
      raise Incomplete, 'missing count' unless count.is_a?(Integer)

      self.matched ||= count + offset
      raise Incomplete, 'count changed' unless count == matched - offset

      validate_items(page.fetch('features'), offset)
    end

    def validate_items(items, offset)
      raise Incomplete, 'feature limit' if matched > limit
      raise Incomplete, 'count mismatch' unless items.size == [page_size, matched - offset].min
    end

    def offsets
      (page_size...matched).step(page_size).to_a
    end

    def add_pages(pages)
      offsets.each { |offset| features.concat(pages.fetch(offset).fetch('features')) }
    end

    def finish
      raise Incomplete, 'count mismatch' unless matched == features.length

      features
    end
  end
end
