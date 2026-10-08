---
type: "query"
date: "2026-10-08T20:07:26.157511+00:00"
question: "Fix B1: map transport errors to BDL::Incomplete in lib/bdl/client.rb and add config/puma.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Fix B1: map transport errors to BDL::Incomplete in lib/bdl/client.rb and add config/puma.rb

## Answer

Goal: Finish B1 so that every unit test on branch task/0d4e29f6 passes. Inputs: Branch task/0d4e29f6. Merge it into your task branch first. It contains the B1 code from task/fb07a05e and the new tests. Read docs/plans/local-mvp.md sections 'Geographic and source contract', 'Session cache', and 'B1'. Defect 1: lib/bdl/client.rb must map Timeout::Error, IOError, SocketError, and SystemCallError to BDL::Incomplete after the last retry. test/unit/bdl/client_transport_errors_test.rb shows 7 failures for this defect. Defect 2: Add config/puma.rb as plan B1 describes. Add one test under test/unit/config/ that loads config/puma.rb without error. Defect 3: test/run.rb stops at the first failing file. Make it run every file and exit non-zero if any file fails. Minor notes: The range-to-district link takes the first match only. Report each ambiguous match and do not pick silently. Geometry.intersects? checks only outer rings. Make it respect holes, or document the limit in the report. The REGION_CODES map is unverified. Name its source in a comment, or mark it unverified. Out of scope: Any test file outside test/run.rb and test/unit/config/. Do not change the tester's tests to make them pass. Ask the architect if a test looks wrong. No Overpass or OSM code. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. It must exit 0 with every file run. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the commit, each defect with its fix, each minor note with its outcome, Graph state, and a TESTS line with test counts.
STATUS: done. COMMIT: 82f1422. Defect 1: BDL::Client maps transport exceptions to BDL::Incomplete. Defect 2: config/puma.rb sets one Puma process, and a unit test loads it. Defect 3: test/run.rb runs every test file before failure exit. Ambiguous stand and range links raise BDL::Incomplete with candidate IDs. Geometry intersection checks hole boundaries. The REGION_CODES map is marked unverified. Graph: fresh. TESTS: bundle exec ruby

## Outcome

- Signal: useful