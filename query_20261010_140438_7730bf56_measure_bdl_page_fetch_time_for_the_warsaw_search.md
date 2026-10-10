---
type: "query"
date: "2026-10-10T14:04:38.084281+00:00"
question: "Measure BDL page fetch time for the Warsaw search at concurrency 4 and 8"
contributor: "graphify"
outcome: "useful"
---

# Q: Measure BDL page fetch time for the Warsaw search at concurrency 4 and 8

## Answer

Goal: Measure the BDL fetch time of the Warsaw search before any code change. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/plan.md sections 'Probe rules' and 'T1' (approved). Base: goal/cd5e1f57 at 57c4d11. Load lib/ from your task worktree. Write the probe to /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/probe.rb. Runs: a, b, c, d, e as the plan lists. Run d only if the projected size of a 3000 page stays under 8 MiB. Projected size = bytes per feature in run c x 3000. Stop all runs at the first stop sign. Out of scope: every repository file. Make no commit. Do not change the radius or other search options. Acceptance: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/measurements.md holds one row per run with the plan fields, the stop sign if any, and a recommendation. Report format: annotate the table summary, the stop sign or none, and the recommended setting or 'none meets 25 s on two runs'. TESTS: none (measurement only).
STATUS: done. TESTS: none; measurement only. Runs: a 30.82 s, b 24.72 s, c 30.28 s, e 24.72 s. Run d skipped because c exceeded 8 MiB. Stop sign: none. Recommend concurrency 8 and page size 1000. Graph: fresh.

## Outcome

- Signal: useful