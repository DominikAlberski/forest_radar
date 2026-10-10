---
type: "query"
date: "2026-10-10T10:59:44.334700+00:00"
question: "Align three BDL and App test fixtures with plan D1-D3 in test/unit"
contributor: "graphify"
outcome: "useful"
source_nodes: ["test_unit_app_test", "test_unit_bdl_client_parallel_pagination_test"]
---

# Q: Align three BDL and App test fixtures with plan D1-D3 in test/unit

## Answer

Goal: correct three test defects that block S2-2 (task 38977b1d). Inputs: goal/c0e3a4e7 head 9a2b379. Plan: $COORD_DIR/artifacts/c0e3a4e7/plan.md, D1-D3. Defect 1: test/unit/bdl/client_parallel_pagination_test.rb pages() builds features without properties. lib/bdl/page_payload.rb rejects such a feature as 'malformed page'. Give each feature a properties Hash, as client_pagination_test.rb line 29 does. Defect 2: test/unit/bdl/client_test.rb test_follows_pages_and_detects_mismatch uses a next link and a constant numberMatched. D1 ignores the next link. A page at offset o reports numberMatched T - o and holds min(page_size, T - o) features. Rewrite the test to offset pages under D1, with page_size passed to BDL::Client.new. Keep its intent: two pages read in offset order. Defect 3: test/unit/app_test.rb test_card_passes_its_deadline_to_the_selector (lines 14-22, 198-200) bounds the deadline with Process.clock_gettime. The App clock is the fake AppTestClock. Derive the expected deadline from the fake clock value instead. Out of scope: lib/ and every other test file. Keep every other assertion. Acceptance: bundle exec rubocop on the three files reports 0 offenses. ruby -Itest on each file loads. The tests for D1-D3 may still fail on the goal head, because lib is unchanged. List each failure and the missing lib behavior. Report format: commit SHA, rubocop result, 'TESTS: <n> runs, <f> failures, <e> errors' per file.
STATUS: done. FILES: test/unit/bdl/client_parallel_pagination_test.rb, test/unit/bdl/client_test.rb, test/unit/app_test.rb. COMMIT: 42ebc17bc179f9686cccac8c32d7c63f811955a9. RUBOCOP: 0 offenses. TESTS: client_parallel_pagination_test.rb: 2 runs, 1 failure, 1 error; client_test.rb: 3 runs, 0 failures, 1 error; app_test.rb: 17 runs, 1 failure, 0 errors. Graph: fresh. NOTES: Both BDL files fail because lib/bdl/client.rb:29 rejects page_size and concurrency. app_test.rb:248 expects the selector deadline after search, but lib/app.rb:80 sets it before search. Task s

## Outcome

- Signal: useful

## Source Nodes

- test_unit_app_test
- test_unit_bdl_client_parallel_pagination_test