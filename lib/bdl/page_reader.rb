# frozen_string_literal: true

require_relative 'page_state'

module BDL
  # Supplies offsets to workers and stops new requests after an error.
  class PageOffsets
    def initialize(offsets)
      @pending = offsets.dup
      @mutex = Mutex.new
      @stopped = false
    end

    def take
      @mutex.synchronize { @pending.shift unless @stopped }
    end

    def stop
      @mutex.synchronize { @stopped = true }
    end
  end

  # Fetches later pages and validates each response in the caller thread.
  class PageWorkers
    def self.stop(work, workers)
      work&.stop
      workers&.each { |thread| thread.kill if thread.alive? }
      workers&.each(&:join)
    end

    def self.fail_worker(work, responses, error)
      work.stop
      responses << [:error, error]
    end

    def initialize(state, transport, clock, concurrency)
      @state = state
      @transport = transport
      @clock = clock
      @concurrency = concurrency
    end

    def read
      offsets = @state.offsets
      work, responses, workers = start_workers(offsets)
      collect(responses, offsets)
    ensure
      PageWorkers.stop(work, workers)
    end

    private

    def start_workers(offsets)
      work = PageOffsets.new(offsets)
      responses = Queue.new
      workers = Array.new([@concurrency, offsets.size].min) { worker(work, responses) }
      [work, responses, workers]
    end

    def worker(work, responses)
      Thread.new do
        Thread.current.report_on_exception = false
        fetch_pages(work, responses)
      end
    end

    def fetch_pages(work, responses)
      while (offset = work.take)
        responses << [offset, @state.fetch(@transport, @clock, offset)]
      end
    rescue StandardError => error
      PageWorkers.fail_worker(work, responses, error)
    end

    def collect(responses, offsets)
      pages = {}
      offsets.size.times { receive(responses, pages) }
      @state.add_pages(pages)
    end

    def receive(responses, pages)
      offset, page = responses.pop
      raise page if offset == :error

      @state.validate(page, offset)
      pages[offset] = page
    end
  end

  # Reads collection pages within one deadline and item limit.
  class PageReader
    def initialize(transport, clock, page_size: 1000, concurrency: 4)
      @transport = transport
      @clock = clock
      @page_size = page_size
      @concurrency = concurrency
    end

    def read(collection, bbox:, deadline:, limit:)
      state = PageState.start(collection, bbox, deadline, limit: limit, page_size: @page_size)
      state.add(state.fetch(@transport, @clock, 0), 0)
      PageWorkers.new(state, @transport, @clock, @concurrency).read
      state.finish
    end
  end
end
