---
type: "query"
date: "2026-10-08T20:37:16.961503+00:00"
question: "Fix B1 collinear edges, TLS errors, retries, deadline, and page validation in lib/bdl, lib/http, lib/geo"
contributor: "graphify"
outcome: "useful"
---

# Q: Fix B1 collinear edges, TLS errors, retries, deadline, and page validation in lib/bdl, lib/http, lib/geo

## Answer

Goal: Make every unit test on branch task/676a5e71 pass by fixing findings B1-R1 to B1-R5. Inputs: Merge branch task/676a5e71 into your task branch first. It holds task/d4817825 and the failing tests (commit 72d9496). Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b1-review.md and /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md. Read docs/plans/local-mvp.md sections 'Geographic and source contract' and 'B1'. Constraints: Call Net::HTTP.start with a block, because test/unit/http/fake_net.rb stubs it. Set max_retries to 0 on the connection. One retry policy owns timeout, IOError, SystemCallError, SocketError, and TLS errors. Keep two retries with waits of 0.5 and 1 second. Never sleep past the deadline. Compute the remaining budget before connect, before each read, and before each retry wait. Check the deadline after parsing and after result construction. Decision for B1-R10: exhausted transport failures raise HTTP::Error, as backend-contract.md says. Required notes, also in scope: B1-R6, hash a canonical form of geometry and properties for the fallback stand digest. B1-R7, keep one feature budget for all collections and reduce it after each page. B1-R9, shorten long methods where cheap, group the ResultBuilder parameters, and fix lines over 120 characters. List each remaining exception with a reason. Out of scope: All test files, test/run.rb, config/, and test/fixtures/. Do not change the tester tests. Ask the architect if a test looks wrong. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. It must exit 0. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the commit, one line per finding R1 to R10 with its fix, the B1-R9 exceptions with reasons, Graph state, and a TESTS line with counts.
MSG from architect: Priority decision: claim and finish ec1bbbd3 before the next Overpass retry for S2 

## Outcome

- Signal: useful