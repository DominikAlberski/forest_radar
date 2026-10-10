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

  DEFAULT_CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

  def self.chrome_path
    path = ENV.fetch('CHROME_PATH', DEFAULT_CHROME)
    raise Error, "Chrome is missing at #{path}. Set CHROME_PATH." unless File.executable?(path)

    path
  end

  def self.which(name)
    return name if name.include?('/') && File.executable?(name)

    path = executable_in_path(name)
    path || raise(Error, "#{name} is missing. Install poppler or set PDFINFO_PATH / PDFTOTEXT_PATH.")
  end

  def self.executable_in_path(name)
    paths = ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).map { |dir| File.join(dir, name) }
    paths.find { |path| File.executable?(path) }
  end
  private_class_method :executable_in_path

  module BrowserLifecycle
    private

    def start_process
      prepare_pipes
      @pid = spawn_browser
      close_child_pipes
      @reader = Thread.new { read_loop }
    end

    def prepare_pipes
      to_chrome_r, @to_chrome = IO.pipe
      @from_chrome, @from_chrome_w = IO.pipe
      to_chrome_r.nonblock = false
      @from_chrome_w.nonblock = false
      @to_chrome_r = to_chrome_r
    end

    def spawn_browser
      args = chrome_arguments
      Process.spawn(Cdp.chrome_path, *args, 3 => @to_chrome_r, 4 => @from_chrome_w,
                                            in: File::NULL, out: File::NULL, err: File::NULL)
    end

    def chrome_arguments
      ["--user-data-dir=#{@profile}", '--headless=new', '--remote-debugging-pipe', '--no-first-run',
       '--no-default-browser-check', '--disable-gpu', '--disable-extensions', 'about:blank']
    end

    def close_child_pipes
      @to_chrome_r.close
      @from_chrome_w.close
    end

    def read_loop
      buffer = +''
      loop { read_chunk(buffer) }
    rescue IOError
      nil
    end

    def read_chunk(buffer)
      buffer << @from_chrome.readpartial(65_536).force_encoding(Encoding::BINARY)
      consume_frames(buffer)
    end

    def consume_frames(buffer)
      dispatch_frame(buffer) while buffer.include?("\0")
    end

    def dispatch_frame(buffer)
      frame = buffer.slice!(0..buffer.index("\0")).chomp("\0").force_encoding(Encoding::UTF_8)
      dispatch_message(JSON.parse(frame))
    end

    def dispatch_message(message)
      @lock.synchronize { store_message(message) }
    end

    def store_message(message)
      message.key?('id') ? @replies[message['id']] = message : @events << message
      @cond.broadcast
    end

    def close_resources
      @to_chrome.close unless @to_chrome.closed?
      stop_browser
      FileUtils.rm_rf(@profile)
    end

    def stop_browser
      stop_process
      wait_process
      @reader.kill
    end

    def stop_process
      Process.kill('TERM', @pid)
    rescue StandardError
      nil
    end

    def wait_process
      Process.wait(@pid)
    rescue StandardError
      nil
    end
  end

  module BrowserCommands
    private

    def send_command(method, params, options)
      command_id = next_command_id
      write_command(command_id, method, params, options[:session])
      reply = wait_reply(command_id, options.fetch(:timeout, 20), method)
      command_result(method, reply)
    end

    def command_params(options)
      options.except(:session, :timeout)
    end

    def next_command_id
      @lock.synchronize { @next_id += 1 }
    end

    def write_command(command_id, method, params, session)
      message = { id: command_id, method: method, params: params }
      message[:sessionId] = session if session
      @to_chrome.write("#{JSON.generate(message)}\0")
    end

    def command_result(method, reply)
      raise Error, "#{method}: #{reply['error']['message']}" if reply['error']

      reply['result']
    end

    def wait_reply(command_id, timeout, method)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      @lock.synchronize { wait_until_reply(command_id, deadline, method) }
    end

    def wait_until_reply(command_id, deadline, method)
      wait_for_reply(deadline, method) until @replies.key?(command_id)
      @replies.delete(command_id)
    end

    def wait_for_reply(deadline, method)
      remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise Error, "#{method} timed out" if remaining <= 0

      @cond.wait(@lock, remaining)
    end
  end

  class Browser
    include BrowserLifecycle
    include BrowserCommands

    attr_reader :events

    def initialize
      @profile = Dir.mktmpdir('forest-radar-chrome')
      initialize_state
      start_process
    end

    private

    def initialize_state
      @events = []
      @replies = {}
      @next_id = 0
      @lock = Mutex.new
      @cond = ConditionVariable.new
    end

    public

    def call(method, params = nil, **options)
      send_command(method, (params || {}).merge(command_params(options)), options)
    end

    def events_for(session, *methods)
      @lock.synchronize { select_events(session, methods) }
    end

    private

    def select_events(session, methods)
      @events.select do |event|
        event['sessionId'] == session && (methods.empty? || methods.include?(event['method']))
      end
    end

    public

    def close
      close_resources
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

    # This sends JavaScript to the Chrome DevTools Protocol runtime.
    def evaluate(expression)
      result = cmd('Runtime.evaluate', expression: expression, returnByValue: true, awaitPromise: true)
      raise Error, "JavaScript failed: #{result['exceptionDetails'].inspect}" if result['exceptionDetails']

      result.dig('result', 'value')
    end

    def wait_for(expression, timeout: 10)
      Timeout.timeout(timeout, Error, "condition not met: #{expression}") do
        wait_until(expression)
      end
      nil
    end

    private

    def wait_until(expression)
      sleep 0.05 until evaluate(expression)
      nil
    end

    public

    def js_errors
      exception_errors + console_errors
    end

    private

    def exception_errors
      @browser.events_for(@session, 'Runtime.exceptionThrown').map { |event| exception_message(event) }
    end

    def exception_message(event)
      details = event.dig('params', 'exceptionDetails')
      details['text'].to_s + details.dig('exception', 'description').to_s
    end

    def console_errors
      entries = @browser.events_for(@session, 'Log.entryAdded').map { |event| event['params']['entry'] }
      entries.select { |entry| entry['level'] == 'error' && entry['source'] != 'network' }.map { |entry| entry['text'] }
    end

    public

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
