---
type: "query"
date: "2026-10-08T19:21:41.999839+00:00"
question: "Review Stage S source contract and fixtures on task/26104722"
contributor: "graphify"
outcome: "useful"
---

# Q: Review Stage S source contract and fixtures on task/26104722

## Answer

Goal: Accept or reject the Stage S source contract. Inputs: Branch task/26104722. Read git diff --stat goal/c1ab3a20...task/26104722 and $COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md. Read docs/plans/local-mvp.md sections 'Geographic and source contract' and 'S'. Out of scope: Application code. Re-running live queries. Line-by-line review of large JSON fixtures. Acceptance: Check that source-contract.md covers every source contract item: endpoints, layers, queries, range identity, range-to-district link, WMS formats, and the stand no-geometry option. Check that the trail verdict follows from the cited fixtures. Flag a fixture that holds secrets, personal data, or no provenance. Note whether range-sample.json (24710 lines) should shrink. Report format: Annotate this task with APPROVED or CHANGES_REQUIRED, critical findings, other findings, Graph state, and TESTS: not run; review only.
APPROVED for the zero-area fallback. Critical findings: none.
Reviewed task/26104722 at 845283273059b7d176e2e16a0d0e4a599f50c7d4 and source-contract.md. Only 17 source fixtures changed.
Coverage: The contract records endpoints, layers, queries, retrieval time, range identity, district link, WMS formats, and skipGeometry behavior.
Range 5157 and district 398 share prefix 17-02. The recorded stand retains attributes with null geometry under skipGeometry=true.
The distinct-code fixture contains SC KONNA. The walking-code count is zero. Both sampled trail features are horse trails.
These fixtures support no verified walking-trail intersection. They do not prove that all possible walking sources are absent.
The worker escalated the source gap. The approved fallback remains appropriate.

Other findings:
S1 (warning). source-contract.md:10 and :55 confuse REST identifiers with WMS layer names.
Evidence: tourism-capabilities.xml:235 identifies the horse trail as WMS Name 4. REST tourism-wms-service.json:255 uses id 19.
WMS Name 19 identifies accommodation at touri

## Outcome

- Signal: useful