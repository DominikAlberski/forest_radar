---
type: "query"
date: "2026-10-10T10:53:35.233094+00:00"
question: "Review L1 tests and L2 source failure log on task/b8a9df9a"
contributor: "graphify"
outcome: "useful"
---

# Q: Review L1 tests and L2 source failure log on task/b8a9df9a

## Answer

Goal: review the source failure log work of goal c0e3a4e7. Inputs: run git diff goal/c0e3a4e7...task/b8a9df9a for L2 (lib/source_log.rb, lib/app.rb, lib/osm/client.rb, docs/plans/bdl-offset-pagination.md). L1 tests are on goal/c0e3a4e7: test/unit/app_log_test.rb and the SourceLog and OSM tests in commit eecde6e. Contract: settings.clock returns a Float monotonic time; lib code never calls .call on it. Check: the logged exception list, the elapsed_ms math, re-raise after logging, no secret or URL in log lines, OSM client logging, the card deadline from settings.clock. Out of scope: BDL pagination (task S2-2), code edits, test runs. Read the TESTS line in the b8a9df9a notes: 15 runs, 0 failures in the L1 files; remaining failures belong to S2-2. Acceptance: each finding cites file and line and has severity critical, warning, or minor. Report format: 'VERDICT: approve' or 'VERDICT: changes', then one line per finding.
VERDICT: approve. Graph: stale. TESTS: worker line read: 15 runs, 0 failures, 0 errors in the L1 files; full-suite failures belong to S2-2. Static: rubocop 1 offense, test/unit/app_log_test.rb:139 Metrics/ClassLength 103/100 (task d6673cd1 owns it); reek 0 warnings. Contract checks pass: lib/app.rb:80,113,121 read settings.clock as a value; no .call on settings.clock; elapsed_ms = ((now - started) * 1000).round; logged_source re-raises (lib/app.rb:117); OSM returns nil after the log (lib/osm/client.rb:28-31); one SourceLog object is shared (lib/app.rb:67-68).
W1 warning lib/app.rb:115-122 and lib/osm/client.rb:14,29: a failure inside SourceLog#write replaces the original error. Scenario: Puma stderr is a closed terminal pipe, so puts raises Errno::EPIPE. In OSM the error escapes relations and the card gives 500, not a card without trails. In App a BDL::Incomplete becomes SystemCallError, so the client gets the model 502 error. Fix: rescue StandardError around the write in log_failure in both files, and add a test with an IO that raises.
m1 minor lib/sourc

## Outcome

- Signal: useful