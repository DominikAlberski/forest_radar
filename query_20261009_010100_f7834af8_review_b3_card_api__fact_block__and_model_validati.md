---
type: "query"
date: "2026-10-09T01:01:00.697604+00:00"
question: "Review B3 card API, fact block, and model validation on task/746eb2a2"
contributor: "graphify"
outcome: "useful"
---

# Q: Review B3 card API, fact block, and model validation on task/746eb2a2

## Answer

Goal: Review B3 commit c4d4109 against plan section B3. Inputs: Branch task/746eb2a2. Read 'git diff goal/c1ab3a20...task/746eb2a2'. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md lines 255 to 296, /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/api-contract.md, /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md and /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md. Check these points: The model client starts its own 29-second deadline after the search; the plan requires a shared deadline. The FAKTY line format must be 'F<id>: <value>' and must match api-contract.md. Check phrase checks for Polish inflections, escaping at render boundaries, and locale keys. Out of scope: B1, B2 and S2 code, post-mvp.md items, method size. Acceptance: Each finding has severity critical, warning or minor, with file and line. Do not run tests. Read the TESTS line on task 746eb2a2. Report format: Write /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review.md. End the file with VERDICT: approve or VERDICT: fix. Annotate the task with the verdict.
# B3 review

Task: 3347dfae-90a7-4aa0-80eb-f38e13eb671a.
Reviewed commit: c4d4109 on task/746eb2a2.
Baseline: git diff goal/c1ab3a20...task/746eb2a2.
Graph: fresh.

The review covers all 19 changed files and the four requested contracts.
GLOSSARY.md has no changes.
B1, B2, S2, deferred features, and method size remain outside this review.

Worker TESTS: bundle exec ruby test/run.rb --unit passed.
Worker TESTS: git diff --check goal/c1ab3a20...HEAD passed.
The reviewer did not run tests.
Static checks: bundle exec ruby -c passed for all 13 changed Ruby files, including config.ru.
Static checks: git diff --check goal

## Outcome

- Signal: useful