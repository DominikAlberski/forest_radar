# frozen_string_literal: true

require_relative '../../test_helper'
require 'model/request_queue'
require 'timeout'

class RequestQueueTest < Minitest::Test
  def setup
    @queue = Model::RequestQueue.new
    @started = Queue.new
    @finish = Queue.new
    @threads = []
  end

  def teardown
    @threads.each(&:kill)
    @threads.each(&:join)
  end

  def start_request(number)
    @threads << Thread.new { @queue.run { blocked_request(number) } }
    @threads.last
  end

  def blocked_request(number)
    @started << number
    @finish.pop
    "Response #{number}"
  end

  def next_started
    Timeout.timeout(2) { @started.pop }
  end

  def wait_until_waiting(thread)
    Timeout.timeout(2) { Thread.pass until thread.status == 'sleep' }
  end

  def test_requests_run_in_fifo_order_without_overlap
    start_request(1)
    assert_equal 1, next_started
    wait_until_waiting(start_request(2))
    wait_until_waiting(start_request(3))
    assert_fifo_completion
  end

  def assert_fifo_completion
    assert @started.empty?
    @finish << true
    assert_equal 2, next_started
    assert @started.empty?
    finish_last_requests
  end

  def finish_last_requests
    @finish << true
    assert_equal 3, next_started
    @finish << true
    assert_equal ['Response 1', 'Response 2', 'Response 3'], @threads.map(&:value)
  end

  def test_failed_request_releases_the_queue
    assert_raises(IOError) { @queue.run { raise IOError, 'offline' } }
    assert_equal('next response', @queue.run { 'next response' })
  end

  def test_cancelled_waiting_request_does_not_block_the_next_request
    start_request(1)
    assert_equal 1, next_started
    waiting = start_request(2)
    wait_until_waiting(waiting)
    assert_cancelled_request_is_skipped(waiting)
  end

  def assert_cancelled_request_is_skipped(waiting)
    waiting.kill.join
    @finish << true
    start_request(3)
    assert_equal 3, next_started
    @finish << true
  end
end
