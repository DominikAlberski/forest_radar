# Local Forest Radar implementation plan

## Scope and evidence

Status: implementation plan for goal c1ab3a20. Deadline: 2026-10-11.
Graph: fresh
The graph has zero commits since its build.
The repository contains specifications only. No application code or tests exist.
The architect read PLAN.md, README.md, GLOSSARY.md, MVP checks, data sources, model guidance, and both existing decisions.
The architect read review 1, its response, review 2, and all seven manager decision artifacts.
The goal message of 2026-10-08 adds a model stub, a passing full suite, and the deadline.
Revision r3 applies the user decision decision-osm-trail-fallback.md and the accepted Stage S verdict.
Only this goal is open. No shared schema or file conflicts exist with another goal.
GLOSSARY.md remains one shared file. Serialize any later goal that changes GLOSSARY.md.

Deliver M1 through M7 from docs/plans/mvp.md with the approved product decisions below.
Use typed coordinates as the M1 fallback.
Exclude place-name lookup, dog guidance, walking time, M8, publication, submission, accounts, databases, and deployment.
Use Sinatra, Ruby, i18n, and the six approved gems in PLAN.md.
Use Ruby standard library for utility scripts and the browser harness.
Apply the Ruby method, class, parameter, and line limits.
The reviewer checks these limits manually. Obtain reviewer agreement before a deviation.

## Approved product behavior

Use forest ranges from lesnictwa as candidate destination areas.
List a range only when a mapped walking trail crosses the range and no known entry ban applies.
Do not use an inventory stand as a destination.
Return at most three qualifying ranges within the radius, ordered by unrounded distance and then stable range identifier.
Return fewer areas, including zero, when fewer areas qualify.
Show a fixed local access warning on every card, including print output.
A mapped trail and no known ban are listing signals. These signals do not establish permission to enter.
A failed ban query is unknown, not an empty successful response. Exclude unknown candidates from recommendations.
If trail evidence is unavailable, show the limitation and no unsupported recommendations.
Do not infer a trail from a raster color or from an unrelated tourism feature.

Required sources are rdlp, nadlesnictwa, lesnictwa, and the stand collections.
If a time or size limit prevents a complete read of any required source, return an error without a card.
Evidence sources are the ban WMS and the OpenStreetMap trail source. Their failure gives unknown evidence, not an error.
BDL stays the source for RDLP regions, districts, ranges, stands, and bans.
Require model FAKTY and WNIOSKI sections. Validate FAKTY against the fact block.
Render authoritative facts from source data. Render only accepted WNIOSKI as soft advice.
Put the model client behind one interface with two implementations: stub and Ollama.
config/model.yml selects the client. The environment variable FOREST_RADAR_MODEL_CLIENT overrides it.
The default client is stub. Switching to Ollama needs a configuration change only, no code change.
The stub builds a fixed Polish answer in the FAKTY and WNIOSKI format from the fact block.
The stub answer passes the same validation as an Ollama answer.
Read the Ollama address and model only from config/model.yml or the environment. Never read them from a request.
Keep live M5 verification pending until the supplied endpoint passes. Pending live M5 does not block goal closure.
Warm the supplied model before timing. Record the model identity and host hardware.
Measure the first attempt and any retry together. Require elapsed time below 30 seconds.
Use a 29-second application deadline to leave time for validation.

## Geographic and source contract

Use the search bounding box for source selection. Use the radius circle for displayed area selection.
Find the RDLP and district that contain the user location.
If either is absent, return HTTP 422 with a localized no-coverage error.
Do not equate missing coverage with proof that the location lies outside Poland.
Query all RDLP regions, districts, ranges, and stands that intersect the box.
Support Polygon, MultiPolygon, holes, and boundary points.
Project geometry into a local equirectangular plane centred on the user location.
Scale longitude by the cosine of the user latitude. Use Earth radius 6371.0088 km.
Compute distance to the nearest range boundary. Use zero inside the range, excluding holes.
A stand is in the radius when its geometry intersects the radius circle in this plane.
Use the same rule for the radius stand count and the fact block.
Display kilometres with one decimal place. Filter and sort with unrounded values.
Test distances within 0.02 km for fixtures within 20 km.
Label distance as straight-line distance to the area, not a route or trailhead distance.

