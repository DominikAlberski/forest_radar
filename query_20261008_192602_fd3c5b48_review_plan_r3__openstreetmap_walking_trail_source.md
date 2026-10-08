---
type: "query"
date: "2026-10-08T19:26:02.575847+00:00"
question: "Review plan r3: OpenStreetMap walking-trail source for goal c1ab3a20"
contributor: "graphify"
outcome: "useful"
---

# Q: Review plan r3: OpenStreetMap walking-trail source for goal c1ab3a20

## Answer

Goal: Accept or reject plan revision r3. Inputs: Run diff -u $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.r3.md $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md. Read $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-osm-trail-fallback.md and the Stage S findings in task 73a9dfc2. Out of scope: Sections that the diff does not change. Code. Live queries. Acceptance: Check that r3 applies the user decision: OSM for walking trails, BDL for all other facts, zero-area card with reason, standard-library HTTP, cache, recorded fixtures, OSM source name and attribution. Check the walking-trail definition, the Overpass limits, the cache key, and the new stages A2 and S2. Check that scopes stay disjoint and the stage order holds. Report format: Annotate APPROVED or CHANGES_REQUIRED, critical findings with plan line numbers, other findings, Graph state, and TESTS: not run; review only.
CHANGES_REQUIRED.
Scope: Changed lines in diff -u plan.r3.md plan.md. Read decision-osm-trail-fallback.md and Stage S findings S1 through S4.

Critical findings:
O1 (critical). plan.md:341 adds live contracts for Overpass trail evidence.
Evidence: decision-osm-trail-fallback.md requires recorded fixtures and says no live call in tests.
Line 105 excludes live calls only from unit and system tests. Line 341 still places Overpass in test/live/.
Failure scenario: The author supplies an Ollama endpoint. The architect runs --live and the tests call public Overpass.
That action violates the accepted user decision even though unit and system tests use fixtures.
Fix: Remove Overpass network calls from all test modes. Verify the live source through Stage S2 research only.
Keep recorded Overpass responses for automated contract checks. Obtain a new user decision before permitting live Overpass tests.

Other findings:
O2 (warning). plan.md:203 and :209 require only one range with a crossing relation.
Line 338 requires Stage D area fixtures from recorded S2 

## Outcome

- Signal: useful