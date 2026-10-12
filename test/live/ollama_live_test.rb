# frozen_string_literal: true

require_relative '../test_helper'
require 'model/client'

class OllamaLiveTest < Minitest::Test
  def test_ollama_returns_description
    client = Model::Client.from_config
    assert_instance_of Model::Client, client
    answer = client.generate({ 'F1' => 'name=Las testowy', 'F2' => 'species=SO', 'F3' => 'total_area=1.5' })
    assert_instance_of String, answer
    puts "Ollama response:\n#{answer}"
  end
end
