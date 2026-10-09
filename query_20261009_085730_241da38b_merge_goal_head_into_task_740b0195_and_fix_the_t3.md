---
type: "query"
date: "2026-10-09T08:57:30.761062+00:00"
question: "Merge goal head into task/740b0195 and fix the T3 review warnings in PLAN.md, README.md, data-sources.md"
contributor: "graphify"
outcome: "useful"
source_nodes: ["glossary", "plan", "readme", "docs_data_sources", "docs_model_and_prompts"]
---

# Q: Merge goal head into task/740b0195 and fix the T3 review warnings in PLAN.md, README.md, data-sources.md

## Answer

Goal: make task/740b0195 landable and apply the T3 review findings. Inputs: branch task/740b0195 (T3, approved). Review: $COORD_DIR/artifacts/c1ab3a20/t3-review.md. Start from task/740b0195. Merge goal/c1ab3a20 (head 81fd83b) into it. Then apply these fixes. W1: README.md:133 names only the hosts that the live suite calls. Check test/live first. W2: PLAN.md:139 adds one sentence: M4 changed on 2026-10-09 from the ban layer to trail crossing, see ADR 0007. M1: docs/data-sources.md:78 gets a heading 'Entry bans (removed)'. M2: the note links docs/decisions/0007-remove-entry-ban-check.md. Out of scope: ADR files, GLOSSARY.md, docs/plans/, lib/, test/. Acceptance: git merge-base --is-ancestor goal/c1ab3a20 HEAD exits 0. git grep -n -i -E 'ban layer|entry ban|no known ban' -- PLAN.md README.md docs/data-sources.md docs/model-and-prompts.md prints only the removal note and the M4 sentence. git grep -n mapserver -- README.md prints nothing. git diff --check passes. Report format: annotate one TESTS line per acceptance command, and the final commit hash.
Clarification: work on your own branch task/ca0393b9. If it starts from goal/c1ab3a20, merge task/740b0195 into it. The architect lands task/ca0393b9 and drops task/740b0195. The acceptance merge-base check applies to your branch.
STATUS: done. FILES: PLAN.md, README.md, docs/data-sources.md. Graph: fresh. Commit: 27e251e.
TESTS: git merge-base --is-ancestor goal/c1ab3a20 HEAD passed.
TESTS: git grep -n -i -E ban phrases printed only the removal section and M4 history.
TESTS: git grep -n mapserver -- README.md printed no matches.
TESTS: git diff --check passed.

## Outcome

- Signal: useful

## Source Nodes

- glossary
- plan
- readme
- docs_data_sources
- docs_model_and_prompts