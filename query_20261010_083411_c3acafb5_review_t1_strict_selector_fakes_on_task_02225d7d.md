---
type: "query"
date: "2026-10-10T08:34:11.026723+00:00"
question: "Review T1 strict selector fakes on task/02225d7d"
contributor: "graphify"
outcome: "useful"
---

# Q: Review T1 strict selector fakes on task/02225d7d

## Answer

Goal: review the strict fakes and the failing deadline test of T1. Inputs: run git diff goal/1e0d3d4c...task/02225d7d. Read docs/plans/strict-selector-fakes.md section T1 on goal/1e0d3d4c. Read the T1 report on task 02225d7d. Out of scope: lib/app.rb; the missing deadline in app.rb is expected and T2 fixes it. Acceptance: check that each fake requires the real keywords with no catch-all. Check that the contract tests compare keyword names against OSM::Client#relations and WalkAreas::Selector#select. Check the deadline bounds t0 + 29 <= deadline <= t1 + 29. Check that no rubocop disable comment exists. Check that selector_test.rb can load test/system/support/fixtures.rb without side effects. Run bundle exec rubocop lib test and bundle exec reek lib test. Report format: annotate VERDICT approve or changes, then findings as critical, warning, or minor with file:line.
VERDICT: approve. Critical 0, warning 0, minor 7. TESTS line of T1 is present and matches the plan. Acceptance met: all four fakes require the real keywords with no catch-all. Contract tests compare against OSM::Client#relations and WalkAreas::Selector#select. app_test.rb:16 asserts t0 + 29 <= deadline <= t1 + 29. No rubocop disable comment exists. Loading fixtures.rb in selector_test.rb has no side effects: no at_exit, no server, no network. It only loads app.rb and reads config/model.yml. Static analysis: rubocop lib test 0 offenses. reek lib 0 warnings. reek test rises from 249 to 254 warnings, all in changed files. MINOR m1 test/system/support/fixtures.rb:82: the block parameter area shadows the new method parameter area from line 78. Fix: rename the block parameter to item. MINOR m2 test/unit/walk_areas/selector_test.rb:5: the selector unit test now loads the full app and config/model.yml through fixtures.rb. Fix: move the two SystemFixtures contract tests to app_test.rb, which already loads app. MINOR m3 app_test.rb:27 and selector_test.rb:60: keyword_names is duplicated. Fix: put one copy in test/te

## Outcome

- Signal: useful