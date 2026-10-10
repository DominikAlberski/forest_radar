# frozen_string_literal: true

require_relative '../test_helper'
require 'stringio'
require_relative '../../lib/source_log' if File.file?(File.expand_path('../../lib/source_log.rb', __dir__))

class SourceLogTest < Minitest::Test
  def log(output, message, source: :bdl, elapsed_ms: 23)
    error = RuntimeError.new(message)
    SourceLog.new(io: output).write(source: source, error: error, elapsed_ms: elapsed_ms)
  end

  def test_writes_the_exact_record_format
    output = StringIO.new
    log(output, 'upstream status 503')
    assert_equal "source=bdl error=RuntimeError message=\"upstream status 503\" elapsed_ms=23\n", output.string
  end

  def test_scrubs_urls_and_decimal_numbers_but_keeps_integers
    output = StringIO.new
    message = 'failed https://private.test/?bbox=52.1,21.2 query=52.078247,21.040624 status=503'
    log(output, message)
    assert_equal "source=bdl error=RuntimeError message=\"failed query=<num>,<num> status=503\" elapsed_ms=23\n",
                 output.string
  end

  def test_replaces_line_breaks_and_escapes_quotes_on_one_line
    output = StringIO.new
    log(output, "first\nsecond \"quoted\"", source: :osm, elapsed_ms: 5)
    expected = "source=osm error=RuntimeError message=\"first second \\\"quoted\\\"\" elapsed_ms=5\n"
    assert_equal expected, output.string
    assert_equal 1, output.string.lines.length
  end

  def test_cuts_the_scrubbed_message_to_two_hundred_characters
    output = StringIO.new
    log(output, 'x' * 201, source: :model)
    expected = "source=model error=RuntimeError message=\"#{'x' * 200}\" elapsed_ms=23\n"
    assert_equal expected, output.string
  end

  def test_defaults_to_standard_error
    stdout, stderr = capture_io { log_without_io }
    assert_empty stdout
    assert_equal "source=osm error=RuntimeError message=\"failed\" elapsed_ms=0\n", stderr
  end

  def log_without_io
    SourceLog.new.write(source: :osm, error: RuntimeError.new('failed'), elapsed_ms: 0)
  end
end
