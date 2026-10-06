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

## The voice

Write the card in plain Polish. Do not use forestry jargon without a gloss. A user knows "sosna". A user does not know "drzewostan sosnowy w wieku 70 lat".

## Working title alternatives

The folder name is `lesny-radar`. Other titles, if this one does not fit:

- **DoLasu** — a plain call to action. Good for a blog title.
- **Nazbierak** — points at foraging. Too narrow.

Pick one before the first commit that adds a user-facing string.