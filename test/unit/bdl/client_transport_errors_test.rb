# frozen_string_literal: true

require_relative '../../test_helper'
require 'bdl/client'

# Defect 1: lib/bdl/client.rb rescues only HTTP::Error, so raw network
# exceptions escape instead of becoming BDL::Incomplete.
class ClientTransportErrorsTest < Minitest::Test
  class Failing
    def initialize(error)
      @error = error
    end

    def get(_path, **)
      raise @error
    end
  end

  [Timeout::Error, IOError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::ETIMEDOUT, SocketError].each do |klass|
    define_method("test_#{klass.name.gsub('::', '_').downcase}_becomes_incomplete") do
      client = BDL::Client.new(transport: Failing.new(klass.new('boom')))
      assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
    end
  end

  def test_http_error_becomes_incomplete
    client = BDL::Client.new(transport: Failing.new(HTTP::ResponseError.new('503')))
    assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
  end

  def test_deadline_error_becomes_incomplete
    client = BDL::Client.new(transport: Failing.new(HTTP::LimitError.new('deadline exceeded')))
    assert_raises(BDL::Incomplete) { client.features('rdlp', bbox: [0, 0, 1, 1]) }
  end

  def test_search_reports_network_failure_as_incomplete
    client = BDL::Client.new(transport: Failing.new(Timeout::Error.new('late')))
    assert_raises(BDL::Incomplete) { client.search(lat: 52.0, lon: 21.0, radius_km: 1) }
  end
end
