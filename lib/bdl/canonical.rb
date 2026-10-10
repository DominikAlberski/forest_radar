# frozen_string_literal: true

module BDL
  # Sorts nested feature keys before a stable identifier digest.
  module Canonical
    module_function

    def call(value)
      case value
      when Hash then value.keys.sort.to_h { |key| [key, call(value[key])] }
      when Array then value.map { |item| call(item) }
      else value
      end
    end
  end
end
