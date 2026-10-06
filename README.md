# Forest Radar

A forest walk advisor for Poland. It finds forests near the user and says what to look for there.

The user gives a location and a radius. The program asks the Bank Danych o Lasach for the forests in that radius. The program sends the findings to a local open-weight model. The model writes a short trip card in Polish: which forest, what grows there, what animals live there, and whether the entry rules allow a dog.

The repository name is `forest_radar`.

## Stage

Specification only. There is no code yet.

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

The model must not classify a mushroom as edible or as poisonous. The card names possible species only. The mushroom section always carries a warning and a link to the nearest sanitary station.

Read `docs/model-and-prompts.md` before you touch the mushroom section.

## Why this project

Hacktoberfest 2026 Week 1 theme: Touch Grass. Build something that gets people off the screen and into the world.

This project uses three open pieces:

1. Open forest data from Lasy Państwowe (the Polish State Forests).
2. An open-weight Polish model (Bielik).
3. Open local inference (Ollama).

No cloud service is required. The location of the user stays on the machine of the user.

## License

MIT. See `LICENSE`.