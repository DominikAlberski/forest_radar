---
type: "query"
date: "2026-10-10T12:48:16.395600+00:00"
question: "Index stand match candidates by address prefix and prefilter by bounding box in lib/bdl/result_builder.rb"
contributor: "graphify"
outcome: "useful"
source_nodes: ["lib_bdl_result_builder", "lib_geo_geometry"]
---

# Q: Index stand match candidates by address prefix and prefilter by bounding box in lib/bdl/result_builder.rb

## Answer

Goal: Cut stand matching time in BDL::ResultBuilder. Today matching_feature? runs 185071 times and takes 37.9 s for the Warsaw search. Build one index per candidate list and per prefix width. The index maps the address prefix to its candidates. Look up only the candidates whose prefix the source address starts with. Keep candidates with a short or missing adress_forest, because an empty prefix matches every address today. Then reject candidates whose bounding box does not overlap the source bounding box. Run Geo::Geometry.intersects? only on the rest. Compute each bounding box one time per feature. Keep the match results and the ambiguous error messages identical, including their candidate order. Inputs: lib/bdl/result_builder.rb lines 27-30 and 88-121. lib/geo/geometry.rb. Profile: $COORD_DIR/artifacts/c0e3a4e7/timing-s2-2.md and your note on task 38977b1d at 11:11. Out of scope: lib/bdl/page_reader.rb, lib/bdl/page_state.rb, lib/app.rb, and test/unit/bdl/client_parallel_pagination_test.rb. Do not change the public build signature. Acceptance: ruby -Itest -e 'Dir["test/unit/bdl/result_builder*_test.rb", "test/unit/geo/*_test.rb"].each { |f| require "./" + f }' passes. The new tests in test/unit/bdl/result_builder_index_test.rb cover: a short prefix candidate, a missing address, a disjoint bounding box, and an ambiguous match. The new tests in test/unit/geo/geometry_bbox_test.rb cover the bounding box overlap. Run the full unit suite: bundle exec rake test passes, except the W2 test in client_parallel_pagination_test.rb, which has a separate fix. bundle exec rubocop and reek report 0 offenses on your files. Measure one live Warsaw build (latitude 52.078247, longitude 21.040624, radius 20 km). Result building must take at most 2 s. Write the timing to $COORD_DIR/artifacts/c0e3a4e7/timing-matching.md. Report format: STATUS, COMMITS, TESTS line, RUBOCOP, REEK, result building time before and after, total search time.
STATUS: blocked. COMMITS: 8cdcf5f. TESTS: focused 52

## Outcome

- Signal: useful

## Source Nodes

- lib_bdl_result_builder
- lib_geo_geometry