# Forest Radar

A forest walk advisor for Poland. It finds forests near the user and says what to look for there.

The user gives a location and a radius. The program asks the Bank Danych o Lasach for the forests in that radius. The program sends the findings to a local open-weight model. The model writes a short trip card in Polish: which forest, what grows there, and what animals live there. The card makes no promise that a forest is open and no promise about dogs.

The repository name is `forest_radar`.

The local MVP runs. Read the current stage and project links in [the vision](docs/vision.md).

The project separates forest facts from model advice. Read [the two data questions](docs/vision.md) and [why this project exists](docs/vision.md).

## The mushroom rule

The model must not classify a mushroom as edible or as poisonous. The card names possible species only. The mushroom section always carries a warning and a link to the nearest sanitary station.

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

## Privacy

The location does not stay on one machine.

- The Bank Danych o Lasach (BDL) receives a query with a bounding box around the location.
- The Overpass API receives a query with the same bounding box.
- The configured model host receives the fact block. The block holds distances and stand data, not raw coordinates. With `client: stub`, no host receives it. A remote model host sees the facts. Use a host you control.
- Google Maps receives the location only after the user opens the sanitary station link.

## License

MIT. See [LICENSE](LICENSE).
