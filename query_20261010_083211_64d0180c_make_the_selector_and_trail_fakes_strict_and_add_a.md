---
type: "query"
date: "2026-10-10T08:32:11.878641+00:00"
question: "Make the selector and trail fakes strict and add a failing card deadline test"
contributor: "graphify"
outcome: "useful"
---

# Q: Make the selector and trail fakes strict and add a failing card deadline test

## Answer

Goal: make each selector-path fake strict, and add an app test that fails because app.rb does not pass deadline: to the selector. Read docs/plans/strict-selector-fakes.md section T1 on goal/1e0d3d4c. Inputs: goal/1e0d3d4c at b9e33e3. Fakes: Trails#relations in selector_test.rb and app_test.rb, Trails#relations and Walk#select in test/system/support/fixtures.rb. Each fake requires the real keywords with no ** catch-all: relations requires bbox: and deadline:, select requires search:, area:, deadline:. Each fake uses or records each keyword. Do not add rubocop disable comments. Add keyword-name contract tests against OSM::Client#relations and WalkAreas::Selector#select through Method#parameters, inside the owning test files. Compare names only. The app deadline test reads the monotonic clock t0 before and t1 after the request. It asserts status 200 and t0 + 29 <= deadline <= t1 + 29. Run two local mutation checks and revert them: rename bbox: to box:, then deadline: to limit:, in the Selector call to relations. selector_test must fail each time. Out of scope: lib/, the model fakes (Expired#generate, fixtures Model#generate), W1 W2 W4 W5, public/app.js. Acceptance: bundle exec rubocop lib test reports 0 offenses. ruby test/unit/walk_areas/selector_test.rb exits 0. ruby test/unit/app_test.rb fails only in the new deadline test. coord with-lock system-test -- ruby test/run.rb --system fails only at the five Walk users: m2_m7_facts_test.rb:29, print_test.rb:28, browser_fact_helpers.rb:36 and :63, browser_print_data_helpers.rb:16. Report format: annotate COMMIT, FILES, TESTS line with counts per command, the failing test names, and the result of both mutation checks.
COMMIT: 303ccea. FILES: test/unit/app_test.rb, test/unit/walk_areas/selector_test.rb, test/system/support/fixtures.rb. TESTS: RuboCop inspected 71 files with 0 offenses. Selector tests passed 9 tests and 23 assertions. App tests ran 8 tests and 49 assertions; only test_card_passes_its_deadline_to_the_selector 

## Outcome

- Signal: useful