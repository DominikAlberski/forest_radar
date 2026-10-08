---
type: "query"
date: "2026-10-08T19:29:38.879316+00:00"
question: "Commit plan r4 to docs/plans/local-mvp.md and the OSM decision to docs/decisions/0006-osm-trail-fallback.md"
contributor: "graphify"
outcome: "useful"
---

# Q: Commit plan r4 to docs/plans/local-mvp.md and the OSM decision to docs/decisions/0006-osm-trail-fallback.md

## Answer

Goal: Commit the approved plan revision and the user decision on the OpenStreetMap trail fallback. Inputs: $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md (approved r4, review 3c074867). $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-osm-trail-fallback.md. Copy each file byte for byte. Out of scope: Application code, GLOSSARY.md, fixtures, and all other documents. Acceptance: Run 'git diff --check goal/c1ab3a20...HEAD'. Run 'cmp docs/plans/local-mvp.md $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md'. Run 'cmp docs/decisions/0006-osm-trail-fallback.md $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-osm-trail-fallback.md'. All three must exit 0. Report format: Annotate changed paths, commit, Graph state, and a TESTS line with each command and its result.
STATUS: done. FILES: docs/plans/local-mvp.md, docs/decisions/0006-osm-trail-fallback.md. COMMIT: 5f3dd99. Graph: fresh. TESTS: git diff --check goal/c1ab3a20...HEAD passed; cmp docs/plans/local-mvp.md artifact/plan.md passed; cmp docs/decisions/0006-osm-trail-fallback.md artifact/decision-osm-trail-fallback.md passed.

## Outcome

- Signal: useful