# frozen_string_literal: true

module BDL
  # Reads collections in one phase and returns them in input order.
  class PhaseReads
    def initialize(state, client, names)
      @state = state
      @client = client
      @names = names
    end

    def read
      responses = Queue.new
      workers = @names.map { |name| worker(name, responses) }
      collect(responses)
    ensure
      self.class.stop(workers)
    end

    private

    def worker(name, responses)
      Thread.new do
        Thread.current.report_on_exception = false
        fetch(name, responses)
      end
    end

    def fetch(name, responses)
      responses << [name, @state.read(@client, name)]
    rescue StandardError => error
      responses << [:error, error]
    end

    public

    def self.stop(workers)
      workers&.each { |thread| thread.kill if thread.alive? }
      workers&.each(&:join)
    end

    def collect(responses)
      results = {}
      @names.size.times { receive(responses, results) }
      @names.to_h { |name| [name, results.fetch(name)] }
    end

    def receive(responses, results)
      name, items = responses.pop
      raise items if name == :error

      results[name] = items
    end
  end
end
