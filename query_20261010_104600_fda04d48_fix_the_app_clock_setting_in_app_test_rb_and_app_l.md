---
type: "query"
date: "2026-10-10T10:46:00.226275+00:00"
question: "Fix the App clock setting in app_test.rb and app_log_test.rb to use a captured local clock"
contributor: "graphify"
outcome: "corrected"
correction: "Sinatra set with a Proc defines the setting method from the proc body. Instance variables of the test are nil there. Capture the test clock in a local variable first. settings.clock returns the time value, not a callable."
---

# Q: Fix the App clock setting in app_test.rb and app_log_test.rb to use a captured local clock

## Answer

Setup: run coord start-task ca15d176-fe67-47b1-925d-2b414223fe4f first. Goal: fix the fake clock setup in the App tests. Problem: app.set :clock, -> { @clock.call } fails. Sinatra set with a Proc defines the setting method from the proc body. The body runs in the App class, so @clock is nil there. Contract: settings.clock returns the current monotonic time in seconds as a Float. Lib code reads settings.clock and never calls .call on it. Required: copy the fake clock to a local variable, and let the lambda read the local variable. Fix test/unit/app_test.rb line 41 and test/unit/app_log_test.rb line 173. Keep the teardown defaults. Keep every assertion. Inputs: goal/c0e3a4e7 head. Out of scope: lib/ and every other test file. Acceptance: bundle exec rubocop test/unit/app_test.rb test/unit/app_log_test.rb reports 0 offenses. ruby test/run.rb --unit loads every file. In irb or a short check, ForestRadar::App.settings.clock returns the fake clock value after the test setup. Report format: annotate the commit SHA and 'TESTS: <n> runs, <f> failures, <e> errors'. List the remaining failures and the missing behavior for each.

## Outcome

- Signal: corrected
- Correction: Sinatra set with a Proc defines the setting method from the proc body. Instance variables of the test are nil there. Capture the test clock in a local variable first. settings.clock returns the time value, not a callable.