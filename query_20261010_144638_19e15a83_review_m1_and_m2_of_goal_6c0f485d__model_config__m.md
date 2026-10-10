---
type: "query"
date: "2026-10-10T14:46:38.650651+00:00"
question: "Review M1 and M2 of goal 6c0f485d: model config, Model::Fallback, Model::Advice, advice_mock"
contributor: "graphify"
outcome: "corrected"
correction: "A leak guard test must never hold the secret it guards, not even as joined parts. Read the needle from ENV or a private file outside the repository and skip when absent."
---

# Q: Review M1 and M2 of goal 6c0f485d: model config, Model::Fallback, Model::Advice, advice_mock

## Answer

Goal: Review the M1 tests and the M2 implementation of plan items D1-D4. Inputs: git diff 6fb110c..d1ec3ea on goal/6c0f485d. Plan: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md items D1-D4, M1, M2, and the Private address rule. M2 report: TESTS 38 unit files pass, RuboCop 0, Reek 0. Live check: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/live-check.md. The online mock result is a known Validator format issue that M4 handles. Out of scope: public/, config/locales/, the Validator format (M4). Do not edit files. Do not print any private address. Acceptance: check the fallback error list, the connect timeout, Advice.wrap, the RACK_ENV guard, the .gitignore line, and that no tracked file holds a LAN address. Report format: VERDICT approve or changes, then findings as critical, warning, or minor with file and line.
VERDICT: changes. Graph: fresh (dispatch query). Static analysis on d1ec3ea: rubocop 0 offenses (86 files), reek 0 warnings. TESTS line in the M2 report: 38 unit files pass. Acceptance checks: the fallback error list matches D2. The connect timeout is min(open_timeout_s, remaining). Advice.wrap matches D4. The RACK_ENV guard is set. The .gitignore line exists, and git check-ignore confirms it. No tracked file holds the literal private prefix. The 10.30.x.x URLs in test/fixtures/sources/tourism-wfs-capabilities.xml come from the upstream BDL WFS response. They are not our address. C1 critical, test/unit/repo_config_test.rb:32 (commit 4a5c97e): private_address joins four string parts into the full private LAN address. The joined value equals the address in the M2 note. This breaks the Private address rule: no committed file holds the address. Failure scenario: someone pushes or shares goal/6c0f485d, and the host address is public in history. Fix: do not commit the address in any form. Read the needle from ENV or from the private model file. Skip with a reason when the needle is absent. Altern

## Outcome

- Signal: corrected
- Correction: A leak guard test must never hold the secret it guards, not even as joined parts. Read the needle from ENV or a private file outside the repository and skip when absent.