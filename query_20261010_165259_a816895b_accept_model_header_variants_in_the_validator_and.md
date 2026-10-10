---
type: "query"
date: "2026-10-10T16:52:59.253997+00:00"
question: "Accept model header variants in the Validator and state the exact format in PROMPT"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts", "lib_model_validator"]
---

# Q: Accept model header variants in the Validator and state the exact format in PROMPT

## Answer

Goal: plan item M4b of goal 6c0f485d, rule D5. Inputs: goal/6c0f485d at a0a9c4b, which holds the M4a tests and test/fixtures/model/raw-local-answer.json. Plan /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md lines 108-114 and 123-125. In lib/model/client.rb change only the PROMPT constant. Do not change the M4a tests. Architect decision on the M4a fact difference: the raw answer dropped WNIOSKI and invented the fact line F2 grzyby_znalezione=10. The fact check stays exact. Do not loosen it. The new PROMPT must show the exact output skeleton with bare FAKTY and WNIOSKI lines. It must say: copy each fact line exactly, add no new fact lines, use no markdown, and put no text before FAKTY. Keep the two safety sentences unchanged. Live check: follow plan line 125. Run git check-ignore .env first, then copy the root .env. Never put the address on a command line, in a note, in a message, or in live-check.md. Delete the copy after the check. If no try gives advice_mock false, report each header form and each fact difference. Do not change the Validator further. The architect then decides. Out of scope: lib/model/fallback.rb, lib/model/env_file.rb, lib/card/, lib/app.rb, all test files, the rest of client.rb. Acceptance: ruby test/run.rb --unit passes. bundle exec rubocop lib test and bundle exec reek lib report 0. The live check result is appended to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md. Report format: TESTS line with counts, the live check result per try (header form, fact difference, error class, advice_mock), a count-only address check of the branch diff, the commit sha.
STATUS: blocked. FILES: lib/model/validator.rb, lib/model/client.rb, docs/model-and-prompts.md. TESTS: unit suite passed; RuboCop 0 offenses; Reek 0 warnings. LIVE: no tries; the existing live test omits raw headers and fact differences. ADDRESS: branch diff contains 0 address values by inspection. GRAPH: fresh. COMM

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts
- lib_model_validator