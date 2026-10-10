---
type: "query"
date: "2026-10-10T17:04:00.073309+00:00"
question: "Write failing tests for D6 advice-only model answers in test/unit/model"
contributor: "graphify"
outcome: "useful"
source_nodes: ["test_live_ollama_live_test", "test_unit_model_validator_test"]
---

# Q: Write failing tests for D6 advice-only model answers in test/unit/model

## Answer

Goal: plan item M6a of goal 6c0f485d (D6, option B). The app shows the facts. The model writes only advice. Write failing tests for the new Validator rules. Inputs: start from goal/6c0f485d at 39a2d35 or later. Plan: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md, items M6 and M6a (lines about 127-147). Every rule there tagged r10 or r11 needs its test. Each invalid case asserts the exact Model::Invalid message. Tests call validate(answer, lines) with two arguments. Replace test_accepts_source_name_with_prohibited_words with a test that expects 'unsafe advice'. The raw-local-answer test expects 'fact line in advice'. Update invalid-response.json so that it still fails under D6. Out of scope: lib/, docs/, all other test files. Do not implement any rule. Do not copy the .env file. Acceptance: bundle exec rubocop test reports 0 offenses. ruby test/run.rb --unit exits non-zero. Every failing test is in your list of new or changed test names. Report format: annotate TESTS with counts, the list of failing test names, the files changed, and the commit sha.
STATUS: done. FILES: test/unit/model/validator_test.rb, test/unit/model/validator_line_endings_test.rb, test/unit/model/client_test.rb, test/fixtures/model/invalid-response.json, test/live/ollama_live_test.rb. TESTS: rubocop 61 files, 0 offenses; unit 209 tests, expected nonzero, 15 failures/errors in validator tests and none elsewhere. Failing tests: test_accepts_advice_only; test_discards_wrong_fact_block_before_advice_header; test_accepts_blank_lines_after_advice_header; test_accepts_mixed_case_header_with_trailing_whitespace; test_rejects_empty_advice; test_rejects_fact_line_in_advice_for_each_prefix_form; test_rejects_fakty_header_in_advice; test_rejects_second_wnioski_header_in_advice; test_accepts_inline_wnioski_header; test_accepts_inline_decorated_wnioski_header; test_rejects_unsafe_advice_in_discarded_text; test_raw_local_answer_is_rejected_for_fact_line_in_advice; test_rej

## Outcome

- Signal: useful

## Source Nodes

- test_live_ollama_live_test
- test_unit_model_validator_test