---
type: "query"
date: "2026-10-09T06:27:10.213058+00:00"
question: "Review ban layer 0 query and live names fix on task/becc425c"
contributor: "graphify"
outcome: "useful"
---

# Q: Review ban layer 0 query and live names fix on task/becc425c

## Answer

Goal: Approve or reject task becc425c. Inputs: Run 'git diff goal/c1ab3a20...task/becc425c'. Read the spec and TESTS note with 'coord show becc425c'. Context: The Entry-ban section of source-contract.md is superseded. The new contract is the REST layer 0 query in the becc425c spec. Do not report drift against the old Entry-ban section. Check these points: an error object, HTTP error, timeout, or bad JSON gives unknown. Only a nonempty features array gives ban. No identify call remains. The lib/assembler/facts.rb names fix reads live range names. Fixtures and PROVENANCE.md mark synthetic files. Out of scope: views, public, test/live, the WMS layer 3 removal reasons. Do not run tests. Acceptance: L1 and L2 are closed or explicitly open. Report format: Write $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/ban-review.md. Each finding has an id, severity (critical, warning, minor), file, and line. Annotate the verdict approve or changes.
STATUS: done. Verdict: approve. Commit: bb45b77. Graph: fresh. L1 closes. L2 handles the recorded live failure. BAN-R1 remains warning: an error object beside features can produce a known status. BAN-R2 is minor: changed Ruby methods exceed five code lines. No critical findings. The query uses the required endpoint and parameters. No identify call remains. Provenance marks synthetic fixtures. No known ban status is proven live. Full evidence and fixes: artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/ban-review.md. TESTS: Worker reports unit pass and diff check pass. Reviewer ran no tests. Four Ruby syntax checks and branch whitespace checks pass. VERDICT: pass

## Outcome

- Signal: useful