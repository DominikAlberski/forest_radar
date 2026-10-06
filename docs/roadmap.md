# Roadmap to the submission

Deadline: 2026-10-11, 23:59 PDT.

## Day 1 — 2026-10-06 (today)

- Finish the specification. This folder. Done.
- Architecture decided: Sinatra. See `docs/decisions/0001-sinatra-over-stdlib.md`.
- Title decided: `forest_radar`.
- Start Ollama with Bielik. Pull the model.
- Record one raw BDL answer for the reference place. Keep it as a fixture.

## Day 2 — 2026-10-07

- Scaffold the Sinatra app. `Gemfile`, `config.ru`, `lib/app.rb`, one route.
- Build the i18n setup. `pl.yml` with the strings. `en.yml` with empty values.
- Build the geo layer. Radius to box. Point to RDLP region.
- Build the BDL client. Stands by box. Districts by box.
- Write the tests with the recorded fixture. No live call in the test.

## Day 3 — 2026-10-08

- Build the assembler. Group the stands by district. Compact the fact block.
- Build the model client. Send the fact block. Get the Polish answer.
- Add the forbidden-word check for M5.
- Compare Bielik and Gemma on the same fact block. Keep both answers.

## Day 4 — 2026-10-09

- Build the card view. Polish page. Printable.
- Build `lib/sanepid.rb`. The Google Maps link for M6.
- Add the fixed mushroom warning.
- Add the ban check from the WMS layer.
- Run the whole path end to end.

## Day 5 — 2026-10-10

- Take the card outside. Walk. Record the field notes (M8).
- Collect the evidence list from `docs/plans/mvp.md`.
- Write the blog post from `docs/blog-outline.md`.

## Day 6 — 2026-10-11

- Publish the post on DEV with the tags `devchallenge`, `hf26challenge`.
- Push the repository. Check the README as a stranger.
- Submit before 23:59 PDT.

## Risks and the answer

| Risk | Answer |
| --- | --- |
| The ban layer is hard to parse | Ship it as best effort. State the limit in the card. |
| The model is slow | Warm it at start. Reduce the fact block. |
| The model writes a forbidden word | The check rejects the answer. Ask the model again one time. |
| A region border splits the box | Pick both regions. Test with a border point early. |
| Time runs out | Cut M4 and the map. Keep M1, M2, M3, M5, M6, M7, M8. |

## What to write down as we go

Keep a running file `docs/session-log.md`. Add one line per working session: the date, what changed, and any wrong model answer with the raw text. The log is the raw material for the "honest limits" section of the post.