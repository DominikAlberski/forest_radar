---
type: "query"
date: "2026-10-10T11:16:27.863905+00:00"
question: "Use a separate condition for blocked requests in client_parallel_pagination_test.rb: The fix moved the blocked wait to a new condition but kept the broadcast in block_request. Each new blocked request still woke the earlier blocked requests."
contributor: "graphify"
outcome: "dead_end"
---

# Q: Use a separate condition for blocked requests in client_parallel_pagination_test.rb: The fix moved the blocked wait to a new condition but kept the broadcast in block_request. Each new blocked request still woke the earlier blocked requests.

## Answer

The fix moved the blocked wait to a new condition but kept the broadcast in block_request. Each new blocked request still woke the earlier blocked requests.

## Outcome

- Signal: dead_end