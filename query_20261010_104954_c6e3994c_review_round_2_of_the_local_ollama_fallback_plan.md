---
type: "query"
date: "2026-10-10T10:49:54.263117+00:00"
question: "Review round 2 of the local Ollama fallback plan"
contributor: "graphify"
outcome: "useful"
---

# Q: Review round 2 of the local Ollama fallback plan

## Answer

Goal: check that plan revision 2 of goal 6c0f485d closes the open findings of review ef6e4ef7. Inputs: run diff -u on $COORD_DIR/artifacts/6c0f485d/plan.r1.md and plan.md. Run diff -u on glossary-draft.r1.md and glossary-draft.md. The findings are the notes on task ef6e4ef7. plan.r1.md has the private address replaced by a placeholder. Code reference: goal/c0e3a4e7. Out of scope: new topics outside the open findings, code edits, test runs. Acceptance: each finding C1, C2, W1-W6, m1-m5 gets closed or open with the plan line. Report format: annotate 'VERDICT: approve' or 'VERDICT: changes', then one line per finding.
VERDICT: approve. All 13 findings from review ef6e4ef7 are closed. One minor note comes from the m1 fix.
C1 closed: the 'Private address rule' section and D1 docs line use the placeholder http://localhost:11434. A grep of the artifact folder finds no private address in plan.md or glossary-draft.md. plan.r1.md line 45 still holds the generic prefix '192.168' but not the address. It is an artifact and is not committed.
C2 closed: D4 Model::Advice.wrap turns a String into mock false. So the String fakes in test/system/support/fixtures.rb:94-98 and test/unit/app_log_test.rb:71 stay valid without a scope change.
W1 closed: the D2 list now has SocketError and OpenSSL::SSL::SSLError. M1 tests SocketError. The 500 gap without fallback is listed as a known gap.
W2 closed: D3 states about 6 s for two connect attempts.
W3 closed: D1 names from_config(path, local_path:, http:, log:, clock:). D3 names Model::Client.new(url, model, http:, open_timeout_s: 3). D4 names Card::Builder#build(facts:, advice:, advice_mock:, lat:, lon:).
W4 closed: the M1 repo check builds the needle at runtime, reads git ls-files, and skips with a reason when git is missing.
W5 closed: the Sequencing section and M3 say that M3 starts after M2 lands.
W6 closed: D2 App.build_model_client passes log: settings.source_log and a clock lambda that reads settings.clock. This matches the lesson that s

## Outcome

- Signal: useful