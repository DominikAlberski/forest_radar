---
type: "query"
date: "2026-10-08T19:18:41.618999+00:00"
question: "Verify trail, range, and WMS source contracts into test/fixtures/sources/"
contributor: "graphify"
outcome: "useful"
---

# Q: Verify trail, range, and WMS source contracts into test/fixtures/sources/

## Answer

Goal: Verify the live source contracts that B1 and B2 need. Inputs: plan.md sections 'Geographic and source contract' and 'S', docs/data-sources.md, and decision-walk-area.md, all under $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5 or the repository. Out of scope: Application code, dependencies, docs/data-sources.md edits, and other fixture folders. Acceptance: Write source-contract.md in $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5 with every item from the source contract section. Commit one recorded live response per verified endpoint under test/fixtures/sources/. Run git diff --check goal/c1ab3a20...HEAD. If no source proves trail-range intersection, annotate the gap and run coord escalate. Report format: Annotate the trail evidence verdict, endpoints, WMS formats, stand no-geometry option, fixture paths, commit, Graph state, and TESTS line.
STATUS: done.
VERDICT: The checked BDL tourism services provide no verified walking-trail geometry or range intersection.
ENDPOINTS: OGC API Features, tourism WFS, tourism WMS, and entry-ban WMS responded.
WMS: Both services advertise application/geo+json, three XML formats, text/xml, text/html, and text/plain.
STANDS: The OGC API supports skipGeometry=true and returns attributes with null geometry.
RANGES: Leśnictwo 5157 and Chojnów district 398 share address prefix 17-02.
FIXTURES: test/fixtures/sources/ contains 17 recorded live responses.
ARTIFACT: source-contract.md records queries, identities, formats, evidence, and the zero-area fallback.
COMMIT: 8452832.
Graph: fresh.
TESTS: git diff --check goal/c1ab3a20...HEAD: exit 0.
ESCALATED: The checked BDL tourism WFS and WMS expose no walking-trail geometry. Apply the approved zero-area fallback.

## Outcome

- Signal: useful