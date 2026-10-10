---
type: "query"
date: "2026-10-10T11:07:05.523923+00:00"
question: "Review S2-2 offset reads, parallel fetch, and deadline start in lib/bdl and lib/app.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Review S2-2 offset reads, parallel fetch, and deadline start in lib/bdl and lib/app.rb

## Answer

Goal: review the S2-2 code of goal c0e3a4e7 against plan D1-D3. Inputs: branch task/38977b1d (commit 686919f plus a goal merge). Diff: git diff goal/c0e3a4e7...task/38977b1d. Tests on the goal branch: commits 072e6d2, 5c60fe6, 14ab0df, 670a300. Plan: $COORD_DIR/artifacts/c0e3a4e7/plan.md, sections D1-D3. Backend TESTS line: 189 runs, 0 failures, 0 errors. RuboCop and Reek pass. Check these points: offset rule and count checks per D1; at most 4 threads; report_on_exception false; no thread alive after return or raise; the first error reaches the rescue in BDL::Client#features; thread safety of the shared results Hash and the deadline check inside worker threads; settings.clock used as a value in lib/app.rb; logged_source kept; no test edits on the task branch. Known open issue: the live Warsaw search exceeds the 60 s limit. A separate timing task measures it. Do not report the timing as a finding. Out of scope: the 60 s and 100000 limits, review minors m1-m6, editing any file. Acceptance: each finding cites file and line on task/38977b1d and has a severity (critical, warning, minor). Report format: verdict (approve or request changes), then the findings list.
VERDICT: request changes. Graph: fresh. TESTS: worker line read: 189 runs, 0 failures, 0 errors. Static on task/38977b1d: rubocop 0 offenses, reek 0 warnings. No test edits on the branch (only 686919f plus merge, lib files only). Checks that pass: D1 offset rule and count checks (lib/bdl/page_state.rb:26-38, 41-43, 46-53); feature limit raised on page 0 before more requests (page_state.rb:37, page_reader.rb:17); T=0 makes no request; at most min(concurrency, pages) threads (page_reader.rb:46); shared Transport is stateless per request (lib/http/transport.rb:26-30); state.fetch reads state only, add runs in the caller thread; worker errors reach the rescue in lib/bdl/client.rb:42 through Thread#value; lib/app.rb:84 reads settings.clock as a value after the search; logged_source is kept (lib/app.rb:81-83).
W1 warn

## Outcome

- Signal: useful