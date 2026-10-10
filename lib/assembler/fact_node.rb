# frozen_string_literal: true

# Builds ordered card facts and model input lines.
module Assembler
  # Flattens nested fact values into ordered model lines.
  FactNode = Struct.new(:value, :path) do
    def entries
      case value
      when Hash then hash_entries
      when Array then array_entries
      else [[path.delete_prefix('.'), value.equal?(nil) ? 'brak danych' : value.to_s]]
      end
    end

    private

    def hash_entries
      value.flat_map { |key, item| self.class.new(item, "#{path}.#{key}").entries }
    end

    def array_entries
      value.each_with_index.flat_map { |item, index| self.class.new(item, "#{path}[#{index}]").entries }
    end
  end
  private_constant :FactNode
end
