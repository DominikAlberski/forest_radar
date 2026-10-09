---
type: "query"
date: "2026-10-09T01:14:50.021082+00:00"
question: "C: Add Polish search page and printable trip card in views and public"
contributor: "graphify"
outcome: "useful"
---

# Q: C: Add Polish search page and printable trip card in views and public

## Answer

Goal: Implement M1 and M7 and display M4 to M6 evidence. Inputs: Start from goal/c1ab3a20 at 6f2e13b. It contains landed B3. Read section C of /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md, lines 298 to 319. Follow every rule in that section. Read /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/api-contract.md and /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/source-contract.md. In lib/app.rb change only the GET / route: render a view and serve public assets. Move the fixed page title and the 'brak danych' label to locale keys where the view shows them. The fact block has no exclusion reasons (B3-R6). Show a null ban or empty trails as unavailable or unknown evidence. Do not claim that a forest is closed or open. Out of scope: POST /api/card behavior, lib/assembler, lib/model, other lib files, dependencies, test/run.rb, test/system, deferred features. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate changed paths, commit, Graph state, pending browser checks, and a TESTS line with both results.
STATUS: done. FILES: views/index.erb, public/app.js, public/style.css, config/locales/pl.yml, config/locales/en.yml, lib/app.rb, test/unit/ui_test.rb. COMMIT: cd6c128. Graph: fresh. TESTS: bundle exec ruby test/run.rb --unit passed; git diff --check goal/c1ab3a20...HEAD passed. NOTES: Browser checks for phone width and printed A4 remain pending.

## Outcome

- Signal: useful