Read pages of 1000 features. Limit one response to 16 MiB.
Limit a search to 100000 features and 60 seconds of total BDL work, including retries and tourism queries.
If any limit prevents a complete required source read, return HTTP 502 with the incomplete-data locale key.
Retry a BDL request at most two times after a timeout, a connection error, or a 5xx status.
Wait 0.5 seconds before the first retry and 1 second before the second retry. Never retry a 4xx status.
Retries count against the 60-second search budget.
Detect repeated pagination links, malformed pages, and declared count mismatches.
Deduplicate stands by collection plus a_i_num, then collection plus adr_for.
If both identifiers are absent, use a canonical geometry and property digest and report the missing identifier.
Preserve species_cd, site_type, spec_age, sub_area, a_year, forest address, and district identity.
Report complete box and radius stand counts separately. Preserve missing attributes as missing.

Query the ban layer at the geometric centre of each district in the box, as M4 requires.
Record the point and query time. State the limitation when the centre lies outside a concave district.
A district-centre sample cannot prove that no ban exists elsewhere in the range.
Apply a named district ban conservatively to candidate ranges in that district.
For an empty successful sample, use only the label no known ban.
Display unavailable or malformed samples as unknown.

The BDL sources that Stage S checked supplied no verified walking-trail evidence. Layer 61 holds horse trails only.
The user decision makes OpenStreetMap the fallback source for walking trails. BDL keeps all other facts.
Do not use BDL horse trails or tourism points as walking-trail evidence.
BDL layer 75 (educational paths) remains unverified. Under the user decision, this plan does not use it.
A mapped walking trail is an OpenStreetMap route relation with route=hiking, route=foot, or route=walking.
Query the public Overpass API once per search for these relations in the search bounding box, with member way geometry.
Use Net::HTTP and the standard-library JSON parser. Add no gem. Use coord escalate before any dependency.
Send a User-Agent that names forest_radar. Read the Overpass address from configuration, not from a request.
Limit one Overpass response to 16 MiB and 25 seconds. Count the Overpass call against the 60-second search budget.
Retry at most one time after a timeout, a connection error, or a 5xx status. Never retry 429 or another 4xx status.
A trail crosses a range when a member way intersects the range polygon, excluding holes, in the local plane.
Record the relation identifier, name, ref, and route value as evidence for each listed range.
If Overpass fails or answers malformed data, the trail evidence is unknown. The card lists zero areas and states this reason.
If Overpass answers successfully with no crossing trail, the card lists zero areas and states that no mapped trail crosses a nearby range.
The card names OpenStreetMap as the trail source and shows the attribution: © OpenStreetMap contributors, with a link to https://www.openstreetmap.org/copyright.
Verify the Overpass contract in Stage S2 before B2 starts. Record it in osm-contract.md in the goal artifact folder.
Tests use recorded Overpass responses only. No test mode, including --live, calls Overpass.
Stage S2 research is the only live Overpass verification. A live Overpass test needs a new user decision.

## Session cache

Use one Puma process. Protect shared cache access across request threads.
Generate an opaque session identifier with SecureRandom and at least 128 bits of entropy.
Set HttpOnly and SameSite=Lax. Set Secure when HTTPS is used.
Keep datasets out of cookies.
Do not cache raw pages. Cache the compact parsed result of one complete search.
The compact result holds RDLP, district, and range records with geometry.
It holds stand attributes, range links, and the in-radius flag, without stand geometry.
Key the result by session, location, radius, and all query parameters.
Key WMS results by session, layer, and sample point.
Key Overpass trail results by the endpoint and the query text, which includes the bounding box. Do not key them by session.
Cache the parsed relation geometry and tags, not the range intersection results.
Use a 30-minute absolute TTL for successful Overpass results. Never cache a failed or malformed Overpass answer.
Use a 30-minute absolute TTL for search results and a five-minute TTL for successful WMS results.
Use global limits of 256 entries and 128 MiB. Evict least-recently-used entries.
A maximal search of 100000 stands must fit in one entry. Test that this search is reused in the session.
Cache complete successful results only. Never cache errors as empty data.
Expiry, eviction, and application restart end reuse.

## Stage gates and ownership

