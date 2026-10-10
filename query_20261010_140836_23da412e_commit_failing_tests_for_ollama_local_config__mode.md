---
type: "query"
date: "2026-10-10T14:08:36.029342+00:00"
question: "Commit failing tests for Ollama local config, model fallback, and advice_mock"
contributor: "graphify"
outcome: "useful"
source_nodes: ["test_test_helper"]
---

# Q: Commit failing tests for Ollama local config, model fallback, and advice_mock

## Answer

Goal: Finish and commit the M1 failing tests of goal 6c0f485d. Task ff4cea0b closed with no commit. Inputs: plan /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md item M1 and D1-D4. The uncommitted M1 work is in the tester-bot worktree: test/test_helper.rb, test/unit/model/client_test.rb, test/unit/card/, test/unit/repo_config_test.rb. Carry it to your new task branch. Add the missing M1 tests: Fallback, Stub, Advice.wrap, from_config local_path, test/unit/app_model_test.rb. Commit before coord done. Out of scope: lib/, config/, public/, test/system/, docs. Acceptance: git log goal/6c0f485d..HEAD shows your commit. bundle exec rubocop test reports 0 offenses. ruby test/run.rb --unit loads all files. New tests fail only for the missing behavior. Old tests keep their state. Report format: TESTS line with pass and fail counts, the list of new failing tests with the reason, the commit id.
TESTS: bundle exec rubocop test passed with 0 offenses. ruby test/run.rb --unit ran 246 tests: 232 passed, 14 expected errors, 0 assertion failures. New errors cover missing Model::Advice, Model::Fallback, local_path, open_timeout_s, advice_mock, and build_model_client APIs. Old tests passed. Graph: fresh. Commits: ad56401 and b737801.

## Outcome

- Signal: useful

## Source Nodes

- test_test_helper