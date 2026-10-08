---
type: "query"
date: "2026-10-08T21:43:02.765237+00:00"
question: "Record Overpass trail fixtures in test/fixtures/osm and BDL fixture provenance"
contributor: "graphify"
outcome: "useful"
---

# Q: Record Overpass trail fixtures in test/fixtures/osm and BDL fixture provenance

## Answer

Goal: Verify the Overpass contract that B2 needs and record live fixtures. Inputs: $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md sections 'Geographic and source contract' and 'S2'. $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-osm-trail-fallback.md. $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md. test/fixtures/sources/range-sample.json. Reviewer warnings S1 to S3 in task 73a9dfc2. Out of scope: Application code, dependencies, and the existing BDL fixture files. Do not provoke rate limits or service failures. Acceptance: Write $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/osm-contract.md with every item of plan section S2. Commit recorded live Overpass responses under test/fixtures/osm/ with test/fixtures/osm/PROVENANCE.md. Keep each fixture below 1 MiB. Write test/fixtures/sources/PROVENANCE.md with the exact request URL for each Stage S fixture. Correct S1 to S3 in source-contract.md. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the endpoint, query, response format, fixture paths, crossing verdict per range, synthetic fixtures, commit, Graph state, and a TESTS line.
STATUS: blocked. FILES: test/fixtures/osm/, test/fixtures/sources/PROVENANCE.md. COMMIT: 3cead59. Graph: fresh. TESTS: git diff --check goal/c1ab3a20...HEAD passed. NOTES: Three public Overpass endpoints returned 500, 504, or timeout. No successful relation or empty response exists. The original distinct-code URL was not recorded. The shared osm-contract.md lists each missing S2 item.
MSG from backend-developer: S2 is blocked. Public Overpass endpoints returned HTTP 500, HTTP 504, and timeout. The live crossing and empty fixtures remain missing. I committed error fixtures and BDL provenance as 3cead59. I corrected S1 to S3 in source-contract.md. The original Stage S distinct-code URL is unavailable. Please decide how to resume live verification.
ESCALATED: Public Overpass endpoints 

## Outcome

- Signal: useful