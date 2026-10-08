---
type: "query"
date: "2026-10-08T20:13:55.556704+00:00"
question: "Add failing B1 tests for collinear edges, TLS, retries, deadline, and malformed pages"
contributor: "graphify"
outcome: "useful"
---

# Q: Add failing B1 tests for collinear edges, TLS, retries, deadline, and malformed pages

## Answer

Goal: Add unit tests that fail on branch task/d4817825 for the five critical findings in b1-review.md. Inputs: Merge branch task/d4817825 into your task branch first. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/b1-review.md findings B1-R1 to B1-R5, B1-R8, B1-R11, and B1-R12. Read docs/plans/local-mvp.md sections 'Geographic and source contract' and 'B1'. Required cases: R1, separated collinear edges do not intersect, touching edges intersect, and a polygon wholly inside a hole does not intersect. R2, an OpenSSL::SSL::SSLError from the transport becomes BDL::Incomplete. R3, the transport sets Net::HTTP max_retries to 0, retries SocketError, makes at most three attempts, and waits 0.5 and 1 seconds. R4, a fake clock advances during connect, read, and retry wait, and the search stops with BDL::Incomplete when the 60-second budget runs out. R5, a page with links null, a feature with unsupported geometry, and a region without geometry each raise BDL::Incomplete, and a complete empty coverage result still raises BDL::NoCoverage. R8, each ambiguous link raises BDL::Incomplete with the candidate IDs in the message. R12, one successful synthetic search with two intersecting regions and one containing region. Assert the collection requests and the compact result. R11, add test/fixtures/ogc/README.md that labels each fixture as synthetic and names its case. Use fakes only. Make no live network request. Out of scope: All lib/ and config/ files. test/run.rb. test/fixtures/sources/ and test/fixtures/osm/. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. The new R1 to R5 tests must fail, and every older test must still pass. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the commit, one line per finding with the test file and test name, the list of failing test names, Graph state, and a TESTS line with counts of passed and failed tests.
STATUS: done. COMMIT: 72d9496. R1: g

## Outcome

- Signal: useful