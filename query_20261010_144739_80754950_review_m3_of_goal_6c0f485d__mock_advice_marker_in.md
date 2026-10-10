---
type: "query"
date: "2026-10-10T14:47:39.173865+00:00"
question: "Review M3 of goal 6c0f485d: mock advice marker in public/app.js and locales"
contributor: "graphify"
outcome: "useful"
---

# Q: Review M3 of goal 6c0f485d: mock advice marker in public/app.js and locales

## Answer

Goal: Review M3, plan item D4 frontend. Inputs: git diff goal/6c0f485d...task/c5f3d813 (commit a610899). Plan: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md items D4 and M3. M3 report: unit suite passes, system test 2 runs 18 assertions, RuboCop 0 offenses. Out of scope: lib/, the Validator format (M4). Do not edit files. Acceptance: check that the marker is a text node from ui.advice_mock, shows only when advice_mock is true, and prints. Check the en locale entry against the en convention of the file. Report format: VERDICT approve or changes, then findings as critical, warning, or minor with file and line.
VERDICT: approve. Graph: fresh (dispatch query). Scope: a610899 on task/c5f3d813, which contains the goal/6c0f485d head. TESTS line: unit suite pass, system test 2 runs 18 assertions, RuboCop 0. My RuboCop run on the two changed test files: 0 offenses. Acceptance: public/app.js:114 appends the marker as a text node from words.advice_mock to the advice h3. It appends the marker only when card.advice_mock is truthy. mock_marker_test.rb checks the marker on screen and in the PDF print. The en entry is an empty string, which matches the en convention of the file. The existing test_polish_values_are_filled_and_english_values_are_empty test enforces this convention. No critical or warning findings. m1 minor, test/system/mock_marker_test.rb:30: advice_heading selects '#card-content section:nth-of-type(2) h3'. A new card section before the advice section breaks the test silently: the test then reads another heading. Fix: give the advice section a class or data attribute in app.js, and select it. m2 minor, test/system/mock_marker_test.rb:22-27: test_non_mock_advice_has_no_marker does not call assert_no_js_errors. A JS error in the non-mock path can then pass unnoticed. Fix: add assert_no_js_errors. m3 minor, test/system/mock_marker_test.rb:18: assert_includes on the whole PDF text does not prove that the marker is in the heading in 

## Outcome

- Signal: useful