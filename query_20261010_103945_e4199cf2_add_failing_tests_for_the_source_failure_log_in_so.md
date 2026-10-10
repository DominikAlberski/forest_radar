---
type: "query"
date: "2026-10-10T10:39:45.853636+00:00"
question: "Add failing tests for the source failure log in SourceLog, App, and OSM client"
contributor: "graphify"
outcome: "useful"
---

# Q: Add failing tests for the source failure log in SourceLog, App, and OSM client

## Answer

Setup: run coord start-task 12276006-7c2b-4f87-809d-bf39ea3ebed0 first. It checks out task/<id> from the goal/c0e3a4e7 head. Goal: write failing tests for D4, the source failure log. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.md, section D4 and task L1 (the full test list). Target API: SourceLog writes to an injected IO, the default is $stderr. The App settings are source_log and clock. OSM::Client.new takes log: and clock: keywords. Line format: source=<bdl|osm|model> error=<class> message="<message>" elapsed_ms=<integer>. Write every test in the L1 list. Use fake clocks, so that elapsed_ms is exact. Out of scope: lib/, docs/, test/unit/app_test.rb, test/unit/bdl/, and test/fixtures/. Another tester owns those paths now. Acceptance: bundle exec rubocop test/unit/source_log_test.rb test/unit/app_log_test.rb test/unit/osm reports 0 offenses. ruby test/run.rb --unit loads every file without a load or syntax error. The new tests fail on the goal head only for the missing behavior. The old OSM tests still pass. Report format: annotate the commit SHA, the list of new tests, and 'TESTS: <n> runs, <f> failures (expected new failures listed)'.
MSG from tester: The L1 note does not name SourceLog's recording method. I will test SourceLog.new(io:).write(source:, error:, elapsed_ms:) as its public API unless you specify another method.
MSG from architect: Decision: use SourceLog.new(io:).write(source:, error:, elapsed_ms:). The io keyword defaults to $stderr. The source value is a Symbol: :bdl, :osm, or :model. The error value is the exception object. SourceLog takes the class name and the message from it. The elapsed_ms value is an Integer. OSM::Client calls the same write method on its log. L2 implements this API.
STATUS: done. FILES: test/unit/source_log_test.rb, test/unit/app_log_test.rb, test/unit/osm/client_log_test.rb. COMMIT: ea79e07f64e47562a8c369b9d0805b073263b3c1. TESTS: SourceLog covers exact format, sanitizing, truncation, and stderr default; App covers BDL, OSM, 

## Outcome

- Signal: useful