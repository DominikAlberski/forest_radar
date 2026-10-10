# frozen_string_literal: true

module Model
  # Signals an unusable model response.
  class Invalid < StandardError; end
  # Signals an expired model request.
  class Deadline < StandardError; end

  # Checks model sections, facts, and safety language.
  class Validator
    PROHIBITED = /jadaln\p{L}*|niejadaln\p{L}*|truj\p{L}*|do\s+spożycia|
                  (?:można|możesz|możecie)\s+(?:je\s+)?(?:jeść|zjeść|spożyć)|
                  bezpieczn\p{L}*\s+do\s+jedzenia/ix
    ACCESS = /las(?:y)?\s+(?:jest|są)\s+otwart\p{L}*|
              wstęp\s+(?:jest\s+)?woln\p{L}*|można\s+wejść|dostęp\s+gwarantowan\p{L}*/ix

    # Holds the input while validating one response.
    Validation = Struct.new(:answer, :lines) do
      def validate
        check_advice
        check_facts
        advice.strip
      end

      private

      def sections
        match = /\AFAKTY\s*\n(?<facts>.*?)\nWNIOSKI\s*\n(?<advice>.+)\z/m.match(answer.to_s.strip)
        raise Invalid, 'missing sections' unless match

        match
      end

      def advice
        sections[:advice]
      end

      def check_advice
        raise Invalid, 'unsafe advice' if advice.match?(PROHIBITED) || advice.match?(ACCESS)
      end

      def check_facts
        expected = lines.map { |id, value| "#{id}: #{value}" }
        raise Invalid, 'fact mismatch' unless sections[:facts].lines.map(&:strip) == expected
      end
    end

    private_constant :Validation

    def initialize(validation_class: Validation)
      @validation_class = validation_class
    end

    def validate(answer, lines)
      @validation_class.new(answer, lines).validate
    end
  end
end
