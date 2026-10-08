---
type: "query"
date: "2026-10-08T19:57:13.265199+00:00"
question: "Implement B1 geographic services, OGC reads, transport, and session cache in lib/geo lib/bdl lib/http lib/cache"
contributor: "graphify"
outcome: "corrected"
correction: "Task fb07a05e is superseded by d4817825. A backend task must include the tests that the plan names. A client must map every transport error class, not only HTTP::Error."
---

# Q: Implement B1 geographic services, OGC reads, transport, and session cache in lib/geo lib/bdl lib/http lib/cache

## Answer

Goal: Implement M2, M3, shared HTTP transport, and the session cache, as docs/plans/local-mvp.md section B1 states. Inputs: docs/plans/local-mvp.md sections 'Geographic and source contract', 'Session cache', and 'B1'. Read $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md and test/fixtures/sources/. Read docs/data-sources.md. Notes: source-contract.md lines 10 and 55 mix REST identifiers with WMS layer names; B1 uses no tourism layer. Use skipGeometry=true only where B1 needs attributes; the in-radius flag needs stand geometry. Link a range to its district by the forest address prefix plus a geometry check. Make the HTTP transport and cache usable by a later Overpass client: configurable base address, User-Agent, size limit, timeout, retry policy per caller, and cache entries with a per-entry key and TTL. Out of scope: WMS, OpenStreetMap, candidate eligibility, model calls, routes, views, and browser tests. Add no gem beyond the six approved gems in PLAN.md. Acceptance: Run 'bundle exec ruby test/run.rb --unit' and 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Write $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/backend-contract.md with the transport, geometry, and cache interfaces. Report format: Annotate service interfaces, changed paths, commit, Graph state, TESTS line with results, and external limitations.
STATUS: done. Interfaces: Geo::Geometry, BDL::Client, HTTP::Transport, Cache::SessionCache, Cache::SearchCache, Cache::SessionId. FILES: Gemfile, Gemfile.lock, lib/bdl/, lib/geo/, lib/http/, lib/cache/, test/. COMMIT: 8b0f659. Graph: fresh. TESTS: bundle exec ruby test/run.rb --unit passed; git diff --check goal/c1ab3a20...HEAD passed. NOTES: The public BDL service can change. The unit suite uses local data only. The backend contract is in the shared goal artifact folder.
STATUS: done. COMMIT: af41425 replaces 8b0f659. TESTS: bundle exec ruby test/run.rb --unit passed; git diff --check goal/c1ab3a20...HEAD pass

## Outcome

- Signal: corrected
- Correction: Task fb07a05e is superseded by d4817825. A backend task must include the tests that the plan names. A client must map every transport error class, not only HTTP::Error.