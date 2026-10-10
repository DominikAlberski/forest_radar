---
type: "query"
date: "2026-10-10T16:10:40.684134+00:00"
question: "Read the model config from the root .env file in lib/model and lib/app.rb"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_model_and_prompts", "lib_app"]
---

# Q: Read the model config from the root .env file in lib/model and lib/app.rb

## Answer

Goal: The app reads the local model config from the untracked .env file in the project root. This replaces config/model.local.yml. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md, sections Private address rule, D1 (revision 8, all env file rules and the rule order), D5, and task M5. Base: goal/6c0f485d at b846293. Current code: Model::Client.from_config with local_path and default_local_path in lib/model/client.rb. ForestRadar::App.build_model_client in lib/app.rb. Copy /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md to docs/plans/ollama-dev-fallback.md as the approved plan revision 8. Root .env: the main checkout may not have it yet. Copy it to your worktree root only after git check-ignore .env prints .env. Delete the copy after the live check. Never put the address on a command line, in a note, in a message, in a report, or in a commit. Stage files only by explicit path. Out of scope: .gitignore (it already ignores .env), config/model.yml, lib/card/, public/, test/system/, the validator and PROMPT (task M4b). Acceptance: (1) ruby test/run.rb --unit passes. (2) bundle exec rubocop lib test reports 0 offenses. (3) bundle exec reek lib reports 0 smells. (4) git check-ignore .env prints .env. (5) git ls-files .env prints nothing. (6) git grep -n local_path on your branch prints nothing in lib and test. (7) If the root .env exists: run one live card under coord with-lock ollama. Append the status, advice_mock, and elapsed time to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md without any URL. Otherwise write 'live check skipped: no root .env'. Report format: TESTS line with counts for checks 1-3, the result of checks 4-7, the list of changed files, and the branch name.
STATUS: done. FILES: .env.example, config/model.local.yml.example, docs/model-and-prompts.md, docs/plans/ollama-dev-fallback.md, lib/app.rb, lib/model/client.rb, lib/model/env_fi

## Outcome

- Signal: useful

## Source Nodes

- docs_model_and_prompts
- lib_app