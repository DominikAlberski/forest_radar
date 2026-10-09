# frozen_string_literal: true

module Cache
  class SessionCache
    def initialize(max_entries: 256, max_bytes: 128 * 1024 * 1024,
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @max_entries = max_entries
      @max_bytes = max_bytes
      @clock = clock
      @entries = {}
      @mutex = Mutex.new
    end

    def read(key)
      @mutex.synchronize do
        entry = @entries.delete(key)
        return nil unless entry && entry[:expires] > @clock.call

        @entries[key] = entry
        entry[:value]
      end
    end

    def write(key, value, ttl:, bytes: nil)
      size = bytes || Marshal.dump(value).bytesize
      return false if size > @max_bytes

      @mutex.synchronize do
        @entries.delete(key)
        @entries[key] = { value: value, expires: @clock.call + ttl, bytes: size }
        evict
      end
      true
    end

    private

    def evict
      @entries.delete(@entries.keys.first) while @entries.size > @max_entries ||
                                                 @entries.values.sum { |entry| entry[:bytes] } > @max_bytes
    end
  end
end
