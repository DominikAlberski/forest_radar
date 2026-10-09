# frozen_string_literal: true

require 'json'
require 'tmpdir'
require 'timeout'
require 'fileutils'
require 'io/nonblock'

# Minimal Chrome DevTools Protocol driver over the debugging pipe (Ruby standard library only).
# Chrome reads commands on file descriptor 3 and writes replies on file descriptor 4.
# Messages are JSON texts that end with a NUL byte.
module Cdp
  class Error < StandardError; end

  DEFAULT_CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'.freeze

  def self.chrome_path
    path = ENV.fetch('CHROME_PATH', DEFAULT_CHROME)
    raise Error, "Chrome is missing at #{path}. Set CHROME_PATH." unless File.executable?(path)

    path
  end

  def self.which(name)
    return name if name.include?('/') && File.executable?(name)

    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).map do |dir|
      File.join(dir, name)
    end.find { |p| File.executable?(p) } ||
      raise(Error, "#{name} is missing. Install poppler or set PDFINFO_PATH / PDFTOTEXT_PATH.")
  end

  class Browser
    attr_reader :events

    def initialize
      @profile = Dir.mktmpdir('forest-radar-chrome')
      @events = []
      @replies = {}
      @next_id = 0
      @lock = Mutex.new
      @cond = ConditionVariable.new
      start_process
    end

    def start_process
      to_chrome_r, @to_chrome = IO.pipe
      @from_chrome, from_chrome_w = IO.pipe
      # Ruby makes pipe ends non-blocking. Chrome reads EAGAIN as a closed pipe, so clear the flag.
      to_chrome_r.nonblock = false
      from_chrome_w.nonblock = false
      args = ["--user-data-dir=#{@profile}", '--headless=new', '--remote-debugging-pipe', '--no-first-run',
              '--no-default-browser-check', '--disable-gpu', '--disable-extensions', 'about:blank']
      @pid = Process.spawn(Cdp.chrome_path, *args, 3 => to_chrome_r, 4 => from_chrome_w,
                                                   in: File::NULL, out: File::NULL, err: File::NULL)
      to_chrome_r.close
      from_chrome_w.close
      @reader = Thread.new { read_loop }
    end

    def read_loop
      buffer = +''
      while (chunk = @from_chrome.readpartial(65_536))
        buffer << chunk.force_encoding(Encoding::BINARY)
        while (index = buffer.index("\0"))
          dispatch(JSON.parse(buffer.slice!(0..index).chomp("\0").force_encoding(Encoding::UTF_8)))
        end
      end
    rescue IOError, EOFError
      nil
    end

    def dispatch(message)
      @lock.synchronize do
        message.key?('id') ? @replies[message['id']] = message : @events << message
        @cond.broadcast
      end
    end

    def call(method, params = nil, session: nil, timeout: 20, **rest)
      params = (params || {}).merge(rest)
      id = @lock.synchronize { @next_id += 1 }
      message = { id: id, method: method, params: params }
      message[:sessionId] = session if session
      @to_chrome.write("#{JSON.generate(message)}\0")
      reply = wait_reply(id, timeout, method)
      raise Error, "#{method}: #{reply['error']['message']}" if reply['error']

      reply['result']
    end

    def wait_reply(id, timeout, method)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      @lock.synchronize do
        until @replies.key?(id)
          left = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raise Error, "#{method} timed out" if left <= 0

          @cond.wait(@lock, left)
        end
        @replies.delete(id)
      end
    end

    def events_for(session, *methods)
      @lock.synchronize do
        @events.select do |e|
          e['sessionId'] == session && (methods.empty? || methods.include?(e['method']))
        end
      end
    end

    def close
      @to_chrome.close unless @to_chrome.closed?
      begin
        Process.kill('TERM', @pid)
      rescue StandardError
        nil
      end
      begin
        Process.wait(@pid)
      rescue StandardError
        nil
      end
      @reader.kill
      FileUtils.rm_rf(@profile)
    end
  end

  class Page
    attr_reader :session

    def initialize(browser)
      @browser = browser
      @target = browser.call('Target.createTarget', url: 'about:blank').fetch('targetId')
      @session = browser.call('Target.attachToTarget', targetId: @target, flatten: true).fetch('sessionId')
      %w[Page Runtime Log Network].each { |domain| cmd("#{domain}.enable") }
    end

    def cmd(method, params = nil, **rest)
      @browser.call(method, params, session: @session, **rest)
    end

    def phone!(width = 375, height = 812)
      cmd('Emulation.setDeviceMetricsOverride', width: width, height: height, deviceScaleFactor: 2, mobile: true)
    end

    def goto(url)
      cmd('Page.navigate', url: url)
      wait_for("document.readyState === 'complete' && !!document.getElementById('search-form')")
    end

    def eval(expression)
      result = cmd('Runtime.evaluate', expression: expression, returnByValue: true, awaitPromise: true)
      raise Error, "JavaScript failed: #{result['exceptionDetails'].inspect}" if result['exceptionDetails']

      result.dig('result', 'value')
    end

    def wait_for(expression, timeout: 10)
      Timeout.timeout(timeout, Error, "condition not met: #{expression}") do
        sleep 0.05 until eval(expression)
      end
      true
    end

    def js_errors
      thrown = @browser.events_for(@session,
                                   'Runtime.exceptionThrown').map do |e|
        e.dig('params', 'exceptionDetails', 'text').to_s +
          e.dig('params', 'exceptionDetails',
                'exception', 'description').to_s
      end
      logged = @browser.events_for(@session, 'Log.entryAdded').map { |e| e['params']['entry'] }
                       .select { |entry| entry['level'] == 'error' && entry['source'] != 'network' }
                       .map { |entry| entry['text'] }
      thrown + logged
    end

    def print_pdf(path)
      data = cmd('Page.printToPDF', paperWidth: 8.27, paperHeight: 11.69, printBackground: true).fetch('data')
      File.binwrite(path, data.unpack1('m'))
    end

    def close
      @browser.call('Target.closeTarget', targetId: @target, timeout: 5)
    rescue StandardError
      nil
    end
  end
end
