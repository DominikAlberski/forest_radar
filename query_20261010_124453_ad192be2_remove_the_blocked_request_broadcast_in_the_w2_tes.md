---
type: "query"
date: "2026-10-10T12:44:53.434115+00:00"
question: "Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb"
contributor: "graphify"
outcome: "corrected"
correction: "A regression test for an early return must pass fast on the fixed code. Put the minimum run time limit only in the failing-test task, not in the fix-validation task."
---

# Q: Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb

## Answer

First steps, in this order. 1. In the tester-bot worktree, discard the uncommitted edits on task/b6f2430e: run git restore on the test file and git status. Do not commit them. 2. Run coord start-task c4e7d1c4. 3. Run git branch --show-current. The output must be task/c4e7d1c4. If it is not, stop and message the architect. 4. Run git log -1 --format=%h. The base must be d62809f or a later goal commit. Do not merge any branch into the task branch. Goal: Make the W2 test valid. The goal head already holds the lib/ fix. Remove the broadcast from block_request in test/unit/bdl/client_parallel_pagination_test.rb. Blocked requests must never wake each other. Only the test teardown or the end of the block time may release them. Add one assert: the W2 test measures its own run time, and the time is at least 0.2 s. Inputs: lessons on tasks b6f2430e, 434a742e, and 03929f46. Rejected commit 1f92100 shows the wrong approach. Out of scope: every file under lib/, every other test file, and the W1 test. Acceptance: ruby -Itest test/unit/bdl/client_parallel_pagination_test.rb passes with 0 failures and 0 errors. The W2 test reports a run time of at least 0.2 s. bundle exec rubocop test/unit/bdl/client_parallel_pagination_test.rb reports 0 offenses. Commit only on task/c4e7d1c4. Run git branch --show-current again before the commit. Report format: STATUS, BRANCH, COMMIT SHA, TESTS line with runs and failures, W2 run time in seconds, RUBOCOP.
STATUS: blocked. FILES: test/unit/bdl/client_parallel_pagination_test.rb. TESTS: ruby -Itest reports 4 runs, 1 failure; RuboCop reports 0 offenses. W2 time remains below 0.2 seconds. Graph: fresh. Cause: the fake records released blocked requests before the read raises, even with a separate blocked condition and no broadcast in block_request. I did not commit.
MSG from tester: W2 fake remains blocked. With block_request broadcast removed, tests fail at the released check (offset 2/3 recorded) before timing; separate blocked condition also yields 

## Outcome

- Signal: corrected
- Correction: A regression test for an early return must pass fast on the fixed code. Put the minimum run time limit only in the failing-test task, not in the fix-validation task.