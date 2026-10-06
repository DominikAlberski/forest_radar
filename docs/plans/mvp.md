# MVP acceptance criteria

Each item is a check. The item passes or it fails. No partial credit.

## M1 — The page takes a location

- The page loads in a browser with no JavaScript error. Pass or fail.
- The page reads a location from the browser geolocation API after a user action. Pass or fail.
- The page accepts a typed place or a typed coordinate pair as a fallback. Pass or fail.
- The page accepts a radius from 1 km to 20 km. Pass or fail.

## M2 — The program finds the forest regions

- Given a coordinate, the program returns the RDLP region code that holds the point. Pass or fail.
- Given a radius that crosses a region border, the program returns both regions. Pass or fail.
- The program returns the district name for the point. Pass or fail.

## M3 — The program reads the stand data

- The program returns the stands inside the box. Pass or fail.
- The program returns the species code, the site type, the age, and the area for each stand. Pass or fail.
- The program reports the count of the stands in the box. Pass or fail.
- The program caches the response for the session. Pass or fail.

## M4 — The program checks the entry ban layer

- The program asks the ban layer for the centre of each district in the box. Pass or fail.
- The program reports a ban as a hard fact when the layer names one. Pass or fail.
- The program reports "no known ban" when the layer is empty. Pass or fail.
- The card never says "open" as a promise. Pass or fail.

## M5 — The model returns the card

- The model returns Polish text. Pass or fail.
- The model answer separates the facts from the advice. Pass or fail.
- The model answer holds none of the words `jadalny`, `niejadalny`, `trujący`. Pass or fail.
- The model answers in under 30 seconds on the reference machine. Pass or fail.

## M6 — The mushroom section

- The card holds the fixed mushroom warning from `pl.yml`. Pass or fail.
- The warning tells the user not to pick a doubtful mushroom. Pass or fail.
- The card holds a link to the nearest sanitary station. Pass or fail.
- The link opens Google Maps, centred on the user location. Pass or fail.
- The program holds no edibility data and no edibility lookup. Pass or fail.

## M7 — The card

- The card holds the three nearest forests with a distance. Pass or fail.
- The card prints on one A4 page. Pass or fail.
- The card is readable on a phone at 100 percent zoom. Pass or fail.
- The card holds the data year and the safety warning. Pass or fail.
- The card holds no hardcoded string. Every string comes from `pl.yml`. Pass or fail.

## M8 — The field test

- The author uses the card on a real walk. Pass or fail.
- The author records the result: what matched, and what did not. Pass or fail.
- The record goes into the blog post. Pass or fail.

## The evidence for the submission

Collect these for the DEV post:

1. A screenshot of one full card.
2. The fact block behind that card.
3. The model answer for that card.
4. The field notes from M8.
5. At least one wrong model answer, with the reason.

## Definition of done for the submission

Every item M1 to M8 is green. The repository holds a README that a stranger can follow. The blog post is published.

## Not in the MVP

- No user accounts.
- No database.
- No map raster.
- No English translation. The keys exist and the values are empty.
- No deployment to a server. The app runs on the machine of the user.