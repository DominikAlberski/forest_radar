# frozen_string_literal: true

require_relative '../../test_helper'
require 'cache/search_cache'

class SearchCacheTest < Minitest::Test
  def test_isolates_sessions_and_reuses_complete_result
    cache = Cache::SearchCache.new
    calls = 0
    args = [52, 21, 5, { bbox: 'x' }]
    2.times { assert_equal 1, cache.fetch(['one', *args]) { calls += 1 } }
    assert_equal 2, cache.fetch(['two', *args]) { calls += 1 }
  end

  def test_reuses_maximal_search
    cache = Cache::SearchCache.new
    result = { stands: Array.new(100_000) { { 'species_cd' => 'SO', 'in_radius' => true } } }
    args = ['large', 52, 21, 20, {}]
    assert_same result, cache.fetch(args) { result }
    assert_same result, cache.fetch(args) { flunk 'cache miss' }
  end
end
