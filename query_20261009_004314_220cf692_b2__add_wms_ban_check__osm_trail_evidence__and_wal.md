---
type: "query"
date: "2026-10-09T00:43:14.400938+00:00"
question: "B2: Add WMS ban check, OSM trail evidence, and walk-area selection in lib/wms, lib/osm, lib/walk_areas"
contributor: "graphify"
outcome: "corrected"
correction: "HTTP::Transport resolves paths with URI#+. Pass a path relative to the base URL, or the full service path. A leading slash drops the base path. Validate each JSON container type before calling fetch, or NoMethodError escapes the rescue."
source_nodes: ["docs_data_sources"]
---

# Q: B2: Add WMS ban check, OSM trail evidence, and walk-area selection in lib/wms, lib/osm, lib/walk_areas

## Answer

Goal: Implement M4 ban evidence and select forest walk areas from verified OSM trail and ban evidence. Follow plan section B2 exactly. Inputs: Goal branch goal/c1ab3a20 at 49a2241 holds landed B1, A2 and S2. Read plan section B2 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md, /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md, /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/osm-contract.md and /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-osm-trail-fallback.md. Use the fixtures in test/fixtures/osm/ and the relation IDs for ranges 5157 and 5172 in osm-contract.md. Out of scope: Changes to B1 interfaces in lib/geo, lib/bdl, lib/http and lib/cache. Model behavior, routes, views and new gems. Do not change the saved bodies of the OSM fixtures. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate fixture provenance, commit, Graph state, a TESTS line with both command results, and source limitations.
Notes from earlier reviews. Do each item in this task. B1-R9: Do not refactor the long methods or the 7 arguments of ResultBuilder#build. They are accepted. B1-R12: In test/unit/bdl/client_search_test.rb, add search-level tests for the shared limit and for an overflow across collections. B1-R6: In test/unit/bdl/result_builder_test.rb, add a case with reordered keys and a case with a differing top-level ID. B1-R10: In test/unit/http/transport_hardening_test.rb line 39, require HTTP::Error only. Decision: retries that run out raise HTTP::Error. Do not change lib/http.
More notes. S2-R1: In test/fixtur

## Outcome

- Signal: corrected
- Correction: HTTP::Transport resolves paths with URI#+. Pass a path relative to the base URL, or the full service path. A leading slash drops the base path. Validate each JSON container type before calling fetch, or NoMethodError escapes the rescue.

## Source Nodes

- docs_data_sources