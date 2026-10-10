# frozen_string_literal: true

require_relative 'builder'
require_relative 'forest_links'
require_relative 'trail_evidence'
require_relative '../assembler/facts'
require_relative '../model/request_queue'

module Card
  # Generates one independent description for each BDL forest.
  class Collection
    def initialize(model:, clock:, queue: Model::RequestQueue::SHARED)
      @model = model
      @clock = clock
      @queue = queue
    end

    def build(search, location, walk: {})
      evidence = TrailEvidence.new(walk)
      search.fetch(:ranges).sort_by { |range| range.fetch('distance_km') }.map do |range|
        forest_card(forest_search(search, range), location, evidence.for(range))
      end
    end

    private

    def forest_search(search, range)
      stands = search.fetch(:stands).select { |stand| stand['range_id'] == range['id'] && stand['in_radius'] }
      districts = search.fetch(:districts).select { |district| district['id'] == range['district_id'] }
      search.merge(ranges: [range], stands: stands, districts: districts,
                   box_stand_count: stands.size, radius_stand_count: stands.size, missing_identifier_count: 0)
    end

    def forest_card(search, location, evidence)
      assembler = Assembler::Facts.new
      advice = model_advice(assembler.model_lines(search, walking: evidence))
      card = Builder.new.build(facts: {}, advice: advice, **location)
      card.merge(forests: ForestLinks.new.build(search), name: forest_name(search), walking: evidence)
    end

    def forest_name(search)
      properties = search.fetch(:ranges).first.fetch('properties', {})
      properties['forest_range_name'] || properties['name'] || I18n.t('ui.forest')
    end

    def model_advice(lines)
      @queue.run { @model.generate(lines, deadline: @clock.call + 89) }
    end
  end
end
