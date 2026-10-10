# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

class ClientDefaultsTest < Minitest::Test
  class EightPageReplay
    attr_reader :maximum, :limits, :deadlines

    def initialize
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @active = @maximum = 0
      @limits = []
      @deadlines = []
    end

    def get(_path, params:, deadline:)
      offset = params.fetch('offset').to_i
      enter(offset, params.fetch(:limit), deadline)
      page(offset)
    ensure
      leave(offset)
    end

    def enter(offset, limit, deadline)
      @mutex.synchronize do
        record_request(limit, deadline)
        record_activity(offset)
        wait_for_peers(offset)
      end
    end

    def record_request(limit, deadline)
      @limits << limit
      @deadlines << deadline
    end

    def wait_for_peers(offset)
      @condition.broadcast
      @condition.wait(@mutex, 0.5) if offset.positive? && @maximum < 8
    end

    def record_activity(offset)
      @active += 1 unless offset.zero?
      @maximum = [@maximum, @active].max
    end

    def leave(offset)
      @mutex.synchronize { @active -= 1 } unless offset.zero?
    end

    def page(offset)
      features = Array.new(1000) { { properties: {} } }
      { numberMatched: 9000 - offset, features: features, links: [] }.to_json
    end
  end

  def test_client_uses_1000_items_and_eight_parallel_requests_by_default
    replay = EightPageReplay.new
    items = BDL::Client.new(transport: replay, clock: -> { 100 }).features('rdlp', bbox: [0, 0, 1, 1])
    assert_defaults(replay, items)
  end

  def assert_defaults(replay, items)
    assert_equal 9000, items.length
    assert_equal [1000], replay.limits.uniq
    assert_equal [160], replay.deadlines.uniq
    assert_equal 8, replay.maximum
  end
end
