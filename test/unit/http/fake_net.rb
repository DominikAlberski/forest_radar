# frozen_string_literal: true

require 'net/http'
require 'http/transport'

# Test doubles for Net::HTTP and the monotonic clock. No test opens a socket.
module FakeNet
  class Clock
    attr_accessor :now

    def initialize(now = 1000.0)
      @now = now
    end

    def advance(seconds)
      @now += seconds
    end

    def sleep(seconds)
      advance(seconds)
    end

    def install
      clock = self
      @original = Process.method(:clock_gettime)
      Process.define_singleton_method(:clock_gettime) { |*_args| clock.now }
    end

    def uninstall
      Process.define_singleton_method(:clock_gettime, @original)
    end
  end

  class Connection
    attr_accessor :open_timeout, :read_timeout, :max_retries, :use_ssl
    attr_reader :script, :clock

    def initialize(script, step)
      @script = script
      @step = step
      @max_retries = 1 # Net::HTTP default
    end

    def request(_request)
      script.max_retries_seen << max_retries
      step = @step
      script.clock&.advance([step[:read_seconds], read_timeout || Float::INFINITY].min) if step[:read_seconds]
      raise Net::ReadTimeout if step[:read_seconds] && read_timeout && step[:read_seconds] > read_timeout

      response = Net::HTTPOK.new('1.1', '200', '')
      body = step[:body]
      response.define_singleton_method(:read_body) { |&block| block.call(body) }
      yield response
    end
  end

  class Script
    attr_reader :calls, :max_retries_seen, :clock

    # A step is an Exception to raise, a String body, or a Hash with :body, :connect_seconds, :read_seconds.
    def initialize(*steps, clock: nil)
      @steps = steps
      @clock = clock
      @calls = 0
      @max_retries_seen = []
    end

    def start(_host, _port, **options)
      @calls += 1
      step = @steps.shift
      raise step if step.is_a?(Exception)

      step = { body: step } if step.is_a?(String)
      connection = Connection.new(self, step)
      options.each { |key, value| connection.public_send("#{key}=", value) if connection.respond_to?("#{key}=") }
      connect = step[:connect_seconds]
      if connect
        @clock.advance([connect, connection.open_timeout || Float::INFINITY].min)
        raise Net::OpenTimeout if connection.open_timeout && connect > connection.open_timeout
      end
      yield connection
    end

    def install
      script = self
      @original = Net::HTTP.method(:start)
      Net::HTTP.define_singleton_method(:start) { |*args, **options, &block| script.start(*args, **options, &block) }
    end

    def uninstall
      Net::HTTP.define_singleton_method(:start, @original)
    end
  end

  module_function

  def with(script, clock = nil)
    clock&.install
    script.install
    yield
  ensure
    script.uninstall
    clock&.uninstall
  end
end
