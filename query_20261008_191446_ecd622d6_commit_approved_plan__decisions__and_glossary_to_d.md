---
type: "query"
date: "2026-10-08T19:14:46.261977+00:00"
question: "Commit approved plan, decisions, and glossary to docs/ and GLOSSARY.md"
contributor: "graphify"
outcome: "useful"
source_nodes: ["glossary"]
---

# Q: Commit approved plan, decisions, and glossary to docs/ and GLOSSARY.md

## Answer

Goal: Commit the approved plan, seven manager decisions, and agreed glossary. Inputs: Under $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5 read plan.md, glossary-proposed.md, the seven decision-*.md files, and plan-review-3.md. Copy each file byte for byte to the target path in plan.md section A. Out of scope: Application code, dependencies, plan.r2.md, review artifacts, and any text edits. Acceptance: Run every command in the code block of plan.md section A. Each command must exit 0. Report format: Annotate changed paths, commit, Graph state, and one TESTS line per command with its result.
STATUS: done.
FILES: GLOSSARY.md; docs/plans/local-mvp.md; docs/decisions/0003-mvp-scope.md; docs/decisions/0004-first-card.md; docs/decisions/0005-ollama-host.md; docs/plans/mvp-decisions/decision-walk-area.md; docs/plans/mvp-decisions/decision-search-completeness.md; docs/plans/mvp-decisions/decision-model-output.md; docs/plans/mvp-decisions/decision-reference-timing.md.
COMMIT: 433df7f.
GLOSSARY: The approved glossary adds Forest walk area and revises Edibility claim, Trip card, Fact block, Hard fact, and Soft advice.
Graph: fresh.
TESTS: git diff --check goal/c1ab3a20...HEAD: exit 0.
TESTS: cmp docs/plans/local-mvp.md against plan.md: exit 0.
TESTS: cmp GLOSSARY.md against glossary-proposed.md: exit 0.
TESTS: cmp docs/decisions/0003-mvp-scope.md against decision-mvp-scope.md: exit 0.
TESTS: cmp docs/decisions/0004-first-card.md against decision-first-card.md: exit 0.
TESTS: cmp docs/decisions/0005-ollama-host.md against decision-ollama-host.md: exit 0.
TESTS: cmp docs/plans/mvp-decisions/decision-walk-area.md against decision-walk-area.md: exit 0.
TESTS: cmp docs/plans/mvp-decisions/decision-search-completeness.md against decision-search-completeness.md: exit 0.
TESTS: cmp docs/plans/mvp-decisions/decision-model-output.md against decision-model-output.md: exit 0.
TESTS: cmp docs/plans/mvp-decisions/decision-reference-timing.md against decision-reference-timing.md: 

## Outcome

- Signal: useful

## Source Nodes

- glossary