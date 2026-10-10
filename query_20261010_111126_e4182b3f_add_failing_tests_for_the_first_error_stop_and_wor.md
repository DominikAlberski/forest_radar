---
type: "query"
date: "2026-10-10T11:11:26.597277+00:00"
question: "Add failing tests for the first-error stop and worker join in client_parallel_pagination_test.rb"
contributor: "graphify"
outcome: "useful"
source_nodes: ["lib_app", "lib_bdl_page_reader", "lib_bdl_page_state", "test_unit_bdl_client_parallel_pagination_test"]
---

# Q: Add failing tests for the first-error stop and worker join in client_parallel_pagination_test.rb

## Answer

Goal: add regression tests for review 014c708c findings W1 and W2 (plan D2). Inputs: goal/c0e3a4e7 head 670a300. Plan D2 in $COORD_DIR/artifacts/c0e3a4e7/plan.md. Review notes: coord show 014c708c. Reference implementation under review: branch task/38977b1d, lib/bdl/page_reader.rb lines 26-57. Test 1 (W1): concurrency 4 and at least 6 later pages. The worker that takes offset page_size fails at once with a terminal error. The other workers block inside the fake transport until the test releases them or for a short bounded time. After read raises Incomplete, no thread that the read started is alive. Test 2 (W2): same setup. Read must raise within a bounded time, before the blocked workers finish. After the failure, the fake transport receives no request for an offset that was not yet started. Use fakes keyed by the offset param. Use no real sleep longer than 1 s per test. Make each test independent of thread scheduling. Out of scope: lib/ and every other file. Acceptance: bundle exec rubocop on the file reports 0 offenses. ruby -Itest test/unit/bdl/client_parallel_pagination_test.rb loads. The two new tests fail on goal/c0e3a4e7. Report the failure messages. The old tests keep passing as before. Report format: commit SHA, rubocop result, 'TESTS: <n> runs, <f> failures, <e> errors', and one line per new test with its failure message.
MSG from tester: Task input is missing the pagination production merge: goal/c0e3a4e7 head 670a300 has Client#initialize without page_size/concurrency, so scoped tests fail before exercising W1/W2. Reference task/38977b1d includes 686919f. May I merge task/38977b1d into this branch to run the required tests?
MSG from architect: Yes. Merge commit 62342c4 into your branch. Do not merge the moving branch task/38977b1d. Commit 62342c4 holds 686919f and the goal head 670a300, without any W1 or W2 fix. Your new W1 and W2 tests must fail on that code. Do not edit production files. Put the merged SHA and the failing test names in your report.
STA

## Outcome

- Signal: useful

## Source Nodes

- lib_app
- lib_bdl_page_reader
- lib_bdl_page_state
- test_unit_bdl_client_parallel_pagination_test