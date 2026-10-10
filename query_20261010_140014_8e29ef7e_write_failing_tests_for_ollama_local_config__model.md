---
type: "query"
date: "2026-10-10T14:00:14.757281+00:00"
question: "Write failing tests for Ollama local config, model fallback, and advice_mock"
contributor: "graphify"
outcome: "useful"
---

# Q: Write failing tests for Ollama local config, model fallback, and advice_mock

## Answer

Goal: Write failing tests for plan D1-D4 backend of goal 6c0f485d. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md section 'Tasks' item M1 and sections D1-D5. The M1 item lists each required test. Base: goal/6c0f485d (synced with main 57c4d11). Out of scope: lib/, config/, public/, test/system/, docs. Do not implement behavior. Acceptance: bundle exec rubocop test reports 0 offenses on your files. ruby test/run.rb --unit loads all files. New tests fail only for the missing behavior. Old tests keep their state. Report format: TESTS line with pass and fail counts, the list of new failing tests with the reason, the branch name.
MSG from tester: The requested D1-D4 tests target an implementation that is absent from this branch: goal/6c0f485d is based on 9e33439, while plan assumes c0e3a4e7 APIs including SourceLog and clock. Should M1 wait for c0f485d sync to c0e3a4e7?
STATUS: blocked. FILES: none. TESTS: not run. NOTES: Graph: fresh. Branch task/ff4cea0b includes goal commit 57c4d11, but lib/model/client.rb still lacks all D1-D4 interfaces. Asked architect whether to sync goal before M1; awaiting direction.
MSG from tester: I cannot write behavior tests against current target without guessing missing APIs, and cannot sync goal branch myself. Please update plan/base or confirm intended API and ask me to restart.

## Outcome

- Signal: useful