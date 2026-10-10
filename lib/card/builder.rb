# frozen_string_literal: true

require 'i18n'
require_relative '../sanepid'

module Card
  # Combines facts, advice, and safety text for a trip card.
  class Builder
    def initialize(translator: I18n)
      @translator = translator
    end

    def build(facts:, advice:, lat:, lon:)
      { facts: facts, advice: advice, warning: @translator.t('card.mushroom_warning'),
        access_warning: @translator.t('card.access_warning'), sanepid_label: @translator.t('card.sanepid_label'),
        sanepid_url: Sanepid.url(lat, lon, template: @translator.t('card.sanepid_url_template')) }
    end
  end
end
