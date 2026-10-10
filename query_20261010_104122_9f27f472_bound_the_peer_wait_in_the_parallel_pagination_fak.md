---
type: "query"
date: "2026-10-10T10:41:22.073969+00:00"
question: "Bound the peer wait in the parallel pagination fake so a sequential reader fails fast"
contributor: "graphify"
outcome: "useful"
---

# Q: Bound the peer wait in the parallel pagination fake so a sequential reader fails fast

## Answer

Setup: run coord start-task 78002b63-e4dd-43be-b164-a18f31a79203 first. Goal: make the parallel pagination tests fail fast instead of hanging. Inputs: test/unit/bdl/client_parallel_pagination_test.rb from task 59296b4a (now on goal/c0e3a4e7). Problem: ConcurrentReplay#wait_for_peer loops on a 0.25 s wait while requests_seen is below 2. A sequential reader never sends a second request, so the loop never ends. Required behavior: the peer wait gives up after one fixed total time, at most 1 s. Then the request continues, and the maximum in flight stays 1, so the overlap assertion fails. Keep all current assertions. Out of scope: all other files, and lib/. Acceptance: ruby test/unit/bdl/client_parallel_pagination_test.rb ends in under 10 s on the goal head and fails only for the missing page_size and concurrency options. bundle exec rubocop test/unit/bdl/client_parallel_pagination_test.rb reports 0 offenses. Report format: annotate the commit SHA and 'TESTS: <n> runs, <f> failures, <e> errors, <seconds> s'.
STATUS: done. COMMIT: 6bb9ff70162afef87c8a25672de04060438f85fa. TESTS: ruby test/unit/bdl/client_parallel_pagination_test.rb: 2 runs, 1 failure, 1 error, 0.001 s; both stop at missing page_size/concurrency options. RuboCop: 0 offenses. Graph: stale.

## Outcome

- Signal: useful