# Plan: slim the README (goal b600e37f)

Graph: stale (graphify MCP down). Base: goal/b600e37f synced with main.
Decision source: decision-readme.md in this folder.
No other open goal changes README.md, docs/vision.md, docs/testing.md, docs/sources.md, docs/contributing.md,
docs/configuration.md, or docs/decisions/.
Goals 6c0f485d and b0a7d5d8 change README.md after this goal lands (PM order).

## One task: D1 (backend-developer, docs only)

Scope: README.md, docs/testing.md (new), docs/sources.md (new), docs/contributing.md (new), docs/configuration.md (new),
docs/vision.md, docs/decisions/0011-slim-readme.md (new).

Text map of the current README (140 lines). Each section goes to exactly one place:

| README section | Destination |
| --- | --- |
| Intro: both paragraphs and the repository name | Stays in README unchanged. |
| Stage + "Read these files next" list | docs/vision.md, heading "## Stage". README keeps one link line. |
| Language rule | docs/contributing.md, heading "## Language rule". |
| The two data questions | docs/vision.md, heading "## The two data questions". README keeps one sentence and a link. |
| The mushroom rule | Stays in README. |
| Why this project | docs/vision.md, heading "## Why this project". |
| Run it | Stays in README as the 5 steps below. |
| Model configuration | docs/configuration.md, heading "## Model configuration". |
| Cache limits | docs/configuration.md, heading "## Cache limits". |
| Source limitations | docs/sources.md, heading "## Source limitations". It links to data-sources.md. |
| Privacy | Stays in README. Tighten words only. Keep every fact. |
| Tests, Browser prerequisites, Live prerequisites, evidence record | docs/testing.md, headings "## Tests", "## Browser prerequisites (`--system`)", "## Live prerequisites (`--live`)". README keeps the unit test command and a link. |
| License | Stays in README. |

The 5 run steps:
1. Install Ruby 4.0 and Bundler.
2. Run `bundle install`.
3. Optional: choose the model client in `config/model.yml`. The default `stub` needs no model host. Link docs/configuration.md.
4. Start the server: `bundle exec rackup -p 9292`. Keep the puma alternative on this step.
5. Open `http://localhost:9292/`. Type a latitude, a longitude, and a radius from 1 to 20 km, or press the location button.

Rules:
- Move text verbatim where possible. Do not delete a fact. Fix each relative link that the move breaks.
  A link inside docs/ resolves from docs/.
- README refers to repository files with Markdown links, not with bare backtick paths.
- docs/model-and-prompts.md is out of scope. Goal 6c0f485d edits it.
- English only. No private network address. Keep the placeholders localhost and host.
- ADR 0011 records the decision: README is a short entry page; details live in docs/. The number 0011 is fixed.
  Goal b0a7d5d8 uses ADR 0010.
- Commit the approved plan as docs/plans/slim-readme.md.

Acceptance (run each from the worktree root; each must exit 0 and print no MISSING line):
- `n=$(wc -l < README.md); test $n -ge 40 && test $n -le 60`
- `for h in '# Forest Radar' '## Run it' '## The mushroom rule' '## Privacy' '## License'; do grep -qxF "$h" README.md || echo "MISSING $h"; done`
- Moved headings:
  `while IFS='|' read f h; do grep -qxF "$h" "$f" || echo "MISSING $f $h"; done <<'X'`
  with the lines docs/vision.md|## Stage, docs/vision.md|## The two data questions, docs/vision.md|## Why this project,
  docs/contributing.md|## Language rule, docs/configuration.md|## Model configuration, docs/configuration.md|## Cache limits,
  docs/sources.md|## Source limitations, docs/testing.md|## Tests,
  docs/testing.md|## Browser prerequisites (`--system`), docs/testing.md|## Live prerequisites (`--live`).
- Links: for each file F in README.md, docs/vision.md, docs/testing.md, docs/sources.md, docs/contributing.md,
  docs/configuration.md, docs/decisions/0011-slim-readme.md: extract each Markdown link target with
  `grep -oE '\]\([^)]+\)' F`, drop http, https, and mailto targets, strip a '#anchor', resolve the rest
  from the folder of F, and print `MISSING F target` if `test -e` fails.
- Commands: `bundle install` and `bundle exec ruby test/run.rb --unit` pass.
- Server: `coord with-lock system-test -- sh -c 'bundle exec rackup -p 9292 >/dev/null 2>&1 & p=$!; for i in $(seq 30); do curl -fsS -o /dev/null http://localhost:9292/ && break; sleep 1; done; c=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9292/); kill $p; test "$c" = 200'`
- No private address: `grep -nE '(^|[^0-9.])(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]+\.[0-9]+' README.md docs/vision.md docs/testing.md docs/sources.md docs/contributing.md docs/configuration.md docs/decisions/0011-slim-readme.md` prints nothing.

## Then
R1 reviewer: compare the old README with the new files. Check that no fact is lost and that every link resolves.
S1: goal sync, vault age, merge suite under the system-test lock, goal pr.

## Follow-up owned by other goals
- Goal 6c0f485d adds the root .env model URL. After it syncs with main, its docs work updates docs/configuration.md.
  The sentence "The model host is read from this file only" then needs a fix. Noted in 6c0f485d later-minors.md.
