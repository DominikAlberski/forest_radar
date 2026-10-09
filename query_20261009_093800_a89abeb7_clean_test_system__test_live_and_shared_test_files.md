---
type: "query"
date: "2026-10-09T09:38:00.134107+00:00"
question: "Clean test/system, test/live and shared test files to zero rubocop offenses"
contributor: "graphify"
outcome: "useful"
---

# Q: Clean test/system, test/live and shared test files to zero rubocop offenses

## Answer

Goal: test/system, test/live and the shared test files reach zero rubocop offenses, and the T2 review test notes are applied. Inputs: goal/c1ab3a20 at a3b91c8 (C0 landed: .rubocop.yml, .reek.yml). Plan: $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md, read your task section and 'Shared rules for L1, L2, L3, S1'. L1, L2, L3, S1 run in parallel. Shared rules: No behavior change. Keep every test case and assertion; a test may move or get a helper. Keep every public method and constructor that code outside your scope calls. Message the architect before a public signature change. Add no rubocop:disable comment and no reek exclusion. Fix reek by design, not by config. A new file under lib/<dir> or test/unit/<dir> belongs to the owner of <dir>. Rescue variables use the name error. Do not run rubocop -a or -A without a review of its diff; C0 autocorrect once removed a splat and broke a test. Reflow deep-aligned continuation arguments when you touch a method (C0 review M3). Notes: follow the S1 section of the plan. Rename Cdp::Page#eval to evaluate. Replace class variables. Fix the shadowed exception. Split test/system/m1_m7_test.rb into files below 100 lines; keep every test case and assertion. Record in the report why no eval is needed: Page#eval sent CDP Runtime.evaluate and never called Kernel#eval. Apply T2-W1, T2-W2, T2-W3, T2-M1, T2-M3, T2-M4 as the plan describes (source: $COORD_DIR/artifacts/c1ab3a20/t2-review.md). Keep the card behavior unchanged. The system fake in test/system/support/fixtures.rb must keep accepting select with the search: keyword and extra keywords; L3 changes Selector#select. C0 re-review m1: test/live/ollama_live_test.rb:106-108 may become a one-line block. Out of scope: lib/, public/, and test/unit/ except ui_test.rb, locales_test.rb and config/. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop test/system test/live test/run.rb test/test_helpe

## Outcome

- Signal: useful