---
type: "query"
date: "2026-10-08T19:55:50.063043+00:00"
question: "Write failing B1 tests for transport errors, retries, geometry holes, and pagination in test/unit"
contributor: "graphify"
outcome: "useful"
---

# Q: Write failing B1 tests for transport errors, retries, geometry holes, and pagination in test/unit

## Answer

Goal: Add the B1 tests that docs/plans/local-mvp.md section B1 requires and that branch task/fb07a05e lacks. Inputs: Branch task/fb07a05e. Merge it into your task branch first. Read plan sections 'Geographic and source contract', 'Session cache', and 'B1'. Read $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md and test/fixtures/sources/. Defect 1: lib/bdl/client.rb rescues only HTTP::Error. A Timeout::Error, IOError, or SystemCallError after the last retry escapes BDL::Client and must become BDL::Incomplete. Defect 2: config/puma.rb is absent. Required coverage: transport retries at most two times with 0.5 s and 1 s waits; no retry on 4xx; the 16 MiB limit; the deadline; network errors after retries. Geometry: Polygon holes, MultiPolygon, boundary points, distance within 0.02 km against a hand-computed value, in-radius stands. Pagination: repeated next link, malformed page, foreign host, count mismatch, feature limit. Stands: duplicate a_i_num, fallback to adr_for, missing identifiers, null attributes. Range-to-district link by address prefix plus geometry. Use small recorded or hand-built fixtures in test/fixtures/ogc/. Out of scope: Any file in lib/ or config/. Do not fix the code. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. The new tests for defect 1 fail, and each other new test passes or fails for a named reason. Run 'git diff --check goal/c1ab3a20...HEAD'. It must exit 0. Report format: Annotate the commit, each failing test with its cause, Graph state, and a TESTS line.
STATUS: done. COMMIT: ce466d4. FILES: test/unit/http/transport_test.rb, test/unit/bdl/{client_transport_errors,client_pagination,result_builder}_test.rb, test/unit/geo/geometry_holes_test.rb, test/fixtures/ogc/*. TESTS: 7 intended failures in client_transport_errors_test.rb (Timeout::Error, IOError, ECONNRESET, ECONNREFUSED, ETIMEDOUT, SocketError, search/Timeout); cause: lib/bdl/client.rb:49 rescues only JSON::ParserError, KeyError, TypeError, HTTP::Erro

## Outcome

- Signal: useful