---
type: "query"
date: "2026-10-10T10:47:25.110756+00:00"
question: "Fix the App clock setting in app_test.rb and app_log_test.rb to use a captured local clock"
contributor: "graphify"
outcome: "useful"
---

# Q: Fix the App clock setting in app_test.rb and app_log_test.rb to use a captured local clock

## Answer

Setup: run coord start-task ca15d176-fe67-47b1-925d-2b414223fe4f first. Goal: fix the fake clock setup in the App tests. Problem: app.set :clock, -> { @clock.call } fails. Sinatra set with a Proc defines the setting method from the proc body. The body runs in the App class, so @clock is nil there. Contract: settings.clock returns the current monotonic time in seconds as a Float. Lib code reads settings.clock and never calls .call on it. Required: copy the fake clock to a local variable, and let the lambda read the local variable. Fix test/unit/app_test.rb line 41 and test/unit/app_log_test.rb line 173. Keep the teardown defaults. Keep every assertion. Inputs: goal/c0e3a4e7 head. Out of scope: lib/ and every other test file. Acceptance: bundle exec rubocop test/unit/app_test.rb test/unit/app_log_test.rb reports 0 offenses. ruby test/run.rb --unit loads every file. In irb or a short check, ForestRadar::App.settings.clock returns the fake clock value after the test setup. Report format: annotate the commit SHA and 'TESTS: <n> runs, <f> failures, <e> errors'. List the remaining failures and the missing behavior for each.
STATUS: blocked. Commit: cb8d3507bf44d481ecb437c1407237d891fd0e20. FILES: test/unit/app_test.rb test/unit/app_log_test.rb. TESTS: 47 runs, 7 failures, 5 errors across ruby test/run.rb --unit; direct clock check passed. bundle exec rubocop test/unit/app_test.rb test/unit/app_log_test.rb failed with 1 Metrics/ClassLength offense in app_log_test.rb:139. Remaining failures: AppLogTest expected log entries but got none and configured OSM source log was nil; cause not established. AppDeadlineTest expected deadline 94769.960304 but got 94758.960447; cause not established. Pagination tests raised ArgumentError for unsupported page_size/concurrency keywords instead of intended results. Graph: stale.
MSG from tester: The clock settings now capture local clocks; the direct settings check returns 123.5. Acceptance remains blocked by pre-existing test-loader failure

## Outcome

- Signal: useful