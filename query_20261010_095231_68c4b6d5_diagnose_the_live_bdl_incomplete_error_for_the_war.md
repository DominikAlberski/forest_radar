---
type: "query"
date: "2026-10-10T09:52:31.135151+00:00"
question: "Diagnose the live BDL Incomplete error for the Warsaw 20 km search"
contributor: "graphify"
outcome: "useful"
---

# Q: Diagnose the live BDL Incomplete error for the Warsaw 20 km search

## Answer

Goal: find the exact cause of errors.source for lat 52.078247, lon 21.040624, radius_km 20. Only BDL::Incomplete maps to errors.source in lib/app.rb. OSM::Client swallows its own errors, so BDL is the likely source. Confirm this with a live run. Inputs: goal branch goal/c0e3a4e7 (equal to main). Read lib/bdl/client.rb, page_state.rb, search_state.rb, result_builder.rb, geometry_validation.rb. Run BDL::Client.new.search with the three values against the live service. Catch BDL::Incomplete and record its message. Record the collections read, numberMatched per collection, the region_cd values, the elapsed time per collection, and the total time. Also run the same search through POST /api/card on a local server, and record the HTTP status and body. If the message is 'ambiguous', record the matched feature ids. Candidate causes: the 60 s search deadline, the 100000 feature limit, an unknown region code, an ambiguous link, malformed geometry, or count changed. Out of scope: any edit to lib/, test/, public/, or config/. Do not commit code. Do not fix the cause. Acceptance: the file $COORD_DIR/artifacts/c0e3a4e7/diagnosis.md exists. It names the raised exception class and message, the code line that raised it, and the live numbers above. It also gives one smallest reproduction command. Report format: annotate 'CAUSE: <class>: <message> at <file:line>', 'EVIDENCE: <key numbers>', and 'TESTS: n/a (diagnosis only)'.
CAUSE: BDL::Incomplete: count changed at lib/bdl/page_state.rb:40
EVIDENCE: Warsaw count changed from 5481 to 4481. Search took 33.947 seconds. API returned 502. Graph: stale.
TESTS: n/a (diagnosis only)

## Outcome

- Signal: useful