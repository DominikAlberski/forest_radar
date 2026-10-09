---
type: "query"
date: "2026-10-09T08:44:25.292851+00:00"
question: "Remove the ban client from lib, unit tests, live tests, and fixtures"
contributor: "graphify"
outcome: "useful"
---

# Q: Remove the ban client from lib, unit tests, live tests, and fixtures

## Answer

Goal: remove the entry ban check from the backend. Follow section T1 of $COORD_DIR/artifacts/398bd3c9/plan.md. The program must send no request to a ban source. The selector lists a range when a mapped trail crosses it. The only exclusion reasons are :trail_unavailable and :no_mapped_trail. The facts and the F-lines hold no ban field. Delete lib/wms/ban_client.rb, its unit test, and the four bans-* fixtures. Remove their entries from test/fixtures/sources/PROVENANCE.md. Inputs: goal/c1ab3a20 at ce87c07. Plan sections 'Affected code' and 'Behavior after the change'. Tests (PLAN-R5): add selector tests for trail-only selection, for a district with no ban data, and for both exclusion reasons. Add facts tests that assert no ban key in the facts and in the F-lines. Out of scope: public/, config/locales/, test/system/, docs, GLOSSARY.md, PLAN.md, README.md. Do not restyle code for rubocop: a later task does that. Acceptance: 1. bundle exec ruby test/run.rb --unit passes. 2. git grep -n -i -E 'ban_client|BanClient|bans:|ban:|no_known_ban|ban_unknown|known_ban' -- lib test/unit test/live test/fixtures prints nothing. Exit status 1 is the pass. 3. git diff --check passes. System tests may fail until the frontend task lands. Report format: annotate one line TESTS: <command> -> <result> for each acceptance command. Add a list of deleted files and changed files.
STATUS: done. Graph: fresh. Deleted: lib/wms/ban_client.rb, test/unit/wms/ban_client_test.rb, four bans fixtures. Changed: lib/app.rb, lib/assembler/facts.rb, lib/walk_areas/selector.rb, test/live/bdl_live_test.rb, test/unit/app_test.rb, test/unit/assembler/facts_test.rb, test/unit/walk_areas/selector_test.rb, test/fixtures/sources/PROVENANCE.md.
TESTS: bundle exec ruby test/run.rb --unit -> pass.
TESTS: git grep -n -i -E 'ban_client|BanClient|bans:|ban:|no_known_ban|ban_unknown|known_ban' -- lib test/unit test/live test/fixtures -> pass, no matches, exit 1.
TESTS: git diff --check -> pass.

## Outcome

- Signal: useful