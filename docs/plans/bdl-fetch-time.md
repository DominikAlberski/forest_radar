# Plan: goal cd5e1f57, BDL page fetch inside the 29-second card deadline

Graph: fresh (last check this session; MCP graphify down, read code directly).

## Problem
The Warsaw search (lat 52.078247, lon 21.040624, radius 20 km) needs about 35 s to read BDL pages.
The target is 29 s. Source of the target: the PM goal message for cd5e1f57 (user decision).
Note: app.rb L84 and ADR 0009 start the card deadline after the BDL search. The PM target still applies to the BDL fetch alone. User choice: option 2. Raise page concurrency from 4 to 8. Test a larger page size.
Do not change the radius or other options without a user decision.

## Code read (main after PR 3, 57c4d11)
- lib/bdl/client.rb: defaults `page_size: 1000, concurrency: 4`. Passes both to PageReader.
- lib/bdl/page_reader.rb: PageReader defaults `page_size: 1000, concurrency: 4`. PageWorkers starts min(concurrency, offsets) threads.
- lib/bdl/page_state.rb: `PAGE_SIZE` fallback. Count check: each page must hold min(page_size, matched - offset) items.
  If BDL caps the page size below the request, this check raises Incomplete ('count mismatch'). That is the page-size cap signal.
- lib/bdl/search_state.rb: 60 s BDL budget. Unchanged.
- lib/http/transport.rb: default retries 2 with 0.5 s and 1 s sleeps. It hides headers. max_bytes 16 MiB per response.
- Warsaw stands: about 5481 features. At page size 1000 there are 5 later offsets, so concurrency 8 acts as 5.
  At page size 2000 there are 2 later offsets. Collections read in sequence, and each first page is serial.
  So option 2 may not reach the target. T1 records the phases to show this.
- ADR 0009 records "four parallel page reads, about 43 s". ADRs are append-only.
  No new ADR: a default value is easy to reverse. T2 commits the measurements in docs/plans/bdl-fetch-time.md.

## Sequence
1. Done: local main holds 57c4d11. goal/cd5e1f57 is synced.
2. T1 measure (backend-developer). Gate before any code change.
3. Gate decision by the architect:
   - A setting passes when two runs each finish in 25 s or less (4 s margin under 29 s): create T2.
   - No setting passes, or the source throttles: report the numbers to the PM. Stop the goal until the user decides.
4. T2 change defaults (backend-developer). 5. R1 review of T2 (reviewer, no scope).

## Probe rules (T1 and the live run in T2)
- Load lib/ from the task worktree of goal/cd5e1f57 (base 57c4d11). The probe script stays outside the repository,
  in $COORD_DIR/artifacts/cd5e1f57/probe.rb.
- Build the client with `HTTP::Transport.new(..., retries: 0)` and the same base URL and user agent as the default.
- Wrap transport.get. Record per request: collection, offset, start time, duration, response bytes, result (ok or error class and status).
- Record per collection: first-page time and parallel-phase time.
- Baseline page time = median page duration of run a.
- Stop signs. Stop all runs at the first sign and record it:
  HTTP 429 or any 5xx, connection refused, reset, or timeout, 'count mismatch', 'response too large',
  a page duration above 2x the baseline page time.
- Pause 20 s between runs.

## T1. Measure BDL page fetch time for the Warsaw search
- Role backend-developer. Scope: none in the repository. Write only $COORD_DIR/artifacts/cd5e1f57/probe.rb and measurements.md. No commit.
- Search: lat 52.078247, lon 21.040624, radius_km 20, through BDL::Client#search with the probe transport.
- Runs in order, one run each, under the probe rules:
  a. concurrency 4, page size 1000 (baseline).
  b. concurrency 8, page size 1000.
  c. concurrency 8, page size 2000.
  d. concurrency 8, page size 3000. Only if c has no stop sign and its largest page is under 8 MiB.
     Page size 5000 is excluded: about 13.8 MB per page is too near the 16 MiB cap.
  e. Repeat the fastest setting that finished in 25 s or less.
