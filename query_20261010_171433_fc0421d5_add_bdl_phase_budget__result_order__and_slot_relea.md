---
type: "query"
date: "2026-10-10T17:14:33.571405+00:00"
question: "Add BDL phase budget, result order, and slot release tests in test/unit/bdl"
contributor: "graphify"
outcome: "useful"
---

# Q: Add BDL phase budget, result order, and slot release tests in test/unit/bdl

## Answer

Goal: close review findings W2, m4, and m5 of review d02bd789 for goal cd5e1f57. Inputs: branch goal/cd5e1f57 at 77cbfd0. Read the review notes: coord show d02bd789. Read lib/bdl/search_state.rb, phase_reads.rb, search_transport.rb. Add three tests through Client#search with a fake transport. One: two collections are each below the item limit, but their sum is above it; assert Incomplete 'feature limit'. Two: collections finish in reverse order through different delays; assert the stand order and the region, district, and range arrays. Three: after one collection fails, the fake has 0 active requests. Out of scope: lib/, all other test files. Do not change lib code. If a test fails because of lib code, report it and stop. Acceptance: ruby test/run.rb --unit passes. bundle exec rubocop test/unit/bdl reports 0 offenses. Report format: annotate TESTS line, the new test names, the commit sha.
TESTS: ruby test/run.rb --unit passed; bundle exec rubocop test/unit/bdl passed. Added test_search_enforces_item_limit_across_collections, test_search_preserves_collection_order_when_reads_finish_in_reverse_order, and active request release assertion in test_one_collection_failure_stops_search. Graph: fresh. Commit: 014c14bafaa127e05ee46a8d1083fdad76acc890.

## Outcome

- Signal: useful