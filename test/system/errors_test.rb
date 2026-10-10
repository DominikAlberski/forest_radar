# frozen_string_literal: true

require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'
require_relative 'support/browser_behavior_helpers'
require_relative 'support/browser_card_helpers'
require_relative 'support/browser_fact_helpers'
class ErrorsTest < BrowserTestCase
  include BrowserCoreHelpers
  include BrowserBehaviorHelpers
  include BrowserCardHelpers

  ERROR_CASES = {
    'Brak danych leśnych dla tej lokalizacji.' => { search: F::Search.new(nil, error: BDL::NoCoverage.new('x')) },
    'Nie można pobrać kompletnych danych źródłowych.' => { search: F::Search.new(nil,
                                                                                 error: BDL::Incomplete.new('x')) },
    'Nie można przygotować karty. Spróbuj ponownie.' => { model: F::Model.new(error: ::Model::Invalid.new('x')) },
    'Model nie odpowiedział w wyznaczonym czasie.' => { model: F::Model.new(error: ::Model::Deadline.new('x')) }
  }.freeze
  REQUEST_FAILURES = ["Promise.reject(new TypeError('Failed to fetch'))",
                      "Promise.resolve(new Response('{broken', { status: 200 }))"].freeze

  def test_error_responses_show_polish_messages_and_no_card
    ERROR_CASES.each { |message, options| assert_page_error(message, options) }
  end

  def test_request_failures_show_polish_text
    REQUEST_FAILURES.each { |reply| assert_request_failure(reply) }
  end
end
