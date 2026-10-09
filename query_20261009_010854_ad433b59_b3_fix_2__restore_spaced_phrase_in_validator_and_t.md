---
type: "query"
date: "2026-10-09T01:08:54.945696+00:00"
question: "B3 fix 2: restore spaced phrase in validator and test every phrase alternative"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts"]
---

# Q: B3 fix 2: restore spaced phrase in validator and test every phrase alternative

## Answer

Goal: Fix B3-R2 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b3-review-2.md. Inputs: Start from branch task/fec7446e at 837f37a. The x flag in lib/model/validator.rb ignores literal spaces. Replace every literal space in PROHIBITED and ACCESS with an explicit whitespace class. Add one table-driven rejection test. The table holds one full Polish sentence for every alternative in both patterns, in lower case and upper case. Include 'Te grzyby nadają się do spożycia.'. Add one acceptance case with safe advice. Also narrow api-contract.md: the shared deadline bounds the model budget. Source work keeps its own source timeouts. Out of scope: lib/app.rb, lib/model/client.rb, all other files, other findings. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate commit, changed paths, the count of table cases, and a TESTS line with both results.
STATUS: done. COMMIT: f840d85. FILES: lib/model/validator.rb, test/unit/model/validator_test.rb. TABLE CASES: 20 rejection cases and one safe acceptance case. CONTRACT: Shared api-contract.md states that source work keeps its own timeouts. Graph: fresh. TESTS: bundle exec ruby test/run.rb --unit passed; git diff --check goal/c1ab3a20...HEAD passed.

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts