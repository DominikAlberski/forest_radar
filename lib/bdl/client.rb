# frozen_string_literal: true

require 'json'
require 'digest'
require 'uri'
require 'openssl'
require_relative '../geo/geometry'
require_relative '../http/transport'
require_relative 'result_builder'
require_relative 'page_reader'
require_relative 'search_state'
require_relative 'search_transport'

module BDL
  # Reports an incomplete BDL response.
  class Incomplete < StandardError; end
  # Reports a search point outside BDL coverage.
  class NoCoverage < StandardError; end

  # Coordinates collection reads and local search assembly.
  class Client
    REGIONS = %w[Bialystok Katowice Krakow Krosno Lublin Lodz Olsztyn Pila Poznan Szczecin
                 Szczecinek Torun Wroclaw Zielona_Gora Gdansk Radom Warszawa].freeze
    # This code mapping is unverified against the live BDL collection metadata.
    REGION_CODES = { '01' => 'Bialystok', '02' => 'Katowice', '03' => 'Krakow', '04' => 'Krosno',
                     '05' => 'Lublin', '06' => 'Lodz', '07' => 'Olsztyn', '08' => 'Pila',
                     '09' => 'Poznan', '10' => 'Szczecin', '11' => 'Szczecinek', '12' => 'Torun',
                     '13' => 'Wroclaw', '14' => 'Zielona_Gora', '15' => 'Gdansk',
                     '16' => 'Radom', '17' => 'Warszawa' }.freeze
    def initialize(transport: HTTP::Transport.new(base_url: 'https://ogcapi.bdl.lasy.gov.pl',
                                                  user_agent: 'ForestRadar/1.0', retries: 2),
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) },
                   page_size: PageState::PAGE_SIZE, concurrency: PageState::CONCURRENCY)
      @transport = transport
      @clock = clock
      @page_size = page_size
      @concurrency = concurrency
    end

    def features(collection, bbox:, deadline: @clock.call + 60, limit: 100_000)
      PageReader.new(@transport, @clock, page_size: @page_size, concurrency: @concurrency)
                .read(collection, bbox: bbox, deadline: deadline, limit: limit)
    rescue JSON::ParserError, KeyError, TypeError, ArgumentError, HTTP::Error, URI::InvalidURIError,
           Timeout::Error, IOError, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
      raise Incomplete, error.message
    end

    def search(lat:, lon:, radius_km:)
      transport = SearchTransport.new(@transport, @concurrency)
      reader = self.class.new(transport: transport, clock: @clock, page_size: @page_size, concurrency: @concurrency)
      SearchState.start(lat, lon, radius_km, @clock).search(reader, @clock)
    end
  end
end
