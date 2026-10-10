# Forest Radar

A forest walk advisor for Poland. It finds forests near the user and says what to look for there.

The user gives a location and a radius. The program asks the Bank Danych o Lasach for the forests in that radius. The program sends the findings to a local open-weight model. The model writes a short trip card in Polish: which forest, what grows there, and what animals live there. The card makes no promise that a forest is open and no promise about dogs.

The repository name is `forest_radar`.

## Stage

The local MVP runs (M1 to M7). The field test (M8) and publication are not done.

Read these files next:

1. `PLAN.md` — what to build, the architecture, and the open questions.
2. `docs/data-sources.md` — the forest data. Every endpoint is verified.
3. `docs/model-and-prompts.md` — the model choice, the prompts, and the safety rules.
4. `docs/plans/mvp.md` — the acceptance criteria.
5. `docs/roadmap.md` — the plan to the submission deadline.

## Language rule

The user interface uses i18n. The Polish locale is complete. The English locale exists with the same keys and empty values.

- All user-facing strings live in `config/locales/pl.yml` and `config/locales/en.yml`.
- Never hardcode a user-facing string in a view or in Ruby code.
- The Polish locale is the source of truth. Add a key there first.
- The English locale is a placeholder for a later translation. Leave the values empty.
- Write the documents and the code comments in English.

## The two data questions

The project produces two kinds of output. Keep them apart.

- **Hard facts.** These come from the Bank Danych o Lasach. Example: the stand at this point holds pine, 70 years old, on a fresh mixed conifer site.
- **Soft advice.** These come from the model. Example: look for boletus and chanterelle here in October.

Mark the second kind as a suggestion in the interface. See the safety rules in `docs/model-and-prompts.md`.

## The mushroom rule

The app displays the model response unchanged. The card carries an AI hallucination disclaimer and a fixed mushroom warning.
The card also links to a sanitary station. The app does not validate model claims about mushrooms or forest access.

Read `docs/model-and-prompts.md` before you touch the mushroom section.

## Why this project

Hacktoberfest 2026 Week 1 theme: Touch Grass. Build something that gets people off the screen and into the world.

This project uses three open pieces:

1. Open forest data from Lasy Państwowe (the Polish State Forests).
2. An open-weight Polish model (Bielik).
3. Open local inference (Ollama).

No cloud service is required. See "Privacy" for where the location goes.

## Run it

Requirements: Ruby 4.0 and Bundler.

```sh
bundle install
bundle exec rackup -p 9292        # or: bundle exec puma -C config/puma.rb
```

Open `http://localhost:9292/`. Type a latitude, a longitude, and a radius from 1 to 20 km, or press the location button.

### Model configuration

`config/model.yml` selects the model client.

- `client: stub` returns a fixed Polish sentence. Use it without a model host.
- Any other value uses Ollama at `url` with the model `model`. Example: `url: http://localhost:11434`.

The default client uses Ollama and Bielik. The root `.env` can override the host with `FOREST_RADAR_MODEL_URL`.
Use `FOREST_RADAR_MODEL_CLIENT` to select the client and `FOREST_RADAR_MODEL_NAME` to select the model.
The app ignores the older stub fallback setting. A browser request cannot select the model host.

### Cache limits

The server keeps source answers in memory, per browser session cookie. The limits are 256 entries and 128 MiB. A search answer lives 30 minutes. A restart clears the cache.

### Source limitations

- Each BDL forest receives a separate card and a separate model description.
- Each model request receives only the summary for that forest.
- Each model request also receives that forest's retrieved OpenStreetMap trail evidence and evidence status.
- The Maps link identifies the forest location. The link does not verify a walking route.
- The card shows the complete model response, an AI hallucination disclaimer, and the mushroom warning.
- A BDL retrieval failure, a model failure, or a missing region gives an error message and no card.
- OpenStreetMap trail selection remains in the API facts. The card does not show the source fact tables.
- The app does not check, rewrite, or retry model content. Printed cards preserve the complete response.
- The model deadline is 89 seconds for each forest card. The app generates the cards sequentially.
- All browser searches share one FIFO model queue in the server process.
- Each request starts its deadline after it reaches the front of the queue.

## Privacy

The location does not stay on one machine.

- The Bank Danych o Lasach (BDL) receives a query with a bounding box around the location.
- The Overpass API receives a query with the same bounding box.
- The configured model host receives the fact block. The block holds distances and stand data, not the raw coordinates. With `client: stub` no host receives it. A remote model host sees the facts. Use a host you control.
- Google Maps receives the location only after the user opens the sanitary station link.

## Tests

```sh
bundle exec ruby test/run.rb --unit      # unit tests, no network, stub model
bundle exec ruby test/run.rb --system    # headless Chrome checks, no coord needed
```

Live checks need the network and an Ollama endpoint. Run them in one command:

```sh
OLLAMA_URL=http://host:11434 OLLAMA_HOST_HARDWARE='<description>' OLLAMA_MODEL=<tag> \
  bundle exec ruby test/run.rb --live
```

Contributors who use the `coord` task board run the shared-resource suites under locks. Run `source .maf/env.sh` once, then:

```sh
coord with-lock system-test -- bundle exec ruby test/run.rb --system
OLLAMA_URL=http://host:11434 OLLAMA_HOST_HARDWARE='<description>' OLLAMA_MODEL=<tag> \
  coord with-lock ollama -- bundle exec ruby test/run.rb --live
```

`--all` runs `--unit` and `--system`. It never runs `--live`.

### Browser prerequisites (`--system`)

- Google Chrome. The default path is `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`. Set `CHROME_PATH` to use another binary.
- `pdfinfo` and `pdftotext` from poppler (`brew install poppler`). Set `PDFINFO_PATH` and `PDFTOTEXT_PATH` if they are not on `PATH`.
- A free local port. The default is `9300 + COORD_SLOT`. Set `PORT` to change it.

The harness starts its own Chrome with a temporary profile and a Ruby driver over the debugging pipe. It starts its own server with fixture services. A missing prerequisite fails the suite. Fixture area geometry is synthetic and labeled `SYNTHETIC`.

### Live prerequisites (`--live`)

- Network access to `ogcapi.bdl.lasy.gov.pl` and the configured model host.
- `OLLAMA_URL` and `OLLAMA_HOST_HARDWARE`. `OLLAMA_MODEL` is optional. A missing endpoint fails the suite. The Polish check on model output is a smoke check. Live M5 needs a recorded human language review.

The evidence record is `docs/plans/m1-m7-evidence.md`.

## License

MIT. See `LICENSE`.
