---
type: "query"
date: "2026-10-09T08:55:52.512028+00:00"
question: "Review T3 ban removal docs on task/740b0195"
contributor: "graphify"
outcome: "useful"
---

# Q: Review T3 ban removal docs on task/740b0195

## Answer

Goal: review task 740b0195 before it lands. Inputs: branch task/740b0195. Diff: git diff goal/c1ab3a20...task/740b0195. Spec: section T3 in $COORD_DIR/artifacts/398bd3c9/plan.md. Agreed glossary terms: $COORD_DIR/artifacts/398bd3c9/glossary-draft.md. Read the TESTS lines on task 740b0195. Check: no doc claims a ban check, the removal note states the reason, the ADR matches the decision artifact, the glossary matches the draft. Architect note: README.md live prerequisites still name mapserver.bdl.lasy.gov.pl. Report whether any live test still needs that host. Out of scope: historical docs listed in the plan, code, tests. Do not edit files. Acceptance: write findings to $COORD_DIR/artifacts/c1ab3a20/t3-review.md with file:line for each finding. Report format: annotate a verdict line approve or changes, then counts of critical, warning, minor findings.
VERDICT: approve. COUNTS: critical 0, warning 2, minor 2. FILES: artifacts/c1ab3a20/t3-review.md. TESTS: not run (reviewer role); the T3 TESTS lines show pass for both acceptance commands. No live test or lib code needs mapserver.bdl.lasy.gov.pl at 81fd83b, so README.md:133 is stale (W1). W2: PLAN.md:139 redefines M4 without a record in the ADR or the evidence file. Graph: fresh.

## Outcome

- Signal: useful