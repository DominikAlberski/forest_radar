---
type: "query"
date: "2026-10-10T08:37:06.032870+00:00"
question: "Pass the card deadline to Selector#select in lib/app.rb and commit ADR 0008"
contributor: "graphify"
outcome: "useful"
---

# Q: Pass the card deadline to Selector#select in lib/app.rb and commit ADR 0008

## Answer

Goal: make POST /api/card pass its deadline to the walk area selector, and commit the follow-up scope decision. Inputs: goal/1e0d3d4c at a1cdf99. Read docs/plans/strict-selector-fakes.md section T2. In lib/app.rb line 82, pass the existing local deadline as the deadline: keyword to settings.selector.select. Copy $COORD_DIR/artifacts/1e0d3d4c/decision-followup-scope.md verbatim to docs/decisions/0008-followup-scope-after-c1ab3a20.md. Out of scope: all test files, other lib files, .reek.yml, public/app.js, W1 W2 W4 W5. Do not change test fakes; reviewer minor notes on them wait for a later goal. Acceptance: ruby test/unit/app_test.rb exits 0. ruby test/run.rb --unit exits 0. coord with-lock system-test -- ruby test/run.rb --system exits 0. bundle exec rubocop lib test reports 0 offenses. bundle exec reek lib reports 0 warnings. Report format: annotate COMMIT, FILES, and a TESTS line with counts per command.
COMMIT: 8ea29bd. FILES: lib/app.rb, docs/decisions/0008-followup-scope-after-c1ab3a20.md. TESTS: app_test 8 tests, 49 assertions; unit 159 tests, 0 failures; system 18 tests, 0 failures; RuboCop 71 files, 0 offenses; Reek 0 warnings. Graph: fresh.

## Outcome

- Signal: useful