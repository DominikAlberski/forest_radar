# frozen_string_literal: true

module BrowserPrintDataHelpers
  F = BrowserTestCase::F
  PDFINFO = BrowserTestCase::PDFINFO
  PDFTOTEXT = BrowserTestCase::PDFTOTEXT

  def long_advice
    "#{'ż ' * 342}ż  BEFOREADVICE AFTERADVICE #{'ż ' * 1140}ż"
  end

  def long_text_walk
    areas = (1..3).map { |area_id| long_text_area(area_id) }
    F::Walk.new(areas)
  end

  def long_text_area(area_id)
    walk_area(area_id, name: "#{'ą' * 47}  BEFOREAREA AFTERAREA", trails: long_trails(area_id))
  end

  def long_trails(area_id)
    (1..4).map { |trail_id| { id: trail_id, name: "#{'ź ' * 24}BEFORETRAIL AFTERTRAIL#{area_id}-#{trail_id}" } }
  end

  def long_search
    data = F.search(count: 3)
    data[:stands] = long_stands
    data[:districts] = long_districts
    data
  end

  def long_stands
    (1..3).map { |area_id| F.stand(area_id, 'species_cd' => "BEFORESUMMARY #{'ś' * 180} AFTERSUMMARY") }
  end

  def long_districts
    (1..5).map { |district_id| long_district(district_id) }
  end

  def long_district(district_id)
    { 'id' => district_id, 'properties' => { 'name' => "#{'ł' * 24} BEFOREDISTRICT AFTERDISTRICT#{district_id}" } }
  end

  def print_and_read(name)
    Dir.mktmpdir('forest-radar-pdf') { |dir| render_pdf(name, dir) }
  end

  def render_pdf(name, directory)
    path = File.join(directory, "#{name}.pdf")
    @page.print_pdf(path)
    assert_pdf_page(path)
    extract_pdf_text(path)
  end

  def assert_pdf_page(path)
    info, status = Open3.capture2e(PDFINFO, path)
    assert status.success?, info
    assert_match(/^Pages:\s+1$/, info)
    assert_pdf_size(info)
  end

  def assert_pdf_size(info)
    width, height = info[/^Page size:\s+([\d.]+) x ([\d.]+) pts/, 0].scan(/[\d.]+/).map(&:to_f)
    assert_in_delta 595, width, 3
    assert_in_delta 842, height, 3
  end

  def extract_pdf_text(path)
    Open3.capture2(PDFTOTEXT, path, '-').first.gsub(/\s+/, ' ')
  end

  def walk_area(identifier, name: "SYNTHETIC las #{identifier}", trails: [F.trail(0.01)])
    { 'id' => identifier, 'distance_km' => identifier.to_f, 'district_id' => 1, 'properties' => { 'name' => name },
      trails: trails }
  end

  def maximal_search
    F.search(count: 3, stands: maximal_stands)
  end

  def maximal_stands
    (1..3).flat_map { |area_id| maximal_stands_for_area(area_id) }
  end

  def maximal_stands_for_area(area_id)
    (1..60).map { |stand_id| maximal_stand(area_id, stand_id) }
  end

  def maximal_stand(area_id, stand_id)
    F.stand(area_id, 'spec_age' => stand_id, 'a_year' => 1990 + (stand_id % 35),
                     'species_cd' => "GAT#{stand_id % 25}", 'site_type' => "SIEDLISKO#{stand_id % 20}",
                     'sub_area' => stand_id.odd? ? 1.5 : nil)
  end

  def maximal_area(identifier)
    trails = (1..12).map do |n|
      { id: n, name: "SYNTHETIC bardzo długa nazwa szlaku turystycznego numer #{n} #{'x' * 40}" }
    end
    walk_area(identifier, name: "SYNTHETIC las #{identifier} #{'długa nazwa ' * 6}", trails: trails)
  end
end
