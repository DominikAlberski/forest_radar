---
type: "query"
date: "2026-10-09T09:41:40.983572+00:00"
question: "Review S1 branch task/1fe5ca87: test/system split, CDP support and test lint cleanup"
contributor: "graphify"
outcome: "useful"
---

# Q: Review S1 branch task/1fe5ca87: test/system split, CDP support and test lint cleanup

## Answer

Goal: Review task/1fe5ca87 (S1) against goal/c1ab3a20. Inputs: git diff goal/c1ab3a20...task/1fe5ca87. Spec: coord show 1fe5ca87, and the S1 section and the shared rules in $COORD_DIR/artifacts/c1ab3a20/cleanup-plan.md. T2 notes: $COORD_DIR/artifacts/c1ab3a20/t2-review.md. Check these points. 1: All 18 test cases of the old m1_m7_test.rb remain, and no assertion is lost. test_m7_fewer_than_three_areas became test_m4_crossing_trail_selects_ranges per T2-W3. 2: Browser#call takes only session and timeout from options, with the old defaults. Other keys stay CDP params. 3: Page#wait_for keeps its name, and no caller uses its return value. 4: T2-W1, W2, W3, M1, M3, M4 are applied. 5: No rubocop:disable comment and no reek exclusion are added. 6: The fixtures select fake accepts search: and extra keywords. 7: The SystemFixtures.range keyword rename from id to identifier has no caller outside test/system. Known minor: cdp.rb uses public, private, public sections in one class. Out of scope: running tests, and lib/ and public/. The reviewer reads the TESTS line. Acceptance: write $COORD_DIR/artifacts/c1ab3a20/S1-review.md with a verdict APPROVE or REQUEST_CHANGES. Report format: each finding as critical, warning or minor, with file:line, evidence and fix.
Verdict: REQUEST_CHANGES. Critical 0, warning 1, minor 8. Review: artifacts/c1ab3a20/S1-review.md. Checks 1, 2, 3, 5, 6 and 7 pass. W1 browser_card_helpers.rb:47-56: no ellipsis assertion, so a trail limit up to 70 passes. m1 print_data_helpers.rb:9: advice has 2993 characters. m2 card_helpers.rb:24: every() passes on an empty list. m3 fixtures.rb:76: select no longer requires search:. m4 fixtures.rb:26: range is dead code. m5: four class names end in TestTest. m6 print_data_helpers.rb:56: Open3 is not required. m7 cdp.rb: mixed public and private sections. m8: helper modules depend on each other implicitly. Graph: fresh.

## Outcome

- Signal: useful