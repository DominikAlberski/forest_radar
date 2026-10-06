# Leśny Radar — Plan

## Goal

Give a person a short list of forest walks near them and what they can find there.
The person gives a location and a radius. The program reads open forest data for that area.
A local open-weight model turns the data into a short Polish trip card.

The screen is the shortest part of the experience. The output is one card. The person prints it or screenshots it and leaves.

## What to build

One program with five parts.

```text
Browser (one Polish page, printable card)
   │  location + radius
   ▼
Geo layer        pick the RDLP regions that cover the radius
   ▼
BDL client       OGC API Features → stands, districts, ranges
                 WMS → entry bans, trails, camping areas
   ▼
Assembler        shape the data into a compact fact block
   ▼
Ollama client    POST /api/chat → Bielik (Polish prompt, Polish answer)
   ▼
Card renderer    one printable Polish trip card
```

## Architecture options (decide before implementation)

### Option A — Ruby, standard library, local web page

One Ruby process serves one HTML page and one JSON endpoint. The page uses the browser geolocation API. No gems at runtime.

- Plus: matches the existing toolchain. Small. Easy to demo.
- Plus: the whole app is one folder of small Ruby files.
- Minus: no framework means hand-written routing and templating.

### Option B — Ruby web application

Sinatra or Rails. Conventional structure. More files.

- Plus: familiar and fast to extend.
- Minus: heavier for a five-day build. The extra structure adds no value to the demo.

### Option C — Python

Python for the data work, a small web layer on top.

- Plus: the richest geo and data libraries.
- Minus: splits the project across two languages for no gain here.

**Recommendation: Option A.** The demo needs one page, one endpoint, and one model call. Ruby standard library holds all of it. The author is a Ruby developer. This matches the two earlier challenge projects.

## Components

| Component | File (proposal) | Job |
| --- | --- | --- |
| Server | `lib/server.rb` | Serve the page and the JSON endpoint |
| Geo | `lib/geo.rb` | Radius to bounding box. Point to RDLP region. |
| BDL client | `lib/bdl.rb` | OGC API Features and WMS calls. Cache the answers. |
| Assembler | `lib/assembler.rb` | Build the fact block from the raw features. |
| Model client | `lib/model.rb` | Talk to Ollama. Hold the Polish prompt. |
| Card | `lib/card.rb` | Render the Polish trip card |

## API contract

### The program serves

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| GET | `/` | — | The Polish page |
| POST | `/api/card` | `{ "lat", "lon", "radius_km" }` | `{ "facts", "card" }` |

The response holds two fields. `facts` is the raw forest data. `card` is the model text. Keep both. This shows the judges the data behind the prose.

### The program calls

| Service | Call | Purpose |
| --- | --- | --- |
| BDL OGC API | `GET /collections/{id}/items?bbox=...` | Stands and districts in the box |
| BDL WMS | `GetFeatureInfo` on the ban layer | Is the walk area closed? |

See `docs/data-sources.md` for every endpoint and a verified sample.

## Repo layout

```text
lesny-radar/
  lib/
    server.rb
    geo.rb
    bdl.rb
    assembler.rb
    model.rb
    card.rb
  public/
    index.html
    card.css
  config/
    model.yml
  test/
  docs/
    data-sources.md
    model-and-prompts.md
    roadmap.md
    plans/mvp.md
    blog-outline.md
  README.md
  PLAN.md
  GLOSSARY.md
```

## Scope — MVP

1. The page reads the location and the radius from the user. Green or Red.
2. The program picks the RDLP region or regions for the location. Green or Red.
3. The program reads the stands and the districts in the box. Green or Red.
4. The program checks the entry ban layer for the box. Green or Red.
5. The model returns a Polish trip card from the fact block. Green or Red.
6. The card is printable and readable on a phone. Green or Red.
7. The author takes the card outside and uses it. Green or Red.

## Deferred — plan only

- Add a map raster from the BDL tourist WMS. Show the trails under the card.
- Add "Zanocuj w lesie" camping areas as a filter.
- Add a berry and mushroom season table per region.
- Fine-tune Bielik on Polish forestry terms.
- Offer a small model for a phone, so the app works with no laptop.

## Pitfalls

- **P1 — the entry ban layer is WMS only.** There is no clean JSON endpoint. Use `GetFeatureInfo`. Treat the answer as best effort. Say so in the card.
- **P2 — the stand data is split by RDLP region.** Nineteen collections hold the stands. Pick the region by a point-in-polygon test against the `rdlp` collection. A radius can cross two regions.
- **P3 — the stand attributes use Polish forestry codes.** `species_cd` holds `SO` for pine. `site_type` holds `BMŚW` for a fresh mixed conifer site. The model can decode these. A small dictionary is more reliable for the hard facts.
- **P4 — Ollama binds to localhost by default.** Set `OLLAMA_HOST=0.0.0.0` on the model host. Otherwise the app cannot reach it.
- **P5 — foraging advice can harm a person.** Never state that a mushroom is safe to eat. See the safety rules in `docs/model-and-prompts.md`.
- **P6 — the public service is shared.** Cache the answers. Send one request per session, not one per keystroke.
- **P7 — the attributes have gaps.** Some stands have a null `species_cd`. State the gap. Do not invent the value.

## Why open innovation matters

The forest data is public. The model is open-weight. The inference is local. A closed cloud API would send the location of the user to a third party and charge per token. This design sends nothing. The user can also swap the model in one line of config. That freedom is the point.

This is the story for the DEV post. See `docs/blog-outline.md`.