---
type: "query"
date: "2026-10-09T01:33:15.177342+00:00"
question: "Fix live test assertions and README test instructions in test/live and README.md"
contributor: "graphify"
outcome: "useful"
source_nodes: ["readme"]
---

# Q: Fix live test assertions and README test instructions in test/live and README.md

## Answer

Goal: Make the live tests prove their named facts and make README test steps correct. Inputs: Branch goal/c1ab3a20 at 75bd595. Read D-R3, D-R4, D-R5, D-R7, and D-R8 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/d-review.md. D-R3: mark the Polish regex as a smoke check. Record that live M5 needs a human language review. D-R4: label the first request state unknown unless residency is checked. Print EVIDENCE after the assertions, with both answers and the rejection results. D-R5: README must separate fatal BDL failures from unavailable trail or ban evidence. Describe the empty-area card. D-R7: give a standalone system command without coord. Show the coord commands separately with setup. Show the full locked live command. D-R8: assert the region code, the live range and district names, and box count against returned stands. Ban note: the live ban source returns HTTP 400 today (task fb7a8d81). The live M4 test must accept 'unknown' and record the source failure as evidence, not as a pass of a known ban status. Update docs/plans/m1-m7-evidence.md for L2 with this state. Out of scope: test/system/, test/unit/, product code, dependencies. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Run 'bundle exec ruby -c' on each changed Ruby file. Run the BDL live test one time if the network is up, and report its result. Report format: Annotate changed paths, commit, Graph state, the live test result, and a TESTS line with all results.
STATUS: done. FILES: test/live/bdl_live_test.rb, test/live/ollama_live_test.rb, README.md, docs/plans/m1-m7-evidence.md. COMMIT: 6f8070e. TESTS: unit pass; git diff --check pass; ruby -c OK on both live files; BDL live run 4 runs, 1 fail: names test expects 'Podkowa Leśna' but facts give 'brak danych' (L1 product defect, fix not on this branch); ban test records unknown evidence; region, count tests pass. NOTES: Ollama live not run (no end

## Outcome

- Signal: useful

## Source Nodes

- readme