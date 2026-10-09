require_relative '../test_helper'
require 'json'
require 'net/http'
require 'yaml'
require 'model/client'

# Live M5 check against the Ollama endpoint that the author supplies.
# A missing endpoint FAILS this test. A fixture cannot satisfy live M5.
#
#   OLLAMA_URL=http://host:11434 OLLAMA_MODEL=<tag> OLLAMA_HOST_HARDWARE='<description>' \
#     coord with-lock ollama -- bundle exec ruby test/run.rb --live
#
# The test prints one EVIDENCE line: model identity, host hardware, warm state, timing with retries,
# and the Polish output. Copy that line into docs/plans/m1-m7-evidence.md.
class OllamaLiveTest < Minitest::Test
  LINES = { 'F1' => 'areas[0].name=Las testowy', 'F2' => 'areas[0].distance_km=2.5',
            'F3' => 'areas[0].species={"SO"=>3}', 'F4' => 'areas[0].years={2024=>3}' }.freeze
  POLISH = /[ąćęłńóśźż]|\b(?:się|nie|oraz|przed|las|lesie)\b/i

  class CountingHTTP
    attr_reader :posts

    def initialize
      @posts = 0
    end

    def start(*args, **options, &block)
      Net::HTTP.start(*args, **options) do |connection|
        counter = self
        connection.define_singleton_method(:post) do |*post_args|
          counter.instance_variable_set(:@posts, counter.posts + 1)
          super(*post_args)
        end
        block.call(connection)
      end
    end
  end

  def setup
    @url = ENV['OLLAMA_URL'].to_s
    @hardware = ENV['OLLAMA_HOST_HARDWARE'].to_s
    flunk 'OLLAMA_URL is not set. Live M5 cannot pass without the supplied endpoint.' if @url.empty?
    flunk 'OLLAMA_HOST_HARDWARE is not set. Record the host hardware.' if @hardware.empty?
    @model = ENV.fetch('OLLAMA_MODEL') { YAML.safe_load_file(File.expand_path('../../config/model.yml', __dir__)).fetch('model') }
  end

  def clock
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def identity
    uri = URI("#{@url}/api/show")
    body = Net::HTTP.post(uri, JSON.generate(model: @model), 'Content-Type' => 'application/json')
    flunk "model #{@model} is unknown to #{@url}: HTTP #{body.code}" unless body.code == '200'
    details = JSON.parse(body.body)['details'] || {}
    { model: @model, family: details['family'], parameters: details['parameter_size'], quantization: details['quantization_level'] }
  end

  def timed_call
    http = CountingHTTP.new
    client = Model::Client.new(@url, @model, http: http)
    started = clock
    advice = client.generate(LINES, deadline: started + 29)
    [advice, (clock - started).round(2), http.posts]
  end

  def test_m5_model_answers_in_polish_within_the_budget
    model = identity
    cold, cold_seconds, cold_posts = timed_call
    advice, warm_seconds, warm_posts = timed_call
    puts "EVIDENCE #{JSON.generate(model: model, hardware: @hardware, cold_seconds: cold_seconds, cold_posts: cold_posts,
                                    warm_seconds: warm_seconds, warm_posts: warm_posts, output: advice)}"
    assert_match POLISH, advice
    assert_match POLISH, cold
    assert_operator warm_seconds, :<, 30
    assert_operator cold_seconds, :<, 30
  end

  def test_m5_validator_rejects_unsafe_live_looking_answers
    unsafe = "FAKTY\n#{LINES.map { |id, v| "#{id}: #{v}" }.join("\n")}\nWNIOSKI\nTen grzyb jest jadalny. Las jest otwarty."
    assert_raises(Model::Invalid) { Model::Validator.new.validate(unsafe, LINES) }
  end
end
