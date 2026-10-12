# frozen_string_literal: true

require_relative '../../test_helper'
require 'model/client'
require 'tempfile'

class ModelClientTest < Minitest::Test
  Response = Struct.new(:code, :body)

  class RecordedHTTP
    attr_reader :calls

    def initialize(content, code: '200')
      @body = JSON.generate(message: { content: content })
      @code = code
      @calls = []
    end

    def start(_host, _port, **)
      yield self
    end

    def post(path, body, _headers)
      @calls << [path, JSON.parse(body)]
      Response.new(@code, @body)
    end
  end

  class SlowHTTP < RecordedHTTP
    def post(*)
      sleep 0.2
      super
    end
  end

  def client(http)
    Model::Client.new('http://localhost:11434', 'bielik', http: http)
  end

  def test_content_is_preserved_without_validation_or_retry
    answer = "  **Las**\nLas jest otwarty. Ten grzyb jest jadalny.\n"
    http = RecordedHTTP.new(answer)
    assert_equal answer, client(http).generate({ 'F1' => 'species=SO' })
    assert_equal 1, http.calls.size
  end

  def test_empty_content_is_also_preserved
    http = RecordedHTTP.new('')
    assert_equal '', client(http).generate({})
    assert_equal 1, http.calls.size
  end

  def test_request_has_simple_prompt_and_source_data
    http = RecordedHTTP.new('Opis')
    client(http).generate({ 'F1' => 'species=SO', 'F2' => 'total_area=1.5' })
    assert_request(http.calls.first)
  end

  def assert_request(call)
    path, body = call
    assert_equal '/api/chat', path
    assert_equal 'bielik', body.fetch('model')
    assert_equal [{ 'role' => 'user', 'content' => expected_prompt }], body.fetch('messages')
    assert_equal false, body.fetch('stream')
  end

  def expected_prompt
    "#{Model::Client::PROMPT}\n\nDane z BDL:\nF1: species=SO\nF2: total_area=1.5"
  end

  def test_http_failure_is_not_retried
    http = RecordedHTTP.new('error', code: '500')
    assert_raises(Model::Invalid) { client(http).generate({}) }
    assert_equal 1, http.calls.size
  end

  def test_expired_deadline_skips_request
    http = RecordedHTTP.new('Opis')
    assert_raises(Model::Deadline) { client(http).generate({}, deadline: 0) }
    assert_empty http.calls
  end

  def test_deadline_interrupts_request
    http = SlowHTTP.new('Opis')
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 0.03
    assert_raises(Model::Deadline) { client(http).generate({}, deadline: deadline) }
    assert_empty http.calls
  end

  def test_client_selection_uses_configuration
    Tempfile.create(['model', '.yml']) do |file|
      file.write("client: stub\nmodel: test\nurl: http://localhost:11434\n")
      file.flush
      assert_instance_of Model::Stub, Model::Client.from_config(file.path, env_path: nil)
    end
  end
end
