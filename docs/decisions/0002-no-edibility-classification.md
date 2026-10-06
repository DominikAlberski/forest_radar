# The model never classifies mushroom edibility

A forest advisor naturally offers to say which mushrooms are safe to eat. This project refuses that feature on purpose. The model names possible species only, and it never states or implies that a mushroom is edible or poisonous. The card instead carries a fixed warning and a link to the nearest sanitary station, where a grzyboznawca identifies the mushroom for free.

## Why

A wrong edibility answer can kill a person. Sanepid itself advises against judging edibility by taste and against judging it with an application. The project removes the judgement instead of trying to make it accurate.

## Consequences

- The prompt forbids the words `jadalny`, `niejadalny`, and `trujący`.
- A test rejects a model answer that holds a forbidden word, and asks the model again.
- The warning is a fixed locale string. The model does not write it.
- The program carries no edibility data. No lookup table, no filter.