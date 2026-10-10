# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'client_search_support'

class ClientSearchParallelTest < Minitest::Test
  include ClientSearchSupport

  class TimedPages
    attr_reader :maximum, :first_page_maximum, :paths

    def initialize(pages, failure: nil)
      @pages = pages
      @failure = failure
      @mutex = Mutex.new
      reset_activity
    end

    def reset_activity
      @active = 0
      @first_active = 0
      @maximum = 0
      @first_page_maximum = 0
      @paths = []
    end

    def get(path, params:, **)
      offset = params.fetch('offset').to_i
      enter(path, offset)
      response(path, offset, params.fetch(:limit))
    ensure
      leave(offset) if offset
    end

    def response(path, offset, limit)
      sleep 0.01
      raise IOError, 'collection failed' if path == @failure

      page(path, offset, limit).to_json
    end

    def enter(path, offset)
      @mutex.synchronize do
        @paths << path
        count_request(offset)
      end
    end

    def count_request(offset)
      @active += 1
      @first_active += 1 if offset.zero?
      record_maximum
    end

    def record_maximum
      @maximum = [@maximum, @active].max
      @first_page_maximum = [@first_page_maximum, @first_active].max
    end

    def leave(offset)
      @mutex.synchronize do
        @active -= 1
        @first_active -= 1 if offset.zero?
      end
    end

    def page(path, offset, limit)
      items = @pages.fetch(path)
      { numberMatched: items.size - offset, features: items.slice(offset, limit), links: [] }
    end
  end

  def collection_pages
    base_pages.transform_values { |value| value.fetch('features') }
  end

  def many_pages
    pages = collection_pages
    %w[nadlesnictwa lesnictwa].each { |name| pages[collection(name)] *= 9 }
    pages
  end

  def test_first_pages_overlap_and_all_pages_share_cap
    transport = TimedPages.new(many_pages)
    assert_equal 9, load_area(transport).districts.size
    assert_operator transport.first_page_maximum, :>, 1
    assert_operator transport.maximum, :<=, 8
  end

  def load_area(transport)
    clock = -> { 100 }
    reader = BDL::Client.new(transport: BDL::SearchTransport.new(transport, 8), page_size: 1, clock: clock)
    BDL::SearchState.start(LAT, LON, 5, clock).tap { |state| state.load_area(reader) }
  end

  def test_one_collection_failure_stops_search
    transport = TimedPages.new(many_pages, failure: collection('lesnictwa'))
    error = assert_raises(BDL::Incomplete) { search_with(transport) }
    assert_equal 'collection failed', error.message
    refute_includes transport.paths, collection('RDLP_Warszawa_wydzielenia')
  end

  def search_with(transport)
    BDL::Client.new(transport: transport, page_size: 1).search(lat: LAT, lon: LON, radius_km: 5)
  end
end
