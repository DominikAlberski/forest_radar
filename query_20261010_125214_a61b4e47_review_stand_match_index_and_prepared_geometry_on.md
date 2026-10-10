---
type: "query"
date: "2026-10-10T12:52:14.823233+00:00"
question: "Review stand match index and prepared geometry on task/0e27fe20"
contributor: "graphify"
outcome: "useful"
---

# Q: Review stand match index and prepared geometry on task/0e27fe20

## Answer

Goal: Review branch task/0e27fe20 against goal/c0e3a4e7. Use git diff goal/c0e3a4e7...task/0e27fe20. The branch adds BDL::MatchIndex in lib/bdl/result_builder.rb and PreparedGeometry in lib/geo/geometry.rb. Inputs: the diff, the TESTS line on task 0e27fe20, and $COORD_DIR/artifacts/c0e3a4e7/timing-matching.md. Check that match results, ambiguous messages, and candidate order equal the old matching_feature? path. Check one suspected defect first. The old path returns false for a feature with nil geometry, because Geometry.polygons returns an empty list. The new merge_boxes may raise NoMethodError on an empty box list. This applies to nil geometry and to a ring with fewer than 2 points. Also check that the prefix index covers short and empty adress_forest values without duplicates. The 2 s target is removed. Do not report build time as a finding. Out of scope: the W2 test and task c4e7d1c4. Do not run tests. Acceptance: each finding names a file, a line, and a severity (critical, warning, minor). Report format: VERDICT approve or changes, then the findings list.
VERDICT: approve, with one warning that the architect can schedule. Scope: commits 8cdcf5f and 28089b9. Files: lib/bdl/result_builder.rb, lib/geo/geometry.rb, test/unit/bdl/result_builder_index_test.rb, test/unit/geo/geometry_bbox_test.rb. Worker TESTS line: focused 53 passed, full unit 197 passed, only the known W2 failure. This TESTS line is present and acceptable. RuboCop on the 4 files: 0 offenses. Reek on the 2 lib files: 0 warnings. Graph: fresh. Equivalence checks, all pass. 1. Prefix index: the index key is adress_forest.to_s[0, width]. The lookup probes address[0, size] for size 0 to min(width, address length). This equals address.start_with?(prefix) exactly. Empty and missing adress_forest map to the key '', and size 0 always probes it. Each item has one key, and each probe has a different length, so no duplicates. 2. Candidate order: positions.sort restores the input order, so ambiguous messages kee

## Outcome

- Signal: useful