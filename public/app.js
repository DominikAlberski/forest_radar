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
  block.append(node('h4', title));
  parent.append(block);
  return block;
}

function render(data) {
  content.replaceChildren();
  const cards = data.cards || [data.card];
  cards.forEach(renderCard);
  if (!cards.length) content.append(node('p', words.no_areas));
  result.hidden = false;
}

function renderCard(card) {
  const article = document.createElement('article');
  article.className = 'forest-card';
  article.append(node('h3', card.name || words.forest));
  article.append(node('p', card.disclaimer, 'disclaimer'));
  const description = section(article, words.advice_title);
  const response = document.createElement('p');
  response.className = 'model-description';
  response.textContent = card.advice;
  description.append(response);
  const maps = document.createElement('ul');
  (card.forests || []).forEach(forest => {
    const item = document.createElement('li');
    const link = document.createElement('a');
    link.textContent = words.forest_map.replace('%{name}', forest.name);
    link.href = forest.url;
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    item.append(link);
    maps.append(item);
  });
  if (maps.childElementCount) description.append(maps);
  if (card.walking) {
    const attribution = node('a', words.osm_attribution);
    attribution.href = 'https://www.openstreetmap.org/copyright';
    description.append(attribution);
  }
  const safety = section(article, words.safety_title);
  safety.append(node('p', card.warning));
  const station = document.createElement('a');
  station.textContent = card.sanepid_label;
  station.href = card.sanepid_url;
  station.target = '_blank';
  station.rel = 'noopener noreferrer';
  safety.append(station);
  content.append(article);
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
