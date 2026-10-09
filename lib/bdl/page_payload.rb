# frozen_string_literal: true

require 'json'

module BDL
  # Validates the structure of one BDL feature page.
  module PagePayload
    module_function

    def parse(body)
      page = JSON.parse(body)
      raise Incomplete, 'malformed page' unless valid?(page)

      page
    end

    def valid?(page)
      page.is_a?(Hash) && links?(page['links']) && features?(page['features'])
    end

    def links?(links)
      links.is_a?(Array) && links.all? { |link| link?(link) }
    end

    def link?(link)
      link.is_a?(Hash) && link['rel'].is_a?(String) && link['href'].is_a?(String)
    end

    def features?(features)
      features.is_a?(Array) && features.all? { |feature| feature?(feature) }
    end

    def feature?(feature)
      feature.is_a?(Hash) && feature['properties'].is_a?(Hash)
    end
  end
end
