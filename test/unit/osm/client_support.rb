# frozen_string_literal: true

require_relative '../http/fake_net'

# Provides a rate-limit response for OSM client tests.
module OSMTestSupport
  class StatusScript < FakeNet::Script
    def start(*, **)
      super do |connection|
        busy_response(connection)
        yield connection
      end
    end

    def busy_response(connection)
      connection.define_singleton_method(:request) do |_request, &block|
        block.call(Net::HTTPTooManyRequests.new('1.1', '429', 'busy'))
      end
    end
  end
end
