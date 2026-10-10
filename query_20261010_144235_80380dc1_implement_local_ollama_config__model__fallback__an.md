---
type: "query"
date: "2026-10-10T14:42:35.717074+00:00"
question: "Implement local Ollama config, Model::Fallback, and advice_mock in lib/model and lib/app.rb"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts", "lib_app", "lib_card_builder"]
---

# Q: Implement local Ollama config, Model::Fallback, and advice_mock in lib/model and lib/app.rb

## Answer

Goal: Implement plan items D1-D4 backend so that the M1 tests pass. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md items D1-D4 and M2 (approved). Base: goal/6c0f485d at 4a5c97e. That commit holds the M1 failing tests from task e015f100. Private address for the live check only: http://<private-address>:11434. Never write this address into a tracked file, a commit, or an artifact. Out of scope: test/, public/, config/locales/, config/model.yml, GLOSSARY.md, ADR files. Do not change the M1 tests. Ask the architect if a test looks wrong. Acceptance: 'ruby test/run.rb --unit' passes with 0 errors and 0 failures. 'bundle exec rubocop lib test' reports 0 offenses. 'bundle exec reek lib' reports 0 warnings. Live check under 'coord with-lock ollama --' with an ignored config/model.local.yml: one card with the server online gives advice_mock false. One card with an unreachable url gives advice_mock true and exactly one log line. Write both results to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md without any URL. Delete config/model.local.yml after the check. Commit before coord done. Report format: TESTS line with counts, rubocop and reek counts, the live check result, the commit id.
MSG from backend-developer: M2 start-task succeeded, but coord show lists no worker. The dispatcher forbids claiming tasks. Please assign M2 to this worker. An old client test expects a String from generate, while M1 requires Model::Advice. Please confirm whether equality compatibility is required or the test needs correction.
Owner: backend-developer-bot. The architect cannot assign or claim. The worker keeps working on task/11d0ff19. Scope addition: test/unit/model/client_test.rb, the old assertion near line 73 only. No other task owns this file now.
MSG from architect: Decision for M2. Continue on task/11d0ff19. The architect has no command to assign a worker. The task note records you as owner. The old test

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts
- lib_app
- lib_card_builder