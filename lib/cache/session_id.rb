require 'securerandom'

module Cache
  module SessionId
    COOKIE = 'forest_radar_session'
    module_function

    def generate
      SecureRandom.hex(16)
    end

    def valid?(value)
      value.is_a?(String) && value.match?(/\A[0-9a-f]{32}\z/)
    end

    def cookie(value, secure:)
      { value: value, httponly: true, same_site: :lax, secure: secure, path: '/' }
    end
  end
end
