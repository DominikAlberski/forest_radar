# frozen_string_literal: true

module Cache
  # Holds bounded, expiring values for source requests.
  class SessionCache
    def initialize(max_entries: 256, max_bytes: 128 * 1024 * 1024,
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @limits = [max_entries, max_bytes]
      @clock = clock
      @entries = {}
      @mutex = Mutex.new
    end

    def read(key)
      @mutex.synchronize { read_entry(key) }
    end

    private

    def read_entry(key)
      entry = @entries.delete(key)
      return nil unless entry && entry[:expires] > @clock.call

      @entries[key] = entry
      entry[:value]
    end

    def write_entry?(key, value, ttl:)
      size = Marshal.dump(value).bytesize
      return false if size > @limits.last

      store(key, value, ttl, size)
      true
    end

    alias write write_entry?
    public :write

    def store(key, value, ttl, size)
      @mutex.synchronize do
        @entries.delete(key)
        @entries[key] = { value: value, expires: @clock.call + ttl, bytes: size }
        evict
      end
    end

    def evict
      @entries.delete(@entries.keys.first) while @entries.size > @limits.first ||
                                                 @entries.values.sum { |entry| entry[:bytes] } > @limits.last
    end
  end
end
