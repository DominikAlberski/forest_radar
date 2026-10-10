# Plan: read all BDL pages by offset (goal c0e3a4e7)

Graph: stale (15 commits since build).

## Problem

The search at lat 52.078247, lon 21.040624, radius 20 km returns errors.source (HTTP 502).
Evidence: diagnosis.md, pagination.md, offsets.md in this artifact folder.

- BDL::Incomplete 'count changed' is raised at lib/bdl/page_state.rb:40.
- BDL reports numberMatched on a page as the first-page total minus the page offset.
  Warsaw stands: 5481, 4481, 3481, 2481, 1481, 481.
- BDL adds a next link only when offset + limit < numberMatched of that page.
  So the next links stop early: Warsaw gives 4000 of 5481, lesnictwa 20 of 25.
- Requests at explicit offsets return all features: 5481 distinct Warsaw ids, 25 lesnictwa ids.
- The current count checks correctly refuse the short read. Only the pagination rule is wrong.
- Every search with more than one page in one collection fails the same way.
- OSM is not involved: OSM::Client catches its own errors.
- Timing: one 1000-feature Warsaw page takes 3 to 7 s. Six pages in sequence take about 30 s.
  Six pages at the same time take 6.8 s. The full search with sequential pages takes about 55 s of the 60 s budget.
- The card deadline (29 s) in lib/app.rb starts before the BDL search.
  A search longer than 29 s makes the selector and the model start after the deadline. The result is errors.deadline.
- A limit of 10000 returns 27.5 MB. This breaks the 16 MiB response limit. Keep pages of 1000.

## Decisions

D1. Read BDL pages by offset. Ignore the next link.
- The first page (offset 0) gives the total T = numberMatched.
- If T exceeds the remaining feature limit, raise Incomplete 'feature limit' before more requests.
- Request offsets PAGE_SIZE, 2 x PAGE_SIZE, ... below T. Use the same path, bbox, limit, and f=json.
- A page at offset o must report numberMatched = T - o. Else raise Incomplete 'count changed'.
- A page at offset o must hold min(PAGE_SIZE, T - o) features. Else raise Incomplete 'count mismatch'.
- The finish check stays: the feature total must equal T.
- Keep the page order of the result: offset order.
- The 'foreign page' and 'repeated page' checks lose their purpose. Remove them with the next-link code.
- The checks apply at offset 0 too. The first page must hold min(PAGE_SIZE, T) features. T = 0 makes no more requests.
- PAGE_SIZE stays 1000 by default. API: BDL::Client.new(transport:, clock:, page_size: 1000, concurrency: 4).
  Client passes page_size and concurrency to PageReader. PageReader passes page_size to PageState.start.

D2. Fetch the pages after the first page at the same time, at most 4 requests at once.
- Each request keeps the transport retries and the shared 60 s search deadline.
- The first error stops the read. The error reaches the rescue in lib/bdl/client.rb (features) in the caller thread.
  The caller then raises Incomplete as today. Set report_on_exception to false on each worker thread.
- Do not leave a running thread after the read returns or raises.
- Why 4 and not 6: 4 keeps the load on the public BDL API low. Warsaw needs 5 pages after the first page.
  So 4 gives two waves of about 7 s. Expected Warsaw read: about 20 s. Expected full search: about 43 s of 60 s (measured collections sum to about 23 s, plus about 20 s Warsaw).

D3. Start the 29 s card deadline after the BDL search returns, in lib/app.rb.
- The deadline covers the OSM selector and the model, as goal 1e0d3d4c (m9) and docs/plans/local-mvp.md intend.
- The BDL search keeps its own 60 s budget.
- Seam: App gets the setting clock (a lambda that returns the monotonic time). lib/app.rb reads the time only through settings.clock.
- New upper bound of one card request: about 60 s BDL plus 29 s card, so about 89 s. ADR 0009 records this bound.

D4. Log each failed source request as one line on stderr (scope change from the PM, approved by the user).
- New module lib/source_log.rb. One SourceLog object writes one line per failure to an IO. The default IO is $stderr.
- App gets the setting source_log. Tests replace it with a SourceLog on a StringIO.
- Sources: bdl (the search call), osm (the trail request), model (the generate call). Each source logs once per failed call.
- BDL and model: lib/app.rb measures the elapsed time around the call through settings.clock. The rescue logs, then halts as today.
- OSM: OSM::Client#relations swallows errors and returns nil. So OSM::Client gets a log: keyword (default: no log) and a clock: keyword (default: monotonic time). Its rescue logs, then returns nil as today.
- Wiring: App configure builds one SourceLog. It sets source_log to that object and builds OSM::Client.new(log: source_log) with the same object.
- Model: every model rescue class in lib/app.rb logs one model line: Model::Deadline, Model::Invalid, IOError, SystemCallError, Timeout::Error.
- BDL: BDL::Incomplete logs one bdl line. BDL::NoCoverage is an expected outcome and writes no line.
  Known gap: a TypeError or ArgumentError from the search goes to the 422 invalid_input rescue and writes no line.
