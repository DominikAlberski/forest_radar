# Vision and the Polish angle

## The problem

A person in a Polish city wants a walk in a forest. The person does not know which forest is close, which forest is open, and what is worth looking at there.

The Polish State Forests publish excellent data. The data is not readable for a normal person. A forest inventory table names a stand `BMŚW` and a species `SO`. That is the language of a forester.

## The product

One page. The user allows location, or types a place. The program reads the forests in a radius. The program returns one short Polish card:

- the three nearest forests with a distance and a walking time
- the trees and the site type, in plain Polish
- what is in season there: mushrooms, berries, animal tracks
- whether a dog is allowed on the route
- whether the area is closed today

## The audience

A city person with a free Saturday. A forager. A dog owner. A parent who wants a short walk. All of them in Poland.

## The national pride angle

Three Polish things meet in one project.

1. **Polish data.** Lasy Państwowe publishes the forest inventory of the whole country as open data.
2. **A Polish model.** Bielik is an open-weight Polish language model. The SpeakLeash foundation and ACK Cyfronet AGH built it in Poland, on Polish supercomputers.
3. **Polish vocabulary.** The domain uses Polish words with no good English equivalent: `wydzielenie`, `nadleśnictwo`, `siedlisko`.

A closed foreign model would need a translation layer and would still guess at the terms. The Polish model reads the codes and the vocabulary natively.

This is the argument for open innovation. The open piece is not a cost saving. The open piece is what makes the product correct for the audience.

## The mushroom stance

A forest app usually offers to say which mushrooms are safe to eat. This app refuses. The model names possible species only. The card carries a warning and a link to the nearest sanitary station, where a grzyboznawca identifies the mushroom for free.

This is a product decision with a clear reason: a wrong answer can kill a person. The app sends the user to a human expert instead of guessing.

## The voice

Write the card in plain Polish. Do not use forestry jargon without a gloss. A user knows "sosna". A user does not know "drzewostan sosnowy w wieku 70 lat".

## The name

- Repository and package name: `forest_radar`.
- The Polish card title, in `pl.yml`: `Leśny Radar`.
- The English card title, in `en.yml`: empty, like every other English string.

## Stage

The local MVP runs (M1 to M7). The field test (M8) and publication are not done.

Read these files next:

1. [PLAN.md](../PLAN.md) — what to build, the architecture, and the open questions.
2. [data-sources.md](data-sources.md) — the forest data. Every endpoint is verified.
3. [model-and-prompts.md](model-and-prompts.md) — the model choice, the prompts, and the safety rules.
4. [mvp.md](plans/mvp.md) — the acceptance criteria.
5. [roadmap.md](roadmap.md) — the plan to the submission deadline.

## The two data questions

The project produces two kinds of output. Keep them apart.

- **Hard facts.** These come from the Bank Danych o Lasach. Example: the stand at this point holds pine, 70 years old, on a fresh mixed conifer site.
- **Soft advice.** These come from the model. Example: look for boletus and chanterelle here in October.

Mark the second kind as a suggestion in the interface. See the safety rules in [model-and-prompts.md](model-and-prompts.md).

## Why this project

Hacktoberfest 2026 Week 1 theme: Touch Grass. Build something that gets people off the screen and into the world.

This project uses three open pieces:

1. Open forest data from Lasy Państwowe (the Polish State Forests).
2. An open-weight Polish model (Bielik).
3. Open local inference (Ollama).

No cloud service is required. See [Privacy](../README.md) for where the location goes.
