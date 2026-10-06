# Roadmap to the submission

Deadline: 2026-10-11, 23:59 PDT.

## Day 1 — 2026-10-06 (today)

- Finish the specification. This folder.
- Decide the architecture option. See `PLAN.md`.
- Decide the title.
- Install or start Ollama with Bielik. Pull the model.
- Record one raw BDL answer for the reference place. Keep it as a fixture.

## Day 2 — 2026-10-07

- Build the geo layer. Radius to box. Point to RDLP region.
- Build the BDL client. Stands by box. Districts by box.
- Write the tests with the recorded fixture. No live call in the test.

## Day 3 — 2026-10-08

- Build the assembler. Group the stands by district. Compact the fact block.
- Build the model client. Send the fact block. Get the Polish answer.
- Compare Bielik and Gemma on the same fact block. Keep both answers.

## Day 4 — 2026-10-09

- Build the card renderer. Polish page. Printable.
- Add the ban check from the WMS layer.
- Add the safety warning.
- Run the whole path end to end.

## Day 5 — 2026-10-10

- Take the card outside. Walk. Record the field notes (M7).
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
| A region border splits the box | Pick both regions. Test with a border point early. |
| Time runs out | Cut M4 and the map. Keep M1, M2, M3, M5, M6, M7. |

## What to write down as we go

Keep a running file `docs/session-log.md`. Add one line per working session: the date, what changed, and any wrong model answer with the raw text. The log is the raw material for the "honest limits" section of the post.