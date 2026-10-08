---
type: "query"
date: "2026-10-08T21:23:28.876783+00:00"
question: "Reject malformed BDL geometry as BDL::Incomplete and wrap two long test lines"
contributor: "graphify"
outcome: "useful"
---

# Q: Reject malformed BDL geometry as BDL::Incomplete and wrap two long test lines

## Answer

Goal: Close review finding B1-R5 and the two R9 line-length warnings. Malformed source geometry must raise BDL::Incomplete, never NoMethodError. Inputs: Merge branch task/e6611e2b (commit 7ee57c2) into your task branch first. It holds all B1 code and tests. Read finding B1-R5 and the R9 evidence in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b1-review-2.md. The defect is in valid_feature? in lib/bdl/client.rb near lines 107-115 and in Geo::Geometry.polygons. Validate the geometry object, its type, and every coordinate container before any geometry helper runs. Reject rings whose first point differs from the last point. Split test/unit/http/transport_test.rb line 41 and test/unit/bdl/client_search_test.rb line 138 to 120 characters or less. Out of scope: lib/http/transport.rb and finding B1-R4; the user accepted R4 as a known limit. Do not change the ResultBuilder#build signature. Do not change test/fixtures/. Do not weaken any existing assertion. Acceptance: Add test/unit/bdl/client_geometry_validation_test.rb. It covers MultiPolygon with null coordinates, a scalar geometry value, a non-Hash geometry, an unclosed ring, and one valid closed polygon. Each malformed case asserts that search raises BDL::Incomplete. Run 'bundle exec ruby test/run.rb --unit'. It must exit 0. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Run 'awk "length > 120" test/unit/http/transport_test.rb test/unit/bdl/client_search_test.rb test/unit/bdl/client_geometry_validation_test.rb'. It must print nothing. Report format: Annotate the commit, the changed files, the new test names, Graph state, and a TESTS line with counts.
STATUS: done. COMMIT: c9a9454. FILES: lib/bdl/client.rb, lib/geo/geometry.rb, test/unit/bdl/client_geometry_validation_test.rb, test/unit/bdl/client_search_test.rb, test/unit/http/transport_test.rb. TESTS: unit 105 tests and 221 assertions pass; diff check passes; awk prints no lines. NEW TESTS: null M

## Outcome

- Signal: useful