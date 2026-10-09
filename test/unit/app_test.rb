require_relative '../test_helper'
require 'rack/test'
require 'app'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    ForestRadar::App
  end

  def test_home_page
    get '/', {}, 'HTTP_HOST' => 'localhost'
    assert_equal 200, last_response.status
  end

  def test_invalid_boundary_values
    [{ lat: 'NaN', lon: 0, radius_km: 1 }, { lat: 91, lon: 0, radius_km: 1 },
     { lat: 0, lon: -181, radius_km: 1 }, { lat: 0, lon: 0, radius_km: 21 }].each do |input|
      post '/api/card', JSON.generate(input), 'CONTENT_TYPE' => 'application/json', 'HTTP_HOST' => 'localhost'
      assert_equal 422, last_response.status
    end
  end

  def test_model_host_is_not_read_from_request
    post '/api/card', JSON.generate(lat: 0, lon: 0, radius_km: 0, ollama_url: 'http://evil.example'),
         'CONTENT_TYPE' => 'application/json', 'HTTP_HOST' => 'localhost'
    assert_equal 422, last_response.status
  end
end
