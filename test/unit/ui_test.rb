# frozen_string_literal: true

require_relative '../test_helper'
require 'rack/test'
require 'app'

class UiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    ForestRadar::App
  end

  def test_search_page_has_accessible_controls_and_assets
    get '/', {}, 'HTTP_HOST' => 'localhost'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<html lang="pl">'
    assert_includes last_response.body, 'id="search-form"'
    assert_includes last_response.body, 'aria-live="polite"'
    assert_includes last_response.body, 'min="1" max="20"'
    get '/app.js', {}, 'HTTP_HOST' => 'localhost'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "form.addEventListener('submit'"
    get '/style.css', {}, 'HTTP_HOST' => 'localhost'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '@page { size: A4;'
  end
end
