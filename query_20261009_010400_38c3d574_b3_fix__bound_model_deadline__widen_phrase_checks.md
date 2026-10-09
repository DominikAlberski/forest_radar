---
type: "query"
date: "2026-10-09T01:04:00.042448+00:00"
question: "B3 fix: bound model deadline, widen phrase checks, filter fact stands by in_radius"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts"]
---

# Q: B3 fix: bound model deadline, widen phrase checks, filter fact stands by in_radius

## Answer

Goal: Fix critical findings B3-R1, B3-R2, B3-R3 and warning B3-R4 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review.md. Inputs: Start from branch task/746eb2a2 at c4d4109. Read b3-review.md and plan.md lines 255 to 296. R1: bound the whole model request, both attempts, and validation by one absolute deadline. Reject an answer that arrives after the deadline. R4: the route creates one 29 s application deadline before search and passes it to the model client. Record the deadline start point in api-contract.md. R2: reject indirect edibility claims such as 'Te grzyby możesz jeść' and inflected access phrases such as 'Wstęp jest wolny' and 'Lasy są otwarte'. Use Unicode-aware matching and test uppercase variants. R3: build area summaries only from stands with in_radius true. Keep the box count unchanged. Add a fixture with linked stands inside and outside the radius. Also fix B3-R9 and B3-R13 because they touch the same validator lines. Out of scope: lib/geo, lib/bdl, lib/osm, lib/wms, lib/walk_areas, lib/http, views, test/run.rb, new gems, other warnings. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate commit, changed paths, one line per fixed finding, Graph state, and a TESTS line with both results.
STATUS: done. COMMIT: 837f37a. FILES: lib/app.rb, lib/assembler/facts.rb, lib/model/client.rb, lib/model/validator.rb, test/unit/assembler/facts_test.rb, test/unit/model/client_test.rb, test/unit/model/validator_test.rb, test/fixtures/model/linked-stands.json. B3-R1: One absolute deadline bounds model requests and validation. B3-R2: Phrase checks reject indirect edibility and inflected access claims. B3-R3: Area summaries use only stands inside the radius. B3-R4: The route starts the application deadline before source search. B3-R9: Phrase checks apply only to advice. B3-R13: The extra-fact test uses a real newline. 

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts