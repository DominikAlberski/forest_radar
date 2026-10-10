---
type: "query"
date: "2026-10-10T14:35:37.680715+00:00"
question: "Review plan revision 3 for goal 6c0f485d: M4 model answer format"
contributor: "graphify"
outcome: "useful"
---

# Q: Review plan revision 3 for goal 6c0f485d: M4 model answer format

## Answer

Goal: Review plan revision 3 of goal 6c0f485d. Check only the new M4 part (D5, M4a, M4b, R3). Inputs: run diff -u /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.r2.md /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md. Context: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md. The user chose option A: record one raw model answer, tighten the prompt, accept small header variants. Check that scopes are disjoint from M2 and M3. Check that the safety and fact checks stay strict. Check that the private address never reaches a fixture or an artifact. Out of scope: plan parts that revision 2 already approved. Do not edit files. Acceptance: each finding names the plan line and a severity (critical, warning, minor). Report format: VERDICT approve or changes, then the findings list.
VERDICT: changes. Graph: stale (MCP down; diff, live-check.md, and goal/6c0f485d lib/model read). TESTS: not run (plan review). Scopes: M4a (test/fixtures/model/raw-local-answer.json, PROVENANCE.md, test/unit/model/validator_test.rb) is disjoint from M2 (lib/model/, lib/app.rb, lib/card/builder.rb, docs, .gitignore) and M3. M4b overlaps the M2 paths lib/model/ and docs/model-and-prompts.md, but the plan starts M4b after M2 lands, so one writer per path holds. Safety: D5 keeps PROHIBITED, ACCESS, and the exact fact compare. Text before FAKTY stays rejected.
W1 warning, plan M4a line 'The M4a task note holds the private address for the recording only'. A task note is persistent board data. coord show, annotations, dispatch context, and graphify memory and LESSONS digests copy task text. This breaks the Private address rule ('no artifact holds the private LAN address'). Failure scenario: a later dispatch prints the M4a note with the LAN address into another worker prompt or a memory file. Fix: the user or the PM writes the ignored config/model.local.yml in the M4a worktree (or exports an ENV

## Outcome

- Signal: useful