Create only the current stage tasks. Wait for review approval before document promotion.
Each implementation task receives a separate review after completion.
The reviewer reads the task diff and TESTS line. The reviewer does not run tests.
Land each approved task before creating the next dependent task.
All shared artifacts belong in this goal's coordination artifact folder.
No worker writes an artifact inside a worktree.
No implementation tasks exist during plan review.
Order: A and S run in parallel. B1 starts after S is accepted. Then B2, B3, C, and D run in sequence.
Revision r3 adds A2 and S2. A2 and S2 start after this revision is approved. They run in parallel with B1.
B2 starts after B1, A2, and S2 land.
If time runs short before the deadline, cut the ban check first, as docs/roadmap.md says.
Without the ban check, the card shows the ban status as not checked. The architect informs the manager first.

### A: Commit approved documents

Owner: backend-developer.
Scope: docs/plans/local-mvp.md, docs/decisions/0003-mvp-scope.md, docs/decisions/0004-first-card.md, docs/decisions/0005-ollama-host.md, docs/plans/mvp-decisions/, GLOSSARY.md.
Goal: Commit the approved plan, seven manager decisions, and complete agreed glossary.
Inputs: Shared plan.md, glossary-proposed.md, seven decision artifacts, and reviewer approval.
Out of scope: Application code, dependencies, and unapproved glossary changes.
Acceptance: Run each command in the following block.
Report format: Record changed paths, commit, glossary resolutions, Graph state, and TESTS commands with results.

```sh
git diff --check goal/c1ab3a20...HEAD
cmp docs/plans/local-mvp.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/plan.md"
cmp GLOSSARY.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/glossary-proposed.md"
cmp docs/decisions/0003-mvp-scope.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-mvp-scope.md"
cmp docs/decisions/0004-first-card.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-first-card.md"
cmp docs/decisions/0005-ollama-host.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-ollama-host.md"
cmp docs/plans/mvp-decisions/decision-walk-area.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-walk-area.md"
cmp docs/plans/mvp-decisions/decision-search-completeness.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-search-completeness.md"
cmp docs/plans/mvp-decisions/decision-model-output.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-model-output.md"
cmp docs/plans/mvp-decisions/decision-reference-timing.md "$COORD_DIR/artifacts/c1ab3a20-3f47-440e-92d8-62f15de77ef5/decision-reference-timing.md"
```

### S: Source gate for trails, ranges, and WMS formats

Owner: backend-developer.
Scope: test/fixtures/sources/.
Goal: Verify the live source contracts that B1 and B2 need.
Inputs: This plan, docs/data-sources.md, and decision-walk-area.md.
Out of scope: Application code, dependencies, and other fixture folders.
Acceptance: Write source-contract.md in the goal artifact folder with every item in the source contract section.
Acceptance: Commit one recorded live response per verified endpoint under test/fixtures/sources/. Run `git diff --check goal/c1ab3a20...HEAD`.
Acceptance: The reviewer accepts source-contract.md before B1 starts.
Report format: Record the verdict for trail evidence, the endpoints, fixture paths, commit, Graph state, and TESTS results.

Keep the three previously agreed promotion paths. Store the four new product decisions with the plan.
Do not propose another ADR unless the decision meets all three ADR criteria.

### A2: Commit the revised plan and the OSM decision

Owner: backend-developer.
Scope: docs/plans/local-mvp.md, docs/decisions/0006-osm-trail-fallback.md.
Goal: Commit plan revision r3 and the user decision on the OpenStreetMap trail fallback.
Inputs: Shared plan.md, decision-osm-trail-fallback.md, and reviewer approval of r3.
Out of scope: Application code, GLOSSARY.md, fixtures, and other documents.
Acceptance: Run `git diff --check goal/c1ab3a20...HEAD`.
Acceptance: Run `cmp` of each committed file against its shared artifact.
Report format: Record changed paths, commit, Graph state, and TESTS commands with results.

### S2: Source gate for OpenStreetMap trails

Owner: backend-developer.
Scope: test/fixtures/osm/, test/fixtures/sources/PROVENANCE.md.
Goal: Verify the Overpass contract that B2 needs and record live fixtures.
Inputs: This plan, decision-osm-trail-fallback.md, source-contract.md, and range-sample.json.
Out of scope: Application code, dependencies, and the existing BDL fixture files.
Acceptance: Write osm-contract.md in the goal artifact folder.
Acceptance: Commit recorded live Overpass responses under test/fixtures/osm/ with a PROVENANCE.md manifest.
Acceptance: Run `git diff --check goal/c1ab3a20...HEAD`. The reviewer accepts osm-contract.md before B2 starts.
Report format: Record the endpoint, query, response format, fixture paths, crossing verdict, commit, Graph state, and TESTS results.

