---
type: "query"
date: "2026-10-10T10:54:14.925948+00:00"
question: "Implement SourceLog, App source_log and clock settings, and OSM client logging"
contributor: "graphify"
outcome: "corrected"
correction: "Before coord done, merge the latest goal head into the task branch. coord land refuses a branch that lacks the goal head."
---

# Q: Implement SourceLog, App source_log and clock settings, and OSM client logging

## Answer

Setup: run coord start-task b8a9df9a-e5d0-4aad-86a3-2f43d7e2e8b7 first. It checks out task/<id> from the goal/c0e3a4e7 head. Goal: implement D4, the source failure log, and add the App setting clock. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.md, section D4, D3 clock seam, and task L2. The L1 tests are landed on goal/c0e3a4e7 (commit eecde6e). API: SourceLog.new(io:).write(source:, error:, elapsed_ms:). The io keyword defaults to $stderr. The source value is a Symbol: :bdl, :osm, or :model. The error value is the exception object. The elapsed_ms value is an Integer. OSM::Client.new takes log: and clock: keywords. OSM::Client stores the log in @log, because the wiring test reads it. App configure builds one SourceLog. It passes the same object to settings.source_log and to OSM::Client. The App setting clock defaults to monotonic time in seconds. Copy the final plan.md to docs/plans/bdl-offset-pagination.md. Out of scope: test/, lib/bdl/, lib/walk_areas/, and the D3 deadline move (S2-2 does it). Acceptance: ruby test/run.rb --unit passes every L1 test in test/unit/source_log_test.rb, test/unit/app_log_test.rb, test/unit/osm/client_log_test.rb. Earlier tests keep their state. bundle exec rubocop lib test reports 0 offenses. bundle exec reek lib reports 0 warnings. Start the app with the stub model and run one live card request. Write that repro line to $COORD_DIR/artifacts/c0e3a4e7/repro-log.md. Report format: annotate the commit SHA, the changed files, and 'TESTS: <n> runs, <f> failures, <e> errors'. List each remaining failure with its file and owner task.
Note: test/unit/bdl/client_parallel_pagination_test.rb can hang on the goal head. Task 78002b63 fixes this. If the suite hangs, run every other unit file and report that file as skipped.
MSG from backend-developer: The App log test sets a clock lambda that reads @clock. Sinatra evaluates the lambda in the App context. The instance variable is nil. Please ask the tester to fix the test clock setup.
MSG from architec

## Outcome

- Signal: corrected
- Correction: Before coord done, merge the latest goal head into the task branch. coord land refuses a branch that lacks the goal head.