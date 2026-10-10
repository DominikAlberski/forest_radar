---
type: "query"
date: "2026-10-10T07:53:10.636460+00:00"
question: "Review the plan for strict selector fakes and the card deadline (goal 1e0d3d4c)"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the plan for strict selector fakes and the card deadline (goal 1e0d3d4c)

## Answer

Goal: review the plan for goal 1e0d3d4c. Approve it or request changes. Inputs: $COORD_DIR/artifacts/1e0d3d4c/plan.md and $COORD_DIR/artifacts/1e0d3d4c/decision-followup-scope.md. Read the code on branch goal/c1ab3a20 with git show. Check lib/app.rb, lib/walk_areas/selector.rb, lib/osm/client.rb, test/unit/app_test.rb, test/unit/walk_areas/selector_test.rb, test/system/support/fixtures.rb. Out of scope: code edits, W1 W2 W4 W5, public/app.js. Acceptance: each finding cites a plan section or a file and line. Check that scopes are disjoint and that the T1 tests fail without the app.rb fix. Report format: annotate VERDICT approve or changes, then findings as critical, warning, minor.
VERDICT: changes. Critical 0, warning 5, minor 5. Full text: artifacts/1e0d3d4c/plan-review.md. Scopes are disjoint. The T1 app deadline test fails without the app.rb fix, because selector.rb:69 defaults deadline to nil. W1 plan T2: ADR 0003 already exists, so use 0008. W2 plan T1: Lint/UnusedMethodArgument flags unused fake keywords. This blocks the T2 rubocop acceptance. Add rubocop test to T1 acceptance. W3 plan T1: test/run.rb:12 runs one process per file. The contract test cannot reach the nested fakes without running the other suites a second time. W4 plan T1: decide that the fakes require deadline:. List the five system Walk call sites as expected failures. W5 plan T1: bound the deadline with t0 before and t1 after the request. m1 app.rb:88 changes a fake ArgumentError into 422. m2 T2 must merge the goal branch, not task/T1. m3 add a deadline mutation check. m4 T1 has no Acceptance line. m5 list the model fakes as out of scope. Graph: fresh.

## Outcome

- Signal: useful