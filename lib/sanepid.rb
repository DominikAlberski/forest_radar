# frozen_string_literal: true

require 'uri'

# Builds the local Sanepid information URL from coordinates.
module Sanepid
  module_function

  def url(lat, lon, template:)
    raise ArgumentError, 'invalid coordinate' unless lat.finite? && lon.finite? && lat.between?(-90, 90) &&
                                                     lon.between?(-180, 180)

    URI.parse(format(template, lat: format('%.6f', lat), lon: format('%.6f', lon))).to_s
  end
end
