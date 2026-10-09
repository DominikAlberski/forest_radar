---
type: "query"
date: "2026-10-09T01:31:36.576268+00:00"
question: "Fix live range and district names in lib/assembler/facts.rb and the ban WMS layer in lib/wms/ban_client.rb"
contributor: "graphify"
outcome: "corrected"
correction: "The BDL ban MapServer layer 0 query returns HTTP 400 and identify hides it with empty results. Treat any layer 0 error as unknown ban status, never as no ban."
---

# Q: Fix live range and district names in lib/assembler/facts.rb and the ban WMS layer in lib/wms/ban_client.rb

## Answer

Goal: Make live cards show range and district names and real ban status. Inputs: Branch goal/c1ab3a20. Read L1 and L2 in docs/plans/m1-m7-evidence.md on branch task/dd23e747. Read test/live/bdl_live_test.rb on that branch. L1: lib/assembler/facts.rb reads properties.name. The live keys are forest_range_name for ranges and inspectorate_name for districts. Read the live keys first and keep 'brak danych' as the fallback. L2: lib/wms/ban_client.rb asks for WMS layer 3. The live service has layers 0 to 2. Fetch the live GetCapabilities. Pick the layer that holds entry bans. Refresh test/fixtures/sources/bans-capabilities.xml and the matching sample files. Update test/fixtures/sources/PROVENANCE.md with the date and the source URL. Out of scope: lib/cache, other lib files, views, public, test/system, test/live, dependencies. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. Report format: Annotate changed paths, the chosen layer id and its title, commit, Graph state, and a TESTS line with both results.
MSG from backend-developer: The live WMS capabilities list only Leśnictwa, Nadleśnictwa, and RDLP. The entry ban is ArcGIS REST layer 0. I will query REST layer 0 to return real ban status.
MSG from architect: Decision: approved. Query ArcGIS REST layer 0 of WMS_zakazy_wstepu_do_lasu/MapServer. I checked it live: layer 0 is the periodic entry ban layer. Keep these constraints. Stay in lib/wms/ban_client.rb and the files in your scope. Use the existing HTTP transport, the same host, and the deadline. Add no dependency. Send the point in WGS84 (inSR 4326) and ask for no geometry. Keep the result shape: ban, no_known_ban, or unknown, with point, sampled_at, and centre_outside. Return unknown on every error, as now. Pass a new cache layer key such as 'rest-0' so old WMS cache entries do not mix. Record a live REST sample as a fixture and record the URL and date in PROVENANCE.md. Report the endpoint and the query 

## Outcome

- Signal: corrected
- Correction: The BDL ban MapServer layer 0 query returns HTTP 400 and identify hides it with empty results. Treat any layer 0 error as unknown ban status, never as no ban.