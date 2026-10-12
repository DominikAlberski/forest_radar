# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'i18n'
require_relative 'bdl/client'
require_relative 'cache/search_cache'
require_relative 'cache/session_id'
require_relative 'walk_areas/selector'
require_relative 'osm/client'
require_relative 'assembler/facts'
require_relative 'model/client'
require_relative 'card/builder'
require_relative 'card/forest_links'
require_relative 'card/collection'
require_relative 'source_log'

module ForestRadar
  # Parses and checks the coordinates in one card request.
  class CardInput
    def initialize(input)
      @input = input
      @values = %w[lat lon radius_km].map { |key| coordinate(key) }
    end

    def values
      raise ArgumentError, 'invalid coordinates' unless valid?

      @values
    end

    private

    def coordinate(key)
      value = @input[key]
      Float(value) if value.is_a?(Numeric) || value.is_a?(String)
    rescue ArgumentError, TypeError
      nil
    end

    def valid?
      lat, lon, radius = @values
      @values.all? { |value| value&.finite? } && lat.between?(-90, 90) &&
        lon.between?(-180, 180) && radius.between?(1, 20)
    end
  end

  # Formats one localized API error response.
  class CardError
    def initialize(key)
      @key = key
    end

    def json
      JSON.generate(error: @key, message: I18n.t("errors.#{@key}"))
    end
  end

  # Serves the search page and generates trip cards from source data.
  class App < Sinatra::Base
    configure do
      I18n.load_path += Dir[File.expand_path('../config/locales/*.yml', __dir__)]
      I18n.default_locale = :pl
      set :views, File.expand_path('../views', __dir__)
      set :public_folder, File.expand_path('../public', __dir__)
      set :search_client, BDL::Client.new
      set :search_cache, Cache::SearchCache.new
      set :clock, -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
      set :source_log, SourceLog.new
      set :selector, WalkAreas::Selector.new(trails: OSM::Client.new(log: source_log))
      set :model_client, Model::Client.from_config
    end

    get '/' do
      content_type :html
      erb :index
    end

    post '/api/card' do
      content_type :json
      lat, lon, radius = CardInput.new(parse_input).values
      session = session_id
      search = logged_source(:bdl) do
        search_for(session, lat, lon, radius)
      end
      deadline = settings.clock + 89
      walk = settings.selector.select(search: search, area: WalkAreas::Area.new(lat: lat, lon: lon, radius_km: radius),
                                      deadline: deadline)
      facts = Assembler::Facts.new.build(search, walk)
      cards = logged_source(:model) { build_cards(search, { lat: lat, lon: lon }, walk) }
      JSON.generate(facts: facts, cards: cards, card: cards.first, sanepid_url: cards.first&.fetch(:sanepid_url))
    rescue TypeError, ArgumentError
      halt 422, CardError.new('invalid_input').json
    rescue BDL::NoCoverage
      halt 422, CardError.new('no_coverage').json
    rescue BDL::Incomplete
      halt 502, CardError.new('source').json
    rescue Model::Deadline
      halt 504, CardError.new('deadline').json
    rescue Model::Invalid, IOError, SystemCallError, Timeout::Error
      halt 502, CardError.new('model').json
    end

    private

    def build_cards(search, location, walk)
      collection = Card::Collection.new(model: settings.model_client, clock: -> { settings.clock })
      collection.build(search, location, walk: walk)
    end

    def search_for(session, lat, lon, radius)
      settings.search_cache.fetch([session, lat, lon, radius, 'card']) do
        settings.search_client.search(lat: lat, lon: lon, radius_km: radius)
      end
    end

    def logged_source(source)
      started = settings.clock
      yield
    rescue BDL::Incomplete, Model::Deadline, Model::Invalid, IOError, SystemCallError, Timeout::Error => error
      log_failure(source, error, started)
      raise
    end

    def log_failure(source, error, started)
      elapsed = ((settings.clock - started) * 1000).round
      write_log(source, error, elapsed)
    end

    def write_log(source, error, elapsed)
      settings.source_log.write(source: source, error: error, elapsed_ms: elapsed)
    rescue StandardError
      nil
    end

    def parse_input
      input = JSON.parse(request.body.read)
      raise ArgumentError, 'invalid JSON object' unless input.is_a?(Hash)

      input
    rescue JSON::ParserError
      raise ArgumentError, 'invalid JSON'
    end

    def session_id
      value = request.cookies[Cache::SessionId::COOKIE]
      return value if Cache::SessionId.valid?(value)

      value = Cache::SessionId.generate
      response.set_cookie(Cache::SessionId::COOKIE, Cache::SessionId.cookie(value, secure: request.secure?))
      value
    end
  end
end
