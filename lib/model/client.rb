# frozen_string_literal: true

require 'json'
require 'net/http'
require 'timeout'
require 'uri'
require 'yaml'
require_relative 'errors'
require_relative 'env_file'

module Model
  # Returns the model description without content checks.
  class Client
    PROMPT = 'Co możesz dodatkowo powiedzieć o tym lesie na podstawie danych z BDL? ' \
             'Interesujące nas informacje to powierzchnia lasu, dostępność dla spacerowiczów, ' \
             'możliwe do napotkania zwierzęta, rośliny i grzyby.'

    # Runs one request within a deadline.
    Generation = Struct.new(:deadline, :request, :clock) do
      def run
        attempt
      rescue Timeout::Error
        raise Deadline, 'model deadline'
      rescue IOError, SystemCallError, JSON::ParserError, KeyError
        raise Invalid, 'model request failed'
      end

      private

      def attempt
        remaining = remaining_budget
        advice = Timeout.timeout(remaining) { request.call(remaining) }
        check_deadline
        advice
      end

      def remaining_budget
        remaining = deadline - clock.call
        raise Deadline, 'model deadline' if remaining <= 0

        remaining
      end

      def check_deadline
        raise Deadline, 'model deadline' if clock.call >= deadline
      end
    end

    private_constant :Generation

    def self.from_config(path = File.expand_path('../../config/model.yml', __dir__),
                         env_path: default_env_path(path), http: Net::HTTP)
      config = YAML.safe_load_file(path)
      config.merge!(EnvFile.read(env_path)) if env_path && File.file?(env_path)
      config.fetch('client') == 'stub' ? Stub.new : new(config.fetch('url'), config.fetch('model'), http: http)
    end

    def self.default_env_path(path)
      File.expand_path('../.env', File.dirname(path)) unless ENV['RACK_ENV'] == 'test'
    end

    def initialize(url, model, http: Net::HTTP)
      @uri = URI(url)
      raise ArgumentError, 'invalid Ollama URL' unless %w[http https].include?(@uri.scheme) && @uri.host

      @model = model
      @http = http
      @clock = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
    end

    def generate(lines, deadline: Process.clock_gettime(Process::CLOCK_MONOTONIC) + 59)
      Generation.new(deadline, ->(remaining) { request(lines, remaining) }, @clock).run
    end

    private

    def request(lines, remaining)
      response = response_for(lines, remaining)
      raise Invalid, 'model HTTP error' unless response.code == '200'

      JSON.parse(response.body).fetch('message').fetch('content')
    end

    def response_for(lines, remaining)
      @http.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https', open_timeout: remaining,
                                        read_timeout: remaining) { |connection| post(connection, lines) }
    end

    def post(connection, lines)
      uri = URI.join(@uri.to_s, '/api/chat')
      connection.post(uri.request_uri, JSON.generate(request_body(lines)), 'Content-Type' => 'application/json')
    end

    def request_body(lines)
      facts = lines.map { |id, value| "#{id}: #{value}" }.join("\n")
      { model: @model, stream: false, messages: [
        { role: 'user', content: "#{PROMPT}\n\nDane z BDL:\n#{facts}" }
      ] }
    end
  end

  # Supplies deterministic advice when the model is disabled.
  class Stub
    def generate(_lines, **)
      'Sprawdź warunki w terenie.'
    end
  end
end
