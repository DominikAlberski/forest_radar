---
type: "query"
date: "2026-10-09T11:34:45.993121+00:00"
question: "Restore the PDF advice assertion and delete SystemFixtures.range in test/system"
contributor: "graphify"
outcome: "useful"
---

# Q: Restore the PDF advice assertion and delete SystemFixtures.range in test/system

## Answer

Goal: Restore the removed PDF assertion for the long advice in the S2 work. Inputs: branch task/8d3a6f0b (S2, done). Start your task branch from task/8d3a6f0b. It already contains goal/c1ab3a20 head. Problem: S2 removed BEFOREADVICE from assert_long_boundaries in browser_card_helpers.rb. That removes a PDF assertion. The shared rule says keep every assertion. Step 1: put BEFOREADVICE back into the PDF text check. Step 2: assert 'BEFOREADVICE' directly followed by the ellipsis in the PDF text, like the other markers. long_advice must stay exactly 3000 characters. If a 687-character word without spaces wraps in pdftotext, use space-separated filler again and adjust the counts. Keep the DOM check assert_long_advice_ellipsis and the .print-more check. Step 3: in the report, explain why long_trails changed from 4 to 5 trails. Note: S1 review m4 is wrong. SystemFixtures.search calls range at fixtures.rb:32. Keep SystemFixtures.range. Out of scope: lib/, public/, test/unit/, test/live/, every other S1 finding. Acceptance: git merge-base --is-ancestor goal/c1ab3a20 HEAD exits 0. bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. bundle exec rubocop test/system reports 0 offenses. git diff --check passes. Also change the advice budget in public/app.js locally without a commit, run the print test, confirm that it fails, and revert. Report format: one TESTS line per acceptance command, one line for the advice budget mutation, one line for the 4-to-5 trail reason.
TESTS: git merge-base --is-ancestor goal/c1ab3a20 HEAD passes. TESTS: bundle exec ruby test/run.rb --unit passes. TESTS: coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. TESTS: bundle exec rubocop test/system reports 0 offenses. TESTS: git diff --check passes. Advice budget mutation: 700 to 701 made the print test fail because the PDF text inserted whitespace before the ellipsis; I reverted it. Trails: long_trails now use

## Outcome

- Signal: useful