require 'json'
require 'net/http'
require 'timeout'
require 'uri'
require 'yaml'
require_relative 'validator'

module Model
  class Client
    PROMPT = 'Odpowiedz po polsku. Zwróć FAKTY i WNIOSKI. W FAKTY przepisz każdą linię bez zmian. ' \
             'WNIOSKI to ostrożne sugestie. Nie oceniaj grzybów jako jadalnych ani trujących. ' \
             'Nie obiecuj dostępu do lasu.'

    def self.from_config(path = File.expand_path('../../config/model.yml', __dir__), http: Net::HTTP)
      config = YAML.safe_load_file(path)
      config.fetch('client') == 'stub' ? Stub.new : new(config.fetch('url'), config.fetch('model'), http: http)
    end

    def initialize(url, model, http: Net::HTTP)
      @uri = URI(url)
      raise ArgumentError, 'invalid Ollama URL' unless %w[http https].include?(@uri.scheme) && @uri.host
      @model, @http = model, http
    end

    def generate(lines, deadline: Process.clock_gettime(Process::CLOCK_MONOTONIC) + 29)
      2.times do |attempt|
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        raise Deadline, 'model deadline' if remaining <= 0
        begin
          advice = Timeout.timeout(remaining) { Validator.new.validate(request(lines, remaining), lines) }
          raise Deadline, 'model deadline' if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
          return advice
        rescue Timeout::Error
          expired = Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
          raise Deadline, 'model deadline' if attempt == 1 || expired
        rescue Invalid, IOError, SystemCallError, JSON::ParserError, KeyError
          raise Invalid, 'unusable model response' if attempt == 1
        end
      end
    end

    private

    def request(lines, remaining)
      uri = @uri + '/api/chat'
      body = { model: @model, stream: false, messages: [
        { role: 'system', content: PROMPT },
        { role: 'user', content: "FAKTY\n#{lines.map { |id, value| "#{id}: #{value}" }.join("\n")}" }
      ] }
      response = @http.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: remaining,
                             read_timeout: remaining) { |connection| connection.post(uri.request_uri, JSON.generate(body),
                                                                                       'Content-Type' => 'application/json') }
      raise Invalid, 'model HTTP error' unless response.code == '200'
      JSON.parse(response.body).fetch('message').fetch('content')
    end
  end

  class Stub
    def generate(lines, deadline: nil)
      'Sprawdź warunki w terenie.'
    end
  end
end
