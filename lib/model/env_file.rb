# frozen_string_literal: true

module Model
  # Reads model settings from the project env file.
  # :reek:TooManyStatements
  module EnvFile
    KEYS = { 'FOREST_RADAR_MODEL_URL' => 'url', 'FOREST_RADAR_MODEL_CLIENT' => 'client',
             'FOREST_RADAR_MODEL_NAME' => 'model',
             'FOREST_RADAR_MODEL_OPEN_TIMEOUT_S' => 'open_timeout_s' }.freeze

    def self.read(path)
      File.foreach(path).with_index(1).each_with_object({}) do |(line, number), config|
        key, value = pair(line, number)
        config[KEYS.fetch(key)] = convert(key, value) if KEYS.key?(key) && !value.empty?
      end
    end

    def self.pair(line, number)
      line = line.strip
      return [nil, ''] if line.empty? || line.start_with?('#')

      key, value = line.delete_prefix('export ').split('=', 2)
      key = key.strip
      [key, KEYS.key?(key) ? parsed_value(valid_value(key, value, number), number) : unknown_value(key, value, number)]
    end

    def self.unknown_value(key, value, number)
      valid_value(key, value, number)
      ''
    end

    def self.valid_value(key, value, number)
      raise ArgumentError, "invalid env line #{number}" unless value && !key.empty?

      value.strip
    end

    def self.parsed_value(value, number)
      return '' if value.start_with?('#')
      return value.split(/\s+#/, 2).first.to_s.strip unless value.start_with?("'", '"')

      match = value.match(/\A(["'])(.*?)\1/)
      raise ArgumentError, "invalid env line #{number}" unless match&.post_match&.match?(/\A\s*(?:#.*)?\z/)

      match[2]
    end

    def self.convert(key, value)
      return value unless key == 'FOREST_RADAR_MODEL_OPEN_TIMEOUT_S'

      positive_timeout(value)
    rescue ArgumentError, TypeError
      raise ArgumentError, "invalid #{key}"
    end

    def self.positive_timeout(value)
      timeout = Float(value)
      raise ArgumentError, 'invalid timeout' unless timeout.positive? && timeout.finite?

      timeout
    end
  end
end
