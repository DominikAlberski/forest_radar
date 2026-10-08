---
type: "query"
date: "2026-10-08T20:37:35.909679+00:00"
question: "Update transport_test.rb to expect HTTP::Error after exhausted retries"
contributor: "graphify"
outcome: "useful"
source_nodes: ["config_puma", "lib_bdl_client", "lib_bdl_result_builder", "lib_cache_search_cache", "lib_cache_session_cache", "lib_cache_session_id", "lib_geo_geometry", "lib_http_transport", "test_run", "test_test_helper"]
---

# Q: Update transport_test.rb to expect HTTP::Error after exhausted retries

## Answer

Goal: Align test/unit/http/transport_test.rb with architect decision B1-R10. Exhausted network retries now raise HTTP::Error, not the original exception. Inputs: Merge branch task/ec1bbbd3 into your task branch first (commit 412c661). It holds all B1 code and tests. Change test_retries_network_errors_then_raises_the_last_one to expect HTTP::Error. Keep the checks for three attempts and the waits of 0.5 and 1 second. Rename the test to match the new behavior. If the Script double in this file must accept max_retries, add the smallest change that does so. Out of scope: All lib/ files. Every other test file. Do not weaken any other assertion. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. It must exit 0. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the commit, the changed test names, Graph state, and a TESTS line with counts.
STATUS: done. COMMIT: 7ee57c2. FILES: test/unit/http/transport_test.rb. CHANGED: test_retries_network_errors_then_raises_the_last_one renamed to test_exhausted_network_retries_raise_http_error; expects HTTP::Error; three attempts and waits 0.5, 1.0 kept. Graph: missing. TESTS: run.rb --unit exit 0; all files 0 failures; diff --check exit 0.

## Outcome

- Signal: useful

## Source Nodes

- config_puma
- lib_bdl_client
- lib_bdl_result_builder
- lib_cache_search_cache
- lib_cache_session_cache
- lib_cache_session_id
- lib_geo_geometry
- lib_http_transport
- test_run
- test_test_helper
- test_unit_bdl_client_pagination_test
- test_unit_bdl_client_search_test
- test_unit_bdl_client_test
- test_unit_bdl_client_transport_errors_test
- test_unit_bdl_result_builder_test
- test_unit_cache_search_cache_test
- test_unit_cache_session_cache_test
- test_unit_cache_session_id_test
- test_unit_config_puma_test
- test_unit_geo_geometry_collinear_test