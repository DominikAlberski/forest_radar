---
type: "query"
date: "2026-10-10T16:34:20.476249+00:00"
question: "Record one raw local model answer and write failing validator tests"
contributor: "graphify"
outcome: "useful"
source_nodes: ["test_unit_model_validator_test"]
---

# Q: Record one raw local model answer and write failing validator tests

## Answer

Goal: plan item M4a of goal 6c0f485d. Record one raw answer from the local model and write failing validator tests. Inputs: goal/6c0f485d at ac2ad4f. Plan /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md lines 115-122 (item M4a), rule D5, and the Private address rule. Fixture shape: test/fixtures/model/valid-response.json. Address source: the root .env of the main checkout is the only source. Run git check-ignore .env in your worktree first. Stop and report if it prints nothing. Then copy the root .env to the root of your worktree. Never put the address on a command line, in an annotation, in a message, or in a report. Stage files only by explicit path. Never use git add -A or git add dot. Delete the copied .env after the recording. Recording: call Model::Client under coord with-lock ollama with facts that hold F1. Inject an http: wrapper that saves the raw response body. Keep request_body and PROMPT unchanged. The fixture holds the message content and the model name only. It holds no URL, host, IP address, timing, or created_at. PROVENANCE.md records the date, the model name, the facts sent, and the PROMPT commit. Tests: each accepted header variant validates. Each rejected case raises Model::Invalid. Raw answer test: follow plan rule W2 on fact lines. Out of scope: lib/, other test files, docs, UI files. Acceptance: bundle exec rubocop on the changed files reports 0 offenses. ruby test/run.rb --unit runs. The new tests fail only for the missing variants. The old tests keep their state. Before coord done, run a count-only check: the address count in your three files and in git log -p of your branch is 0. Report format: TESTS line with counts and the failing test names, the exact header form of the raw answer, any fact line difference, the address count, the commit sha.
STATUS: done. FILES: test/fixtures/model/raw-local-answer.json, test/fixtures/model/PROVENANCE.md, test/unit/model/validator_test.rb. TESTS: RuboCop passed with ze

## Outcome

- Signal: useful

## Source Nodes

- test_unit_model_validator_test