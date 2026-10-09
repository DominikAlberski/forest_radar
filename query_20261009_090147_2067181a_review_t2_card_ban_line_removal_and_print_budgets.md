---
type: "query"
date: "2026-10-09T09:01:47.233192+00:00"
question: "Review T2 card ban line removal and print budgets on task/4ccadacd"
contributor: "graphify"
outcome: "useful"
---

# Q: Review T2 card ban line removal and print budgets on task/4ccadacd

## Answer

Goal: review task 4ccadacd before it lands. Inputs: branch task/4ccadacd. Diff: git diff goal/c1ab3a20...task/4ccadacd. Spec: section T2 and 'Behavior after the change' in $COORD_DIR/artifacts/398bd3c9/plan.md. Read the TESTS lines on task 4ccadacd. Check: no ban text remains in the card or locales. Each print budget matches C-R2, including the ellipsis count and the advice omission label. Wide characters count as one character. The screen keeps the full text. Safety text and attribution print in full. The E-R1 and C-R2 tests assert the marker before and after each limit. The en.yml value for print_omitted follows the existing en.yml pattern. test_m7_maximum_content_card_prints_on_one_a4_page is unchanged. Report whether a trail crossing test carries the m4 name. Out of scope: lib/, rubocop style, docs. Do not edit code. Acceptance: write findings to $COORD_DIR/artifacts/c1ab3a20/t2-review.md with file:line for each finding. Report format: annotate a verdict line approve or changes, then counts of critical, warning, minor findings.
VERDICT: changes. COUNTS: critical 0, warning 3, minor 4. FILES: artifacts/c1ab3a20/t2-review.md. TESTS: not run (reviewer role); the T2 TESTS lines show pass for all 4 acceptance commands. W1: the C-R2 markers do not sit at the limits, so no budget number is proven. W2: the no-access-promise refute_match was lost with the ban test. W3: no trail crossing test carries an m4 name. The code matches C-R2. Graph: fresh.

## Outcome

- Signal: useful