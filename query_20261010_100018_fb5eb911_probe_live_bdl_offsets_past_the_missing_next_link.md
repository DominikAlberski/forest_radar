---
type: "query"
date: "2026-10-10T10:00:18.553457+00:00"
question: "Probe live BDL offsets past the missing next link and the page size limit"
contributor: "graphify"
outcome: "useful"
---

# Q: Probe live BDL offsets past the missing next link and the page size limit

## Answer

Goal: learn how the client can read all matched BDL features. Inputs: $COORD_DIR/artifacts/c0e3a4e7/pagination.md. Use the same Warsaw bbox. Hypothesis: the server adds a next link only when offset plus limit is below the remaining numberMatched. So it stops early. Step 1: request RDLP_Warszawa_wydzielenia with limit 1000 at offset 4000 and offset 5000. Record numberMatched, numberReturned, feature count, links, and seconds. Say if pages 0 to 5000 give 5481 distinct ids. Step 2: request lesnictwa with limit 10 at offset 20. Say if the 25 ids are complete. Step 3: request the Warsaw collection at offset 0 with limit 2000, 5000, and 10000. Record numberReturned, seconds, and response size. Say the largest limit that the server honors. Step 4: send the six Warsaw pages of limit 1000 at the same time in threads. Record the total wall time. Step 5: say if the hypothesis holds for every page in pagination.md and in this probe. Out of scope: any edit to lib/, test/, public/, or config/. Do not commit. Do not fix. Acceptance: $COORD_DIR/artifacts/c0e3a4e7/offsets.md exists with a table per step and one conclusion line per step. Report format: annotate 'OFFSETS: <result>', 'MAX_LIMIT: <value and seconds>', 'PARALLEL: <seconds>', and 'TESTS: n/a (diagnosis only)'.
OFFSETS: Manual Warsaw offsets returned 5481 distinct IDs. Manual lesnictwa offsets returned 25 distinct IDs. Graph: stale.
MAX_LIMIT: The largest tested limit was 10000. It returned all 5481 Warsaw features in 11.459 seconds.
PARALLEL: Six Warsaw pages took 6.763 seconds of wall time.
TESTS: n/a (diagnosis only)

## Outcome

- Signal: useful