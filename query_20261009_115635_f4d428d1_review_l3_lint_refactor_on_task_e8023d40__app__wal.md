---
type: "query"
date: "2026-10-09T11:56:35.257779+00:00"
question: "Review L3 lint refactor on task/e8023d40 (app, walk_areas, assembler, model, cache, card, sanepid)"
contributor: "graphify"
outcome: "useful"
---

# Q: Review L3 lint refactor on task/e8023d40 (app, walk_areas, assembler, model, cache, card, sanepid)

## Answer

Goal: Review the L3 lint refactor before it lands on goal/c1ab3a20. Inputs: branch task/e8023d40. Diff: git diff goal/c1ab3a20...task/e8023d40. Worker report and TESTS lines: coord show e8023d40. Changed public signatures: Selector#select(search:, area:, deadline:), SearchCache#fetch(request, ttl:), SessionCache#write(key, value, ttl:), Model::Stub#generate, Model::Validator#initialize(validation_class:), Card::Builder#initialize(translator:). SearchCache#wms_fetch is removed. Focus 1: judge the SearchCache#fetch design with one request array as key. Focus 2: judge SessionCache. write is an alias of a private write_entry? method made public, and @limits is an array of max_entries and max_bytes. Decide if these only hide reek findings and hurt clarity. Focus 3: check that each removed or changed signature has no remaining caller in lib, test or public. Focus 4: check that behavior did not change in assembler facts, model client timeouts and validator. Out of scope: lib/bdl, lib/http, lib/osm, test/system and test/live. Do not run tests. Do not edit code. Acceptance: write $COORD_DIR/artifacts/c1ab3a20/L3-review.md. Give each finding an id, a severity (critical, warning, minor), and a file:line. Report format: annotate the verdict approve or changes-requested, the count per severity, and the artifact path.
STATUS: done. Verdict: changes-requested. Critical 0, warning 5, minor 9. Artifact: $COORD_DIR/artifacts/c1ab3a20/L3-review.md. TESTS: reviewer runs no tests. Worker TESTS lines pass. RuboCop and Reek on a branch snapshot report 0 findings. NOTES: Behavior is unchanged in facts, model client, validator and selector. No removed signature has a caller. W1: the write alias hides a predicate name. W2: nil checks are disguised to evade NilCheck. W3: selector test fakes accept any keyword. W4: the SearchCache key array loses the named session. W5: constructor injection exists only for reek. Graph: fresh.

## Outcome

- Signal: useful