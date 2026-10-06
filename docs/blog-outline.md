---
title: ""
published: false
tags: devchallenge, hf26challenge
---

<!-- Working outline. Fill this in during the build. Do not publish this file. -->

# Blog outline

The reviewing is weighted toward the writing. Plan the post before the code is finished.

## Title candidates

- "The Polish forest service publishes everything. I built a pilot for it."
- "A Polish model, Polish forest data, and one card you take outside."
- "Touch grass with open data: finding the right forest walk in Poland."

## Thesis

Three open pieces meet: Polish open forest data, an open-weight Polish model, and local inference. Together they make a product that a closed API cannot make correctly for its audience.

## Section 1 — What I Built

- One page. A location and a radius. One Polish card.
- The card says: which forest, what grows there, what is in season, the entry rules, the dog rules.
- Who it is for: a city person in Poland with a free Saturday.

## Section 2 — Demo

- A screenshot of one full card.
- The fact block behind it. Show the raw BDL fields.
- A short video or a GIF of the flow.

## Section 3 — Code

- The GitHub repository.
- Ruby standard library. No runtime gems.
- The tests with the recorded fixture.

## Section 4 — How I Built It

- The data: Bank Danych o Lasach. OGC API Features. The stand fields.
- The model: Bielik on Ollama over the LAN.
- The prompt: the Polish system prompt. The fact block.
- The two-model comparison: Bielik against Gemma on one fact block.

## Section 5 — The honest limits (the part that worked last time)

- The model invents mushroom names for the wrong site type. Show the raw answer.
- The ban layer is WMS only. State the limit.
- The data holds no mushroom, berry, or dog field. The model fills the gap with a guess.

Write this section from the session log. Name each failure with the raw text.

## Section 6 — Why Does Open Innovation Matter?

- The location of the user never leaves the machine. A closed cloud API would receive it.
- The model is swappable. One line of config changes the engine.
- No per-token cost. The hardware is already there.
- The Polish model knows the Polish domain terms. A foreign closed model would guess.

## Section 7 — My Agent Session

- Save the session with DevRelay. Embed it, or link to it.
- Optional, but the judges like it.

## Section 8 — Prize Categories

List every category that genuinely applies. Remove the section if none apply.

- **Best Use of Gemma** — if Gemma 3 is used as the second model in the comparison.

## Preparation checklist

- [ ] One full card screenshot
- [ ] The fact block behind the card
- [ ] Both model answers for one fact block
- [ ] The field notes from the real walk
- [ ] At least one wrong model answer, with the raw text
- [ ] The repository is public and the README works for a stranger
- [ ] The tags are `devchallenge` and `hf26challenge`