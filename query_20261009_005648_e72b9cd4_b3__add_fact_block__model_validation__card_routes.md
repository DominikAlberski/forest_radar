---
type: "query"
date: "2026-10-09T00:56:48.587757+00:00"
question: "B3: Add fact block, model validation, card routes, and Polish locale data in lib/app, lib/assembler, lib/model, lib/card"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts"]
---

# Q: B3: Add fact block, model validation, card routes, and Polish locale data in lib/app, lib/assembler, lib/model, lib/card

## Answer

Goal: Implement M1 request validation, M5, M6, and the browser API contract. Inputs: Start from goal/c1ab3a20 at 9800b46. It contains the landed B2. Read section B3 of /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md, lines 255 to 296. Follow every rule in that section. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md, /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md, and the decision-*.md files in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5. Write the API contract to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/api-contract.md. Out of scope: lib/geo, lib/bdl, lib/osm, lib/wms, lib/walk_areas, lib/http, views, browser tests, test/run.rb, deferred features, new gems.
Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate api-contract.md path, changed paths, commit, Graph state, pending live M5 verification, and a TESTS line with both command results. Ask the architect with coord msg if a source module needs a change.
STATUS: done. FILES: config.ru, lib/app.rb, lib/assembler/, lib/model/, lib/card/, lib/sanepid.rb, config/model.yml, config/locales/, tests, docs/model-and-prompts.md. API: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/api-contract.md. COMMIT: c4d4109. Graph: fresh. TESTS: bundle exec ruby test/run.rb --unit passed; git diff --check goal/c1ab3a20...HEAD passed. NOTES: Live M5 verification awaits the supplied Ollama endpoint.

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts