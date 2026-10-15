---
type: "query"
date: "2026-10-10T17:19:53.070019+00:00"
question: "Review the D6 validator and prompt change in commit 3656677"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the D6 validator and prompt change in commit 3656677

## Answer

Goal: review commit 3656677 on goal/6c0f485d (D6: the app shows facts, the model gives advice only). Inputs: git show 3656677. Files: lib/model/validator.rb, lib/model/client.rb, docs/model-and-prompts.md, docs/decisions/0012-app-shows-facts.md, docs/plans/ollama-dev-fallback.md, test/unit/model/validator_test.rb. Worker TESTS line: ruby test/run.rb --unit passed. Focus 1: the validator scans the whole answer for unsafe phrases. Focus 2: the PROMPT sentences match the docs. Focus 3: no fact line reaches the advice text. Focus 4: the validator does not check an address by count only. Out of scope: M6a test files, live Ollama checks, the later-minors list. Acceptance: each finding cites file, line, and severity (critical, warning, minor). Report format: annotate VERDICT approve or changes, then the findings list.
VERDICT: approve. Commit 3656677 against its parent. TESTS: the worker TESTS line is present and reports pass. Graph: fresh. Static analysis at 3656677: rubocop reports 0 offenses on the 3 Ruby files, and reek reports 0 warnings. Focus 1 holds: validator.rb line 44 scans the whole normalized answer before it extracts the advice. Focus 2 holds: PROMPT in client.rb lines 17-19 is equal to the docs block at docs/model-and-prompts.md line 98. Both safety sentences are verbatim. Focus 3 holds for the specified fact-line forms, with the gaps m1 and m2 below. Focus 4 holds: the private address count in the diff is 0. The check order matches the plan: unsafe, empty, fact line, header. FINDINGS: W1 warning, test/unit/model/validator_test.rb lines 18-19 and 29-40: the M6b commit adds 2 constants and 3 tests to an M6a test file. The M6b scope excludes test files, and the plan says 'Do not change the M6a tests'. The commit TESTS line says the M6a files have no diff, which is not true for this file. Fix: the architect accepts the added tests or moves them to a tester task. m1 minor, lib/model/validator.rb line 23 FACT_LINE: a leading backtick is not matched. Failure scena

## Outcome

- Signal: useful