# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'session_cache'

module Cache
  # Stores search results by session and request coordinates.
  class SearchCache
    def initialize(store: SessionCache.new)
      @store = store
    end

    def fetch(request, ttl: 1800, &)
      key = Digest::SHA256.hexdigest(JSON.generate(request))
      cached = @store.read(key)
      return cached if cached

      store(key, ttl, &)
    end

    private

    def store(key, ttl)
      result = yield
      @store.write(key, result, ttl: ttl)
      result
    end
  end
end
