# The model and the prompts

## The model

Default: **Bielik**, served by Ollama on the local network.

```text
ollama pull SpeakLeash/bielik-11b-v2.3-instruct:Q4_K_M
```

- Open weights. The SpeakLeash foundation and ACK Cyfronet AGH built it in Poland.
- Polish first, with coverage of 32 European languages.
- `Q4_K_M` is about 6.5 GB of weights. It fits a 16 GB machine.

### The swappable alternative

```text
ollama pull gemma3:12b
```

Set the model in `config/model.yml`. One line changes the model.

Keep both. Bielik is the correct model for the Polish output. Gemma is a second engine for the comparison in the blog post. The swap is also the clearest demonstration of the open-innovation argument.

### The speed note

An 11B model on a 16 GB machine is not instant. Expect a few seconds for a card. Warm the model before the first user request. Tell the user that the request takes a moment.

## The prompt design

Four rules.

1. Give the model the facts, not the question. The model must answer from the fact block.
2. Ask for Polish. Do not ask for a translation.
3. Mark the soft advice. The prompt must separate the certain part from the guessed part.
4. Forbid any edibility claim. The mushroom section names species only.

### System prompt, first draft

Write the prompt in Polish.

```text
Jesteś leśnym doradcą. Odpowiadasz po polsku, krótko i rzeczowo.

Masz poniżej dane z Banku Danych o Lasach dla lasów w promieniu zadanym
przez użytkownika. Te dane są pewne:
- gatunek drzewa (species_cd)
- typ siedliska (site_type)
- wiek drzewostanu (spec_age)
- nadleśnictwo i adres leśny

Z tych danych wywnioskuj, czego można się spodziewać w terenie:
grzyby, jagody, ślady zwierząt. Ten wniosek jest tylko sugestią.

Zasady:
1. NIGDY nie oceniaj, czy grzyb jest jadalny ani trujący.
   Nie używaj słów "jadalny", "niejadalny", "trujący".
   Podaj tylko możliwe gatunki.
2. Nie zgaduj, jeśli danych nie ma. Napisz "brak danych".
3. Napisz krótko. Maksymalnie 250 słów.
```

### User message

```text
Lokalizacja: 52.23, 21.00
Promień: 10 km
Data: 2026-10-06

DANE Z BDL:
<fact block>
```

The program builds the fact block. The fact block holds the stands that matter, grouped by district. Keep it short. A model with a 4K context cannot read the whole box.

### Compact the fact block

The box for a 10 km radius can hold thousands of stands. Do not send them all. Reduce the block:

- Group by district.
- Summarize stands in the displayed forest ranges.
- Keep the dominant species and the dominant site type.
- Report the counts, not every row.

Each model fact line uses `F<id>: <value>`. The application checks every line against the fact block.
The application rejects the full answer when a line is absent, changed, or added.
The word checks can detect known phrases. They cannot prove complete semantic safety.

## The mushroom rule

The rule comes from the author. It is not negotiable.

**The model must not distinguish between an edible and a non-edible mushroom.**

- The model may name the possible species for the habitat.
- The model must never state, imply, or rank the edibility of a species.
- The model must not use the Polish words "jadalny", "niejadalny", or "trujący".
- The program must not compute an edibility value either. No lookup table, no filter.

Sanepid supports the rule. Sanepid writes: do not check edibility by taste, and do not check it with an application.

### The mandatory warning

The card holds this text in the mushroom section. The text is a fixed locale string. The model does not write it.

Polish:

```text
Zbieranie grzybów, których nie znasz, może zagrażać zdrowiu i życiu.
Jeśli masz wątpliwości, nie zbieraj grzyba. Możesz też zanieść go do
najbliższej stacji sanitarno-epidemiologicznej. Grzyboznawca sprawdzi
go bezpłatnie.
```

Facts for the disclaimer:

- The service is free of charge.
- The service runs on weekdays.
- Bring whole, fresh mushrooms. Bring them within 48 hours of picking.
- Do not clean, cut, or cook the mushrooms before the check.
- The legal basis is the Rozporządzenie Ministra Zdrowia of 17 May 2011 (Dz.U. 2023 poz. 2237).

### The nearest sanitary station link

The card holds a link. The link opens Google Maps on the nearest stations.

```text
https://www.google.com/maps/search/stacja+sanitarno-epidemiologiczna/@{lat},{lon},11z
```

- `lib/sanepid.rb` builds the URL. The method takes the latitude and the longitude.
- Store the URL template in `pl.yml`. Never hardcode the URL in the view.
- Open the link in a new tab. Add `rel="noopener"`.
- Add the short label from the locale file. Example: `Sprawdź grzyby u grzyboznawcy`.

## The honest-limits section

The earlier dashboard project showed the model inventing a reason with no evidence. The reviewers liked that part. Keep the pattern here.

Record every wrong or invented answer. Send the records with the submission. Name the failure.

Known risks to record:

- The model names a mushroom for a site type where that mushroom does not grow.
- The model ignores the edibility rule and writes "jadalny".
- The model states an entry rule without source evidence.
- The model invents a district name.
- The model reports a dog rule as a fact, when the rule depends on the district and the season.

### The countermeasure

Tell the model to separate the two kinds of output. Ask for two sections:

```text
FAKTY (z danych BDL)
WNIOSKI (sugestia, do sprawdzenia w terenie)
```

Then the card renders the two sections with different styling. This shows the difference on the screen.

Add one more check. A test asserts that the answer holds none of the forbidden words: `jadalny`, `niejadalny`, `trujący`. A failed check rejects the answer and asks the model again.

## Safety rules

1. Never state that a mushroom is edible. Never state that a mushroom is poisonous.
2. Always print the fixed warning in the mushroom section.
3. Never present soft advice as a fact.
4. State the data year. The inventory year is `a_year`.
5. Tell the user to take a doubtful mushroom to a grzyboznawca.

## Reference

- Bielik on Ollama: `https://ollama.com/SpeakLeash`
- Bielik 11B v3 technical report: `https://arxiv.org/abs/2601.11579`
- Sanepid mushroom advice (example): `https://www.gov.pl/web/psse-slupca/bezplatne-porady-grzybowe`
- Legal basis: Dz.U. 2023 poz. 2237
- Ollama API: `POST /api/chat` with `{"model", "messages", "stream": false}`
