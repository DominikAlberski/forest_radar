# frozen_string_literal: true

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
  # SMOKE CHECK ONLY. Any one accented letter or listed word passes, so English advice with a name such as
  # "Łódź" also passes. Live M5 needs a recorded human language review before it counts as accepted.
  POLISH = /[ąćęłńóśźż]|\b(?:się|nie|oraz|przed|las|lesie)\b/i

  class CountingHTTP
    attr_reader :posts

    def initialize
      @posts = 0
    end

    def start(*, **, &block)
      Net::HTTP.start(*, **) { |connection| count_posts(connection, block) }
    end

    def count_posts(connection, block)
      counter = self
      wrap_post(connection, counter)
      block.call(connection)
    end

    def wrap_post(connection, counter)
      connection.define_singleton_method(:post) do |*post_args|
        counter.instance_variable_set(:@posts, counter.posts + 1)
        super(*post_args)
      end
    end
  end

  def setup
    @url = ENV['OLLAMA_URL'].to_s
    @hardware = ENV['OLLAMA_HOST_HARDWARE'].to_s
    require_live_config
    @model = configured_model
  end

  def require_live_config
    flunk 'OLLAMA_URL is not set. Live M5 cannot pass without the supplied endpoint.' if @url.empty?
    flunk 'OLLAMA_HOST_HARDWARE is not set. Record the host hardware.' if @hardware.empty?
  end

  def configured_model
    ENV.fetch('OLLAMA_MODEL') { model_from_config }
  end

  def model_from_config
    path = File.expand_path('../../config/model.yml', __dir__)
    YAML.safe_load_file(path).fetch('model')
  end

  def clock
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def identity
    uri = URI("#{@url}/api/show")
    body = Net::HTTP.post(uri, JSON.generate(model: @model), 'Content-Type' => 'application/json')
    model_identity(identity_details(body))
  end

  def identity_details(body)
    flunk "model #{@model} is unknown to #{@url}: HTTP #{body.code}" unless body.code == '200'
    JSON.parse(body.body)['details'] || {}
  end

  def model_identity(details)
    { model: @model, family: details['family'], parameters: details['parameter_size'],
      quantization: details['quantization_level'] }
  end

  def timed_call
    http = CountingHTTP.new
    client = Model::Client.new(@url, @model, http: http)
    started = clock
    advice = client.generate(LINES, deadline: started + 29)
    [advice, (clock - started).round(2), http.posts]
  end

  def unsafe_answer
    "FAKTY\n#{LINES.map { |id, v| "#{id}: #{v}" }.join("\n")}\nWNIOSKI\nTen grzyb jest jadalny. Las jest otwarty."
  end

  def rejected?
    Model::Validator.new.validate(unsafe_answer, LINES)
    false
  rescue Model::Invalid
    true
  end

  # The first request state is "unknown": the test does not check whether Ollama already held the model in memory.
  def test_m5_model_answers_within_the_budget_and_prints_evidence_after_the_assertions
    model = identity
    first, second = live_calls
    rejection = rejected?
    assert_live_answers(first, second, rejection)
    print_evidence(model, first, second, rejection)
  end

  def live_calls
    [timed_call, timed_call]
  end

  def assert_live_answers(first, second, rejection)
    [first, second].each { |advice, seconds, _posts| assert_answer(advice, seconds) }
    assert rejection, 'validator accepted an unsafe answer'
  end

  def assert_answer(advice, seconds)
    assert_match POLISH, advice
    assert_operator seconds, :<, 30
  end

  def print_evidence(model, first, second, rejection)
    puts "EVIDENCE #{JSON.generate(evidence(model, first, second, rejection))}"
  end

  def evidence(model, first, second, rejection)
    { model: model, hardware: @hardware, first: request_evidence(first, 'unknown'),
      second: request_evidence(second, 'follows a first request'),
      rejection: { unsafe_answer_rejected: rejection },
      language_review: 'PENDING human review; POLISH regex is a smoke check' }
  end

  def request_evidence(call, state)
    advice, seconds, posts = call
    { state: state, seconds: seconds, posts: posts, output: advice }
  end

  def test_m5_validator_rejects_unsafe_live_looking_answers
    assert_raises(Model::Invalid) { Model::Validator.new.validate(unsafe_answer, LINES) }
  end
end
