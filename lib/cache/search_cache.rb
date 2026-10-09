# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'session_cache'

module Cache
  class SearchCache
    def initialize(store: SessionCache.new)
      @store = store
    end

    def fetch(session_id:, lat:, lon:, radius_km:, query:, ttl: 1800)
      key = Digest::SHA256.hexdigest(JSON.generate([session_id, lat, lon, radius_km, query]))
      cached = @store.read(key)
      return cached if cached

      result = yield
      @store.write(key, result, ttl: ttl)
      result
    end

    def wms_fetch(session_id:, layer:, point:, ttl: 300)
      key = Digest::SHA256.hexdigest(JSON.generate([session_id, layer, point]))
      cached = @store.read(key)
      return cached if cached

      result = yield
      @store.write(key, result, ttl: ttl) if result
      result
    end
  end
end
