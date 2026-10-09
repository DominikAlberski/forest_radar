require_relative '../geo/geometry'
require_relative '../osm/client'

module WalkAreas
  class Selector
    def initialize(trails:, bans:)
      @trails, @bans = trails, bans
    end

    def select(search:, lat:, lon:, radius_km:, session_id:, deadline: nil)
      box = Geo::Geometry.bbox(lat, lon, radius_km)
      relations = @trails.relations(bbox: box, deadline: deadline)
      districts = search.fetch(:districts).to_h do |item|
        [item.fetch('id'), @bans.sample(item, session_id: session_id, deadline: deadline)]
      end
      eligible, excluded = [], []
      search.fetch(:ranges).each do |range|
        next if range.fetch('distance_km') > radius_km
        trails = relations&.select { |relation| crosses?(relation, range.fetch('geometry')) }
        reason = exclusion(trails, districts[range['district_id']])
        (reason ? excluded : eligible) << range.merge(trails: trails || [], ban: districts[range['district_id']],
                                                        exclusion_reason: reason)
      end
      { areas: eligible.sort_by { |item| [item['distance_km'], item['id'].to_s] }.first(3),
        excluded: excluded, trail_source: 'OpenStreetMap', attribution: OSM::Client::ATTRIBUTION,
        attribution_url: OSM::Client::COPYRIGHT_URL }
    end

    private

    def exclusion(trails, ban)
      return :trail_unavailable unless trails
      return :no_mapped_trail if trails.empty?
      return :ban_unknown unless ban && ban[:status] != :unknown
      :known_ban if ban[:status] == :ban
    end

    def crosses?(relation, polygon)
      rings = Geo::Geometry.polygons(polygon).flat_map(&:itself)
      points = rings.flatten(1)
      west, east = points.map(&:first).minmax
      south, north = points.map(&:last).minmax
      relation[:ways].any? do |way|
        way.each_cons(2).any? do |a, b|
          next false if [a[0], b[0]].max < west || [a[0], b[0]].min > east ||
                        [a[1], b[1]].max < south || [a[1], b[1]].min > north
          Geo::Geometry.contains?(polygon, a) || Geo::Geometry.contains?(polygon, b) ||
            rings.any? { |ring| ring.each_cons(2).any? { |c, d| Geo::Geometry.crossing?(a, b, c, d) } }
        end
      end
    end
  end
end
