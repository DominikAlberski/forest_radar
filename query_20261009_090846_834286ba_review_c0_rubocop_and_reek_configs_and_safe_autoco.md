---
type: "query"
date: "2026-10-09T09:08:46.333893+00:00"
question: "Review C0 rubocop and reek configs and safe autocorrect on task/36ea3fd4"
contributor: "graphify"
outcome: "useful"
---

# Q: Review C0 rubocop and reek configs and safe autocorrect on task/36ea3fd4

## Answer

Goal: review C0 before it lands on goal/c1ab3a20. Inputs: branch task/36ea3fd4. Read git diff goal/c1ab3a20...task/36ea3fd4. Spec: section 'Config rules' and task C0 in $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md. Read the TESTS lines on task 36ea3fd4. Check that each config entry matches the plan and has a reason comment. Check that autocorrect changed no behavior, for example a removed return or a changed rescue variable. Check that no manual refactor exists except line splits. Out of scope: remaining rubocop and reek offenses; tasks L1, L2, L3, S1 fix them. Do not run tests. Acceptance: findings written to $COORD_DIR/artifacts/c1ab3a20/c0-review.md with file and line for each finding. Report format: annotate a verdict line 'approve' or 'changes', and the count of critical, warning and minor findings.
Verdict: changes. Critical 1, warning 3, minor 4. Review: artifacts/c1ab3a20/c0-review.md. C1: client_search_test.rb:71 lost a splat, so the SSL retry test passes on a TypeError. W1: autocorrect renamed rescue variables to e, and reek now flags e. W2: client_test.rb:54 autocorrect took the CPR-M4 decision. W3: two kept splats break under rubocop -a in L2. Graph: fresh.

## Outcome

- Signal: useful