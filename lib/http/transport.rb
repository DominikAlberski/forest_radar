# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'openssl'

module HTTP
  class Error < StandardError; end
  class LimitError < Error; end
  class ResponseError < Error; end

  class Transport
    def initialize(base_url:, user_agent:, max_bytes: 16 * 1024 * 1024, timeout: 10, retries: 0, sleeper: Kernel)
      @base = URI(base_url)
      @user_agent = user_agent
      @max_bytes = max_bytes
      @timeout = timeout
      @retries = retries
      @sleeper = sleeper
    end

    def get(path, params: {}, deadline: nil)
      uri = @base + path
      uri.query = URI.encode_www_form(params) unless params.empty?
      attempts = 0
      begin
        remaining(deadline)
        request(uri, deadline)
      rescue Timeout::Error, IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError, ResponseError => error
        if attempts >= @retries || (error.is_a?(ResponseError) && !error.message.start_with?('5'))
          raise error if error.is_a?(ResponseError)

          raise Error, error.message
        end
        delay = 0.5 * (2**attempts)
        raise LimitError, 'deadline exceeded' if remaining(deadline) < delay

        @sleeper.sleep(delay)
        attempts += 1
        retry
      end
    end

    private

    def remaining(deadline)
      seconds = deadline ? [@timeout, deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)].min : @timeout
      raise LimitError, 'deadline exceeded' if seconds <= 0

      seconds
    end

    def request(uri, deadline)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: remaining(deadline),
                                          read_timeout: remaining(deadline)) do |http|
        http.max_retries = 0 if http.respond_to?(:max_retries=)
        http.read_timeout = remaining(deadline) if http.respond_to?(:read_timeout=)
        body = +''
        http.request(Net::HTTP::Get.new(uri, 'User-Agent' => @user_agent)) do |response|
          raise ResponseError, response.code unless response.is_a?(Net::HTTPSuccess)

          response.read_body do |chunk|
            body << chunk
            raise LimitError, 'response too large' if body.bytesize > @max_bytes

            remaining(deadline)
            http.read_timeout = remaining(deadline) if http.respond_to?(:read_timeout=)
          end
        end
        body
      end
    end
  end
end
