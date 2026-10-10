---
type: "query"
date: "2026-10-10T10:09:28.358463+00:00"
question: "Add failing tests for BDL offset pagination, parallel reads, and card deadline"
contributor: "graphify"
outcome: "corrected"
correction: "Run coord start-task <id> after coord claim. It checks out task/<id> from the goal head. The idle worker branch sits at old main 9e33439."
---

# Q: Add failing tests for BDL offset pagination, parallel reads, and card deadline

## Answer

Goal: write failing tests for goal c0e3a4e7 before the fix. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.md, section D1 to D3 and task S2-1 (the test list). Evidence: $COORD_DIR/artifacts/c0e3a4e7/diagnosis.md, pagination.md, offsets.md. Target API: BDL::Client.new(transport:, clock:, page_size: 1000, concurrency: 4), and the App setting clock. Write every test in the S2-1 list of plan.md. Fakes return bodies keyed by the offset param, not by call order. In the in-flight test, each fake request blocks until a second request arrives. Use a Queue or a ConditionVariable with a short timeout, so a bug cannot hang the suite. Out of scope: lib/, docs/, and all test files outside the scope. Acceptance: ruby test/run.rb runs without load or syntax errors. The new tests fail only for the missing behavior. All old tests still pass, except the fixtures that you update for the decreasing numberMatched. bundle exec rubocop test/unit/bdl test/unit/app_test.rb reports 0 offenses. Report format: annotate the commit SHA, the list of new tests, and 'TESTS: <n> runs, <f> failures (expected new failures listed)'.
STATUS: blocked. FILES: none. TESTS: not run. NOTES: Graph: stale. The task branch starts at 9e33439 and lacks the goal head 97a19a8. The goal worktree has the app changes, but coord start-task created this branch from old main. The worktree also lacks all scoped test and fixture paths. This conflicts with the required goal-branch base and task scope.
MSG from tester: Task setup is blocked. coord start-task left tester-bot at 9e33439, while goal/c0e3a4e7 is 97a19a8 with the required app deadline fix. Scoped test/fixture paths do not exist in this checkout. Please repair task branch/worktree from goal head and restore task scope, then redispatch. I made no edits.

## Outcome

- Signal: corrected
- Correction: Run coord start-task <id> after coord claim. It checks out task/<id> from the goal head. The idle worker branch sits at old main 9e33439.