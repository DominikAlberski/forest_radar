# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientParallelPaginationTest < Minitest::Test
  class ConcurrentReplay
    attr_reader :calls, :maximum, :threads

    def initialize(pages, error_offset: nil)
      @pages = pages
      @error_offset = error_offset
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
    end

    def get(path, params:, deadline:)
      offset = params.fetch('offset', '0').to_i
      enter(path, params, deadline, offset)
      leave
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
        @condition.wait(@mutex, 0.25) while @requests_seen < 2
      end
    end

    def leave
      @mutex.synchronize { @in_flight -= 1 }
    end
  end

  def pages(count)
    (0...count).to_h do |offset|
      remaining = count - offset
      [offset, { numberMatched: remaining, features: [{ id: offset }], links: [] }.to_json]
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

  def read(transport)
    client(transport).features('rdlp', bbox: [0, 0, 1, 1])
  end
end
