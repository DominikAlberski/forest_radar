'use strict';

const words = JSON.parse(document.getElementById('ui-strings').textContent);
const form = document.getElementById('search-form');
const status = document.getElementById('status');
const result = document.getElementById('result');
const content = document.getElementById('card-content');
const locate = document.getElementById('locate');
const search = form.querySelector('[type="submit"]');

function node(tag, text, className) {
  const element = document.createElement(tag);
  element.textContent = text == null || text === '' || text === 'brak danych' ? words.unavailable : String(text);
  if (className) element.className = className;
  return element;
}

function section(parent, title) {
  const block = document.createElement('section');
  block.className = 'card-section';
  block.append(node('h3', title));
  parent.append(block);
  return block;
}

function line(parent, label, value) {
  const row = document.createElement('p');
  row.append(node('strong', `${label}: `), node('span', value));
  parent.append(row);
}

function counts(value) {
  return value && Object.keys(value).length ? Object.entries(value).map(([key, count]) => `${key}: ${count}`) : [];
}

function printText(value, limit, label = '') {
  const full = String(value);
  const characters = Array.from(full);
  const span = document.createElement('span');
  span.append(node('span', full, 'screen-text'));
  const short = characters.length > limit ? `${characters.slice(0, limit - 1).join('')}…${label}` : full;
  span.append(node('span', short, 'print-text'));
  return span;
}

function limitedList(parent, label, entries, fallback) {
  const row = document.createElement('p');
  row.append(node('strong', `${label}: `));
  if (!entries.length) row.append(node('span', fallback));
  entries.forEach((entry, index) => {
    const item = document.createElement('span');
    if (index) item.append(', ');
    item.append(printText(entry, 60));
    if (index >= 4) item.className = 'print-extra';
    row.append(item);
  });
  if (entries.length > 4) {
    row.append(node('span', ` ${words.more_count.replace('%{count}', entries.length - 4)}`, 'print-more'));
  }
  parent.append(row);
}

function renderArea(parent, area) {
  const block = document.createElement('article');
  block.className = 'area';
  const title = document.createElement('h4');
  title.append(printText(area.name, 60));
  block.append(title, node('p', `${area.distance_km} ${words.kilometers}`, 'distance'));
  limitedList(block, words.trails, (area.trails || []).map(trail => trail.name || trail.ref || words.unnamed_trail), words.trail_unknown);
  line(block, words.stands, area.stand_count);
  limitedList(block, words.species, counts(area.species), words.unavailable);
  limitedList(block, words.sites, counts(area.sites), words.unavailable);
  limitedList(block, words.ages, counts(area.ages), words.unavailable);
  limitedList(block, words.years, counts(area.years), words.unavailable);
  line(block, words.area, area.total_area);
  const missing = Object.entries(area.missing_attributes || {}).filter(([, count]) => count > 0);
  if (missing.length) limitedList(block, words.missing, missing.map(([key, count]) => `${words.attributes[key] || key}: ${count}`), words.unavailable);
  parent.append(block);
}

function render(data) {
  content.replaceChildren();
  const facts = data.facts;
  const card = data.card;
  const evidence = section(content, words.facts_title);
  evidence.append(node('p', words.facts_intro));
  if (facts.areas && facts.areas.length) facts.areas.slice(0, 3).forEach(area => renderArea(evidence, area));
  else evidence.append(node('p', words.no_areas));
  line(evidence, words.box_stands, facts.box_stand_count);
  line(evidence, words.radius_stands, facts.radius_stand_count);
  line(evidence, words.missing_ids, facts.missing_identifier_count);
  if (facts.districts && facts.districts.length) {
    const row = document.createElement('p');
    row.append(node('strong', `${words.districts}: `));
    const names = facts.districts.map(district => district.name);
    row.append(node('span', names.join(', '), 'screen-text'));
    const printed = document.createElement('span');
    printed.className = 'print-text';
    names.slice(0, 3).forEach((name, index) => {
      if (index) printed.append(', ');
      printed.append(printText(name, 40));
    });
    if (names.length > 3) printed.append(` ${words.more_count.replace('%{count}', names.length - 3)}`);
    row.append(printed);
    evidence.append(row);
  }
  const source = node('p', `${words.trail_source}: ${facts.trail_source || words.openstreetmap}`);
  evidence.append(source);
  const attribution = document.createElement('a');
  attribution.textContent = facts.attribution || words.osm_attribution;
  attribution.href = 'https://www.openstreetmap.org/copyright';
  evidence.append(attribution);
  const advice = section(content, words.advice_title);
  const adviceText = document.createElement('p');
  adviceText.append(printText(card.advice, 700, ` ${words.print_omitted}`));
  advice.append(adviceText);
  const safety = section(content, words.safety_title);
  safety.append(node('p', card.access_warning));
  safety.append(node('p', card.warning));
  const station = document.createElement('a');
  station.textContent = card.sanepid_label;
  station.href = card.sanepid_url;
  station.target = '_blank';
  station.rel = 'noopener noreferrer';
  safety.append(station);
  result.hidden = false;
}

locate.addEventListener('click', () => {
  if (!navigator.geolocation) { status.textContent = words.location_unavailable; return; }
  status.textContent = words.locating;
  locate.disabled = true;
  navigator.geolocation.getCurrentPosition(position => {
    form.elements.lat.value = position.coords.latitude;
    form.elements.lon.value = position.coords.longitude;
    status.textContent = words.location_ready;
    locate.disabled = false;
  }, () => {
    status.textContent = words.location_denied;
    locate.disabled = false;
  });
});

form.addEventListener('submit', async event => {
  event.preventDefault();
  if (!form.reportValidity()) return;
  status.textContent = words.loading;
  search.disabled = true;
  result.hidden = true;
  try {
    const response = await fetch('/api/card', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ lat: Number(form.elements.lat.value), lon: Number(form.elements.lon.value), radius_km: Number(form.elements.radius_km.value) })
    });
    const data = await response.json();
    if (!response.ok) {
      const message = typeof data?.message === 'string' && data.message.length <= 200 && data.message.trim();
      status.textContent = message || words.error;
      return;
    }
    render(data);
    status.textContent = words.ready;
  } catch (_error) {
    result.hidden = true;
    status.textContent = words.error;
  } finally {
    search.disabled = false;
  }
});

document.getElementById('print').addEventListener('click', () => window.print());
