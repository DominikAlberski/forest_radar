---
type: "query"
date: "2026-10-10T11:37:17.777237+00:00"
question: "Read BDL pages by offset in parallel and start the card deadline after search in lib/bdl and lib/app.rb"
contributor: "graphify"
outcome: "useful"
source_nodes: ["lib_app", "lib_bdl_page_reader", "lib_bdl_page_state"]
---

# Q: Read BDL pages by offset in parallel and start the card deadline after search in lib/bdl and lib/app.rb

## Answer

Goal: implement plan D1, D2 and D3 of goal c0e3a4e7. Inputs: the plan in $COORD_DIR/artifacts/c0e3a4e7/plan.md, sections D1-D3 and S2-2. Goal head 9a2b379 holds the S2-1 failing tests (commits 072e6d2, 5c60fe6) and L2. D1: read BDL pages by offset and ignore the next link. D2: fetch the pages after offset 0 at the same time, at most 4 requests at once, in worker threads. D3: start the 29 s card deadline after the BDL search returns. Read the start time from settings.clock as a value. Never call .call on settings.clock. Keep the L2 logged_source wrapper and the SourceLog behavior. Out of scope: test files, lib/source_log.rb, lib/osm/, review minors m1-m6, the 60 s and 100000 limits. Ask the architect if a test seems wrong. Do not edit tests. Acceptance: ruby test/run.rb --unit passes with 0 failures and 0 errors. bundle exec rubocop lib test reports 0 offenses. bundle exec reek lib reports 0 warnings. Live: the Warsaw search (lat 52.078247, lon 21.040624, radius 20 km) returns 5481 stands. With the stub model from config/model.yml, POST /api/card returns HTTP 200 with a card. Merge the latest goal head into your branch before coord done. Report format: commit SHAs, 'TESTS: <n> runs, <f> failures, <e> errors', rubocop and reek results, live stand count, card HTTP status and time, and any stderr log lines.
MSG from backend-developer: The unit tests have conflicting fixtures. ClientParallelPaginationTest omits feature properties. AppTest uses a frozen clock but expects live time bounds. ClientTest expects next links. Please assign test corrections to the test owner.
MSG from architect: All three test claims are valid. Tester task 6ee8d0f7-3d50-4937-9b5f-599f449cf55c corrects them. Continue the lib work against D1-D3 now. Do not edit tests. Merge the goal head after 6ee8d0f7-3d50-4937-9b5f-599f449cf55c lands, then run the acceptance. Report other test conflicts with file and line.
MSG from backend-developer: Pagination tests for bad offset 1 omit offset 2. Parallel fetch

## Outcome

- Signal: useful

## Source Nodes

- lib_app
- lib_bdl_page_reader
- lib_bdl_page_state