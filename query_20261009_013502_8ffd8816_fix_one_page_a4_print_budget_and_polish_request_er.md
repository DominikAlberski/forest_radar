---
type: "query"
date: "2026-10-09T01:35:02.853841+00:00"
question: "Fix one-page A4 print budget and Polish request errors in public/app.js and public/style.css"
contributor: "graphify"
outcome: "useful"
---

# Q: Fix one-page A4 print budget and Polish request errors in public/app.js and public/style.css

## Answer

Goal: Make the maximum-content card print on one A4 page. Show Polish text for request failures. Inputs: Branch goal/c1ab3a20 at 75bd595 holds landed D. Read C-R1 and C-R2 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/c-review.md. Read D-R1 and D-R2 in /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/d-review.md. C-R2: add a print content budget in public/style.css and public/app.js. Limit summary entries and trail names in print with a visible 'and N more' style locale label if needed. Keep safety warnings, source labels, and OpenStreetMap attribution in print. C-R1: show validated API error messages. Use the locale error text for transport, parse, and render failures. D-R2: in test/system/m1_m7_test.rb, give test_request_failures_show_polish_text a body. Cover a transport failure and malformed JSON. Assert the Polish fallback, a hidden result, and an enabled submit button. Remove the C-R1 skip. Keep test_m7_maximum_content_card_prints_on_one_a4_page unchanged. Out of scope: lib/, views/, config/locales/ (use existing keys; ask me if a new key is needed), other test files, dependencies. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Run 'coord with-lock system-test -- bundle exec ruby test/run.rb --system' with zero failures and zero skips. Report format: Annotate changed paths, commit, Graph state, and a TESTS line with all three results.
MSG from frontend-developer: Print truncation needs a Polish 'and N more' label. Please approve a new ui.more_count locale key or suggest an existing key.
MSG from architect: Decision: approved. Add the key ui.more_count. Polish text: 'i jeszcze %{count}'. English text: 'and %{count} more'. This Polish form avoids plural forms. I add config/locales/pl.yml and config/locales/en.yml to your scope for this key only. No other open task owns these files. Add the key 

## Outcome

- Signal: useful