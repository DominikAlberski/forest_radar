---
type: "query"
date: "2026-10-10T10:54:59.924652+00:00"
question: "Bring L2 onto goal head and guard SourceLog write failures in lib/app.rb and lib/osm/client.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Bring L2 onto goal head and guard SourceLog write failures in lib/app.rb and lib/osm/client.rb

## Answer

Goal: make the L2 work landable and close review warning W1. Inputs: branch task/b8a9df9a (commits 3dd4f8b, 454c426, reviewed and approved in 86cd90c7). Goal head 1a3fc1a has d6673cd1, which task/b8a9df9a lacks. Step 1: merge task/b8a9df9a into your task branch. Your branch starts from the goal head. Step 2 (W1): a failure inside SourceLog#write must never replace the original error. Example: puts raises Errno::EPIPE on a closed stderr. In lib/app.rb log_failure and in the OSM client log path, rescue StandardError around the write only. Then keep the original behavior: App re-raises the original error, and OSM returns nil. Add one test per file with an IO that raises on write. Out of scope: lib/bdl/, other review minors (m1-m6, t1-t2), every other file. Acceptance: ruby -Itest test/unit/app_log_test.rb, test/unit/source_log_test.rb and test/unit/osm/client_log_test.rb pass. bundle exec rubocop on the changed files reports 0 offenses. bundle exec reek lib/app.rb lib/osm/client.rb lib/source_log.rb reports 0 warnings. Report format: commit SHAs, 'TESTS: <n> runs, <f> failures, <e> errors' for the three files, rubocop and reek results.
STATUS: done. COMMITS: 4d09606, 469bb92. FILES: lib/source_log.rb, lib/app.rb, lib/osm/client.rb, docs/plans/bdl-offset-pagination.md, test/unit/app_log_test.rb, test/unit/osm/client_log_test.rb. TESTS: 17 runs, 0 failures, 0 errors. RuboCop reports 0 offenses on the changed files. Reek reports 0 warnings. Graph: stale.

## Outcome

- Signal: useful