# frozen_string_literal: true

module BrowserCardHelpers
  F = BrowserTestCase::F
  PDFINFO = BrowserTestCase::PDFINFO
  PDFTOTEXT = BrowserTestCase::PDFTOTEXT

  def assert_standard_print(text)
    assert_includes text, 'OpenStreetMap'
    assert_includes text, 'nie zbieraj grzyba'
    assert_includes text, 'Przed spacerem sprawdź aktualne zasady wstępu do lasu.'
    assert_includes text, 'Lata danych'
  end

  def assert_openstreetmap_attribution
    assert_includes card_text, 'Źródło szlaków: OpenStreetMap'
    link = @page.evaluate("(() => { const a = [...document.querySelectorAll('#card-content a')].find(a => " \
                          "a.href.includes('openstreetmap')); return a && [a.href, a.textContent]; })()")
    assert_equal ['https://www.openstreetmap.org/copyright', OSM::Client::ATTRIBUTION], link
  end

  def assert_fifth_entry_screen
    assert_includes card_text, 'SYNTHETIC entry 5'
    script = "[...document.querySelectorAll('.print-more')].every((element) => " \
             "getComputedStyle(element).display === 'none')"
    assert_equal true, @page.evaluate(script)
  end

  def assert_fifth_entry_print
    text = print_and_read('fifth-entry')
    refute_includes text, 'SYNTHETIC entry 5'
    assert_includes text, 'i jeszcze 1'
  end

  def assert_long_screen_text
    %w[AFTERADVICE AFTERTRAIL AFTERAREA AFTERDISTRICT AFTERSUMMARY].each do |marker|
      assert_includes card_text, marker
    end
  end

  def assert_long_print_text(text)
    assert_long_boundaries(text)
    assert_long_context(text)
    assert_full_safety_text(text)
  end

  def assert_long_boundaries(text)
    %w[BEFOREADVICE BEFORETRAIL BEFOREAREA BEFOREDISTRICT BEFORESUMMARY].each { |marker| assert_includes text, marker }
    %w[AFTERADVICE AFTERTRAIL AFTERAREA AFTERDISTRICT AFTERSUMMARY].each { |marker| refute_includes text, marker }
  end

  def assert_long_context(text)
    assert_includes text, 'i jeszcze 2'
    assert_includes text, '[pominięto dalszą część]'
    assert_includes text, '© OpenStreetMap'
  end

  def assert_full_safety_text(text)
    assert_full_mushroom_warning(text)
    assert_includes text, 'Przed spacerem sprawdź aktualne zasady wstępu do lasu.'
  end

  def assert_full_mushroom_warning(text)
    warning = 'Zbieranie grzybów, których nie znasz, może zagrażać zdrowiu i życiu. ' \
              'Jeśli masz wątpliwości, nie zbieraj grzyba. Możesz też zanieść go do ' \
              'najbliższej stacji sanitarno-epidemiologicznej. Grzyboznawca sprawdzi go bezpłatnie.'
    assert_includes text, warning
  end
end
