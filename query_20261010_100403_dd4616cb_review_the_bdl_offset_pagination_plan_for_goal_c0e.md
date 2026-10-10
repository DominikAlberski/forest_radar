---
type: "query"
date: "2026-10-10T10:04:03.770067+00:00"
question: "Review the BDL offset pagination plan for goal c0e3a4e7"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the BDL offset pagination plan for goal c0e3a4e7

## Answer

Goal: review the plan in $COORD_DIR/artifacts/c0e3a4e7/plan.md. Inputs: the plan, diagnosis.md, pagination.md, and offsets.md in the same folder. Read lib/bdl/page_state.rb, lib/bdl/page_reader.rb, lib/bdl/client.rb, lib/app.rb, and lib/http/transport.rb on main. Check that D1 to D4 fix the live failure. Check that D2 is thread safe with HTTP::Transport. Check that task scopes are disjoint and in the right order. Out of scope: code edits and test runs. Acceptance: one verdict, approve or request changes. Report format: annotate 'VERDICT: approve|changes', then one line per finding with severity critical, warning, or minor and the plan section.
VERDICT: changes. Graph: stale. D1 to D4 fix the live failure. D2 is thread safe with HTTP::Transport. The findings are gaps in the contract between the tester and the developer. TESTS: not run, the review scope excludes test runs.
W1 warning, S2-1/D2: The plan lists no test for D2. Add tests for at most 4 requests in flight, for the first error that stops the read, and for no live thread after the read. Failure scenario: a sequential fix passes every S2-1 test, and Warsaw stays at about 55 s of the 60 s budget.
W2 warning, S2-1/D2: The Replay fake in test/unit/bdl/client_pagination_test.rb:17-20 returns bodies in call order through @bodies.shift. Parallel requests reach shift in a random order. Failure scenario: the offset 2 thread gets the offset 1 body, and the three-page test fails at random. Fix: tell the tester to key fake bodies by params offset, or let tests set the concurrency to 1.
W3 warning, D1: The plan says 'through the constructor' but names no keyword. The page size passes from Client.new to PageReader and then to PageState.start. Failure scenario: the tester writes BDL::Client.new(page_size: 1), the developer adds it to PageReader only, and S2-2 must edit test files outside its scope. Fix: name the API in the plan, for example BDL::Client.new(transport:, clock:, page_size: 1000).
W4 warning, D3/S2-1: lib/app.r

## Outcome

- Signal: useful