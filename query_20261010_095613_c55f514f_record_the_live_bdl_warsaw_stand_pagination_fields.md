---
type: "query"
date: "2026-10-10T09:56:13.543190+00:00"
question: "Record the live BDL Warsaw stand pagination fields per page"
contributor: "graphify"
outcome: "useful"
---

# Q: Record the live BDL Warsaw stand pagination fields per page

## Answer

Goal: learn the meaning of numberMatched on later BDL pages. Task 209bf615 saw 5481 on page 1 and 4481 on page 2 of RDLP_Warszawa_wydzielenia. The difference equals the page size 1000. Inputs: $COORD_DIR/artifacts/c0e3a4e7/diagnosis.md. Use the bbox from Geo::Geometry.bbox(52.078247, 21.040624, 20). Read every page of RDLP_Warszawa_wydzielenia with raw HTTP. Follow each next link and ignore the count check. For each page, record the request URL with its offset, numberMatched, numberReturned, the feature count, the first and last feature id, and the elapsed seconds. Then record the total distinct feature ids, any id seen twice, and the total read time. Repeat the full read one more time and say if the numbers are stable. Also check one smaller collection with two or more pages, if one exists in the same bbox. Out of scope: any edit to lib/, test/, public/, or config/. Do not commit. Do not fix. Acceptance: $COORD_DIR/artifacts/c0e3a4e7/pagination.md exists with one table per read and a one-line rule for numberMatched. Report format: annotate 'RULE: <numberMatched rule>', 'EVIDENCE: <totals and times>', and 'TESTS: n/a (diagnosis only)'.
RULE: numberMatched equals the initial match total minus the page offset. It includes the current page.
EVIDENCE: Warsaw returned 4000 distinct IDs in 19.680 and 21.024 seconds. Both reads stopped without a next link. Lesnictwa returned 20 IDs in 8.620 seconds. Graph: stale.
TESTS: n/a (diagnosis only)

## Outcome

- Signal: useful