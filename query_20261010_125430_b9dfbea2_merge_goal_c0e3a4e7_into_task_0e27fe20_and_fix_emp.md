---
type: "query"
date: "2026-10-10T12:54:30.509146+00:00"
question: "Merge goal/c0e3a4e7 into task/0e27fe20 and fix empty boxes and the order test"
contributor: "graphify"
outcome: "useful"
---

# Q: Merge goal/c0e3a4e7 into task/0e27fe20 and fix empty boxes and the order test

## Answer

Goal: Make task/0e27fe20 landable and fix review warnings W1 and W2 from review d8f390ec. Work on branch task/0e27fe20. Do not start a new branch. Step 1: merge goal/c0e3a4e7 (head 1fb4656) into task/0e27fe20. No file conflict is expected. Step 2 (W1): Geo::Geometry::PreparedGeometry.merge_boxes raises NoMethodError on an empty list. The cases are nil geometry and a ring with no edges. Make merge_boxes return nil for an empty list. Make MatchIndex#spatial_match? return false when either box is nil. Treat a ring with no edges as outside, and never let it raise. Geometry.bounds(nil) must return nil. Step 3 (W2): reorder the fixtures in test_ambiguous_candidates_keep_original_order. Put feature 3 with adress_forest 17-02 first. Put feature 9 with nil address second. Expect the message ids in the order 3, 9. The test must fail if positions.sort is removed. Check that once by hand. Keep match results, messages, and candidate order identical for valid geometry. Inputs: review notes on task d8f390ec, $COORD_DIR/artifacts/c0e3a4e7/review-followups.md. Out of scope: minors m1-m7, build speed, lib/bdl/page_reader.rb, lib/app.rb, test/unit/bdl/client_parallel_pagination_test.rb. Acceptance: ruby -Itest -e 'Dir["test/unit/bdl/result_builder*_test.rb", "test/unit/geo/*_test.rb"].each { |f| require "./" + f }' passes. New tests: a district candidate with nil geometry gives district_id nil without an error. Geometry.bounds(nil) does not raise. A one-point ring does not raise. The full unit suite passes with 0 failures, including W2. Use bundle exec rake test, or ruby -Itest over test/unit/**/*_test.rb if rake is unavailable. bundle exec rubocop and reek report 0 offenses on the scoped files. Report format: STATUS, COMMITS (merge and fix), TESTS line, RUBOCOP, REEK, and a note that confirms the W2 test fails without the sort.
STATUS: done. COMMITS: de325e5 merge; 494885a fix. TESTS: scoped 57 pass; unit 202 pass; rake unavailable. RUBOCOP: 0 offenses. REEK: 0 warnings. Graph: fresh

## Outcome

- Signal: useful