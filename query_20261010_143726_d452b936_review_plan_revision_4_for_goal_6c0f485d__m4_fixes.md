---
type: "query"
date: "2026-10-10T14:37:26.201573+00:00"
question: "Review plan revision 4 for goal 6c0f485d: M4 fixes for d99c35cf"
contributor: "graphify"
outcome: "useful"
---

# Q: Review plan revision 4 for goal 6c0f485d: M4 fixes for d99c35cf

## Answer

Goal: Review plan revision 4 of goal 6c0f485d, round 2 of the M4 review. Inputs: run diff -u /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.r3.md /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md. Check only the open findings of task d99c35cf: W1, W2, W3, m1, m2, m3, m4. Out of scope: plan parts without a change. Do not edit files. Acceptance: for each finding state closed or open with the plan line. Name any new critical issue that the change itself causes. Report format: VERDICT approve or changes, then one line per finding.
VERDICT: changes. Graph: stale (MCP down; diff, goal/6c0f485d .gitignore, and the M2 task note read with the address redacted). TESTS: not run (plan review).
W1 OPEN in part, plan M4a line 'Address (W1)'. The M4a note and reports stay clean, and the tester deletes the file after the recording. But the line names the M2 task 11d0ff19 note as the place of the address. I checked: that note holds an http URL with a host and a port. This breaks the Private address rule ('no artifact holds the private LAN address'). Board notes are copied into dispatch prompts and memory. Fix: the PM or the user moves the address out of the board, for example into an ignored file in the main checkout. Then the plan names that file. Ask the PM to remove the address from note 11d0ff19, because a worker cannot edit a note.
W2 CLOSED, plan M4a line 'Raw answer test (W2)'. The test asserts validation on exact facts, else 'fact mismatch'. The architect decides before M4b.
W3 CLOSED, plan M4a line 'Recording method (W3)'. The recording goes through Model::Client with an http wrapper. The fixture uses the {message:{content}} shape plus the model name.
m1 CLOSED, plan D5 'Still rejected (m1)' and 'The returned advice holds no header decoration'.
m2 CLOSED, plan M4b Prompt keeps both safety sentences. R3 checks them.
m3 CLOSED, PROVENANCE.md records the facts and the PROMPT commit. The M4b live check record

## Outcome

- Signal: useful