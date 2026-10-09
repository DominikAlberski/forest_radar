# frozen_string_literal: true

require 'i18n'
require_relative '../sanepid'

module Card
  class Builder
    def build(facts:, advice:, lat:, lon:)
      { facts: facts, advice: advice, warning: I18n.t('card.mushroom_warning'),
        access_warning: I18n.t('card.access_warning'), sanepid_label: I18n.t('card.sanepid_label'),
        sanepid_url: Sanepid.url(lat, lon, template: I18n.t('card.sanepid_url_template')) }
    end
  end
end
