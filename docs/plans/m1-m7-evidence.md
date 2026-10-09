# M1 to M7 evidence

Status date: 2026-10-09. Task: D (acceptance harness). Fixtures are deterministic and labeled. A fixture never stands for a live source.

## Acceptance matrix

| Item | Unit | Browser (`--system`, `test/system/m1_m7_test.rb`) | Live (`--live`) |
| --- | --- | --- | --- |
| M1 page loads, no JavaScript error | `ui_test.rb` | `test_m1_page_loads_without_javascript_error` | — |
| M1 geolocation after a user action | — | `test_m1_geolocation_fills_the_fields_after_a_click`, `..._denial_keeps_typed_coordinates` | — |
| M1 typed coordinates | `app_test.rb` | `test_m1_typed_coordinates_and_radius_reach_the_service` | — |
| M1 radius 1 to 20 km | `app_test.rb` | `test_m1_radius_limits_are_enforced_before_any_request` | — |
| M2 region and district | `bdl/*_test.rb` | card shows district evidence | `BdlLiveTest#test_m2_*` (fails: see L1) |
| M3 stands, attributes, count, cache | `bdl/*`, `cache/*`, `assembler/facts_test.rb` | `test_m7_card_shows_three_nearest_areas...` (years) | `BdlLiveTest#test_m3_*` |
| M4 ban layer, ban fact, no known ban, no "open" promise | `wms/*`, `locales_test.rb` | `test_m4_*`, `test_unknown_ban_and_trail_evidence_*` | `BdlLiveTest#test_m4_*` (fails: see L2) |
| M5 Polish, sections, no unsafe words, under 30 s | `model/*_test.rb`, `app_test.rb` | stub model only | `OllamaLiveTest` — **pending, no endpoint** |
| M6 warning, sanitary link | `locales_test.rb`, `sanepid_test.rb` | `test_m6_card_holds_fixed_warning_and_sanepid_link` | — |
| M7 three nearest forests with distance | `walk_areas/*` | `test_m7_card_shows_three_nearest_areas...`, `test_m7_fewer_than_three_areas...` | — |
| M7 one A4 page | — | `test_m7_card_prints_on_one_a4_page_with_attribution` (passes), `test_m7_maximum_content_card_prints_on_one_a4_page` (fails: C-R2) | — |
| M7 phone at 100 percent | — | `test_m7_phone_viewport_has_no_horizontal_overflow` | — |
| M7 data year, safety warning | `ui_test.rb` | `test_m7_card_prints...` (print text) | — |
| M7 locale strings only | `locales_test.rb` | — | — |
| Error paths (source, model, deadline, no coverage) | `app_test.rb` | `test_error_responses_show_polish_messages_and_no_card` | — |
| External text as text | — | `test_external_text_renders_as_text` | — |
| OpenStreetMap attribution on screen and in print | — | `assert_openstreetmap_attribution`, print text checks | — |

## Fixture labels

The recorded S2 Overpass and BDL responses give fewer than three qualifying areas for one point. The browser fixtures use synthetic square geometry. Names start with `SYNTHETIC`. See `test/system/support/fixtures.rb`.

## Known gaps (not fixed here)

B3-R5, B3-R7, B3-R8, B3-R12, and C-R1 stay open. `test_request_failures_show_polish_text` is skipped for C-R1.

## Defects found by the new tests (need an architect decision)

- **C-R2 (open).** `test_m7_maximum_content_card_prints_on_one_a4_page` fails. Chrome prints the maximum-content card on 3 pages. The print stylesheet (`public/style.css` line 25 and later) has no content budget, and `public/app.js` renders every summary entry and every trail name. The test is not skipped.
- **L1 (live, new).** `forest_range_name` and `inspectorate_name` are the live property names for ranges and districts. `lib/assembler/facts.rb` reads `properties.name`. Live cards show "brak danych" for every area and district name. Evidence: `BdlLiveTest#test_m2_card_facts_carry_the_live_range_and_district_names`.
- **L2 (live, new).** The live ban WMS exposes layers `0`, `1`, `2`. `lib/wms/ban_client.rb` asks for layer `3`. The server answers `LayerNotDefined`, and every live ban status becomes `unknown`. The recorded `bans-capabilities.xml` lists layer 3 and is stale. Evidence: `BdlLiveTest#test_m4_ban_layer_answers_with_a_known_status_for_a_live_district`.
- **Observation.** The OpenStreetMap attribution text on the card is the English `© OpenStreetMap contributors` from the backend. The locale key `ui.osm_attribution` is only a fallback.

## Pending live checks

- Live M5: no Ollama endpoint is supplied. `OllamaLiveTest` fails without `OLLAMA_URL`. Record model identity, host hardware, warm state, timing with retries, Polish output, and rejection checks from its `EVIDENCE` line.
- Live Overpass: no contract on purpose.
