# frozen_string_literal: true

require_relative 'page_state'
require_relative 'page_payload'

module BDL
  # Reads all pages of one BDL collection within a shared deadline and item limit.
  class PageReader
    def initialize(transport, clock)
      @transport = transport
      @clock = clock
    end

    def read(collection, bbox:, deadline:, limit:)
      state = PageState.start(collection, bbox, deadline, limit)
      load_pages(state)
      state.finish
    end

    private

    def load_pages(state)
      loop do
        page = state.fetch(@transport, @clock)
        state.add(page)
        break unless state.follow_link?(page)
      end
    end
  end
end
