# frozen_string_literal: true

require 'open3'
require_relative 'support/browser_test_case'
require_relative 'support/browser_core_helpers'

class PrintTest < BrowserTestCase
  include BrowserCoreHelpers

  def test_phone_viewport_has_no_horizontal_overflow
    use(F.real_selector(4), model: F::Model.new('x' * 3000))
    render_card
    assert_equal true, @page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')
  end

  def test_print_preserves_full_description_and_warnings
    use(F.real_selector(4), model: F::Model.new("#{'Spacer w lesie. ' * 600}KONIEC OPISU"))
    render_card
    Dir.mktmpdir('forest-card-print') { |directory| assert_printed_card(directory) }
  end

  def assert_printed_card(directory)
    path = File.join(directory, 'card.pdf')
    @page.print_pdf(path)
    text, status = Open3.capture2(PDFTOTEXT, path, '-')
    assert status.success?
    assert_print_text(text.gsub(/\s+/, ' '))
  end

  def assert_print_text(text)
    assert_includes text, 'KONIEC OPISU'
    assert_includes text, 'halucynacje'
    assert_includes text, 'nie zbieraj grzyba'
    refute_includes text, '[pominięto dalszą część]'
  end
end
