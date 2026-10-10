# frozen_string_literal: true

module Model
  # Gives model requests one FIFO turn at a time.
  class RequestQueue
    def initialize
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @pending = []
    end

    def run
      ticket = Object.new
      wait_for_turn(ticket)
      yield
    ensure
      release(ticket)
    end

    SHARED = new

    private

    def wait_for_turn(ticket)
      @mutex.synchronize do
        @pending << ticket
        @condition.wait(@mutex) until @pending.first.equal?(ticket)
      end
    end

    def release(ticket)
      @mutex.synchronize do
        @pending.delete(ticket)
        @condition.broadcast
      end
    end
  end
end