Record the endpoint, query text, bounding box, response format, retrieval time, and usage policy notes.
Record one response for the Stage S sample range box. State whether a hiking relation crosses range 5157.
Record one search box with as many crossing ranges as live data give, up to three. Record the BDL range responses for that box.
Record one response with no matching relation. Record a live error response if one occurs.
If no live error occurs, write a labeled synthetic error fixture. Do not provoke rate limits or failures.
Keep each fixture below 1 MiB. Record any formatting change in PROVENANCE.md. Never simplify coordinates silently.
Write test/fixtures/sources/PROVENANCE.md with the exact request URL and parameters for each Stage S fixture.
Correct the Stage S review warnings in source-contract.md. Separate WMS layer names from REST identifiers.
Record BDL layer 75 as unverified and unused.
If no crossing relation exists near the sample range, find one nearby forest range with a crossing relation. Record it.

### B1: Geographic services, complete OGC reads, and cache

Owner: backend-developer.
Scope: Gemfile, Gemfile.lock, config/puma.rb, lib/geo/, lib/bdl/, lib/http/, lib/cache/, test/unit/geo/, test/unit/bdl/, test/unit/http/, test/unit/cache/, test/fixtures/ogc/, test/test_helper.rb, test/run.rb.
Goal: Implement M2, M3, shared transport, and isolated session caching.
Inputs: Landed A and S, source-contract.md, this plan, and docs/data-sources.md.
Out of scope: WMS, candidate eligibility, model calls, routes, views, and browser tests.
Acceptance: Run `bundle exec ruby test/run.rb --unit` and `git diff --check goal/c1ab3a20...HEAD`.
Report format: Record service interfaces, changed paths, commit, Graph state, TESTS results, and external limitations.

Implement the geographic, pagination, completeness, and cache rules above.
Cover borders, holes, range geometry, null attributes, duplicate identifiers, counts, pagination, bounded failures, and cache isolation.
Implement explicit --unit, --system, --live, and --all runner modes.
If a requested suite is absent, fail that mode. B1 requires only --unit.
Document transport and geometry interfaces in shared backend-contract.md before review.

### B2: Ban and OpenStreetMap walking-trail evidence

Owner: backend-developer.
Scope: lib/wms/, lib/osm/, lib/walk_areas/, test/unit/wms/, test/unit/osm/, test/unit/walk_areas/, test/fixtures/wms/, docs/data-sources.md.
Goal: Implement M4 and select forest walk areas from verified trail and ban evidence.
Inputs: Landed B1, A2, and S2, backend-contract.md, source-contract.md, osm-contract.md, decision-osm-trail-fallback.md, and this plan.
Out of scope: Changes to B1 interfaces, model behavior, routes, views, and dependency additions.
Acceptance: Run `bundle exec ruby test/run.rb --unit` and `git diff --check goal/c1ab3a20...HEAD`.
Report format: Record fixture provenance, commit, Graph state, TESTS results, and source limitations.

Implement trail qualification from the Overpass contract that S2 verified. Use the fixtures in test/fixtures/osm/.
Use the B1 transport, geometry, and cache interfaces. Do not change them.
Parse WMS output with the standard library. Use JSON if the source offers it.
Otherwise write a strict parser for the recorded format. Do not add rexml or another gem.
Read ban tables as data. Never render upstream HTML.
Test named bans, empty tables, failures, malformed HTML, and district-centre limitations.
Test trail-range intersection, disjoint trails, unknown evidence, stable ordering, and zero through three eligible areas.
Preserve excluded-area reasons for the card's limitations section.
Test the Overpass cache, the no-retry rule for 429, the 16 MiB limit, and the budget.
Return the trail source name and the attribution with the walk-area result.
Update source documentation from observed contracts. Add OpenStreetMap, its licence, and its attribution.
Do not claim sampling proves access.

### B3: Fact block, model validation, routes, and locale data

