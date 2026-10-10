---
type: "query"
date: "2026-10-10T17:13:16.853685+00:00"
question: "Implement D6 advice-only validation in lib/model/validator.rb and the PROMPT"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts", "lib_model_validator", "test_live_ollama_live_test", "test_unit_model_validator_test"]
---

# Q: Implement D6 advice-only validation in lib/model/validator.rb and the PROMPT

## Answer

Goal: plan item M6b of goal 6c0f485d. Implement D6. The app shows the facts. The model writes only advice. Inputs: start from branch task/36142a1e at c1d8f92. That branch holds the M6a failing tests. Plan: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md, items M6 and M6b. Change in lib/model/client.rb only the PROMPT constant. Keep both safety sentences verbatim. Do not change or delete any M6a test. Add only these tests to validator_test.rb. One: each M4 WNIOSKI header variant validates and returns undecorated advice: WNIOSKI, WNIOSKI:, **WNIOSKI**, **WNIOSKI:**, ## WNIOSKI, wnioski:. Two: each M4 FAKTY variant and an inline '**WNIOSKI:** text' line after the advice raise 'header in advice'. Three: an answer with an unsafe phrase and a fact line raises 'unsafe advice'. ADR 0012 text. Title: The application shows the facts; the model writes only advice. Body: The local model often omits, changes, or adds fact lines, so a fact check rejected most answers. The app now shows the facts from its own fact block, and the Validator checks only the advice for safety, fact lines, and headers. Free advice prose can still name a wrong number; the card shows facts and advice in separate sections. Docs: follow the M6b Docs rules in the plan. Out of scope: all other lib files, all other test files, GLOSSARY.md, docs/configuration.md. Never write the private address or any URL in a file or a note. Acceptance: ruby test/run.rb --unit passes. bundle exec rubocop lib test reports 0 offenses. bundle exec reek lib reports 0 warnings. Live check: follow the M6b live check in the plan exactly, 5 cards under coord with-lock ollama. The count is information, not a gate. Append the results to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md. Report format: annotate TESTS line, rubocop and reek counts, the count of cards with advice_mock false out of 5, per card the error class and header form, the commit sha.
STAT

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts
- lib_model_validator
- test_live_ollama_live_test
- test_unit_model_validator_test