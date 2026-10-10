---
type: "query"
date: "2026-10-10T13:18:43.356682+00:00"
question: "Require lib/geo/geometry in test/unit/geo/geometry_bbox_test.rb so it runs alone"
contributor: "graphify"
outcome: "useful"
---

# Q: Require lib/geo/geometry in test/unit/geo/geometry_bbox_test.rb so it runs alone

## Answer

Goal: Make the merge suite pass. ruby test/run.rb --all runs each test file in its own process. test/unit/geo/geometry_bbox_test.rb fails alone with NameError: uninitialized constant GeometryBBoxTest::Geo. The file requires only test_helper. Add the require of lib/geo/geometry the same way as the other geo tests. Inputs: branch goal/c0e3a4e7 at 20ff3a3. Start the task branch from it. The file came from cc99fbd. Out of scope: every other file. Do not change lib/ or the test logic. Acceptance: ruby -Itest test/unit/geo/geometry_bbox_test.rb passes alone. ruby test/run.rb --unit exits 0. bundle exec rubocop on the file reports 0 offenses. Report format: STATUS, COMMITS, TESTS line with the exit code of ruby test/run.rb --unit.
STATUS: done. COMMITS: f34c110. TESTS: ruby -Itest test/unit/geo/geometry_bbox_test.rb exit 0; ruby test/run.rb --unit exit 0; bundle exec rubocop test/unit/geo/geometry_bbox_test.rb exit 0, no offenses. Graph: fresh.

## Outcome

- Signal: useful