Owner: backend-developer.
Scope: config.ru, lib/app.rb, lib/assembler/, lib/model/, lib/card/, lib/sanepid.rb, config/model.yml, config/locales/, test/unit/app_test.rb, test/unit/assembler/, test/unit/model/, test/unit/card/, test/unit/sanepid_test.rb, test/unit/locales_test.rb, test/fixtures/model/, docs/model-and-prompts.md.
Goal: Implement M1 request validation, M5, M6, and the browser API contract.
Inputs: Landed B2, backend-contract.md, source-contract.md, and approved manager decisions.
Out of scope: Geographic services, source adapters, views, browser tests, and deferred features.
Acceptance: Run `bundle exec ruby test/run.rb --unit` and `git diff --check goal/c1ab3a20...HEAD`.
Report format: Record api-contract.md, changed paths, commit, Graph state, TESTS results, and pending live M5 verification.

Validate finite latitude, longitude, and radius. Accept radius values from 1 through 20 km.
Keep GET / and POST /api/card with facts, card, and sanepid_url response keys.
Document nested fields, HTTP statuses, locale keys, errors, and test injection seams in shared api-contract.md.
Use HTTP 422 for invalid input and no coverage. Use HTTP 502 for incomplete or unavailable required source data.
Use HTTP 504 for model deadline expiry. Reject unusable model output with HTTP 502.
Return no generated card on model failure. The interface displays the localized error.

Include displayed ranges, computed distances, evidence, complete stand counts, inventory years, and district summaries in the fact block.
Summarize stands belonging to displayed ranges. Do not replace displayed ranges with three unrelated large stands.
Keep summaries compact and deterministic. Label missing attributes and mixed inventory years.
Define the FAKTY line format in api-contract.md: one line per fact, `F<id>: <value>`.
Each identifier and value must match an entry of the fact block exactly.
A FAKTY line with another format is an unsupported factual addition.
Reject missing sections, unknown identifiers, mismatched values, and unsupported factual additions.
Check WNIOSKI for prohibited words and access promises only.
On any failure, reject the whole answer. Never filter out single lines and keep the rest.
Never render model FAKTY as authoritative facts.
Remove prompt instructions for generated distances and walking time. Test this removal.
Use Polish instructions. Implement the stub and Ollama clients and the configuration rules above.
Test that a request field cannot change the Ollama address. Test client selection by configuration.
Test the Ollama client against recorded HTTP fixtures only.
Reject prohibited words without case sensitivity, including inflections and clear indirect edibility claims.
Reject access promises, including las jest otwarty and wstęp wolny, in generated text and fixed locale values.
Phrase checks cannot prove complete semantic safety. Document the limitation.
Allow at most one retry within the shared 29-second deadline.
Escape external content at rendering boundaries.

Keep the fixed mushroom warning outside generation. Test the instruction not to pick a doubtful mushroom.
Keep all fixed user-facing strings in pl.yml. Keep matching English keys with empty values.
Build the sanitary station URL from its locale template.
Format coordinates with dot decimals and six decimal places. Test negative values and coordinate limits.
Do not add edibility data or species edibility lookup.

### C: Polish page and printable trip card

Owner: frontend-developer.
Scope: views/, public/, config/locales/, test/unit/ui_test.rb.
Goal: Implement M1 and M7 and display M4 through M6 evidence.
Inputs: Landed B3, api-contract.md, source-contract.md, and this plan.
Out of scope: Backend behavior, dependencies, system harness, and deferred features.
Acceptance: Run `bundle exec ruby test/run.rb --unit` and `git diff --check goal/c1ab3a20...HEAD`.
Report format: Record changed paths, commit, Graph state, TESTS results, and pending browser checks.

Transfer locale ownership from B3 only after B3 lands.
Use geolocation only after user action. Preserve typed coordinates after denial.
Show progress, errors, missing attributes, unavailable evidence, and zero results in Polish.
Render at most three forest walk areas with computed distances.
Separate authoritative facts and accepted soft advice visibly.
Show source years, local access uncertainty, the safety warning, and the fixed mushroom warning.
Name OpenStreetMap as the trail source. Show the OpenStreetMap attribution and copyright link, including in print output.
Render external text as text, never markup.
Open the sanitary station link in a new tab with noopener.
Support a phone viewport at 100 percent zoom and one printed A4 page.
Use locale strings for all fixed labels, including JavaScript and print content.

