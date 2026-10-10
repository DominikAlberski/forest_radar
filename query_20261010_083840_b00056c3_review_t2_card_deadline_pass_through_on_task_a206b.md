---
type: "query"
date: "2026-10-10T08:38:40.266039+00:00"
question: "Review T2 card deadline pass-through on task/a206b88c"
contributor: "graphify"
outcome: "useful"
---

# Q: Review T2 card deadline pass-through on task/a206b88c

## Answer

Goal: review the T2 change that passes the card deadline to Selector#select. Inputs: run git diff goal/1e0d3d4c...task/a206b88c. Read docs/plans/strict-selector-fakes.md section T2 on goal/1e0d3d4c. Read the T2 report on task a206b88c. Out of scope: test files and the seven R1 minor findings on T1. Acceptance: check that lib/app.rb passes the same deadline value to the selector and to the model client. Check that docs/decisions/0008-followup-scope-after-c1ab3a20.md equals $COORD_DIR/artifacts/1e0d3d4c/decision-followup-scope.md. Check that the selector honours the deadline in its OSM call. Run bundle exec rubocop lib test and bundle exec reek lib. Report format: annotate VERDICT approve or changes, then findings as critical, warning, or minor with file:line.
VERDICT: approve. Critical 0, warning 0, minor 0. The T2 TESTS line is present: unit 159 tests 0 failures, system 18 tests 0 failures, rubocop 0, reek 0. lib/app.rb:77 computes one local deadline. lib/app.rb:83 passes it to the selector, and lib/app.rb:86 passes the same value to the model client. The selector forwards it at lib/walk_areas/selector.rb:71. lib/osm/client.rb:60 caps the Overpass request at min(deadline, own cutoff). docs/decisions/0008-followup-scope-after-c1ab3a20.md is byte-identical to artifacts/1e0d3d4c/decision-followup-scope.md (diff is empty). The diff touches only lib/app.rb and the ADR, which is in scope. task/a206b88c contains the goal head a1cdf99. Static analysis on the task branch: rubocop lib test 0 offenses in 71 files, reek lib 0 warnings. Graph: fresh.

## Outcome

- Signal: useful