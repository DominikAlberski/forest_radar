# Plan: clean the code with rubocop and reek (folded goal 76718dbc, now on goal c1ab3a20)

Graph: fresh (vault age 0 commits). Source goal: 76718dbc (closed as superseded). Branch: goal/c1ab3a20.

## Order inside goal c1ab3a20
1. Ban removal T1 (backend lib/unit tests) and T3 (docs) run now. T2 (frontend, C-R2, E-R1) starts after T1 lands.
   Plan: $COORD_DIR/artifacts/398bd3c9/plan.md (approved, review e2ac22e0).
2. This cleanup starts after T1 and T2 land. lib/wms/ban_client.rb is then deleted, so nobody cleans it.

## Baseline (goal/c1ab3a20 at ce87c07, no config files, rubocop 1.91.0, reek 6.5.0)
- rubocop lib test: 430 offenses in 49 files. The PM scan said 436.
- reek lib: 226 warnings. ban_client.rb holds 18 rubocop offenses and 23 reek warnings and goes away.
- Real issues: Security/Eval (test/system/support/cdp.rb:138), Lint/ShadowedException (cdp.rb:60),
  Lint/UselessAssignment (test/unit/bdl/client_test.rb:51), Style/ClassVars (test/system/m1_m7_test.rb:17-18).
- Security/Eval is a false positive. Cdp::Page defines its own `eval` method (CDP Runtime.evaluate).
  The call in `wait_for` calls that method, not Kernel#eval. Decision: rename the method to `evaluate`.
  This removes the name clash, and no Kernel#eval remains.
- Size at the skill limits (method 5 lines, class 100 lines, 4 parameters incl. keywords, line 120):
  lib 52 offenses, test/unit 62, test/system 22, test/live 7.
- With the planned config (review 1): rubocop 540 offenses, reek 227 warnings. After `rubocop -a`:
  L1 40, L2 117, L3 87, S1 66 rubocop offenses. Reek: L2 72, L3 68, the rest in L1 and lib/wms.
- Metrics/ParameterLists offenses (CPR-W3): lib/http/transport.rb:11 (6), lib/bdl/result_builder.rb:7 (7),
  lib/cache/search_cache.rb:11 (6), lib/walk_areas/selector.rb:10 (6), test/unit/bdl/result_builder_test.rb:19 (6),
  test/system/support/cdp.rb:71 (5).

## Config rules (C0 writes them)
- .rubocop.yml: NewCops enable. TargetRubyVersion from the installed Ruby. Metrics/MethodLength Max 5.
  Metrics/ClassLength Max 100. Metrics/ParameterLists Max 4 with CountKeywordArgs true. Layout/LineLength Max 120.
  Keep the other cops at their defaults. Each disabled or changed cop has a one-line reason comment.
  No test-only relaxation of MethodLength (review 1, Q1). TargetRubyVersion: 4.0.
- Naming/MethodParameterName: add x, y, a, b, t to AllowedNames with a reason comment (geometry formulas, CPR-M2).
  .reek.yml accepts the same names for UncommunicativeParameterName and UncommunicativeVariableName.
- Style/Documentation stays enabled for lib: each lib class or module gets a one-line purpose comment (CPR-M3).
  It is disabled for test/ with a reason comment. Reek IrresponsibleModule follows the same rule.
- .reek.yml: exclude nothing in lib. Each disabled smell has a one-line reason comment.
  LongParameterList max_params 4, reason: matches the skill limit and rubocop Metrics/ParameterLists (CPR2-N2).
  Reek runs on lib only. Tests may have a short exclude list in .reek.yml, but the acceptance does not run reek on test.
- Naming/RescuedExceptionsVariableName: PreferredName error, reason: reek flags `e` as an uncommunicative name (C0 review W1).
  Rescue variables keep the name `error`. Do not add `e` to the reek accept list.
- Gemfile: add rubocop 1.91.0 and reek 6.5.0 in a :development group. Update Gemfile.lock with `bundle install --local`.

## Tasks (one owner per path)

C0 backend-developer — "Add rubocop and reek configs and apply safe autocorrect to lib and test"
Scope: .rubocop.yml, .reek.yml, Gemfile, Gemfile.lock, lib/, test/.
Starts after T1 and T2 land. The other cleanup tasks start after C0 lands.
- Add the configs as above. Run `bundle exec rubocop -a lib test`.
  Then run `bundle exec rubocop -A --only Style/FrozenStringLiteralComment lib test` (CPR-W1).
  The frozen comment can raise FrozenError where code mutates a literal. The unit and system suites are the guard.
  Fix such a FrozenError with the smallest change (for example `+''` or `.dup`).
- Manual edits are allowed only to split lines above 120 characters (CPR-W2). Make no other manual refactor.
Acceptance: unit suite passes. System suite passes under the system-test lock.
`bundle exec rubocop lib test --only Layout,Style/FrozenStringLiteralComment` reports 0 offenses. `git diff --check` passes.
Report: the rubocop and reek totals after the task.

L1 backend-developer — "Refactor lib/geo to zero rubocop and reek findings"
Scope: lib/geo/, test/unit/geo/.

