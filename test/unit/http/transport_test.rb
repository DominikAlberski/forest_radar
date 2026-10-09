# frozen_string_literal: true

require_relative '../../test_helper'
require 'http/transport'

class TransportTest < Minitest::Test
  class Sleeper
    attr_reader :delays

    def initialize
      @delays = []
    end

    def sleep(seconds)
      @delays << seconds
    end
  end

  # Replays scripted outcomes: an Exception is raised, a String is a 200 body,
  # an Integer is an error status, an Array is a chunked 200 body.
  class Script
    attr_reader :calls

    def initialize(*steps)
      @steps = steps
      @calls = 0
    end

    def start(*_args, **_options)
      @calls += 1
      step = @steps.shift
      raise step if step.is_a?(Exception)

      yield Http.new(step)
    end
  end

  class Http
    def initialize(step)
      @step = step
    end

    def request(_request)
      step = @step
      response_class = step.is_a?(Integer) ? Net::HTTPResponse::CODE_TO_OBJ[step.to_s] : Net::HTTPOK
      status = step.is_a?(Integer) ? step.to_s : '200'
      response = response_class.new('1.1', status, '')
      chunks = step.is_a?(Array) ? step : [step.to_s]
      response.define_singleton_method(:read_body) { |&block| chunks.each(&block) }
      yield response
    end
  end

  def transport(retries: 2, **)
    @sleeper = Sleeper.new
    HTTP::Transport.new(base_url: 'https://example.test', user_agent: 'test', retries: retries,
                        sleeper: @sleeper, **)
  end

  def run_script(script, &block)
    original = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*args, **options, &inner| script.start(*args, **options, &inner) }
    block.call
  ensure
    Net::HTTP.define_singleton_method(:start, original)
  end

  def test_returns_body
    script = Script.new('{"ok":true}')
    assert_equal '{"ok":true}', run_script(script) { transport.get('/x') }
    assert_empty @sleeper.delays
  end

  def test_retries_server_error_twice_with_half_and_one_second_waits
    script = Script.new(503, 502, '{}')
    assert_equal '{}', run_script(script) { transport.get('/x') }
    assert_equal 3, script.calls
    assert_equal [0.5, 1.0], @sleeper.delays
  end

  def test_gives_up_after_two_retries_on_server_error
    script = Script.new(500, 500, 500, '{}')
    assert_raises(HTTP::ResponseError) { run_script(script) { transport.get('/x') } }
    assert_equal 3, script.calls
    assert_equal [0.5, 1.0], @sleeper.delays
  end

  def test_does_not_retry_client_error
    script = Script.new(404, '{}')
    assert_raises(HTTP::ResponseError) { run_script(script) { transport.get('/x') } }
    assert_equal 1, script.calls
    assert_empty @sleeper.delays
  end

  def test_exhausted_network_retries_raise_http_error
    [Timeout::Error, IOError, Errno::ECONNRESET].each do |klass|
      script = Script.new(klass.new, klass.new, klass.new)
      assert_raises(HTTP::Error) { run_script(script) { transport.get('/x') } }
      assert_equal 3, script.calls
      assert_equal [0.5, 1.0], @sleeper.delays
    end
  end

  def test_recovers_from_a_network_error
    script = Script.new(Errno::ECONNREFUSED.new, '{}')
    assert_equal '{}', run_script(script) { transport.get('/x') }
    assert_equal [0.5], @sleeper.delays
  end

  def test_zero_retries_means_one_attempt
    script = Script.new(503, '{}')
    assert_raises(HTTP::ResponseError) { run_script(script) { transport(retries: 0).get('/x', params: { a: 1 }) } }
    assert_equal 1, script.calls
  end

  def test_rejects_body_over_sixteen_mebibytes_without_retry
    limit = 16 * 1024 * 1024
    script = Script.new(['a' * limit, 'b'], '{}')
    assert_raises(HTTP::LimitError) { run_script(script) { transport.get('/x') } }
    assert_equal 1, script.calls
  end

  def test_accepts_body_of_exactly_sixteen_mebibytes
    limit = 16 * 1024 * 1024
    body = run_script(Script.new(['a' * limit])) { transport.get('/x') }
    assert_equal limit, body.bytesize
  end

  def test_custom_byte_limit
    assert_raises(HTTP::LimitError) { run_script(Script.new(['abcd'])) { transport(max_bytes: 3).get('/x') } }
  end

  def test_expired_deadline_stops_before_any_request
    script = Script.new('{}')
    past = Process.clock_gettime(Process::CLOCK_MONOTONIC) - 1
    assert_raises(HTTP::LimitError) { run_script(script) { transport.get('/x', deadline: past) } }
    assert_equal 0, script.calls
  end

  def test_deadline_error_is_a_transport_error
    assert_operator HTTP::LimitError, :<, HTTP::Error
    assert_operator HTTP::ResponseError, :<, HTTP::Error
  end
end
