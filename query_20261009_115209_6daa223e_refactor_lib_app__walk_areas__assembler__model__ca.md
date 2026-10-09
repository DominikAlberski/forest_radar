---
type: "query"
date: "2026-10-09T11:52:09.537757+00:00"
question: "Refactor lib app, walk_areas, assembler, model, cache, card, sanepid and their unit tests to zero findings"
contributor: "graphify"
outcome: "useful"
---

# Q: Refactor lib app, walk_areas, assembler, model, cache, card, sanepid and their unit tests to zero findings

## Answer

Goal: lib/app.rb, lib/walk_areas, lib/assembler, lib/model, lib/cache, lib/card, lib/sanepid.rb and their unit tests reach zero rubocop and reek findings. Inputs: goal/c1ab3a20 at a3b91c8 (C0 landed: .rubocop.yml, .reek.yml). Plan: $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md, read your task section and 'Shared rules for L1, L2, L3, S1'. L1, L2, L3, S1 run in parallel. Shared rules: No behavior change. Keep every test case and assertion; a test may move or get a helper. Keep every public method and constructor that code outside your scope calls. Message the architect before a public signature change. Add no rubocop:disable comment and no reek exclusion. Fix reek by design, not by config. A new file under lib/<dir> or test/unit/<dir> belongs to the owner of <dir>. Rescue variables use the name error. Do not run rubocop -a or -A without a review of its diff; C0 autocorrect once removed a splat and broke a test. Reflow deep-aligned continuation arguments when you touch a method (C0 review M3). Notes: CPR-W3: keep WalkAreas::Selector.new(trails:) and Cache::SearchCache.new with no argument callable; S1 files call them. Fix the parameter count of Selector#select and SearchCache internals inside lib. Keep Model::Client.new(url, model, http:) callable; test/live calls it. CPR2-N1: lib/app.rb keeps calling select with the search: keyword; test/system/support/fixtures.rb:80 depends on it. Other arguments may become keywords or a value object. T1-M1: remove the unused session_id: keyword from Selector#select, lib/app.rb, and the unit tests. T1-M2: delete the dead method Cache::SearchCache#wms_fetch. T1-W1: test/unit/assembler/facts_test.rb cannot detect a nested ban field. Add a ban field to the input. Assert that no F-line key path has a segment equal to ban. Out of scope: every path outside your scope, test/system/ (S1). Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop l

## Outcome

- Signal: useful