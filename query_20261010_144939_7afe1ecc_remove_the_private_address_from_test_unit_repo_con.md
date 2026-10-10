---
type: "query"
date: "2026-10-10T14:49:39.646959+00:00"
question: "Remove the private address from test/unit/repo_config_test.rb and fix the connect timeout test"
contributor: "graphify"
outcome: "corrected"
correction: "For a leak test, read the needle from ENV or a private local file. Never commit the needle as literal, joined parts, or encoding."
source_nodes: ["test_system_support_browser_test_case"]
---

# Q: Remove the private address from test/unit/repo_config_test.rb and fix the connect timeout test

## Answer

Goal: Fix review 7482a7f0 finding C1. Remove the private LAN address in every form from test/unit/repo_config_test.rb. Inputs: goal/6c0f485d at d1ec3ea. Review 7482a7f0 note: C1, W1, m7. Plan /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/6c0f485d/plan.md, Private address rule. Behavior: the leak test reads the needle from ENV['FOREST_RADAR_PRIVATE_ADDRESS'] or from the url host in ~/.config/forest_radar/model.local.yml. The test skips with a reason when neither source exists. No committed file holds the address as a literal, as joined parts, or encoded. Never print the address in output, annotations, or messages. Notes from the same review: W1, in test/unit/model/client_test.rb, set the deadline to clock plus 29, set open_timeout_s 3, and assert open_timeout equals 3. Keep the small remaining case as a second assertion. m7, in test/system/support/browser_test_case.rb, set ENV['RACK_ENV'] to 'test' unless set, before the App loads. Out of scope: lib/, public/, other test files, git history (the architect handles history). Acceptance: ruby test/run.rb --unit passes. bundle exec rubocop lib test reports 0 offenses. git grep -nE '([0-9]{1,3}[.]){3}[0-9]{1,3}' -- test/unit lists no private address part list. Commit before coord done. Report format: TESTS line with counts, rubocop count, the commit id. Do not include the address.
STATUS: done. FILES: test/unit/repo_config_test.rb test/unit/model/client_test.rb test/system/support/browser_test_case.rb. TESTS: ruby test/run.rb --unit passed; bundle exec rubocop lib test reported 0 offenses; scoped address check passed; commit 853a326. NOTES: Graph: fresh. Full unit suite had 1 existing skip. The address pattern scan found one unrelated loopback match in test/unit/app_model_test.rb.

## Outcome

- Signal: corrected
- Correction: For a leak test, read the needle from ENV or a private local file. Never commit the needle as literal, joined parts, or encoding.

## Source Nodes

- test_system_support_browser_test_case