- Line format: 'source=<bdl|osm|model> error=<class> message="<message>" elapsed_ms=<integer>'.
- Privacy: the line never holds coordinates, a bbox, a URL, a query, the session id, or the request body.
  SourceLog removes each URL (http:// or https:// up to the next space) from the message.
  It replaces each decimal number with "<num>". A decimal number is an optional minus sign, digits, a dot or a comma, and digits.
  Integers, such as HTTP status codes, stay. SourceLog replaces each control character, such as a line break, with a space.
  It escapes each double quote as \". Then it cuts the message to 200 characters. One failure always gives exactly one line.
  The session id never enters the message. The app flow test checks this with the session cookie set, not through the scrub.
- Config/puma.rb stays as is: Puma in the foreground writes stderr to the terminal.
- The response bodies stay the same. No new locale key.
- This replaces the round-2 D4 (rack.errors line 'BDL incomplete: <message>').

ADR 0009 records D1: "Read BDL pages by offset, not by next links".
Reason: the BDL server builds next links from the reduced numberMatched. A later reader will want to restore next links.

## Tasks (in order)

The unit suite command is ruby test/run.rb --unit.

S2-0. backend-developer: commit this plan and ADR 0009. Done and landed (74548cc).
S2-1. tester (task 59296b4a): failing tests for D1 to D3. Scope test/unit/bdl/, test/fixtures/ogc/, test/unit/app_test.rb.
  - Fixtures in the live shape: decreasing numberMatched, no next link after the early stop.
  - A three-page read with page size 1 and T = 3 returns three features at offsets 0, 1, 2.
  - A wrong numberMatched on a later page raises 'count changed'. A short page raises 'count mismatch'.
  - T above the limit raises 'feature limit' after one request.
  - The requests do not follow a next link to another host.
  - The selector deadline starts after the search: a fake search that advances the clock still leaves 29 s.
  - D2: a fake transport counts requests in flight under a mutex. With concurrency 4 and 6 later pages, the maximum in flight is above 1 and at most 4.
  - D2: an error on one later page raises Incomplete. After the read, no thread that the read started is alive.
  - Fake transports return bodies keyed by the offset param, not by call order.
  - D3 uses the App setting clock. A fake search advances the fake clock. The selector deadline equals the clock after the search plus 29.
  - Update the existing pagination fixtures and tests that assume a constant numberMatched.
  - The tests fail on main only for the missing behavior, not for load or syntax errors outside the new API.
  - The rack.errors log test is removed. L1 owns the log tests.
  - Acceptance: rubocop on the test files reports 0 offenses.
L1. tester: failing tests for D4. Runs in parallel with S2-1. Scope test/unit/source_log_test.rb, test/unit/app_log_test.rb, test/unit/osm/.
  - SourceLog writes the exact line format. It removes a URL and replaces decimal numbers. Integers stay. It cuts long messages.
  - A message with a line break and a double quote gives one line with a space and an escaped quote.
  - App: a fake search that raises BDL::Incomplete gives 502 and exactly one bdl line with the fake clock elapsed time.
  - App: a fake model that raises Model::Deadline gives 504 and one model line. Model::Invalid gives 502 and one model line.
  - App: a fake model that raises SystemCallError gives 502 and one model line.
  - App: BDL::NoCoverage gives 422 and no line.
  - App wiring: the OSM client that configure builds uses the same SourceLog as settings.source_log.
  - App: a successful card writes no line.
  - OSM: a transport error gives nil and one osm line with the fake clock elapsed time. A good response writes no line.
  - Privacy: the fake error messages hold the request lat and lon, a URL with a bbox, and a query with decimals.
    The test asserts that none of these reach the line. The app test sets the session cookie and asserts that the session id is absent.
  - Acceptance: bundle exec rubocop on the L1 test files reports 0 offenses.
    ruby test/run.rb --unit loads all files. The L1 tests fail on the goal head only for the missing behavior.
L2. backend-developer: implement D4. Scope lib/source_log.rb, lib/app.rb, lib/osm/client.rb, docs/plans/bdl-offset-pagination.md.
  Acceptance: the L1 tests pass. ruby test/run.rb --unit passes. bundle exec rubocop lib test and bundle exec reek lib report 0 offenses.
  Inputs: the L1 branch. Update the committed plan copy to this revision.
  L2 adds the App setting clock (the D3 seam), because L2 lands before S2-2. S2-2 moves the deadline start only.
  Live: start the app on the goal head without the fix. POST /api/card for lat 52.078247, lon 21.040624, radius 20 km.
  Record the stderr line in $COORD_DIR/artifacts/c0e3a4e7/repro-log.md. The expected line: source=bdl error=BDL::Incomplete message="count changed".
R1. reviewer: review L1 and L2.
S2-2. backend-developer: fix D1 to D3. After L2 lands, because both edit lib/app.rb.
  Scope lib/bdl/page_state.rb, lib/bdl/page_reader.rb, lib/bdl/client.rb, lib/app.rb. Inputs: the S2-1 branch.
  Acceptance: the S2-1 and L1 tests pass. ruby test/run.rb --unit passes. bundle exec rubocop lib test and bundle exec reek lib report 0 offenses.
  Live: the same Warsaw search returns 5481 Warsaw stands. With the stub model (config/model.yml default), POST /api/card returns HTTP 200 with a card.
  An error is allowed only with a live Ollama model, and its stderr line must name the reason. Record the times and any log lines.
S3. reviewer: review S2-2 with the S2-1 commits.

## Out of scope

W1, W2, W4, W5, the grapheme gap in public/app.js, the R1 minor findings m1 to m7,
parallel reads of different collections, and a change to the 60 s or 100000 limits.

## Risks

- The BDL server can change its paging rule. The count checks then refuse the read with errors.source. This is safe.
- Four requests at once put more load on the public BDL API. The limit keeps it small.