- Acceptance: measurements.md holds one row per run (total, per-collection first page and parallel phase, request count,
  largest page bytes), the stop sign if any, and a recommendation.
- Report: annotate the table summary and the recommended setting, or "none meets 25 s on two runs".

## T2. Raise BDL page concurrency and page size defaults
- Role backend-developer. Scope: lib/bdl/client.rb, lib/bdl/page_reader.rb, lib/bdl/page_state.rb, test/unit/bdl/, docs/plans/bdl-fetch-time.md.
- Inputs: measurements.md, the setting that the architect picks.
- Change: set the picked concurrency and page size as defaults in one place. The three lib files must not disagree.
  Keep the count check, the deadline check, retries 2 in the default transport, and the 60 s budget.
  Page size must stay at most 3000 (half the byte cap by measured bytes per feature).
- Docs: docs/plans/bdl-fetch-time.md holds this plan and the measurement table.
- Out of scope: radius, search options, lib/app.rb, lib/http/, the card deadline, ADR files.
- Acceptance: `ruby test/run.rb --unit` passes. `bundle exec rubocop` reports 0 offenses. `bundle exec reek` reports 0 warnings.
  A unit test covers the new defaults and concurrency 8. One live Warsaw run with probe.rb and the new defaults,
  under the probe rules, finishes in 25 s or less.
- Report: TESTS line, rubocop and reek counts, the measured Warsaw time.

## R1. Review T2
- Reviewer, no scope. Inputs: branch task/<T2>, measurements.md. Check the defaults agree, the checks stay, and the tests cover concurrency 8.

## Shared files with other goals
- 6c0f485d: lib/model/, lib/app.rb, lib/card/builder.rb, public/, locales, GLOSSARY.md, docs/plans/ollama-dev-fallback.md. No overlap.
- b0a7d5d8: lib/places/, lib/app.rb, public/, locales, GLOSSARY.md, its ADR. No overlap. This goal adds no ADR.
- Glossary: no new terms.

## Notes from review a9ff2b22 (for T2 spec)
- n2: docs/plans/bdl-fetch-time.md states that its numbers replace the ADR 0009 timing figure.

## Measurements

| Run | Concurrency | Page size | Total s | Collection first/parallel s | Requests | Largest page bytes | Stop sign |
| --- | ---: | ---: | ---: | --- | ---: | ---: | --- |
| a | 4 | 1000 | 30.82 | rdlp: 4.95/0.00; nadlesnictwa: 4.41/0.00; lesnictwa: 7.47/0.00; RDLP_Radom_wydzielenia: 2.49/0.00; RDLP_Warszawa_wydzielenia: 4.87/5.89 | 10 | 10292906 | none |
| b | 8 | 1000 | 24.72 | rdlp: 4.38/0.00; nadlesnictwa: 4.98/0.00; lesnictwa: 4.17/0.00; RDLP_Radom_wydzielenia: 1.68/0.00; RDLP_Warszawa_wydzielenia: 3.63/5.09 | 10 | 10292906 | none |
| c | 8 | 2000 | 30.28 | rdlp: 4.33/0.00; nadlesnictwa: 4.25/0.00; lesnictwa: 7.97/0.00; RDLP_Radom_wydzielenia: 1.54/0.00; RDLP_Warszawa_wydzielenia: 4.69/6.77 | 7 | 10292906 | none |
| e | 8 | 1000 | 24.72 | rdlp: 4.29/0.00; nadlesnictwa: 4.33/0.00; lesnictwa: 5.10/0.00; RDLP_Radom_wydzielenia: 1.49/0.00; RDLP_Warszawa_wydzielenia: 3.22/5.48 | 10 | 10292906 | none |

Run d was skipped. Run c had a page larger than 8 MiB.

These measurements replace the timing figure in ADR 0009.
