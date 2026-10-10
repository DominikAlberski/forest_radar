# frozen_string_literal: true

# Writes one scrubbed source failure to an IO.
class SourceLog
  def initialize(io: $stderr) # rubocop:disable Naming/MethodParameterName
    @io = io
  end

  def write(source:, error:, elapsed_ms:)
    @io.puts %(source=#{source} error=#{error.class} message="#{scrub(error.message)}" elapsed_ms=#{elapsed_ms})
  end

  private

  # :reek:UtilityFunction
  def scrub(raw)
    clean = raw.gsub(%r{https?://\S+\s*}, '')
    clean = clean.gsub(/-?\d+[.,]\d+/, '<num>').gsub(/[[:cntrl:]]/, ' ')
    clean.gsub('"', '\\"')[0, 200]
  end
end
