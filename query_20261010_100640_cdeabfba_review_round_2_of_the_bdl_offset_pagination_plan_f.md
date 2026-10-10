---
type: "query"
date: "2026-10-10T10:06:40.245011+00:00"
question: "Review round 2 of the BDL offset pagination plan for goal c0e3a4e7"
contributor: "graphify"
outcome: "useful"
---

# Q: Review round 2 of the BDL offset pagination plan for goal c0e3a4e7

## Answer

Goal: check the revised plan for goal c0e3a4e7. Inputs: $COORD_DIR/artifacts/c0e3a4e7/plan.r1.md (round 1 copy) and plan.md (revision). Read diff -u plan.r1.md plan.md. Round 1 findings are in task 4ee59325: W1 to W5 and m1 to m7. Check only those open findings. Out of scope: new topics outside the diff, code edits, and test runs. Acceptance: one verdict, approve or request changes. Report format: annotate 'VERDICT: approve|changes', then one line per finding id with closed or open and a reason.
VERDICT: approve. One minor finding stays open. The architect can fix it without another review round.
W1 closed: S2-1 now has a D2 in-flight count test and an error test that checks for no live thread. Residual risk: a fake that returns at once can finish each request before the next starts. Then 'maximum in flight above 1' fails at random. The tester should hold each fake request until a second request arrives, for example with a Queue or a ConditionVariable.
W2 closed: the fake transports return bodies by the offset param, not by call order.
W3 closed: the plan names the API BDL::Client.new(transport:, clock:, page_size:, concurrency:) and the pass-through to PageReader and PageState.start.
W4 closed: the plan adds the App setting clock and the test asserts that the deadline equals the clock after the search plus 29.
W5 closed: the sink is env['rack.errors'] with a fixed line format. Rack::Test gives a StringIO stream that the test can read.
m1 closed: the plan explains the cap of 4 and records the times. Note: the measured collection times in diagnosis.md add up to about 23 s (5.4 + 7.7 + 7.3 + 2.8). With a 20 s Warsaw read the total is about 43 s, not 37 s. Correct the number in the ADR.
m2 closed: errors reach the rescue in Client#features in the caller thread, and report_on_exception is false.
m3 closed: the checks apply at offset 0, and T = 0 makes no more requests.
m4 closed: the live run is mandatory and proves that offset works with f=json.
m5 closed: S2-0 now upd

## Outcome

- Signal: useful