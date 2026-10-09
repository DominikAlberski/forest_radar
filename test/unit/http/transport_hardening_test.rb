require_relative '../../test_helper'
require_relative 'fake_net'

# Review findings B1-R3 and B1-R4 (transport part).
class TransportHardeningTest < Minitest::Test
  def setup
    @clock = FakeNet::Clock.new
  end

  def transport(**options)
    HTTP::Transport.new(base_url: 'https://example.test', user_agent: 'test', retries: 2,
                        sleeper: @clock, timeout: 10, **options)
  end

  def run_with(script, &block)
    FakeNet.with(script, @clock, &block)
  end

  # R3
  def test_disables_net_http_internal_retries
    script = FakeNet::Script.new('{}', clock: @clock)
    run_with(script) { transport.get('/x') }
    assert_equal [0], script.max_retries_seen
  end

  # R3
  def test_retries_socket_error_with_half_and_one_second_waits
    waits = []
    @clock.define_singleton_method(:sleep) { |seconds| waits << seconds; advance(seconds) }
    script = FakeNet::Script.new(SocketError.new('dns'), SocketError.new('dns'), '{}', clock: @clock)
    assert_equal '{}', run_with(script) { transport.get('/x') }
    assert_equal 3, script.calls
    assert_equal [0.5, 1.0], waits
  end

  # R3
  def test_socket_error_gives_up_after_three_attempts
    script = FakeNet::Script.new(*Array.new(4) { SocketError.new('dns') }, clock: @clock)
    assert_raises(HTTP::Error) { run_with(script) { transport.get('/x') } }
    assert_equal 3, script.calls
  end

  # R4
  def test_retry_wait_never_passes_the_deadline
    script = FakeNet::Script.new(*Array.new(4) { Timeout::Error.new('slow') }, clock: @clock)
    started = @clock.now
    assert_raises(HTTP::Error) { run_with(script) { transport.get('/x', deadline: started + 1.2) } }
    assert_operator @clock.now, :<=, started + 1.2
  end

  # R4
  def test_connect_time_shrinks_the_read_timeout
    step = { connect_seconds: 4, read_seconds: 5, body: '{}' }
    script = FakeNet::Script.new(step, step, step, clock: @clock)
    started = @clock.now
    assert_raises(HTTP::Error) { run_with(script) { transport.get('/x', deadline: started + 5) } }
    assert_operator @clock.now, :<=, started + 5
  end

  # R4
  def test_slow_read_stops_at_the_deadline
    step = { read_seconds: 30, body: '{}' }
    script = FakeNet::Script.new(step, step, step, clock: @clock)
    started = @clock.now
    assert_raises(HTTP::Error) { run_with(script) { transport.get('/x', deadline: started + 8) } }
    assert_operator @clock.now, :<=, started + 8
  end
end
