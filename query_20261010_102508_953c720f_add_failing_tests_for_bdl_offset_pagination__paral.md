---
type: "query"
date: "2026-10-10T10:25:08.862710+00:00"
question: "Add failing tests for BDL offset pagination, parallel reads, and card deadline (retry of 6313d6ce)"
contributor: "graphify"
outcome: "corrected"
correction: "A peer-wait in a concurrency fake must give up after a fixed total timeout. A while loop around a timed wait hangs forever when the code under test is sequential."
---

# Q: Add failing tests for BDL offset pagination, parallel reads, and card deadline (retry of 6313d6ce)

## Answer

Setup: run coord start-task 59296b4a-5073-4dac-a96d-da9312b1fbc6 before any edit. That command checks out task/<id> from goal/c0e3a4e7 head 74548cc. Do not work on worker/tester-bot, which sits at old main 9e33439. Task 6313d6ce closed without work because start-task did not run. Goal: write failing tests for goal c0e3a4e7 before the fix. Inputs: docs/plans/bdl-offset-pagination.md on the goal branch (same as $COORD_DIR/artifacts/c0e3a4e7/plan.md), sections D1 to D3 and the S2-1 test list. Evidence: $COORD_DIR/artifacts/c0e3a4e7/diagnosis.md, pagination.md, offsets.md. Target API: BDL::Client.new(transport:, clock:, page_size: 1000, concurrency: 4), and the App setting clock. Write every test in the S2-1 list. Fakes return bodies keyed by the offset param, not by call order. In the in-flight test, each fake request blocks until a second request arrives. Use a Queue or a ConditionVariable with a short timeout, so a bug cannot hang the suite. Out of scope: lib/, docs/, and all test files outside the scope. Acceptance: ruby test/run.rb runs without load or syntax errors. The new tests fail only for the missing behavior. All old tests still pass, except the fixtures that you update for the decreasing numberMatched. bundle exec rubocop test/unit/bdl test/unit/app_test.rb reports 0 offenses. Report format: annotate the commit SHA, the list of new tests, and 'TESTS: <n> runs, <f> failures (expected new failures listed)'.
MSG from architect: Scope change for task 59296b4a. Do not write the test that the app logs the Incomplete message to rack.errors. A later tester task owns the log tests. The unit suite command is ruby test/run.rb --unit. All other parts of the spec stay the same.
COMMIT: 4c081b2. Graph: stale. Tests: offset order; live-shaped early next-link stop; count change and short-page checks; limit preflight; foreign and repeated links; parallel in-flight bound and worker cleanup; deadline after search. Root cause: eight pagination tests and two parallel tests cann

## Outcome

- Signal: corrected
- Correction: A peer-wait in a concurrency fake must give up after a fixed total timeout. A while loop around a timed wait hangs forever when the code under test is sequential.