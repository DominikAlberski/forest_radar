---
type: "query"
date: "2026-10-10T14:45:36.853831+00:00"
question: "Show the mock advice marker in public/app.js with ui.advice_mock locale keys"
contributor: "graphify"
outcome: "useful"
source_nodes: ["public_app", "test_unit_locales_test"]
---

# Q: Show the mock advice marker in public/app.js with ui.advice_mock locale keys

## Answer

Goal: Implement plan item D4 frontend (M3). Show a visible marker in the advice heading when card.advice_mock is true. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md items D4 and M3. Base: goal/6c0f485d at d1ec3ea. That commit has card.advice_mock in the card JSON. Out of scope: lib/, config/model.yml, the other test files, GLOSSARY.md. Behavior: the marker is a text node, not only a style. The text comes from the locale key ui.advice_mock in pl and en. The marker shows on screen and in print view. No marker when advice_mock is false. Acceptance: ruby test/run.rb --unit passes. The locales test passes with ui.advice_mock in pl and en. Run coord with-lock system-test -- the system test test/system/mock_marker_test.rb with the stub model. It asserts the marker text on screen and in print view. bundle exec rubocop lib test reports 0 offenses. Commit before coord done. Report format: TESTS line with counts, the system test result, the commit id.
STATUS: done. FILES: public/app.js, config/locales/pl.yml, config/locales/en.yml, test/unit/locales_test.rb, test/system/mock_marker_test.rb. TESTS: Unit suite passed with zero failures. System test passed: 2 runs, 18 assertions. RuboCop inspected 87 files with zero offenses. NOTES: Graph: fresh. Commit: a610899.

## Outcome

- Signal: useful

## Source Nodes

- public_app
- test_unit_locales_test