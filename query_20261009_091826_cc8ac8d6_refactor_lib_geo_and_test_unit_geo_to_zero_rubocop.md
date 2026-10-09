---
type: "query"
date: "2026-10-09T09:18:26.549274+00:00"
question: "Refactor lib/geo and test/unit/geo to zero rubocop and reek findings"
contributor: "graphify"
outcome: "useful"
---

# Q: Refactor lib/geo and test/unit/geo to zero rubocop and reek findings

## Answer

Goal: lib/geo and test/unit/geo reach zero rubocop and reek findings. Inputs: goal/c1ab3a20 at a3b91c8 (C0 landed: .rubocop.yml, .reek.yml). Plan: $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md, read your task section and 'Shared rules for L1, L2, L3, S1'. L1, L2, L3, S1 run in parallel. Shared rules: No behavior change. Keep every test case and assertion; a test may move or get a helper. Keep every public method and constructor that code outside your scope calls. Message the architect before a public signature change. Add no rubocop:disable comment and no reek exclusion. Fix reek by design, not by config. A new file under lib/<dir> or test/unit/<dir> belongs to the owner of <dir>. Rescue variables use the name error. Do not run rubocop -a or -A without a review of its diff; C0 autocorrect once removed a splat and broke a test. Reflow deep-aligned continuation arguments when you touch a method (C0 review M3). Out of scope: every path outside lib/geo/ and test/unit/geo/. Geo::Geometry public methods are called from lib/walk_areas and lib/bdl; keep them. Acceptance: bundle exec ruby test/run.rb --unit passes. bundle exec rubocop lib/geo test/unit/geo reports 0 offenses. bundle exec reek lib/geo reports 0 warnings. git diff --check passes. Report format: one TESTS line per acceptance command. Annotate the rubocop and reek counts before and after for your scope. List each changed public signature, or 'none'.
STATUS: done. FILES: lib/geo/geometry.rb, lib/geo/geometry/segments.rb, test/unit/geo/geometry_test.rb, test/unit/geo/geometry_holes_test.rb, test/unit/geo/geometry_collinear_test.rb. NOTES: Graph: fresh. RuboCop: 26 before, 0 after. Reek: 41 before, 0 after. Changed public signatures: none.
TESTS: bundle exec ruby test/run.rb --unit passed.
TESTS: bundle exec rubocop lib/geo test/unit/geo passed with zero offenses.
TESTS: bundle exec reek lib/geo passed with zero warnings.
TESTS: git diff --check passed.

## Outcome

- Signal: useful