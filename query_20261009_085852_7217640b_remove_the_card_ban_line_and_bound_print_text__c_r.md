---
type: "query"
date: "2026-10-09T08:58:52.429746+00:00"
question: "Remove the card ban line and bound print text (C-R2, E-R1)"
contributor: "graphify"
outcome: "useful"
---

# Q: Remove the card ban line and bound print text (C-R2, E-R1)

## Answer

Goal: remove the card ban line and add print length budgets (C-R2, E-R1). Inputs: goal/c1ab3a20 with T1 landed (81fd83b). Spec: section T2 and 'Behavior after the change' in $COORD_DIR/artifacts/398bd3c9/plan.md. Follow every T2 bullet there. T1 removed Selector bans: keyword. Fix the callers in test/system/support/fixtures.rb:99 and test/system/m1_m7_test.rb:169. Keep the session_id: keyword in those callers. Cleanup task L3 removes it later. Out of scope: lib/, test/unit except ui_test.rb and locales_test.rb, docs, rubocop style. Keep test_m7_maximum_content_card_prints_on_one_a4_page unchanged. Acceptance: bundle exec ruby test/run.rb --unit passes. coord with-lock system-test -- bundle exec ruby test/run.rb --system passes. git grep -n -i -E 'zakaz|\bban' -- public config/locales test/system prints nothing. git diff --check passes. Report format: annotate one TESTS line per acceptance command with pass or fail, the list of changed files, and the new test method names.
Note from the T3 review W2: PLAN.md M4 now means mapped trail crossing. Name the trail crossing system test with an m4 prefix if one exists or you add one.
STATUS: done. Graph: fresh. FILES: public/app.js, public/style.css, config/locales/pl.yml, config/locales/en.yml, test/system/m1_m7_test.rb, test/system/support/fixtures.rb. New tests: test_print_hides_fifth_entry_and_shows_remaining_count, test_print_bounds_long_text_and_preserves_safety_text.
TESTS: bundle exec ruby test/run.rb --unit: pass.
TESTS: coord with-lock system-test -- bundle exec ruby test/run.rb --system: pass.
TESTS: git grep -n -i -E zakaz-or-ban -- public config/locales test/system: pass, no matches.
TESTS: git diff --check: pass.

## Outcome

- Signal: useful