# Plan for goal 1e0d3d4c: strict selector fakes and the card deadline for OSM

Graph: fresh. Source of the plan: goal/c1ab3a20 at d69d545.

## Base branch

goal/1e0d3d4c starts at main 9e33439. Main does not hold the code yet.
The code lives on goal/c1ab3a20, which is not merged.
The architect does not start a goal from another goal branch.
Stage 1 (this plan review) runs now.
Stage 2 starts after the user merges goal/c1ab3a20 into main and the architect runs `coord goal sync 1e0d3d4c`.

## Facts from the code

- lib/walk_areas/selector.rb: `Selector#select(search:, area:, deadline: nil)` calls `@trails.relations(bbox:, deadline:)`.
- lib/osm/client.rb: `OSM::Client#relations(bbox:, deadline: nil)` caps the request at min(deadline, own cutoff).
- lib/app.rb, `post '/api/card'`: computes `deadline` (monotonic now + 29). It passes it to `model_client.generate`.
  It does not pass it to `settings.selector.select`. This is m9.
- Fakes that accept any keyword (`**`), W3:
  - test/unit/walk_areas/selector_test.rb `Trails#relations(**)`
  - test/unit/app_test.rb `Trails#relations(**)`
  - test/system/support/fixtures.rb `Trails#relations(**)` and `Walk#select(search:, **)`

## Tasks

### T1 (tester): strict fakes and a failing deadline test
Scope: test/unit/app_test.rb, test/unit/walk_areas/selector_test.rb, test/system/support/fixtures.rb.
- Each selector-path fake declares the exact keywords of the real method. No `**` catch-all.
- All fakes require `deadline:` (no default). `Trails#relations` requires `bbox:` and `deadline:`.
  `Walk#select` requires `search:`, `area:`, and `deadline:`.
- Each fake uses or records every keyword it takes, so Lint/UnusedMethodArgument stays quiet. No rubocop disable comments.
- Note: app.rb rescues ArgumentError and returns 422 invalid_input. A fake keyword mismatch on the app path shows as 422.
  So the contract tests are the proof of keyword names, and the deadline test asserts status 200.
- Contract tests, one in each owning test file (test/run.rb runs one process per file; no shared contract file):
  - selector_test.rb: the keyword names of its `Trails#relations` equal those of `OSM::Client#relations`, through `Method#parameters`.
  - app_test.rb: the same check for its `Trails#relations`.
  - fixtures.rb fakes: a check in selector_test.rb or app_test.rb that `Walk#select` names equal `WalkAreas::Selector#select`, and fixtures `Trails#relations` names equal `OSM::Client#relations`. The tester chooses the file.
  - Compare keyword names only. Required vs optional may differ.
- Deadline test in app_test.rb: read the monotonic clock t0 before the request and t1 after it.
  Assert status 200 and t0 + 29 <= recorded deadline <= t1 + 29.
- Mutation checks, local only, not committed. Revert each one.
  (a) rename `bbox:` to `box:` in the Selector call: selector_test fails.
  (b) rename `deadline:` to `limit:` in the Selector call: selector_test fails.
- Out of scope: the model fakes (app_test.rb `Expired#generate`, fixtures `Model#generate`), lib/.
- Acceptance:
  - `bundle exec rubocop lib test` reports 0 offenses.
  - `ruby test/unit/walk_areas/selector_test.rb` exit 0.
  - `ruby test/unit/app_test.rb` fails only in the new deadline test.
  - `coord with-lock system-test -- ruby test/run.rb --system`: the only failures come from the five Walk users:
    m2_m7_facts_test.rb:29, print_test.rb:28, browser_fact_helpers.rb:36 and :63, browser_print_data_helpers.rb:16.
- Report: TESTS line with the counts above, the failing test names, and the result of both mutation checks.

### T2 (backend-developer): pass the card deadline to the selector, commit the decision
Created after T1 lands on goal/1e0d3d4c. The goal branch is red between T1 and T2 by design.
Scope: lib/app.rb, docs/decisions/0008-followup-scope-after-c1ab3a20.md (new). ADRs 0001-0007 exist.
Inputs: goal/1e0d3d4c with T1 landed.
- `post '/api/card'` passes `deadline: deadline` to `settings.selector.select`. No other behavior change.
- Commit the PM decision file verbatim as docs/decisions/0008-followup-scope-after-c1ab3a20.md.
- Acceptance: `ruby test/run.rb --unit` exit 0; `coord with-lock system-test -- ruby test/run.rb --system` exit 0;
  `bundle exec rubocop lib test` 0 offenses; `bundle exec reek lib` 0 warnings.

### R1, R2 (reviewer): one review after each task. Created in stage 3.

## Out of scope
W1, W2, W4, W5. The model fakes. The grapheme gap in public/app.js. The search client deadline. .reek.yml changes are allowed only with a reason comment, and none are expected.

## Merge suite
After both tasks land: `coord goal sync`, then `coord with-lock system-test -- ruby test/run.rb --all` in the goal worktree.
No glossary terms. No ADR beyond the PM decision file.
