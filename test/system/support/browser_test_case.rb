# frozen_string_literal: true

require 'minitest/autorun'
require 'puma'
require_relative 'cdp'
require_relative 'fixtures'

class BrowserTestCase < Minitest::Test
  F = SystemFixtures
  PORT = Integer(ENV.fetch('PORT') { 9300 + ENV.fetch('COORD_SLOT', '0').to_i })
  BASE = "http://localhost:#{PORT}".freeze
  PDFINFO = Cdp.which(ENV.fetch('PDFINFO_PATH', 'pdfinfo'))
  PDFTOTEXT = Cdp.which(ENV.fetch('PDFTOTEXT_PATH', 'pdftotext'))
  @browser = Cdp::Browser.new
  @server = Puma::Server.new(ForestRadar::App, nil, min_threads: 0, max_threads: 4,
                                                    log_writer: Puma::LogWriter.strings)
  @server.add_tcp_listener('127.0.0.1', PORT)
  @server.run
  Minitest.after_run do
    @server.stop(true)
    @browser.close
  end

  def browser
    BrowserTestCase.instance_variable_get(:@browser)
  end
end
