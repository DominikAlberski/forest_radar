---
type: "query"
date: "2026-10-10T11:14:50.009540+00:00"
question: "Use a separate condition for blocked requests in client_parallel_pagination_test.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Use a separate condition for blocked requests in client_parallel_pagination_test.rb

## Answer

Goal: make the W1 and W2 tests from task b6f2430e valid. Inputs: branch task/b6f2430e at commit 40a6ac0. Base your branch on 40a6ac0. Backend finding: ConcurrentReplay at line 87 uses one condition for peer waits and blocked requests. A peer broadcast releases offset 2 before offset 1 fails. The W2 test then ends in 0.003 s. Required change: blocked requests wait on their own condition variable. Only the block time limit or an explicit test release may wake them. Peer waits and block_request must not broadcast to blocked requests. Keep the 0.25 s limit and no sleep over 1 s. Out of scope: lib/ and every other file. Acceptance: bundle exec rubocop on the file reports 0 offenses. ruby -Itest test/unit/bdl/client_parallel_pagination_test.rb gives 4 runs and 2 failures on 40a6ac0 code. Both new tests must fail for the right reason. W2 must run at least 0.2 s before it fails on the current code, or fail on the released check. The two old tests keep passing. Report format: commit SHA, rubocop result, 'TESTS: <n> runs, <f> failures, <e> errors', one line per new test with its failure message and run time.
STATUS: done. FILES: test/unit/bdl/client_parallel_pagination_test.rb. TESTS: bundle exec rubocop reports 0 offenses; ruby -Itest test/unit/bdl/client_parallel_pagination_test.rb: 4 runs, 2 intended failures, 0 errors. Graph: fresh. Separate blocked requests onto a dedicated condition to avoid peer broadcasts releasing them. W1 and W2 regression failures remain.

## Outcome

- Signal: useful