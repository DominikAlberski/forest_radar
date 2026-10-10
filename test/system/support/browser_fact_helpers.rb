# frozen_string_literal: true

module BrowserFactHelpers
  F = BrowserTestCase::F

  def assert_card_facts
    assert_area_names
    assert_area_distances
    assert_includes card_text, 'Lata danych: 2024: 1'
    assert_includes card_text, 'Typy siedlisk'
    assert_includes card_text, 'Liczba wydzieleń'
  end

  def assert_area_names
    names = @page.evaluate("[...document.querySelectorAll('.area h4')].map(e => e.innerText)")
    assert_equal ['SYNTHETIC las 1', 'SYNTHETIC las 2', 'SYNTHETIC las 3'], names
  end

  def assert_area_distances
    distances = @page.evaluate("[...document.querySelectorAll('.area .distance')].map(e => e.textContent)")
    assert_equal ['1 km', '2 km', '3 km'], distances
  end

  def assert_external_markup(markup)
    assert_includes card_text, markup
    assert_equal 0, external_element_count
    assert_nil @page.evaluate('window.pwned')
    assert_includes card_text, '<script>window.pwned=2</script>'
  end

  def external_element_count
    @page.evaluate("document.querySelectorAll('#card-content img, #card-content script, #card-content b').length")
  end

  def prepare_external_markup(markup)
    walk = F::Walk.new([walk_area(1, name: markup,
                                     trails: [{ id: 1, name: '<script>window.pwned=2</script>' }])])
    use(walk, model: F::Model.new(markup))
    render_card
  end

  def assert_m6_warnings
    refute_match(/otwart|wstęp wolny|gwarant/i, card_text)
    assert_includes card_text, 'nie zbieraj grzyba'
    assert_includes card_text, 'Przed spacerem sprawdź aktualne zasady wstępu do lasu.'
    assert_includes card_text, 'Wskazówki modelu'
  end

  def assert_station_link
    link = @page.evaluate("(() => { const a = document.querySelector('#card-content a[target=_blank]'); " \
                          'return [a.href, a.rel]; })()')
    assert_match %r{\Ahttps://www\.google\.com/maps/search/stacja\+sanitarno-epidemiologiczna/@0\.005000,0\.005000,11z},
                 link[0].sub('%2C', ',')
    assert_includes link[1], 'noopener'
  end

  def assert_phone_viewport
    assert_equal true, @page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')
    assert_equal 1, @page.evaluate('window.visualViewport.scale')
  end

  def print_maximum_card
    use(F::Walk.new((1..3).map { |area_id| maximal_area(area_id) }), search: F::Search.new(maximal_search))
    render_card
  end
end