L2 backend-developer — "Refactor lib/bdl, lib/http, lib/osm to zero rubocop and reek findings"
Scope: lib/bdl/, lib/http/, lib/osm/, test/unit/bdl/, test/unit/http/, test/unit/osm/.
Reason for one task: HTTP::Transport has 6 keyword parameters, and the bdl and osm clients build it.
The fix changes its signature, so one owner must update all its callers.
- CPR-M4: check test/unit/bdl/client_test.rb:51. The test builds `client` and never uses it.
  Decide if the test must call `client`. Keep or restore the test intent, then fix the offense.

L3 backend-developer — "Refactor lib app, walk_areas, assembler, model, cache, card, sanepid to zero findings"
Scope: lib/app.rb, lib/walk_areas/, lib/assembler/, lib/model/, lib/cache/, lib/card/, lib/sanepid.rb,
test/unit/app_test.rb, test/unit/walk_areas/, test/unit/assembler/, test/unit/model/, test/unit/cache/,
test/unit/card/ (if present), test/unit/sanepid_test.rb.
- CPR-W3: keep `WalkAreas::Selector.new(trails:)` and `Cache::SearchCache.new` with no argument callable as today.
  S1 files call them. Fix the parameter count of Selector#select and SearchCache internals inside lib.
- CPR2-N1: lib/app.rb keeps calling `select` with the `search:` keyword. The S1 system fake
  (test/system/support/fixtures.rb:80) depends on it. Other arguments may change to keywords or a value object.
- T1-M1: remove the unused `session_id:` keyword from Selector#select, lib/app.rb:42, and the unit tests.
  No test/system file calls Selector#select directly. The system fake accepts extra keywords.
- T1-M2: delete the dead method Cache::SearchCache#wms_fetch (lib/cache/search_cache.rb:20).
- T1-W1: test/unit/assembler/facts_test.rb:19 cannot detect a nested ban field. Add a ban field to the input.
  Assert that no F-line key path has a segment equal to "ban".

S1 tester — "Clean test/system, test/live, and shared test files to zero rubocop offenses"
Scope: test/system/, test/live/, test/run.rb, test/test_helper.rb, test/unit/ui_test.rb,
test/unit/locales_test.rb, test/unit/config/.
- Rename Cdp::Page#eval to evaluate. Replace class variables. Fix the shadowed exception.
- Split m1_m7_test.rb (241 lines) into files below 100 lines. Keep every test case and every assertion.
- Record in the report why no eval is needed: Page#eval sent CDP Runtime.evaluate and never called Kernel#eval.
- T2 review notes (artifacts/c1ab3a20/t2-review.md). These are test changes. Keep the card behavior unchanged.
  T2-W1: in the C-R2 long-text test, put each BEFORE marker so that it ends just inside the limit (60, 40, 700).
  Put each AFTER marker so that it starts just after the limit. Assert the ellipsis in print.
  T2-W2: restore the lost check. Add refute_match(/otwart|wstęp wolny|gwarant/i, card_text) to the m6 fixed warning test.
  T2-W3: give one trail crossing system test with the real selector an m4 name. PLAN.md M4 now means trail crossing.
  T2-M1: make the advice 3000 characters. T2-M3: assert the full access warning, the full mushroom warning,
  and the OpenStreetMap attribution in print. T2-M4: check that every .print-more element is hidden on screen.

Shared rules for L1, L2, L3, S1 (they run in parallel):
- No behavior change. Keep every existing test case and assertion. A test may move or get a helper.
- Keep every public method and constructor that code outside the task scope calls.
  If a public signature must change, message the architect first.
- Do not add rubocop:disable comments or reek exclusions. If a finding cannot be fixed, message the architect with the reason.
- Fix reek by design (extract method, value object, rename), not by config.
- New files (CPR-M5): a new file under lib/<dir> or test/unit/<dir> belongs to the task that owns <dir>.
  Other new test files belong to S1.
Acceptance per task: `bundle exec ruby test/run.rb --unit` passes. `bundle exec rubocop <scope>` reports 0 offenses.
For L1-L3: `bundle exec reek <lib scope>` reports 0 warnings.
L2, L3, and S1 also run `coord with-lock system-test -- bundle exec ruby test/run.rb --system` (CPR-W4).
S1 also runs `git grep -n -w eval -- lib test`, which must print nothing (exit 1 is the pass). `git diff --check` passes.

Reviews: one reviewer task per implementation task, after it is done.
Final gate: `bundle exec rubocop lib test` 0 offenses, `bundle exec reek lib` 0 warnings,
and the merge suite `coord with-lock system-test -- bundle exec ruby test/run.rb --all`.
Then push goal/c1ab3a20 so PR 1 updates. Report the before and after numbers.
Fallback if time is short: land L1-L3 first, then S1. The fallback orders the landing only.
The goal stays open until S1 lands (CPR-M1).

## Review 1 (changes): CPR-W1..W4 and CPR-M1..M5 applied above.

## Answered questions (review 1)
- Q1: Should test methods keep the 5-line limit? Answer: yes, keep 5 lines. The test/unit count is 43 MethodLength offenses, which is manageable.
- Q2: Is the L2 grouping right, or should http be a separate foundation task? Answer: yes, keep http in L2.
- Q3: Is the rename of Cdp::Page#eval enough proof for acceptance item 6 (remove eval or prove it is needed)? Answer: yes, with the `git grep -w eval` check in S1.

## Review 2 (approve): CPR2-N1..N3 applied above.
