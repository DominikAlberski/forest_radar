---
type: "query"
date: "2026-10-10T17:06:47.615677+00:00"
question: "Move README details into docs files and cut README.md to about 50 lines"
contributor: "graphify"
outcome: "useful"
source_nodes: ["readme", "docs_vision"]
---

# Q: Move README details into docs files and cut README.md to about 50 lines

## Answer

Goal: slim README.md to 40-60 lines as the approved plan says. Move each section to its named docs file. Commit the plan as docs/plans/slim-readme.md. Commit ADR 0011 from /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/b600e37f/decision-readme.md. Inputs: /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/b600e37f/plan.md (approved round 2), /Users/dominik/Projects/AI/forest_radar/.maf/coordination/artifacts/b600e37f/decision-readme.md, README.md on goal/b600e37f. Reviewer notes: n1, the private address grep passes when it prints nothing; exit code 1 is fine. n2, write config/model.yml in step 3 as a Markdown link. n3, build the heading check input with one line per file and heading pair. Out of scope: code, tests, docs/model-and-prompts.md, docs/data-sources.md, GLOSSARY.md, all other files. Acceptance: run every command in the plan section 'Acceptance'. Each must pass and print no MISSING line. Run the server check under coord with-lock system-test. Report format: TESTS line, README line count, the output of each acceptance check, the list of moved sections with their destination, the commit hash.
STATUS: done. TESTS: bundle install passed. The unit suite passed. The server returned HTTP 200 under the system-test lock. README line count: 44. The line-count check exited 0 and printed nothing. The README heading check printed no MISSING line. The moved heading check printed no MISSING line. The link check printed no MISSING line. The private address check printed nothing. Moved Stage, The two data questions, and Why this project to docs/vision.md. Moved Language rule to docs/contributing.md. Moved Model configuration and Cache limits to docs/configuration.md. Moved Source limitations to docs/sources.md. Moved Tests and both prerequisite sections to docs/testing.md. The plan is in docs/plans/slim-readme.md. ADR 0011 is in docs/decisions/0011-slim-readme.md. Graph: fresh. Commit: e20292b.

## Outcome

- Signal: useful

## Source Nodes

- readme
- docs_vision