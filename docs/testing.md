# Testing

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

## Browser prerequisites (`--system`)

- Google Chrome. The default path is `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`. Set `CHROME_PATH` to use another binary.
- `pdfinfo` and `pdftotext` from poppler (`brew install poppler`). Set `PDFINFO_PATH` and `PDFTOTEXT_PATH` if they are not on `PATH`.
- A free local port. The default is `9300 + COORD_SLOT`. Set `PORT` to change it.

The harness starts its own Chrome with a temporary profile and a Ruby driver over the debugging pipe. It starts its own server with fixture services. A missing prerequisite fails the suite. Fixture area geometry is synthetic and labeled `SYNTHETIC`.

## Live prerequisites (`--live`)

- Network access to `ogcapi.bdl.lasy.gov.pl` and the configured model host.
- `OLLAMA_URL` and `OLLAMA_HOST_HARDWARE`. `OLLAMA_MODEL` is optional. A missing endpoint fails the suite. The Polish check on model output is a smoke check. Live M5 needs a recorded human language review.

The evidence record is [m1-m7-evidence.md](plans/m1-m7-evidence.md).
