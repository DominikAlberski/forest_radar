---
type: "query"
date: "2026-10-09T09:46:32.214934+00:00"
question: "Refactor lib/bdl, lib/http, lib/osm and their unit tests to zero rubocop and reek findings"
contributor: "graphify"
outcome: "corrected"
correction: "A task branch must contain the goal head before coord land. After a sibling task lands, merge the goal branch into the open task branch before coord done."
---

# Q: Refactor lib/bdl, lib/http, lib/osm and their unit tests to zero rubocop and reek findings

## Answer

Goal: lib/bdl, lib/http, lib/osm and their unit tests reach zero rubocop and reek findings. Inputs: goal/c1ab3a20 at a3b91c8 (C0 landed: .rubocop.yml, .reek.yml). Plan: $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md, read your task section and 'Shared rules for L1, L2, L3, S1'. L1, L2, L3, S1 run in parallel. Shared rules: No behavior change. Keep every test case and assertion; a test may move or get a helper. Keep every public method and constructor that code outside your scope calls. Message the architect before a public signature change. Add no rubocop:disable comment and no reek exclusion. Fix reek by design, not by config. A new file under lib/<dir> or test/unit/<dir> belongs to the owner of <dir>. Rescue variables use the name error. Do not run rubocop -a or -A without a review of its diff; C0 autocorrect once removed a splat and broke a test. Reflow deep-aligned continuation arguments when you touch a method (C0 review M3). Notes: HTTP::Transport has 6 keyword parameters; you own all its callers in lib/bdl and lib/osm. Keep OSM::Client.new with no argument and with transport: callable; lib/app.rb and test/unit/walk_areas call them. Keep BDL::Client.new with transport: callable. CPR-M4: test/unit/bdl/client_test.rb:54 builds client and never uses it. Decide if the test must call client. Keep or restore the test intent, then fix the offense. Record the decision in the report. C0 review W3: test/unit/http/transport_hardening_test.rb:43 and :50 splat an array into FakeNet::Script.new(*steps). Change these calls by hand, for example list the steps, so that each step stays a separate argument. Same rule for client_search_test.rb:71. Out of scope: every path outside your scope. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop lib/bdl lib/http lib/osm test/unit/bdl test/unit/http test/unit/osm reports 0 offenses. bundle exec reek lib/bdl lib/http lib/osm reports 0 w

## Outcome

- Signal: corrected
- Correction: A task branch must contain the goal head before coord land. After a sibling task lands, merge the goal branch into the open task branch before coord done.