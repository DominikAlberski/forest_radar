---
type: "query"
date: "2026-10-10T13:14:47.292674+00:00"
question: "Review task/0fc4b1a6 address-first stand matching in lib/bdl/result_builder.rb"
contributor: "graphify"
outcome: "useful"
---

# Q: Review task/0fc4b1a6 address-first stand matching in lib/bdl/result_builder.rb

## Answer

Goal: Review the address-first stand match. Inputs: branch task/0fc4b1a6, diff goal/c0e3a4e7...task/0fc4b1a6, commit 83f36f6, spec and report on task 0fc4b1a6. Rule: one candidate with a full-width adress_forest prefix equal to the stand adr_for prefix links without geometry. Otherwise the spatial filter and the ambiguous error apply. Check: short and empty prefixes stay on the geometry path. linked_range is unchanged. MatchIndex and the prepared geometry cache are unchanged. The fixture change in test_ambiguous_candidates_keep_original_order still fails without positions.sort. Out of scope: fetch time, page_reader.rb, app.rb, minors m1-m7. Acceptance: read the TESTS line (unit 205 pass). Run bundle exec rubocop and reek on the two changed files. Report format: VERDICT approve or changes, then findings as critical, warning, or minor with file:line.
VERDICT: approve. The two warnings are test gaps only, and the architect can schedule them. Scope: commit 83f36f6 on task/0fc4b1a6. Files: lib/bdl/result_builder.rb, test/unit/bdl/result_builder_index_test.rb. Worker TESTS line: focused 60 passed, full unit 205 passed, no failures. RuboCop on the 2 files: 0 offenses. Reek: 0 warnings. Graph: fresh. Checks, all pass. 1. Rule: exact_stand_match (lib/bdl/result_builder.rb:146) keeps only the candidates with a full-width adress_forest prefix. It returns the candidate only when exactly one exists. Otherwise spatial_stand_match runs the old unique_match over all candidates, so the ambiguous error does not change. 2. Short and empty prefixes: full_prefix? (line 71) needs prefix.length >= width, so these candidates never take the exact path. 3. linked_range (line 163) does not change. MatchIndex and the prepared geometry cache do not change. 4. Order test: district 3 ('17') sits at position 0 and district 9 (nil) at position 1. Neither has a full prefix. The lookup yields [1, 0] before the sort, so without positions.sort the message is '9, 3' and the test fails. 5. Width 10 with 

## Outcome

- Signal: useful