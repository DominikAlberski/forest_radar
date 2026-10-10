---
type: "query"
date: "2026-10-10T17:07:20.006787+00:00"
question: "Review parallel BDL phase reads in lib/bdl on goal/cd5e1f57"
contributor: "graphify"
outcome: "useful"
---

# Q: Review parallel BDL phase reads in lib/bdl on goal/cd5e1f57

## Answer

Goal: review the parallel phase reads of goal cd5e1f57. Inputs: branch goal/cd5e1f57, commit 77cbfd0 against its parent. Read lib/bdl/phase_reads.rb, search_transport.rb, search_state.rb, client.rb, test/unit/bdl/client_search_parallel_test.rb. Check these points. One: the cap of 8 holds across collections and later pages, with no deadlock. Two: the first thread error stops the other threads and releases each slot. Three: the result does not depend on thread finish order. Four: each parallel read gets limit remaining, so one phase can fetch up to three times the budget before the raise. Judge if this is critical. Five: the deadline checks still apply. Out of scope: lib/app.rb, lib/http/, test runs. Acceptance: each finding names file, line, severity critical, warning, or minor. Report format: annotate VERDICT approve or changes, then the findings list.
VERDICT: changes. Graph: stale (graphify MCP down; dispatch CLI query only). Reviewed 77cbfd0 against f5610c8: client.rb, phase_reads.rb, search_state.rb, search_transport.rb, docs/plans/bdl-fetch-time.md, client_search_parallel_test.rb, client_search_coverage_test.rb. Also read page_reader.rb and page_state.rb at 77cbfd0. Worker TESTS line (task f762d2af): unit passed, RuboCop 0, Reek 0. Static analysis at 77cbfd0: rubocop lib/bdl test/unit/bdl reports 24 files with no offenses. reek lib/bdl reports 0 warnings.
Point 1 holds: SearchTransport (search_transport.rb lines 12-17) takes one slot per get and frees it in ensure. client.rb lines 49-51 give one SearchTransport per search to all first and later pages. No code holds a slot while it waits for another slot, so no deadlock.
Point 2 holds: phase_reads.rb line 50 raises the first error. The ensure on line 17 kills and joins each collection thread. Kill runs the ensure of PageWorkers.read (page_reader.rb line 48), which stops its page threads. It also runs the ensure of SearchTransport#get, which frees the slot.
Point 3 holds for results: phase_reads.rb line 45 builds

## Outcome

- Signal: useful