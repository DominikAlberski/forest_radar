---
type: "query"
date: "2026-10-09T01:31:36.985507+00:00"
question: "D: Add M1-M7 browser and live harness in test/system and test/live, close deferred unit test gaps, document startup"
contributor: "graphify"
outcome: "corrected"
correction: "Check source contracts against the live service before the UI stage. Recorded fixtures hid a removed ban layer and renamed name keys."
---

# Q: D: Add M1-M7 browser and live harness in test/system and test/live, close deferred unit test gaps, document startup

## Answer

Goal: Add browser and live checks for every M1 to M7 item. Document reproducible startup. Inputs: Start from goal/c1ab3a20 at c271101. It contains landed C. Read section D of /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md, lines 320 to 336. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/api-contract.md and /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md. Read findings B3-R10 and B3-R11 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review.md, B3-R14 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review-2.md, and B3-R15 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review-3.md. Read C-R2 and C-R3 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/c-review.md. Add unit tests for B3-R10, B3-R11, B3-R14, and B3-R15. For B3-R15, restore the cases 'Lasy są otwarte.', its uppercase form, and 'Wstęp wolny.' in the validator table. Add browser cases for C-R3: success render, unknown ban and trail evidence, external text as text, geolocation denial, request errors, and print layout. Check one A4 page with a maximum-content card for C-R2. Read the browser path from CHROME_PATH and pdfinfo from PDFINFO_PATH, with the plan defaults. Out of scope: All product code (lib/, views/, public/, config/). Do not fix B3-R5, B3-R7, B3-R8, B3-R12, or C-R1. Record them as known gaps in docs/plans/m1-m7-evidence.md. If a new test fails only because of a known gap, mark it skip with the finding id. Also out of scope: model installation, new dependencies, M8, publication. Live Ollama checks stay pending; no endpoint is supplied. Acceptance: Run 'bu

## Outcome

- Signal: corrected
- Correction: Check source contracts against the live service before the UI stage. Recorded fixtures hid a removed ban layer and renamed name keys.