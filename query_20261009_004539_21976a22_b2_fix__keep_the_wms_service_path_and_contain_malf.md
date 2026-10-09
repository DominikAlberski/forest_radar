---
type: "query"
date: "2026-10-09T00:45:39.746615+00:00"
question: "B2 fix: Keep the WMS service path and contain malformed Overpass and WMS structures in lib/wms, lib/osm"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_data_sources"]
---

# Q: B2 fix: Keep the WMS service path and contain malformed Overpass and WMS structures in lib/wms, lib/osm

## Answer

Goal: Fix the three critical B2 review findings. Inputs: Start from branch task/60ea2836 at 4c67401. It is not landed. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b2-review.md. B2-R1: lib/wms/ban_client.rb:55 passes '/WMSServer'. The leading slash drops the base path. The request must reach the full ban WMS path in source-contract.md. Add a test that asserts the request address through the real transport and FakeNet. B2-R2: lib/osm/client.rb parse_relation must reject null or scalar elements, tags, members, geometry and points with the existing controlled errors. The result must be nil, not a crash. B2-R3: lib/wms/ban_client.rb query must reject null or scalar features the same way. The result must be status unknown. Add tests for each malformed case.
Also fix these review items in the same scope. B2-R4: Add fake-clock tests for the 25-second Overpass cutoff and for an earlier caller deadline. B2-R5: Make the 16 MiB test fail if the size guard is removed. Use a valid oversized envelope or assert the transport limit error. B2-R6: Send HTTP 429 through FakeNet and the configured Overpass transport. Assert one network attempt. B2-R9: In docs/data-sources.md, put the Reference heading back with its two links after the OpenStreetMap section. Decision B2-R8: The six keyword parameters of Selector#select are accepted. Do not change lib/walk_areas. Out of scope: B1 files, lib/walk_areas, new gems, refactors for method size. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate the commit, the finding IDs fixed, Graph state, and a TESTS line with both command results.
MSG from backend-developer: The recorded Overpass fixture contains null way points from clipping. Rejecting every null point would reject the verified fixture. I preserve null placeholders and reject scalar points and malformed containers.
STATUS: done. COMMIT: 

## Outcome

- Signal: useful

## Source Nodes

- docs_data_sources