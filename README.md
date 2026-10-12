# Forest Radar

A forest walk advisor for Poland. It finds forests near the user and says what to look for there.

The user gives a location and a radius. The program asks the Bank Danych o Lasach for the forests in that radius. The program sends the findings to a local open-weight model. The model writes a short trip card in Polish: which forest, what grows there, and what animals live there. The card makes no promise that a forest is open and no promise about dogs.

The repository name is `forest_radar`.

The local MVP runs. Read the current stage and project links in [the vision](docs/vision.md).

The project separates forest facts from model advice. Read [the two data questions](docs/vision.md) and [why this project exists](docs/vision.md).

## The mushroom rule

The app displays the model response unchanged. The card carries an AI hallucination disclaimer and a fixed mushroom warning.
The card also links to a sanitary station. The app does not validate model claims about mushrooms or forest access.

Read [the model and prompt rules](docs/model-and-prompts.md) before you touch the mushroom section.

## Run it

1. Install Ruby 4.0 and Bundler.
2. Run `bundle install`.
3. Optional: choose the model client in [config/model.yml](config/model.yml). The default `stub` needs no model host. Read [configuration](docs/configuration.md).
4. Start the server with `bundle exec rackup -p 9292`. You can also run `bundle exec puma -C config/puma.rb`.
5. Open `http://localhost:9292/`. Type a latitude, a longitude, and a radius from 1 to 20 km, or press the location button.

Run the unit tests with `bundle exec ruby test/run.rb --unit`. Read [testing](docs/testing.md) for other suites and prerequisites.

Read [source limitations](docs/sources.md) before you interpret a card.

Contributors should read the [language rule](docs/contributing.md).
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
- The configured model host receives the fact block. The block holds distances and stand data, not raw coordinates. With `client: stub`, no host receives it. A remote model host sees the facts. Use a host you control.
- Google Maps receives the location only after the user opens the sanitary station link.

## License

MIT. See [LICENSE](LICENSE).
