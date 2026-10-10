# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientParallelPaginationTest < Minitest::Test
  class ConcurrentReplay
    BLOCKED_OFFSETS = (2..4)
    PEER_WAIT_SECONDS = 0.25

    attr_reader :calls, :maximum, :threads

    def initialize(pages, error_offset: nil, blocking_offsets: [])
      @pages = pages
      @error_offset = error_offset
      @blocking_offsets = blocking_offsets
      initialize_state
    end

    def initialize_state
      @calls = []
      @threads = []
      initialize_activity
      initialize_mutex
    end

    def initialize_activity
      @in_flight = 0
      @requests_seen = 0
      @maximum = 0
    end

    def initialize_mutex
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @blocked_condition = ConditionVariable.new
    end

    def get(path, params:, deadline:)
      offset = params.fetch('offset', '0').to_i
      enter(path, params, deadline, offset)
      response(offset)
    ensure
      leave
    end

    def response(offset)
      block_request(offset) if @blocking_offsets.include?(offset)
      raise IOError, 'page failed' if offset == @error_offset

      @pages.fetch(offset)
    end

    private

    def enter(path, params, deadline, offset)
      record_request(path, params, deadline, offset)
      wait_for_peer if offset.positive?
    end

    def record_request(path, params, deadline, offset)
      @mutex.synchronize do
        record_call(path, params, deadline)
        record_activity(offset)
      end
    end

    def record_call(path, params, deadline)
      @calls << [path, params.dup, deadline]
    end

    def record_activity(offset)
      @in_flight += 1
      @maximum = [@maximum, @in_flight].max
      @requests_seen += 1 if offset.positive?
      @threads << Thread.current unless offset.zero?
    end

    def wait_for_peer
      @mutex.synchronize do
        @condition.broadcast
        @condition.wait(@mutex, PEER_WAIT_SECONDS) if @requests_seen < 2
      end
    end

    def block_request(offset)
      wait_until_block_deadline
      @mutex.synchronize { @calls << [:released, offset] }
    end

    def wait_until_block_deadline
      deadline = monotonic_now + PEER_WAIT_SECONDS
      @mutex.synchronize { wait_while_blocked(deadline) }
    end

    def wait_while_blocked(deadline)
      while (remaining = deadline - monotonic_now).positive?
        @blocked_condition.wait(@mutex, remaining)
      end
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def leave
      @mutex.synchronize { @in_flight -= 1 }
    end
  end

  def pages(count)
    (0...count).to_h do |offset|
      remaining = count - offset
      [offset, { numberMatched: remaining,
                 features: [{ id: offset, properties: {} }], links: [] }.to_json]
    end
  end

  def client(transport)
    BDL::Client.new(transport: transport, clock: -> { 100 }, page_size: 1, concurrency: 4)
  end

  def test_later_pages_overlap_with_at_most_four_requests
    transport = ConcurrentReplay.new(pages(7))
    items = client(transport).features('rdlp', bbox: [0, 0, 1, 1])
    assert_equal 7, items.length
    assert_operator transport.maximum, :>, 1
    assert_operator transport.maximum, :<=, 4
  end

  def test_later_page_error_raises_incomplete_and_joins_workers
    transport = ConcurrentReplay.new(pages(7), error_offset: 2)
    error = assert_raises(BDL::Incomplete) { read(transport) }
    assert_equal 'page failed', error.message
    refute transport.threads.any?(&:alive?)
  end

  def test_first_later_page_error_joins_workers_even_when_other_pages_block
    transport = blocked_transport

    error = assert_raises(BDL::Incomplete) { read(transport) }

    assert_equal 'page failed', error.message
    refute transport.threads.any?(&:alive?), 'read returned while a worker was alive'
  end

  def test_first_error_returns_before_blocked_workers_finish_and_stops_new_requests
    transport = blocked_transport

    error = assert_raises(BDL::Incomplete) { read(transport) }
    assert_equal 'page failed', error.message
    refute_block_released(transport)
    refute_page_requested(transport, '5')
  end

  def read(transport)
    client(transport).features('rdlp', bbox: [0, 0, 1, 1])
  end

  def blocked_transport
    ConcurrentReplay.new(pages(10), error_offset: 1,
                                    blocking_offsets: ConcurrentReplay::BLOCKED_OFFSETS)
  end

  def refute_block_released(transport)
    refute_includes transport.calls, [:released, 2], 'blocked worker finished before read raised'
  end

  def refute_page_requested(transport, offset)
    requested = transport.calls.any? { |call| call[1].is_a?(Hash) && call[1]['offset'] == offset }
    refute requested, 'read started an offset after the first error'
  end
end
