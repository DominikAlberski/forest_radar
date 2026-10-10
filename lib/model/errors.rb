# frozen_string_literal: true

module Model
  # Signals a failed model request.
  class Invalid < StandardError; end
  # Signals an expired model request.
  class Deadline < StandardError; end
end
