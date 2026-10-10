---
type: "query"
date: "2026-10-10T14:26:12.094297+00:00"
question: "Set BDL default concurrency 8 and page size 1000 in lib/bdl"
contributor: "graphify"
outcome: "useful"
source_nodes: ["lib_bdl_page_reader", "lib_bdl_page_state"]
---

# Q: Set BDL default concurrency 8 and page size 1000 in lib/bdl

## Answer

Goal: Set the BDL default page concurrency to 8 and the default page size to 1000. Define both defaults in one place. The three lib/bdl files must agree. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/plan.md section T2 and note n2 (approved). /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/measurements.md: runs b and e took 24.72 s at concurrency 8, page size 1000. /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/probe.rb for the live run. Base: goal/cd5e1f57 at 57c4d11. Constraints: keep the count check, the deadline check, retries 2 in the default transport, and the 60 s budget. Page size must stay at most 3000. docs/plans/bdl-fetch-time.md holds the plan and the measurement table. The doc states that its numbers replace the ADR 0009 timing figure. Out of scope: radius, search options, lib/app.rb, lib/http/, the card deadline, ADR files, GLOSSARY.md. Acceptance: 'ruby test/run.rb --unit' passes. 'bundle exec rubocop' reports 0 offenses. 'bundle exec reek' reports 0 warnings. A unit test covers the new defaults and concurrency 8. One live Warsaw run with probe.rb and the new defaults, under the probe rules, finishes in 25 s or less. The margin is small: 24.72 s. If the live run exceeds 25 s, commit nothing more and report the time. Do not tune other values. Report format: TESTS line, rubocop and reek counts, the measured Warsaw time, the stop sign or none, the commit hash.
STATUS: blocked. TESTS: unit passed; scoped RuboCop 0 offenses; Reek 0 warnings. Global RuboCop has 7 existing offenses. Live Warsaw took 26.57 s with no stop sign. No commit exists. Graph: fresh.
MSG from backend-developer: The live Warsaw run took 26.57 s with the new defaults. The 25 s acceptance limit failed. I made no commit. Unit tests, scoped RuboCop, and Reek passed. Please decide the next step.
MSG from architect: Commit the current T2 work on task/eb679ad4 now. Include the doc and the unit te

## Outcome

- Signal: useful

## Source Nodes

- lib_bdl_page_reader
- lib_bdl_page_state