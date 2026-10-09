# frozen_string_literal: true

require_relative '../../test_helper'
require 'cache/search_cache'

class SearchCacheTest < Minitest::Test
  def test_isolates_sessions_and_reuses_complete_result
    cache = Cache::SearchCache.new
    calls = 0
    args = { lat: 52, lon: 21, radius_km: 5, query: { bbox: 'x' } }
    2.times { assert_equal 1, cache.fetch(session_id: 'one', **args) { calls += 1 } }
    assert_equal 2, cache.fetch(session_id: 'two', **args) { calls += 1 }
  end

  def test_reuses_maximal_search
    cache = Cache::SearchCache.new
    result = { stands: Array.new(100_000) { { 'species_cd' => 'SO', 'in_radius' => true } } }
    args = { session_id: 'large', lat: 52, lon: 21, radius_km: 20, query: {} }
    assert_same result, cache.fetch(**args) { result }
    assert_same result, cache.fetch(**args) { flunk 'cache miss' }
  end
end
