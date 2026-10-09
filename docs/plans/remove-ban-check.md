# Plan: remove the entry ban check (goal 398bd3c9)

Graph: fresh (vault age 0 commits at goal/c1ab3a20 ce87c07).

## Base branch
Revised 2026-10-09: the user refused to merge PR 1 (goal/c1ab3a20) until the code quality improves.
The PM folded goals 398bd3c9 and 76718dbc into goal c1ab3a20. All tasks land on goal/c1ab3a20 (base ce87c07).
PR 1 then gets the fixes. The earlier wait-for-merge gate is void. Goal 398bd3c9 is closed as superseded.

## Affected code (read on goal/c1ab3a20)
- lib/wms/ban_client.rb: the WMS/REST ban client. lib/app.rb:8,23 requires it and passes `bans:` to the selector.
- lib/walk_areas/selector.rb: samples a ban per district. It excludes ranges with `:ban_unknown` and `:known_ban`. It adds `ban:` to each range.
- lib/assembler/facts.rb: copies `ban:` into each area. The facts lines (F1..Fn) go to the model, so ban data reaches the prompt.
- public/app.js:56-57: the card line "Informacja o zakazie wstępu".
- config/locales/pl.yml and en.yml: keys ban, ban_reported, no_known_ban, ban_unknown.
- Tests: test/unit/wms/ban_client_test.rb, test/unit/app_test.rb, test/unit/walk_areas/selector_test.rb,
  test/unit/assembler/facts_test.rb, test/system/m1_m7_test.rb, test/system/support/fixtures.rb, test/live/bdl_live_test.rb.
- Fixtures: test/fixtures/sources/bans-*.{xml,json} (4 files) and their entries in PROVENANCE.md.
- Docs: PLAN.md, README.md, docs/data-sources.md, docs/model-and-prompts.md:146, GLOSSARY.md:73.

## Behavior after the change
- The program sends no request to a ban source.
- The selector lists a range when a mapped trail crosses it. Exclusion reasons are only
  `:trail_unavailable` and `:no_mapped_trail`. An unknown ban no longer excludes a range.
- The facts and the model prompt hold no ban field.
- The card has no ban line. No card text states a ban, the absence of a ban, or an unknown ban status.
- The safety text `card.access_warning` ("Przed spacerem sprawdź aktualne zasady wstępu do lasu.") stays.
  It is a general reminder, not a ban statement.
- C-R2: in print, variable text has a length budget. Each list entry (trail name, summary entry)
  prints at most 60 characters with an ellipsis. The model advice prints at most 700 characters
  with a visible omission label. Range names print at most 60 characters. The district line prints at most
three names of at most 40 characters each, plus an "i jeszcze N" label (PLAN-R2). The ellipsis counts toward
the limit. The screen keeps the full text. Safety warnings and attribution print in full.
- E-R1: browser tests assert the truncation contract (see T2).

## Tasks (one owner per path)

T1 backend-developer — "Remove the ban client from lib, unit tests, live tests, and fixtures"
Scope: lib/wms/, lib/app.rb, lib/walk_areas/selector.rb, lib/assembler/facts.rb, test/unit/wms/,
test/unit/app_test.rb, test/unit/walk_areas/selector_test.rb, test/unit/assembler/facts_test.rb,
test/live/bdl_live_test.rb, test/fixtures/sources/.
Tests (PLAN-R5): selector tests for trail-only selection, for a range whose district has no ban data,
and for both remaining exclusion reasons. Facts tests assert that the facts and the F-lines hold no ban key.
Acceptance: `bundle exec ruby test/run.rb --unit` passes. `git grep -n -i -E "ban_client|BanClient|bans:|ban:|no_known_ban|ban_unknown|known_ban" -- lib test/unit test/live test/fixtures` prints nothing.
`git diff --check` passes. System tests may fail until T2 lands (T2 owns test/system).

T2 frontend-developer — "Remove the card ban line and bound print text (C-R2, E-R1)". Starts after T1 lands.
Scope: public/, config/locales/, test/system/, test/unit/ui_test.rb, test/unit/locales_test.rb.
- Remove the ban line and the four locale keys in pl.yml and en.yml.
- Remove `Bans` and `bans:` from test/system/support/fixtures.rb and the ban tests in m1_m7_test.rb.
- Add the print budgets above. Add any new label to both locale files.
- E-R1 (PLAN-R3): add a separate system test. Use a unique text for the fifth entry. On screen: the fifth
  entry is visible and the "i jeszcze N" label is hidden. In print: the fifth entry is absent and the label shows the correct N.
- C-R2: add a separate system test with four 200-character trail names and a 3000-character advice.
  Use three areas, long range names, long district names, wide characters, and line breaks (PLAN-R2, Q1).
  It prints on one A4 page and the printed text holds the mushroom warning and the OpenStreetMap attribution.
  Put a unique marker before and after each limit. Assert the marker before the limit prints and the marker after it does not.
  Assert the omission labels in print. Assert the full texts on screen (PLAN-R3).
- Assert that the card keeps the access warning (PLAN-R5).
- Keep test_m7_maximum_content_card_prints_on_one_a4_page unchanged.
- E-R2 note: keep each new test method within the Ruby method length limit.
Acceptance: `bundle exec ruby test/run.rb --unit` passes. `coord with-lock system-test -- bundle exec ruby test/run.rb --system` passes.
`git grep -n -i -E "zakaz|\bban" -- public config/locales test/system` prints nothing.

T3 backend-developer — "Update docs, glossary, and add ADR 0007 for the ban removal". Runs in parallel with T1.
Scope: PLAN.md, README.md, docs/data-sources.md, docs/model-and-prompts.md, GLOSSARY.md,
docs/decisions/0007-remove-entry-ban-check.md, docs/plans/remove-ban-check.md.
- Commit this approved plan as docs/plans/remove-ban-check.md.
- Commit the decision text from artifacts/398bd3c9/decision-remove-ban-check.md as ADR 0007.
- Remove the ban layer from PLAN.md, README.md, and docs/data-sources.md. Note the removal and its reason in data-sources.md.
- docs/model-and-prompts.md:146: drop the reference to the ban layer.
- GLOSSARY.md: apply the agreed terms from glossary-draft.md.
Out of scope: historical records docs/plans/local-mvp.md, m1-m7-evidence.md, mvp.md, mvp-decisions/, docs/decisions/0001-0006, docs/blog-outline.md, docs/roadmap.md, docs/session-log.md.
Acceptance: `git grep -n -i -E "ban layer|entry ban|no known ban" -- PLAN.md README.md docs/data-sources.md docs/model-and-prompts.md` prints only the removal note. `git diff --check` passes.

Reviews: one reviewer task per implementation task, after it is done.
Merge suite: `coord with-lock system-test -- bundle exec ruby test/run.rb --all` in the goal worktree.

## Review 1 (approve): PLAN-R1..R5 applied above and in glossary-draft.md.

## Open questions for the reviewer (answered: keep both)
- Q1: Is 60 characters per entry and 700 characters of advice a fair print budget?
- Q2: Should GLOSSARY keep the "Zakaz wstępu do lasu" term? The plan keeps it: the concept exists in the domain, and the access warning relates to it.
