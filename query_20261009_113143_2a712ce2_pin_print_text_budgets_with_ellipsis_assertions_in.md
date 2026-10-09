---
type: "query"
date: "2026-10-09T11:31:43.484767+00:00"
question: "Pin print text budgets with ellipsis assertions in test/system support helpers"
contributor: "graphify"
outcome: "useful"
---

# Q: Pin print text budgets with ellipsis assertions in test/system support helpers

## Answer

Goal: Apply the S1 review findings W1, m1, m2, m3, m4, m5 and m6 in test/system. Inputs: goal/c1ab3a20 at f8e5242, which holds S1. Review: $COORD_DIR/artifacts/c1ab3a20/S1-review.md. W1: in browser_card_helpers.rb, the long-text print test must assert the ellipsis directly after each BEFORE marker for trail, area, district and advice. First print the pdftotext output to check for a line wrap before the ellipsis. m1: make the long advice exactly 3000 characters, or state the true count. m2: also assert that at least one .print-more element exists. m3: the select fake in fixtures.rb requires the search: keyword and still accepts extra keywords. m4: delete the unused SystemFixtures.range. m5: rename the classes ErrorsTestTest, M1TestTest, M2M7FactsTestTest and PrintTestTest to drop the double suffix. m6: add require open3 in browser_print_data_helpers.rb. Shared rules of the plan apply: no behavior change in lib or public, keep every test case and assertion, no rubocop:disable comment. Optional: m7 and m8 only if they are small. Out of scope: lib/, public/, test/unit/, test/live/. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop test/system reports 0 offenses. git diff --check passes. Also change the trail budget in public/app.js from 60 to 65 locally, without a commit, run the print test, and confirm that it fails. Then revert the change. Report format: one TESTS line per acceptance command, plus one line for the budget mutation check. List each fixed finding id.
STATUS: done. FILES: test/system. TESTS: unit, system, RuboCop, and diff check pass; 60-to-65 budget mutation fails at the trail ellipsis assertion. FIXED: W1, m1, m2, m3, m4, m5, m6. Graph: fresh.

## Outcome

- Signal: useful