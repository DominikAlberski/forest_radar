# frozen_string_literal: true

module Model
  class Invalid < StandardError; end
  class Deadline < StandardError; end

  class Validator
    PROHIBITED = /jadaln\p{L}*|niejadaln\p{L}*|truj\p{L}*|do\s+spożycia|
                  (?:można|możesz|możecie)\s+(?:je\s+)?(?:jeść|zjeść|spożyć)|
                  bezpieczn\p{L}*\s+do\s+jedzenia/ix
    ACCESS = /las(?:y)?\s+(?:jest|są)\s+otwart\p{L}*|
              wstęp\s+(?:jest\s+)?woln\p{L}*|można\s+wejść|dostęp\s+gwarantowan\p{L}*/ix

    def validate(answer, lines)
      match = /\AFAKTY\s*\n(?<facts>.*?)\nWNIOSKI\s*\n(?<advice>.+)\z/m.match(answer.to_s.strip)
      raise Invalid, 'missing sections' unless match
      raise Invalid, 'unsafe advice' if match[:advice].match?(PROHIBITED) || match[:advice].match?(ACCESS)

      given = match[:facts].lines.map(&:strip)
      expected = lines.map { |id, value| "#{id}: #{value}" }
      raise Invalid, 'fact mismatch' unless given == expected

      match[:advice].strip
    end
  end
end
