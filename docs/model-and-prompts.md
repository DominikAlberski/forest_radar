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

Three rules.

1. Give the model the facts, not the question. The model must answer from the fact block.
2. Ask for Polish. Do not ask for a translation.
3. Mark the soft advice. The prompt must separate the certain part from the guessed part.

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
1. Nie twierdź, że grzyb jest jadalny. Napisz "możliwy gatunek", nigdy "jadalny".
2. Nie zgaduj, jeśli danych nie ma. Napisz "brak danych".
3. Podaj odległość i szacowany czas dojścia.
4. Napisz krótko. Maksymalnie 250 słów.
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
- Keep the three largest stands per district.
- Keep the dominant species and the dominant site type.
- Report the counts, not every row.

## The honest-limits section

The earlier dashboard project showed the model inventing a reason with no evidence. The judges liked that part. Keep the pattern here.

Record every wrong or invented answer. Send the records with the submission. Name the failure.

Known risks to record:

- The model names a mushroom for a site type where that mushroom does not grow.
- The model states an entry rule that the ban layer does not support.
- The model invents a district name.
- The model reports a dog rule as a fact, when the rule depends on the district and the season.

### The countermeasure

Tell the model to separate the two kinds of output. Ask for two sections:

```text
FAKTY (z danych BDL)
WNIOSKI (sugestia, do sprawdzenia w terenie)
```

Then the card renders the two sections with different styling. This shows the difference on the screen.

## Safety rules

1. Never state that a mushroom is safe to eat. Foraging errors can kill.
2. Always print a short warning on the card. Name the risk.
3. Never present soft advice as a fact.
4. State the data year. The inventory year is `a_year`.

## Reference

- Bielik on Ollama: `https://ollama.com/SpeakLeash`
- Bielik 11B v3 technical report: `https://arxiv.org/abs/2601.11579`
- Ollama API: `POST /api/chat` with `{"model", "messages", "stream": false}`