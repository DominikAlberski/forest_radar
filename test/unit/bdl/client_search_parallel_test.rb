# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'client_search_support'

class ClientSearchParallelTest < Minitest::Test
  include ClientSearchSupport

  class TimedPages
    attr_reader :maximum, :first_page_maximum, :paths, :active
    attr_writer :delays

    def initialize(pages, failure: nil)
      @pages = pages
      @failure = failure
      @delays = {}
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
      sleep(@delays.fetch(path, 0.01))
      raise IOError, 'collection failed' if path == @failure

      response_page(path, offset, limit).to_json
    end

    def response_page(path, offset, limit)
      items = @pages.fetch(path)
      { 'numberMatched' => items.size - offset, 'features' => items.slice(offset, limit), 'links' => [] }
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

  def many_pages
    pages = base_pages.transform_values { |value| value.fetch('features') }
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
    assert_equal 0, transport.active
  end

  def test_search_enforces_item_limit_across_collections
    error = assert_raises(BDL::Incomplete) do
      search_with(TimedPages.new(overflow_area_pages), page_size: 100_000)
    end
    assert_equal 'feature limit', error.message
  end

  def overflow_area_pages
    pages = base_pages
    pages.merge!(oversized_area_collections)
    pages
  end

  def oversized_area_collections
    geometry = square(20.5, 51.5, 21.5, 52.5)
    region = Array.new(50_000) { |id| feature(id, { 'region_cd' => '17' }, geometry) }
    districts = Array.new(50_001) { |id| feature(id, { 'adress_forest' => '17-02- -' }, geometry) }
    ranges = [feature(3, { 'adress_forest' => '17-02-1-05-' }, geometry)]
    { collection('rdlp') => region, collection('nadlesnictwa') => districts, collection('lesnictwa') => ranges }
  end

  def test_search_preserves_collection_order_when_reads_finish_in_reverse_order
    transport = ordered_transport
    assert_result_order(search_with(transport), transport)
  end

  def ordered_transport
    TimedPages.new(ordered_result_pages).tap do |transport|
      transport.delays = { collection('RDLP_Warszawa_wydzielenia') => 0.04,
                           collection('RDLP_Lodz_wydzielenia') => 0.01 }
    end
  end

  def assert_result_order(result, transport)
    assert_stand_order(result)
    assert_area_order(result)
    assert_collection_request_order(transport)
  end

  def assert_stand_order(result)
    identifiers = result[:stands].map { |stand| stand['a_i_num'] }
    assert_equal [111, 222], identifiers
  end

  def assert_area_order(result)
    assert_equal [17, 6], region_codes(result)
    assert_equal [2, 4], result[:districts].map { |district| district.fetch('id') }.to_a
    assert_equal [3, 5], result[:ranges].map { |range| range.fetch('id') }.to_a
  end

  def region_codes(result)
    result[:regions].map { |region| region.dig('properties', 'region_cd').to_i }
  end

  def assert_collection_request_order(transport)
    expected = %w[RDLP_Warszawa_wydzielenia RDLP_Lodz_wydzielenia].map { |name| collection(name) }
    stand_paths = transport.paths.grep(/wydzielenia/)
    assert_equal expected, stand_paths
  end

  def ordered_result_pages
    pages = base_pages
    area = square(20.5, 51.5, 21.5, 52.5)
    pages.merge!(ordered_area_pages(area), ordered_stand_pages(area))
    pages
  end

  def ordered_area_pages(area)
    { collection('rdlp') => [feature(1, { 'region_cd' => '17' }, area), feature(4, { 'region_cd' => '06' }, area)],
      collection('nadlesnictwa') => [feature(2, { 'adress_forest' => '17-02- -' }, area),
                                     feature(4, { 'adress_forest' => '06-04- -' }, area)],
      collection('lesnictwa') => [feature(3, { 'adress_forest' => '17-02-1-05-' }, area),
                                  feature(5, { 'adress_forest' => '06-04-1-05-' }, area)] }
  end

  def ordered_stand_pages(area)
    { collection('RDLP_Warszawa_wydzielenia') => [stand_feature(111, '17-02-1-05-1', area)],
      collection('RDLP_Lodz_wydzielenia') => [stand_feature(222, '06-04-1-05-2', area)] }
  end

  def stand_feature(identifier, address, area)
    feature(identifier, { 'a_i_num' => identifier, 'adr_for' => address, 'species_cd' => 'SO' }, area)
  end

  def search_with(transport, page_size: 1)
    BDL::Client.new(transport: transport, page_size: page_size).search(lat: LAT, lon: LON, radius_km: 5)
  end
end
