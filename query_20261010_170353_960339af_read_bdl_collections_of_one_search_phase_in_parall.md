---
type: "query"
date: "2026-10-10T17:03:53.780074+00:00"
question: "Read BDL collections of one search phase in parallel under one cap of 8 in lib/bdl"
contributor: "graphify"
outcome: "useful"
source_nodes: ["lib_bdl_search_state", "test_unit_bdl_client_search_coverage_test"]
---

# Q: Read BDL collections of one search phase in parallel under one cap of 8 in lib/bdl

## Answer

Goal: The user chose option A. Read the first pages of all collections of one search phase in parallel threads. Phase 1 is rdlp, nadlesnictwa, and lesnictwa. Phase 2 is the stand collections that the regions select. Phase 2 starts after the coverage check, as now. One shared cap of 8 concurrent requests applies to all requests of one search. The cap is not per collection. Later pages join the same cap. Inputs: base goal/cd5e1f57 at f5610c8, which already has concurrency 8 and page size 1000. Read lib/bdl/search_state.rb, page_reader.rb, client.rb. /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/plan.md section 'Probe rules'. /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/measurements.md run b: area first pages take about 4.5 s each in sequence. /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/cd5e1f57/probe.rb for the live run. Constraints: keep the total item budget of 100000 for one search. Keep the count check, the 60 s deadline, the deadline checks, retries 2, and page size 1000. The first error in any thread stops all other threads and raises Incomplete, as now. The result must not depend on thread finish order. Client#features must keep its current behavior for single calls. Append a section for option A with the new measurements to docs/plans/bdl-fetch-time.md. Out of scope: lib/app.rb, lib/http/, the radius, search options, the card deadline, ADR files, GLOSSARY.md. Acceptance: 'ruby test/run.rb --unit' passes. 'bundle exec rubocop lib/bdl test/unit/bdl' reports 0 offenses. 'bundle exec reek lib/bdl' reports 0 warnings. New unit tests show: the cap of 8 holds across collections; phase 1 first pages overlap; the 100000 budget still raises; one failing collection stops the search. Live: run probe.rb on Warsaw (lat 52.078247, lon 21.040624, radius 20 km) under the probe rules, at most 3 runs. Each run must finish in 20 s or less. Stop at the first stop sign, for example HTTP 429, HTTP

## Outcome

- Signal: useful

## Source Nodes

- lib_bdl_search_state
- test_unit_bdl_client_search_coverage_test