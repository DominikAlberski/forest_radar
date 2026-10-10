# frozen_string_literal: true

require 'bdl/client'

# Builds BDL features for result assembly tests.
module ResultBuilderSupport
  COLLECTION = 'RDLP_Warszawa_wydzielenia'

  def square(left, bottom, right, top)
    { 'type' => 'Polygon',
      'coordinates' => [[[left, bottom], [right, bottom], [right, top], [left, top], [left, bottom]]] }
  end

  def feature(identifier, address, geometry)
    { 'id' => identifier, 'type' => 'Feature', 'geometry' => geometry, 'properties' => { 'adress_forest' => address } }
  end

  def stand(properties, geometry = square(0, 0, 0.01, 0.01))
    { 'type' => 'Feature', 'geometry' => geometry, 'properties' => properties }
  end

  def build(stands, **options)
    settings = { districts: [], ranges: [], lat: 0, lon: 0, radius: 1 }.merge(options)
    input = BDL::BuildInput.new(regions: [], districts: settings.fetch(:districts), ranges: settings.fetch(:ranges),
                                stands: stands.map { |item| [COLLECTION, item] })
    BDL::ResultBuilder.new.build(settings.fetch(:lat), settings.fetch(:lon), settings.fetch(:radius), input)
  end
end
