# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'openssl'
require_relative 'transport_options'

module HTTP
  # Reports a failed HTTP request.
  class Error < StandardError; end
  # Reports an exceeded request limit.
  class LimitError < Error; end
  # Reports a non-success response status.
  class ResponseError < Error; end

  # Fetches bounded HTTP responses with controlled retries.
  class Transport
    RETRY_REQUEST = Object.new.freeze

    def initialize(base_url:, user_agent:, **options)
      @base = URI(base_url)
      @user_agent = user_agent
      @options = TransportOptions.new(options)
    end

    def get(path, params: {}, deadline: nil)
      uri = @base + path
      uri.query = URI.encode_www_form(params) unless params.empty?
      fetch_with_retries(uri, deadline)
    end

    private

    def fetch_with_retries(request_uri, cutoff)
      attempts = 0
      while (result = try_request(request_uri, cutoff, attempts)).equal?(RETRY_REQUEST)
        attempts += 1
      end
      result
    end

    def try_request(request_uri, cutoff, attempts)
      remaining(cutoff)
      request(request_uri, cutoff)
    rescue Timeout::Error, IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError, ResponseError => error
      handle_failure(error, attempts, cutoff)
      RETRY_REQUEST
    end

    def handle_failure(error, attempts, deadline)
      message = error.message
      raise_terminal_failure(error, message) if terminal_failure?(error, message, attempts)

      wait_before_retry(attempts, deadline)
    end

    def terminal_failure?(error, message, attempts)
      attempts >= @options.retries || (error.is_a?(ResponseError) && !message.start_with?('5'))
    end

    def raise_terminal_failure(error, message)
      raise error if error.is_a?(ResponseError)

      raise Error, message
    end

    def wait_before_retry(attempts, deadline)
      delay = 0.5 * (2**attempts)
      raise LimitError, 'deadline exceeded' if remaining(deadline) < delay

      @options.sleeper.sleep(delay)
    end

    def remaining(deadline)
      timeout = @options.timeout
      seconds = deadline ? [timeout, deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)].min : timeout
      raise LimitError, 'deadline exceeded' if seconds <= 0

      seconds
    end

    def request(target, expires_at)
      Net::HTTP.start(target.host, target.port, **connection_options(target, expires_at)) do |http|
        http.max_retries = 0
        http.read_timeout = remaining(expires_at)
        read_response(http, target, expires_at)
      end
    end

    def connection_options(address, deadline)
      timeout = remaining(deadline)
      { use_ssl: address.scheme == 'https', open_timeout: timeout, read_timeout: timeout }
    end

    def read_response(connection, address, expires_at)
      body = +''
      connection.request(Net::HTTP::Get.new(address, 'User-Agent' => @user_agent)) do |response|
        read_checked_body(response, body, connection, expires_at)
      end
      body
    end

    def read_checked_body(response, body, connection, expires_at)
      validate_response(response)
      response.read_body { |chunk| append_chunk(body, chunk, connection, expires_at) }
    end

    def validate_response(response)
      case response
      when Net::HTTPSuccess then nil
      else raise ResponseError, response.code
      end
    end

    def append_chunk(body, chunk, channel, cutoff)
      body << chunk
      raise LimitError, 'response too large' if body.bytesize > @options.max_bytes

      timeout = remaining(cutoff)
      channel.read_timeout = timeout
    end
  end
end
