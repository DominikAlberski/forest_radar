require_relative '../../test_helper'
require 'model/client'
require 'tempfile'

class ModelClientTest < Minitest::Test
  Response = Struct.new(:code, :body)

  class RecordedHTTP
    attr_reader :calls

    def initialize(body)
      @body, @calls = body, []
    end

    def start(host, port, **options)
      @calls << [host, port, options]
      yield self
    end

    def post(path, body, headers)
      @calls << [path, JSON.parse(body), headers]
      Response.new('200', @body)
    end
  end

  class SlowHTTP < RecordedHTTP
    def initialize(body, delay)
      super(body)
      @delay = delay
    end

    def start(host, port, **options)
      sleep @delay
      super
    end

    def post(path, body, headers)
      sleep @delay
      super
    end
  end

  def test_client_selection_uses_configuration
    Tempfile.create(['model', '.yml']) do |file|
      file.write("client: stub\nmodel: test\nurl: http://localhost:11434\n")
      file.flush
      assert_instance_of Model::Stub, Model::Client.from_config(file.path)
    end
  end

  def test_prompt_does_not_request_generated_distance_or_walking_time
    refute_match(/podaj odległość|czas dojścia/i, Model::Client::PROMPT)
  end

  def test_recorded_ollama_response
    fixture = File.read(File.expand_path('../../fixtures/model/valid-response.json', __dir__))
    http = RecordedHTTP.new(fixture)
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    assert_equal 'Sprawdź warunki w terenie.', client.generate({ 'F1' => 'distance_km=1.2' })
    assert_equal 'localhost', http.calls.first.first
    assert_equal '/api/chat', http.calls.last.first
  end

  def test_invalid_recorded_answer_retries_once
    fixture = File.read(File.expand_path('../../fixtures/model/invalid-response.json', __dir__))
    http = RecordedHTTP.new(fixture)
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    assert_raises(Model::Invalid) { client.generate({ 'F1' => 'distance_km=1.2' }) }
    assert_equal 2, http.calls.count { |item| item.first == '/api/chat' }
  end

  def test_deadline_bounds_open_and_response_together
    fixture = File.read(File.expand_path('../../fixtures/model/valid-response.json', __dir__))
    http = SlowHTTP.new(fixture, 0.02)
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 0.03
    assert_raises(Model::Deadline) { client.generate({ 'F1' => 'distance_km=1.2' }, deadline: deadline) }
  end

  def test_expired_deadline_skips_both_attempts
    http = RecordedHTTP.new('{}')
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    assert_raises(Model::Deadline) { client.generate({}, deadline: 0) }
    assert_empty http.calls
  end

  class ScriptedHTTP < RecordedHTTP
    attr_reader :timeouts

    def initialize(bodies, delay)
      super(nil)
      @bodies, @delay, @timeouts = bodies, delay, []
    end

    def start(host, port, **options)
      @timeouts << options[:read_timeout]
      super
    end

    def post(path, body, headers)
      sleep @delay
      @body = @bodies.shift
      super
    end
  end

  class HangingHTTP < RecordedHTTP
    attr_reader :finished

    def post(path, body, headers)
      sleep 0.4
      @finished = true
      super
    end
  end

  def clock
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def test_expired_deadline_interrupts_the_delayed_operation
    http = HangingHTTP.new('{}')
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    started = clock
    assert_raises(Model::Deadline) { client.generate({ 'F1' => 'x=1' }, deadline: started + 0.05) }
    assert_operator clock - started, :<, 0.3
    sleep 0.5
    refute http.finished, 'the delayed request kept running after expiry'
  end

  def test_retry_starts_with_reduced_remaining_budget
    invalid = File.read(File.expand_path('../../fixtures/model/invalid-response.json', __dir__))
    http = ScriptedHTTP.new([invalid, invalid], 0.1)
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    assert_raises(Model::Invalid) { client.generate({ 'F1' => 'x=1' }, deadline: clock + 5) }
    first, second = http.timeouts
    assert_operator first - second, :>=, 0.08
    assert_operator second, :<, 5
  end

  def test_retry_with_little_budget_left_is_cut_off_at_the_deadline
    invalid = File.read(File.expand_path('../../fixtures/model/invalid-response.json', __dir__))
    http = ScriptedHTTP.new([invalid, invalid], 0.1)
    client = Model::Client.new('http://localhost:11434', 'bielik', http: http)
    assert_raises(Model::Deadline) { client.generate({ 'F1' => 'x=1' }, deadline: clock + 0.15) }
    assert_operator http.timeouts.last, :<, 0.07
  end
end
