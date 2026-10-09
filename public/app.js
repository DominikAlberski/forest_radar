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
  return value && Object.keys(value).length ? Object.entries(value).map(([key, count]) => `${key}: ${count}`).join(', ') : words.unavailable;
}

function renderArea(parent, area) {
  const block = document.createElement('article');
  block.className = 'area';
  block.append(node('h4', area.name), node('p', `${area.distance_km} ${words.kilometers}`, 'distance'));
  line(block, words.trails, area.trails && area.trails.length ? area.trails.map(trail => trail.name || trail.ref || words.unnamed_trail).join(', ') : words.trail_unknown);
  const ban = area.ban && area.ban.status;
  line(block, words.ban, ban === 'ban' ? words.ban_reported : ban === 'no_known_ban' ? words.no_known_ban : words.ban_unknown);
  line(block, words.stands, area.stand_count);
  line(block, words.species, counts(area.species));
  line(block, words.sites, counts(area.sites));
  line(block, words.ages, counts(area.ages));
  line(block, words.years, counts(area.years));
  line(block, words.area, area.total_area);
  const missing = Object.entries(area.missing_attributes || {}).filter(([, count]) => count > 0);
  if (missing.length) line(block, words.missing, missing.map(([key, count]) => `${words.attributes[key] || key}: ${count}`).join(', '));
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
    line(evidence, words.districts, facts.districts.map(district => district.name).join(', '));
  }
  const source = node('p', `${words.trail_source}: ${facts.trail_source || words.openstreetmap}`);
  evidence.append(source);
  const attribution = document.createElement('a');
  attribution.textContent = facts.attribution || words.osm_attribution;
  attribution.href = 'https://www.openstreetmap.org/copyright';
  evidence.append(attribution);
  const advice = section(content, words.advice_title);
  advice.append(node('p', card.advice));
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
    if (!response.ok) throw new Error(data.message || words.error);
    render(data);
    status.textContent = words.ready;
  } catch (error) {
    status.textContent = error.message || words.error;
  } finally {
    search.disabled = false;
  }
});

document.getElementById('print').addEventListener('click', () => window.print());
