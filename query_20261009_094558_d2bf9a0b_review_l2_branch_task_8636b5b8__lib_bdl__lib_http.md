---
type: "query"
date: "2026-10-09T09:45:58.993043+00:00"
question: "Review L2 branch task/8636b5b8: lib/bdl, lib/http, lib/osm refactor and unit tests"
contributor: "graphify"
outcome: "useful"
---

# Q: Review L2 branch task/8636b5b8: lib/bdl, lib/http, lib/osm refactor and unit tests

## Answer

Goal: Review task/8636b5b8 (L2) against goal/c1ab3a20. Inputs: git diff goal/c1ab3a20...task/8636b5b8. Spec: coord show 8636b5b8, and the L2 section and the shared rules in $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md. Check these points. 1: No behavior change in lib/bdl, lib/http and lib/osm. 2: Every test case and assertion remains. The test count went from 79 to 80. 3: HTTP::Transport#initialize(base_url:, user_agent:, **options) keeps the old defaults. Unknown keys raise ArgumentError. test/unit/http/transport_test.rb:142 covers this. 4: BDL::ResultBuilder#build(lat, lon, radius, input) takes BDL::BuildInput with the fields regions, districts, ranges and stands. Each caller is updated. 5: The removed client construction in the CPR-M4 test is dead code. 6: No rubocop:disable comment and no reek exclusion are added. 7: Retry, deadline and size limit logic in transport.rb is equal to the old code. Note L1 m3: count the new public helpers that need not be public. Out of scope: running tests, test/system, and paths outside L2. The reviewer reads the TESTS lines. Acceptance: write $COORD_DIR/artifacts/c1ab3a20/L2-review.md with a verdict APPROVE or REQUEST_CHANGES. Report format: each finding as critical, warning or minor, with file:line, evidence and fix.
Verdict: APPROVE. Critical 0, warning 0, minor 6. Review: artifacts/c1ab3a20/L2-review.md. Checks 1 to 7 pass. m1: the branch lacks goal head f8e5242, so merge the goal before landing. m2: 36 new helpers are public with no outside caller. m3 client.rb:29 and page_state.rb:9: PAGE_SIZE is defined twice. m4: fake get methods accept any keywords, so no test proves the deadline is passed. m5 transport_options.rb:13: the message names one unknown key only. m6 page_state.rb:8: Struct subclass style differs from SearchState. Graph: fresh.

## Outcome

- Signal: useful