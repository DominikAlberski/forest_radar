---
type: "query"
date: "2026-10-09T06:23:03.204025+00:00"
question: "Replace REST identify with layer 0 query in lib/wms/ban_client.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Replace REST identify with layer 0 query in lib/wms/ban_client.rb

## Answer

Goal: The ban client must report unknown when the live source cannot prove a status. Inputs: Start from branch task/fb7a8d81 at commit 7a4e874. Keep its names fix in lib/assembler/facts.rb. Read the architect decision note on task fb7a8d81 at 01:31:18Z. Problem: task fb7a8d81 uses REST identify. Live identify on layer 0 returns an empty result everywhere. So every card shows no_known_ban, and that is a false safety claim. Required behavior: Call /ArcGIS/rest/services/WMS_zakazy_wstepu_do_lasu/MapServer/0/query with the district centre point. Send geometryType esriGeometryPoint, inSR 4326, spatialRel esriSpatialRelIntersects, outFields '*', returnGeometry false, f json. A features array with items means ban. An empty features array means no_known_ban. An error object, an HTTP error, a timeout, or bad JSON means unknown. Do not use identify. Keep the cache layer key 'rest-0', the transport, the deadline, and the result shape. Fixtures: Record the live 400 answer of this query as a fixture. Remove bans-identify.json. Update PROVENANCE.md with the query URL, the date, and the 400 answer. Tests: The live 400 fixture gives unknown. A synthetic features fixture gives ban. A synthetic empty features fixture gives no_known_ban. Mark the synthetic fixtures as synthetic in PROVENANCE.md. Out of scope: lib/assembler, other lib files, views, public, config, test/system, test/live, dependencies. Acceptance: Run 'bundle exec ruby test/run.rb --unit'. Run 'git diff --check goal/c1ab3a20...HEAD'. Both must pass. A live known ban status is not required. Report format: Annotate changed paths, the endpoint and parameters, commits, Graph state, and a TESTS line with both results.
STATUS: done. FILES: lib/wms/ban_client.rb, test/unit/wms/ban_client_test.rb, test/fixtures/sources/. ENDPOINT: /ArcGIS/rest/services/WMS_zakazy_wstepu_do_lasu/MapServer/0/query. PARAMS: geometry, geometryType=esriGeometryPoint, inSR=4326, spatialRel=esriSpatialRelIntersects, outFields=*, returnGeometry=false, 

## Outcome

- Signal: useful