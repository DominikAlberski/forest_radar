---
type: "query"
date: "2026-10-10T10:21:56.936947+00:00"
question: "Review round 3 of the BDL plan: source failure log D4 and new task order"
contributor: "graphify"
outcome: "useful"
---

# Q: Review round 3 of the BDL plan: source failure log D4 and new task order

## Answer

Goal: check the plan revision for goal c0e3a4e7. The PM and the user approved a scope change: one stderr line for each failed source request (BDL, OSM, model), with no personal data. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.r2.md (round 2 copy) and plan.md (revision). Read diff -u plan.r2.md plan.md. Check the new D4, the tasks L1 and L2, the task order, and the single owner of lib/app.rb at a time. Check that the privacy rule can be tested. Check that each source logs exactly once per failed call. The m1 and m6 fixes are also in the diff. Out of scope: D1 to D3, which were approved in round 2. Also out of scope: code edits and test runs. Acceptance: one verdict, approve or request changes. This is round 3 of 3. Report format: annotate 'VERDICT: approve|changes', then one line per finding with severity, file section, and fix.
VERDICT: changes. All findings are short text fixes to plan.md. The architect can apply them without a round 4. Task order and the single owner of lib/app.rb are correct: L2 lands before S2-2. The test scopes of S2-1 and L1 are disjoint. The m1 fix (43 s) and the m6 fix (rubocop in S2-1) are closed.
W1 warning, D4/L2 OSM wiring: lib/app.rb configure builds WalkAreas::Selector.new(trails: OSM::Client.new) with no log. The plan gives OSM::Client a log: keyword with the default 'no log', but it never says that App passes the source log in. Tests that replace settings.source_log do not reach the OSM client either, because configure builds that client once. Failure scenario: Overpass returns 504 in production, OSM::Client#relations returns nil, and no osm line reaches stderr. Fix: in D4, require configure to build OSM::Client.new(log: source_log) from the same SourceLog object. In L1, add one app-level test where the selector OSM path fails and gives one osm line, or a test that checks the wiring.
W2 warning, D4 privacy and line format: The plan does not handle line breaks or quotes in the message. JSON::ParserError messages repeat a part of the r

## Outcome

- Signal: useful