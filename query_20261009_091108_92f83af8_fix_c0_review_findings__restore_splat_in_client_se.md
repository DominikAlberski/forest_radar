---
type: "query"
date: "2026-10-09T09:11:08.173516+00:00"
question: "Fix C0 review findings: restore splat in client_search_test, rescue variable name error, CPR-M4 assignment"
contributor: "graphify"
outcome: "useful"
---

# Q: Fix C0 review findings: restore splat in client_search_test, rescue variable name error, CPR-M4 assignment

## Answer

Goal: fix the C0 review findings before C0 lands. Inputs: start from branch task/36ea3fd4 (commit c0f4b68). Merge or rebase it into your task branch first. Review: $COORD_DIR/artifacts/c1ab3a20/c0-review.md, findings C1, W1, W2, M2. Plan: $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md (new W1 rule under Config rules). C1: restore the splat in test/unit/bdl/client_search_test.rb:71. Search the C0 diff for every other removed splat in a call argument and restore it when the callee takes *args. W1: set Naming/RescuedExceptionsVariableName PreferredName error in .rubocop.yml with a reason comment. Rename every rescue variable e back to error in lib and test. W2: restore the assignment 'client =' at test/unit/bdl/client_test.rb:54. L2 owns the CPR-M4 decision. M2: in test/live/ollama_live_test.rb:106-108, build the facts text in a local variable, then interpolate it. Copy cleanup-plan.md word for word to docs/plans/cleanup-rubocop-reek.md again. Out of scope: other offenses, refactors, Gemfile and Gemfile.lock, public/. Do not run rubocop -a. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop lib test --only Layout,Style/FrozenStringLiteralComment,Naming/RescuedExceptionsVariableName reports 0 offenses. bundle exec reek lib reports no UncommunicativeVariableName for e. git diff --check passes. Report format: one TESTS line per acceptance command. List each restored splat with file and line. Annotate the rubocop total of lib and test and the reek total of lib.
STATUS: done. FILES: .rubocop.yml, lib/bdl/client.rb, lib/http/transport.rb, test/live/ollama_live_test.rb, test/unit/bdl/client_search_test.rb, test/unit/bdl/client_test.rb, docs/plans/cleanup-rubocop-reek.md. NOTES: Graph: fresh. Restored splats: test/unit/bdl/client_search_test.rb:71; inherited restorations: test/unit/http/transport_hardening_test.rb:43 and :50. RuboCop: 245 offenses in lib and test. Reek: 168 war

## Outcome

- Signal: useful