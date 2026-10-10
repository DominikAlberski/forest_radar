---
type: "query"
date: "2026-10-10T10:07:40.263800+00:00"
question: "Commit BDL offset pagination plan, ADR 0009, and doc pointers"
contributor: "graphify"
outcome: "useful"
source_nodes: ["docs_data_sources"]
---

# Q: Commit BDL offset pagination plan, ADR 0009, and doc pointers

## Answer

Goal: commit the approved plan and ADR 0009 for goal c0e3a4e7. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.md (approved). Copy it unchanged to docs/plans/bdl-offset-pagination.md. Write docs/decisions/0009-bdl-offset-pagination.md in the format of ADR 0008. ADR title: 'Read BDL pages by offset, not by next links'. ADR body: The BDL OGC server builds next links from numberMatched, and numberMatched shrinks by the offset on each page. So next links stop early and a read loses stands. The reader computes offsets from the first numberMatched instead. With 4 parallel page reads a full search takes about 43 s of the 60 s BDL budget. One card request can take up to about 89 s (60 s BDL plus 29 s card). In docs/plans/local-mvp.md, change the line about repeated next links to point to ADR 0009. In docs/data-sources.md, describe the page model as offset reads and point to ADR 0009. Out of scope: lib/, test/, all other docs. Acceptance: git diff --stat shows only the four scoped files. diff of $COORD_DIR/artifacts/c0e3a4e7/plan.md and docs/plans/bdl-offset-pagination.md is empty. Report format: annotate the commit SHA and the line 'TESTS: n/a (docs only)'.
STATUS: done. COMMIT: c8a84cad693460502f8b256071c9604cff0cbd9a. TESTS: n/a (docs only). Graph: stale. Plan copy matches the approved artifact. The staged diff contains only the four scoped files.

## Outcome

- Signal: useful

## Source Nodes

- docs_data_sources