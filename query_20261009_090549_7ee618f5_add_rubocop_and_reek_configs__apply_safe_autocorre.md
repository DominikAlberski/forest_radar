---
type: "query"
date: "2026-10-09T09:05:49.229910+00:00"
question: "Add rubocop and reek configs, apply safe autocorrect to lib and test, commit the cleanup plan"
contributor: "graphify"
outcome: "useful"
---

# Q: Add rubocop and reek configs, apply safe autocorrect to lib and test, commit the cleanup plan

## Answer

Goal: add the rubocop and reek configs and apply safe autocorrect only. Inputs: goal/c1ab3a20 at 4a2b0fc (T1, T2, T3 landed). Spec: section 'Config rules' and task C0 in $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md. Follow every C0 bullet there. Copy cleanup-plan.md word for word to docs/plans/cleanup-rubocop-reek.md and commit it. Out of scope: manual refactors except line splits above 120 characters, public/, config/locales/, other docs. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop lib test --only Layout,Style/FrozenStringLiteralComment reports 0 offenses. git diff --check passes. Report format: annotate one TESTS line per acceptance command. Annotate the rubocop total of lib and test, the reek total of lib, and the rubocop offense count per scope L1, L2, L3, S1.
STATUS: done. FILES: .rubocop.yml, .reek.yml, Gemfile, Gemfile.lock, lib/, test/, docs/plans/cleanup-rubocop-reek.md. NOTES: Graph: fresh. RuboCop found 243 offenses in lib and test. Reek found 170 warnings in lib. L1: 26. L2: 105. L3: 62. S1: 50. Restored two splat calls because autocorrect changed test inputs.
TESTS: bundle exec ruby test/run.rb --unit passed.
TESTS: coord with-lock system-test -- bundle exec ruby test/run.rb --system passed.
TESTS: bundle exec rubocop lib test --only Layout,Style/FrozenStringLiteralComment passed with zero offenses.
TESTS: git diff --check passed.

## Outcome

- Signal: useful