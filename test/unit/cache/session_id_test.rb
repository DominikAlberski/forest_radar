require_relative '../../test_helper'
require 'cache/session_id'

class SessionIdTest < Minitest::Test
  def test_opaque_id_and_cookie_policy
    id = Cache::SessionId.generate
    assert Cache::SessionId.valid?(id)
    refute_equal id, Cache::SessionId.generate
    assert_equal true, Cache::SessionId.cookie(id, secure: true)[:secure]
    assert_equal :lax, Cache::SessionId.cookie(id, secure: false)[:same_site]
  end
end
