---
type: "query"
date: "2026-10-10T11:40:07.988999+00:00"
question: "Review the parallel BDL page reader and card deadline fix on task/38977b1d"
contributor: "graphify"
outcome: "useful"
---

# Q: Review the parallel BDL page reader and card deadline fix on task/38977b1d

## Answer

Goal: Review the lib/ fix on branch task/38977b1d against goal/c0e3a4e7. Inputs: git diff goal/c0e3a4e7...task/38977b1d -- lib/. Read $COORD_DIR/artifacts/c0e3a4e7/plan.md and review-followups.md. Check findings W1, W2, m1, m2, m4, m7. Check that read raises on the first error. Check that no worker starts a new offset after an error. Check that every worker thread is stopped and joined. Check that the card deadline starts after the search in lib/app.rb. Out of scope: the test file test/unit/bdl/client_parallel_pagination_test.rb. Its W2 test fake is invalid and has a separate fix. Out of scope: result_builder.rb speed. Acceptance: each finding cites file and line in lib/. Read the TESTS line on task 38977b1d. Do not run tests. Report format: VERDICT approve or changes. Then CRITICAL, WARNING, MINOR lists with file:line and one sentence each.
VERDICT: approve. Graph: fresh. TESTS: worker line read on 38977b1d: W1 1 run, pagination 13 runs, client 3 runs, all 0 failures, 0 errors. Static: rubocop 0 offenses, reek 0 warnings. Closed: W1 (workers rescue StandardError at lib/bdl/page_reader.rb:71-73, so join at :28 no longer re-raises; every thread is killed and joined in the ensure at :47-48). W2 (the first error enters the response Queue at :33 and the caller raises it at :83; PageOffsets.stop at :18-20 makes take return nil, so no worker starts a new offset after an error). m1 (report_on_exception is set inside the block at :62). m2 (pages Hash is written only in the caller thread at :86; the Queue carries results). m4 (no ThreadError control flow; take returns nil). m7 (each page is validated on arrival at :85). Card deadline starts after the search at lib/app.rb:84 and reads settings.clock as a value.
CRITICAL: none.
WARNING: none.
MINOR:
- lib/bdl/page_reader.rb:71 with :77,82: a worker that dies from a non-StandardError (for example SystemStackError) pushes nothing, so responses.pop waits forever; push the error tuple from an ensure or rescue Exception, or bound p

## Outcome

- Signal: useful