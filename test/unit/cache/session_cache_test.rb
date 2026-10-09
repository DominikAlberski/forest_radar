# frozen_string_literal: true

require_relative '../../test_helper'
require 'cache/session_cache'

class SessionCacheTest < Minitest::Test
  def test_expiry_and_lru
    now = 0
    cache = Cache::SessionCache.new(max_entries: 2, clock: -> { now })
    cache.write('a', 1, ttl: 10)
    cache.write('b', 2, ttl: 10)
    assert_equal 1, cache.read('a')
    cache.write('c', 3, ttl: 10)
    assert_nil cache.read('b')
    now = 11
    assert_nil cache.read('a')
  end
end
