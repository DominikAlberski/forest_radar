---
type: "query"
date: "2026-10-10T12:33:50.507975+00:00"
question: "Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb

## Answer

Goal: Make the W2 test valid. Start from goal/c0e3a4e7 head d62809f. It already holds the lib/ fix. Apply one exact rule. Remove the broadcast from block_request in test/unit/bdl/client_parallel_pagination_test.rb. Blocked requests must never wake each other. Only the test teardown or the end of the block time may release them. Add one assert: the W2 test measures its own run time, and the time is at least 0.2 s. Inputs: lessons on tasks b6f2430e and 434a742e. Rejected commit 1f92100 shows the wrong approach. Out of scope: every file under lib/. Every other test file. Do not change the W1 test. Commit only on your task branch task/<your short id>. Run git branch --show-current before you commit. Acceptance: ruby -Itest test/unit/bdl/client_parallel_pagination_test.rb passes with 0 failures and 0 errors. The W2 test reports a run time of at least 0.2 s. bundle exec rubocop test/unit/bdl/client_parallel_pagination_test.rb reports 0 offenses. Report format: STATUS, BRANCH, COMMIT SHA, TESTS line with runs and failures, W2 run time in seconds.
MSG from tester: Goal merge conflicts in lib/bdl/page_reader.rb, lib/bdl/page_state.rb, and the scoped test file. I aborted it because production paths are outside this task. Current branch is task/b6f2430e, not a task-specific branch. Local test changes remove the blocked broadcast and add a W2 elapsed-time assertion. At this base, unit run fails W1 worker join and W2 elapsed assertion (0.000124 s). RuboCop initially flagged method length; I extracted helpers, but have not rerun after that edit. Please advise on reconciling the goal head and task branch.
STATUS: blocked. BRANCH: task/b6f2430e. COMMIT SHA: none. TESTS: unit file 4 runs, 2 failures (W1 join and W2 measured 0.000124 s); RuboCop initially reported 1 method-length offense before helper extraction. Goal merge conflicts in lib/bdl/page_reader.rb, lib/bdl/page_state.rb, and scoped test file. Graph: fresh.

## Outcome

- Signal: useful