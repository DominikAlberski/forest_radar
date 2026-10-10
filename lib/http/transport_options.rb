# frozen_string_literal: true

module HTTP
  # Stores transport limits and retry dependencies.
  class TransportOptions
    DEFAULTS = { max_bytes: 16 * 1024 * 1024, timeout: 10, retries: 0, sleeper: Kernel }.freeze

    attr_reader :max_bytes, :timeout, :retries, :sleeper

    def initialize(options)
      allowed = DEFAULTS.keys
      unknown = options.keys - allowed
      raise ArgumentError, "unknown keyword: #{unknown.first.inspect}" unless unknown.empty?

      @max_bytes, @timeout, @retries, @sleeper = DEFAULTS.merge(options).values_at(*allowed)
    end
  end
end
