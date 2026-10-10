# Overpass response provenance

The worker requested public Overpass data on 2026-10-08 at about 19:32–19:33 UTC.
The client sent `User-Agent: forest_radar source contract research`.
The worker removed one trailing space before a newline in `overpass-500.html`. No content field changed.
No successful Overpass response was available during the first request round.

The worker retried sequentially on 2026-10-08 at 20:03–20:04 UTC.
The query used `[out:json][timeout:25]` and the same User-Agent.
The small node probe returned HTTP 504 from `overpass-api.de` and HTTP 500 from both alternative endpoints.
The range query returned HTTP 504 from `overpass-api.de` and HTTP 500 from `overpass.private.coffee`.
`overpass.kumi.systems` returned JSON for the range query.
A later no-relation query for `(0,0,0.001,0.001)` returned HTTP 500 from that endpoint.

| Fixture | Endpoint and request | Response |
| --- | --- | --- |
| `overpass-500.html` | GET `https://overpass.private.coffee/api/interpreter` with `data=[out:json][timeout:20];rel["type"="route"]["route"~"^(hiking|foot|walking)$"](52.25,20.6,52.35,20.8);out geom(52.25,20.6,52.35,20.8);` | HTTP 500, HTML, 645 saved bytes; 646 original bytes |
| `overpass-504.html` | GET `https://overpass-api.de/api/interpreter` with `data=[out:json][timeout:10];node(52.3,20.7,52.301,20.701);out 1;` | HTTP 504, XHTML, 695 bytes |
| `range-sample.json` | GET `https://overpass.kumi.systems/api/interpreter` with URL encoded `data=[out:json][timeout:25];rel["type"="route"]["route"~"^(hiking|foot|walking)$"](52.25,20.6,52.35,20.8);out geom(52.25,20.6,52.35,20.8);` | HTTP 200, JSON, 337410 bytes |
| `bdl-range-box-page2.json` | GET `https://ogcapi.bdl.lasy.gov.pl/collections/lesnictwa/items?offset=1&bbox=20.6,52.25,20.8,52.35&limit=1&f=json` | HTTP 200, GeoJSON, 719809 bytes |
| `no-relations.json` | GET `https://overpass-api.de/api/interpreter` with URL encoded `data=[out:json][timeout:25];rel["type"="route"]["route"~"^(hiking|foot|walking)$"](0,0,0.001,0.001);out geom(0,0,0.001,0.001);` | HTTP 200, JSON, 287 bytes |

All four Overpass fixture requests used URL encoded `data` parameters. The BDL request had no `data` parameter.
The response bytes are below 1 MiB.
The HTTP status is part of this manifest because the saved bodies do not contain a status line.
The worker also tried the main endpoint with the route query. It returned HTTP 504.
The Maps Mail endpoint timed out after 20 seconds on the small probe and returned no body.
The worker saved the successful JSON body without formatting changes.
It contains 15 route relations and a reported OSM database timestamp of `2026-06-01T08:52:28Z`.
The worker saved the BDL page on 2026-10-08 at about 20:09 UTC without formatting changes.
It contains range 5172, Bagno, in the same search box as the Stage S range 5157 fixture.

The worker retried the small no-relation query at 20:37 UTC on 2026-10-08.
The worker used `[out:json][timeout:25]` and the same User-Agent.
The query selected hiking, foot, and walking route relations in `(0,0,0.001,0.001)`.
The worker requested `out geom(0,0,0.001,0.001)`.
The main endpoint returned HTTP 504. The private.coffee and kumi.systems endpoints returned HTTP 500.
All three responses were HTML. The worker saved no new fixture from this round.

The worker retried the no-relation query at 21:07 UTC on 2026-10-08.
The first endpoint, `overpass-api.de`, returned HTTP 200 and an empty `elements` array.
The worker stopped the round at this JSON success and saved the body without formatting changes.
The response reports OSM database timestamp `2026-10-08T21:06:06Z` and ODbL copyright text.

The sample box has two BDL ranges. The recorded relation geometry contains member way points
inside both range polygons, excluding holes. Range 5157 has crossing relations 120876,
164104, 164112, 223619, 309148, 4168861, and 18481853. Range 5172 has crossing
relations 120876, 132346, 164104, 164112, 223619, 1316339, 1341942, 9121424,
11058923, 16316390, 16651853, and 18481849. These verdicts use the unmodified
`range-sample.json` relation geometry and the two recorded BDL range polygons.
