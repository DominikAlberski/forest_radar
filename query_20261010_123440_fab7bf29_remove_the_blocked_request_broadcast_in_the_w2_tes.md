---
type: "query"
date: "2026-10-10T12:34:40.949242+00:00"
question: "Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb: Tester worked in the old branch task/b6f2430e again and never ran coord start-task, so no task branch existed. It then merged the goal head into the stale branch and hit conflicts in lib/. A task spec line about the branch did not prevent this. The worktree must be switched by coord start-task before any edit."
contributor: "graphify"
outcome: "dead_end"
---

# Q: Remove the blocked-request broadcast in the W2 test fake in client_parallel_pagination_test.rb: Tester worked in the old branch task/b6f2430e again and never ran coord start-task, so no task branch existed. It then merged the goal head into the stale branch and hit conflicts in lib/. A task spec line about the branch did not prevent this. The worktree must be switched by coord start-task before any edit.

## Answer

Tester worked in the old branch task/b6f2430e again and never ran coord start-task, so no task branch existed. It then merged the goal head into the stale branch and hit conflicts in lib/. A task spec line about the branch did not prevent this. The worktree must be switched by coord start-task before any edit.

## Outcome

- Signal: dead_end