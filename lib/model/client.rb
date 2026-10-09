# frozen_string_literal: true

require 'json'
require 'net/http'
require 'timeout'
require 'uri'
require 'yaml'
require_relative 'validator'

module Model
  # Requests bounded, validated advice from the configured model.
  class Client
    PROMPT = 'Odpowiedz po polsku. Zwróć FAKTY i WNIOSKI. W FAKTY przepisz każdą linię bez zmian. ' \
             'WNIOSKI to ostrożne sugestie. Nie oceniaj grzybów jako jadalnych ani trujących. ' \
             'Nie obiecuj dostępu do lasu.'

    # Runs one request and retries one unusable response within a deadline.
    Generation = Struct.new(:lines, :deadline, :request, :clock) do
      def run
        attempt
      rescue Timeout::Error
        retry_after_timeout
      rescue Invalid, IOError, SystemCallError, JSON::ParserError, KeyError
        final_attempt
      end

      private

      def retry_after_timeout
        remaining_budget
        final_attempt
      end

      def final_attempt
        attempt
      rescue Timeout::Error
        raise Deadline, 'model deadline'
      rescue Invalid, IOError, SystemCallError, JSON::ParserError, KeyError
        raise Invalid, 'unusable model response'
      end

      def attempt
        remaining = remaining_budget
        advice = Timeout.timeout(remaining) { Validator.new.validate(request.call(remaining), lines) }
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

    def self.from_config(path = File.expand_path('../../config/model.yml', __dir__), http: Net::HTTP)
      config = YAML.safe_load_file(path)
      config.fetch('client') == 'stub' ? Stub.new : new(config.fetch('url'), config.fetch('model'), http: http)
    end

    def initialize(url, model, http: Net::HTTP)
      @uri = URI(url)
      raise ArgumentError, 'invalid Ollama URL' unless %w[http https].include?(@uri.scheme) && @uri.host

      @model = model
      @http = http
      @clock = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
    end

    def generate(lines, deadline: Process.clock_gettime(Process::CLOCK_MONOTONIC) + 29)
      Generation.new(lines, deadline, ->(remaining) { request(lines, remaining) }, @clock).run
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
        { role: 'system', content: PROMPT }, { role: 'user', content: "FAKTY\n#{facts}" }
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