### D: Acceptance harness and reproducible instructions

Owner: tester.
Scope: test/system/, test/live/, test/run.rb, README.md, PLAN.md, docs/plans/m1-m7-evidence.md.
Goal: Add browser and live checks for every M1 through M7 item and document reproducible startup.
Inputs: Landed C, this plan, api-contract.md, source-contract.md, and approved product decisions.
Out of scope: Product fixes, model installation, unapproved dependencies, M8, and publication.
Acceptance: Run `bundle exec ruby test/run.rb --unit` and `git diff --check goal/c1ab3a20...HEAD`.
Acceptance: Run `coord with-lock system-test -- bundle exec ruby test/run.rb --system` for the changed browser harness.
Report format: Record the acceptance matrix, browser prerequisites, commit, Graph state, TESTS results, and unresolved live checks.

Transfer test/run.rb ownership from B1 only after earlier stages land.
Read the browser path from CHROME_PATH. Default to /Applications/Google Chrome.app/Contents/MacOS/Google Chrome.
Read the pdfinfo path from PDFINFO_PATH. Default to pdfinfo on PATH.
Use headless Chrome with a Ruby standard-library driver over its debugging pipe.
Verify the driver during harness development. If the driver needs another dependency, escalate before adding that dependency.
Use a separate temporary Chrome profile and the worktree server port.
Do not run the full --all merge suite as a worker.
Cover geolocation success and denial, typed coordinates, invalid radius, and JavaScript errors.
Cover source failures, model failures, card sections, local access warnings, links, and source years.
Check phone overflow at 100 percent zoom.
Print with paperWidth 8.27 and paperHeight 11.69 inches. Assert Pages: 1 and an A4 page size of about 595 x 842 pt.
Include one fixture with three qualifying areas and one fixture with fewer than three.
Build the area fixtures from the recorded S2 Overpass responses and the recorded BDL responses.
If the records give fewer than three qualifying areas, use a labeled synthetic geometry fixture for the three-area case.
Include one fixture with unknown trail evidence. Check the OpenStreetMap attribution on screen and in print.
Use deterministic HTTP fixtures for browser checks. Label fixture evidence explicitly.
Add live contracts for BDL, ban parsing, and the supplied Ollama endpoint. Add no live Overpass contract.
Record model identity, host hardware, warm state, timing including retries, Polish output, and rejection checks.
A fixture cannot satisfy live M5. A missing endpoint must fail the --live suite.
Use the stub client in --unit and --system. The --all suite runs --unit and --system only.
Document cache limits, startup, model configuration, and source limitations.
Remove dog guidance promises from README.md.
Correct privacy claims in README.md and PLAN.md: BDL and the Overpass API receive location queries; Maps receives location after link activation.
The configured model host also receives the fact block. Explain that host boundary.

## Review, merge, and closure

Inspect each completed task diff against goal/c1ab3a20 and its TESTS line. Do not rerun worker tests.
Create one reviewer task after each implementation task. Name the task branch in Inputs. Omit --scope.
If a bug needs correction, create a tester regression task before the fix task.
Name the regression branch in the fix Inputs. Worktrees do not share commits.
After two rejected fixes of the same kind, send the manager two or three options with costs.
After approval, land each task with coord land and a Conventional Commits subject.
After all tasks land, run coord goal sync for this goal.
Run vault age and record the graph state.
Source the goal worktree .maf/env.sh.
Run the merge suite once on the merged result:

```sh
coord with-lock system-test -- bundle exec ruby test/run.rb --all
```

The --all suite includes unit and browser checks with the stub client. Missing prerequisites fail the suite.
Run --live only when the author supplies the Ollama endpoint. Take the ollama lock for that run.
Do not close the goal while any task remains open. Report live M5 and live source checks as pending.
The shared .maf/config.json currently has no github section. Recheck the configuration before closure.
Report the outcome and Graph state to the project manager.

## Community evidence

Prior plan research supports deterministic provider fixtures plus separate live contract checks.
The sources do not establish BDL service behavior or access rights.
Source: https://dev.to/jayeshjain01/how-to-test-applications-with-external-apis-strategies-and-solutions-22ec
Source: https://dev.to/ankitjaininfo/your-openapi-spec-is-gaslighting-your-tests-catch-contract-drift-1cfj
