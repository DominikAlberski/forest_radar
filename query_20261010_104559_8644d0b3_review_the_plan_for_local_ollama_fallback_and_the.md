---
type: "query"
date: "2026-10-10T10:45:59.471304+00:00"
question: "Review the plan for local Ollama fallback and the mock marker"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the plan for local Ollama fallback and the mock marker

## Answer

Goal: review the stage 1 plan of goal 6c0f485d. Inputs: $COORD_DIR/artifacts/6c0f485d/plan.md and glossary-draft.md. Read the code on goal/c0e3a4e7: lib/model/client.rb, lib/app.rb, lib/card/builder.rb, public/app.js, config/model.yml, .gitignore. Check that the scopes are disjoint and the task order is correct. Check that the private address never enters a committed file. Check the D4 contract and the decision to show the marker in production. Check the glossary terms for vagueness or duplicates. Out of scope: code edits, test runs, goal c0e3a4e7 itself. Acceptance: every finding names the plan section and the code file and line. Report format: annotate 'VERDICT: approve' or 'VERDICT: changes', then findings marked critical, warning, or minor.
VERDICT: changes. Graph: stale. I read the code on goal/c0e3a4e7 (head 5c60fe6).
C1 critical, plan D1 and M2 scope, docs/model-and-prompts.md: D1 tells M2 to write 'set url: http://<private-address>:11434' into docs/model-and-prompts.md, which is a committed file. This conflicts with the D1 rule 'Only the developer's machine holds that address' and with the M1 repo check 'no committed file holds 192.168'. Failure scenario: M2 follows D1 and commits the private address, and then the M1 repo test fails. Fix: the docs say 'set url to the address of your Ollama host' with the placeholder http://localhost:11434. Also remove the address from plan.md, because a later task can commit the plan to docs/plans as in goal c0e3a4e7 S2-0.
C2 critical, plan D4 and the M1/M2 scopes, test/system/support/fixtures.rb:94-98 and test/unit/app_log_test.rb:71,181: these model fakes return a String. After D4, lib/app.rb:86-87 reads advice.text and advice.mock. Neither file is in the M1 or the M2 scope. Failure scenario: M2 lands, and every system card test and every app_log test raises NoMethodError, so the app returns HTTP 500. M2 cannot pass 'ruby test/run.rb --unit', and the merge suite fails. Fix: add test/unit/app_log_test.rb, test/unit/app_test.rb 

## Outcome

- Signal: useful