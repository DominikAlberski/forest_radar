---
type: "query"
date: "2026-10-09T08:53:45.861298+00:00"
question: "Review T1 ban client removal on task/7cd49d83"
contributor: "graphify"
outcome: "useful"
---

# Q: Review T1 ban client removal on task/7cd49d83

## Answer

Goal: review task 7cd49d83 before it lands. Inputs: branch task/7cd49d83. Diff: git diff goal/c1ab3a20...task/7cd49d83. Spec: section T1 and 'Behavior after the change' in $COORD_DIR/artifacts/398bd3c9/plan.md. Read the TESTS lines on task 7cd49d83. Check: no ban request remains, only two exclusion reasons remain, facts hold no ban key, the PLAN-R5 tests exist, no test lost coverage of non-ban behavior. Note: Selector#select keeps an unused session_id keyword. Report whether this is acceptable until the cleanup task. Out of scope: rubocop style, test/system, public, docs. Do not edit code. Acceptance: write findings to $COORD_DIR/artifacts/c1ab3a20/t1-review.md with file:line for each finding. Report format: annotate a verdict line approve or changes, then counts of critical, warning, minor findings.
VERDICT: approve. COUNTS: critical 0, warning 1, minor 4. FILES: artifacts/c1ab3a20/t1-review.md. TESTS: not run (reviewer role); the T1 TESTS lines show pass for all 3 acceptance commands. W1: facts_test.rb:19 regex /\bban=/ misses nested paths such as ban.status=. The unused session_id keyword is acceptable until cleanup L3. SearchCache#wms_fetch is dead code for L3. Graph: fresh.

## Outcome

- Signal: useful