---
type: "query"
date: "2026-10-09T08:56:34.986649+00:00"
question: "Update docs and glossary, add ADR 0007 for the ban removal"
contributor: "graphify"
outcome: "corrected"
correction: "A task that runs in parallel with another task must merge the goal head before it lands. coord land refuses a branch that lacks the goal head."
source_nodes: ["glossary", "plan", "readme", "docs_data_sources", "docs_model_and_prompts"]
---

# Q: Update docs and glossary, add ADR 0007 for the ban removal

## Answer

Goal: document the removal of the entry ban check. Follow section T3 of $COORD_DIR/artifacts/398bd3c9/plan.md. Inputs: goal/c1ab3a20 at ce87c07. Commit plan.md as docs/plans/remove-ban-check.md. Commit $COORD_DIR/artifacts/398bd3c9/decision-remove-ban-check.md as docs/decisions/0007-remove-entry-ban-check.md. Apply $COORD_DIR/artifacts/398bd3c9/glossary-draft.md to GLOSSARY.md: change the 'Forest walk area' definition, keep 'Zakaz wstępu do lasu'. Remove the ban layer from PLAN.md, README.md, and docs/data-sources.md. Add a removal note with the reason in docs/data-sources.md. Drop the ban layer reference at docs/model-and-prompts.md:146. Out of scope: lib, test, public, config. Also out of scope: docs/plans/local-mvp.md, m1-m7-evidence.md, mvp.md, mvp-decisions/, docs/decisions/0001 to 0006, docs/blog-outline.md, docs/roadmap.md, docs/session-log.md. Acceptance: 1. git grep -n -i -E 'ban layer|entry ban|no known ban' -- PLAN.md README.md docs/data-sources.md docs/model-and-prompts.md prints only the removal note. 2. git diff --check passes. Report format: annotate one line TESTS: <command> -> <result> for each acceptance command, plus the list of changed files.
STATUS: done. Graph: fresh. Changed: PLAN.md, README.md, docs/data-sources.md, docs/model-and-prompts.md, GLOSSARY.md, docs/decisions/0007-remove-entry-ban-check.md, docs/plans/remove-ban-check.md.
TESTS: git grep -n -i -E 'ban layer|entry ban|no known ban' -- PLAN.md README.md docs/data-sources.md docs/model-and-prompts.md -> pass; only removal note.
TESTS: git diff --check -> pass.

## Outcome

- Signal: corrected
- Correction: A task that runs in parallel with another task must merge the goal head before it lands. coord land refuses a branch that lacks the goal head.

## Source Nodes

- glossary
- plan
- readme
- docs_data_sources
- docs_model_and_prompts