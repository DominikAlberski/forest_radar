# frozen_string_literal: true

require_relative '../../test_helper'
require 'model/validator'

class ModelValidatorTest < Minitest::Test
  def setup
    @lines = { 'F1' => 'areas[0].distance_km=2.5' }
  end

  def test_accepts_exact_facts_and_advice
    assert_equal 'Sprawdź teren.', Model::Validator.new.validate(
      "FAKTY\nF1: areas[0].distance_km=2.5\nWNIOSKI\nSprawdź teren.", @lines
    )
  end

  def test_rejects_changed_or_added_fact
    ['F1: areas[0].distance_km=3', "F1: areas[0].distance_km=2.5\nF2: extra", 'distance=2.5'].each do |line|
      assert_raises(Model::Invalid) do
        Model::Validator.new.validate("FAKTY\n#{line}\nWNIOSKI\nSugestia.", @lines)
      end
    end
  end

  def test_rejects_edibility_and_access_claims
    phrases = [
      'Ten grzyb jest jadalny.', 'Ten grzyb jest niejadalny.', 'Ten grzyb jest trujący.',
      'Te grzyby nadają się do spożycia.', 'Te grzyby możesz jeść.',
      'Te grzyby są bezpieczne do jedzenia.', 'Las jest otwarty.', 'Lasy są otwarte.', 'Wstęp wolny.',
      'Wstęp jest wolny.', 'Do lasu można wejść.', 'Dostęp gwarantowany.'
    ]
    phrases.each do |phrase|
      [phrase.downcase, phrase.upcase].each do |advice|
        assert_raises(Model::Invalid, advice) do
          Model::Validator.new.validate("FAKTY\nF1: areas[0].distance_km=2.5\nWNIOSKI\n#{advice}", @lines)
        end
      end
    end
  end

  def test_accepts_safe_advice
    assert_equal 'Sprawdź szlak przed wyjściem.', Model::Validator.new.validate(
      "FAKTY\nF1: areas[0].distance_km=2.5\nWNIOSKI\nSprawdź szlak przed wyjściem.", @lines
    )
  end

  def test_accepts_source_name_with_prohibited_words
    lines = { 'F1' => 'trail_name=Grzyby jadalne' }
    assert_equal 'Sprawdź teren.', Model::Validator.new.validate(
      "FAKTY\nF1: trail_name=Grzyby jadalne\nWNIOSKI\nSprawdź teren.", lines
    )
  end
end
