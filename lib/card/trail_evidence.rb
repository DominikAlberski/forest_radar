# frozen_string_literal: true

module Card
  # Keeps retrieved trail evidence specific to one BDL forest.
  class TrailEvidence
    def initialize(walk)
      ranges = walk.fetch(:evidence) { walk.fetch(:areas, []) + walk.fetch(:excluded, []) }
      @ranges = ranges.to_h { |range| [range['id'], range] }
    end

    def for(range)
      evidence = @ranges[range['id']]
      { source: 'OpenStreetMap / Overpass', status: status(evidence), trails: trails(evidence) }
    end

    private

    def trails(evidence)
      (evidence || {}).fetch(:trails, []).map { |trail| trail.slice(:id, :name, :ref, :route) }
    end

    def status(evidence)
      return 'not_checked' unless evidence
      return evidence[:exclusion_reason].to_s if evidence[:exclusion_reason]

      evidence.fetch(:trails, []).empty? ? 'no_mapped_trail' : 'mapped_crossing'
    end
  end
end
