---
type: "query"
date: "2026-10-10T12:49:08.153726+00:00"
question: "Review the W2 fake blocked condition on task/c4e7d1c4"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the W2 fake blocked condition on task/c4e7d1c4

## Answer

Goal: Review commit e524706 on task/c4e7d1c4. Inputs: git diff goal/c0e3a4e7...task/c4e7d1c4. Spec and SPEC CORRECTION notes on task c4e7d1c4. Production behavior: lib/bdl/page_reader.rb lines 26-28 kill and join workers on the first error. Check these points. Blocked requests wait on their own condition. No code broadcasts or signals that condition. The wait loops to a monotonic deadline. The released entry is recorded only after the deadline. W1 is unchanged. W2 would fail on code that joins blocked workers without a kill. Out of scope: lib/ changes and task 0e27fe20. Acceptance: you read the diff and the TESTS line in the task report. Do not run tests. Report format: VERDICT approve or changes, then findings as critical, warning, or minor with file and line.
VERDICT: approve. Scope: commit e524706, one file, test/unit/bdl/client_parallel_pagination_test.rb. Worker TESTS line: three file runs, each 4 runs, 0 failures, 0 errors. RuboCop on the branch file: 0 offenses. Graph: fresh. Checks: 1. Blocked requests wait on @blocked_condition (line 36, line 98). Pass. 2. git grep finds no broadcast or signal on @blocked_condition. Pass. 3. wait_while_blocked loops to a CLOCK_MONOTONIC deadline (lines 91-104). A spurious wakeup re-enters the wait. Pass. 4. block_request records [:released, offset] only after the deadline (line 88). Pass. 5. W1 (lines 138-145) has no change. Pass. 6. W2 catches join without kill. Scenario: workers take offsets 1-4; offset 1 raises; a join without kill waits 0.25 s; offset 2 then records [:released, 2]; refute_block_released at line 166 fails. Pass. A stop without join passes W2, but W1 catches that case. No critical findings. No warning findings. MINOR m1, line 98: @blocked_condition is never signaled, so the wait acts as a sleep. A reader can think a signal is missing. Fix: add a one-line comment that says no code signals this condition on purpose. MINOR m2, line 150: the commit removes the blank line after assert_raises in W2. W1 keeps th

## Outcome

- Signal: useful