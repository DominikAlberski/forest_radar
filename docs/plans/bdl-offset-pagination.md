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

D4. Log the BDL::Incomplete message once per failed request.
- Sink: env['rack.errors']. Puma writes it to stderr. The line format: 'BDL incomplete: <message>'.
- Tests read the rack.errors stream of the test request (Rack::Test last_request.env['rack.errors']).
- The response body stays the same: error 'source' and the errors.source text. No new locale key.

ADR 0009 records D1: "Read BDL pages by offset, not by next links".
Reason: the BDL server builds next links from the reduced numberMatched. A later reader will want to restore next links.

## Tasks (in order)

S2-0. backend-developer: commit this plan as docs/plans/bdl-offset-pagination.md and ADR docs/decisions/0009-bdl-offset-pagination.md.
  Also update docs/plans/local-mvp.md (the repeated-link line) and docs/data-sources.md (the page model) to point to ADR 0009.
S2-1. tester: failing tests. Scope test/unit/bdl/, test/fixtures/ogc/, test/unit/app_test.rb.
  - Fixtures in the live shape: decreasing numberMatched, no next link after the early stop.
  - A three-page read with page size 1 and T = 3 returns three features at offsets 0, 1, 2.
  - A wrong numberMatched on a later page raises 'count changed'. A short page raises 'count mismatch'.
  - T above the limit raises 'feature limit' after one request.
  - The requests do not follow a next link to another host.
  - The selector deadline starts after the search: a fake search that advances the clock still leaves 29 s.
  - The app logs the Incomplete message to rack.errors.
  - D2: a fake transport counts requests in flight under a mutex. With concurrency 4 and 6 later pages, the maximum in flight is above 1 and at most 4.
    Each fake request blocks until a second request arrives (Queue or ConditionVariable), so the test is deterministic.
  - D2: an error on one later page raises Incomplete. After the read, no thread that the read started is alive.
  - Fake transports return bodies keyed by the offset param, not by call order.
  - D3 uses the App setting clock. A fake search advances the fake clock. The selector deadline equals the clock after the search plus 29.
  - Update the existing pagination fixtures and tests that assume a constant numberMatched.
  - The tests fail on main only for the missing behavior, not for load or syntax errors outside the new API.
  - Acceptance also: bundle exec rubocop test/unit/bdl test/unit/app_test.rb reports 0 offenses.
S2-2. backend-developer: fix. Scope lib/bdl/page_state.rb, lib/bdl/page_reader.rb, lib/bdl/client.rb, lib/app.rb.
  Input: the tester branch. Acceptance: the tester tests pass, ruby test/run.rb passes,
  bundle exec rubocop lib test and bundle exec reek lib report 0 offenses,
  and a live run of the reproduction search returns a result with 5481 Warsaw stands.
  A live POST /api/card for the same search returns HTTP 200 with a card. Record the times.
  The live run is mandatory. It also proves that offset works together with f=json.
S3. reviewer: review the fix branch (with the tester commits).

## Out of scope

W1, W2, W4, W5, the grapheme gap in public/app.js, the R1 minor findings m1 to m7,
parallel reads of different collections, and a change to the 60 s or 100000 limits.

## Risks

- The BDL server can change its paging rule. The count checks then refuse the read with errors.source. This is safe.
- Four requests at once put more load on the public BDL API. The limit keeps it small.
