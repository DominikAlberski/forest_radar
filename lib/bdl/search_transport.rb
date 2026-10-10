# frozen_string_literal: true

module BDL
  # Limits all requests made by one search.
  class SearchTransport
    def initialize(transport, concurrency)
      @transport = transport
      @slots = SizedQueue.new(concurrency)
      concurrency.times { @slots << true }
    end

    def get(path, params:, deadline:)
      @slots.pop
      acquired = true
      @transport.get(path, params: params, deadline: deadline)
    ensure
      @slots << true if acquired
    end
  end
end
