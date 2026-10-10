---
type: "query"
date: "2026-10-10T13:16:32.115910+00:00"
question: "Match stands by unique address prefix before geometry in lib/bdl/result_builder.rb"
contributor: "graphify"
outcome: "corrected"
correction: "Acceptance must include ruby test/run.rb --unit. A single-process require loop hides missing requires in one test file."
---

# Q: Match stands by unique address prefix before geometry in lib/bdl/result_builder.rb

## Answer

Goal: Reduce the result build time. Link a stand to its district and its range by address alone when the address is unique. Use geometry only to break a tie. Rule for stand_match: take the candidates from MatchIndex. Find the candidates whose adress_forest prefix at full width (5 for district, 10 for range) equals the first width characters of the stand adr_for. If exactly one such candidate exists, return it without a geometry check. Otherwise use the current spatial filter over all candidates, with the current ambiguous error. Keep short-prefix and empty-address candidates on the geometry path. Keep linked_range (range to district) unchanged. Inputs: branch goal/c0e3a4e7 at cc99fbd. Start the task branch from it. Read lib/bdl/result_builder.rb and test/unit/bdl/result_builder_index_test.rb. Out of scope: do not revert MatchIndex or the prepared geometry cache. They come from commits 8cdcf5f and 28089b9, which are squashed in cc99fbd. Do not change lib/bdl/page_reader.rb, lib/app.rb, lib/geo/, the fetch radius, or minors m1-m7. Acceptance: Update test_disjoint_box_does_not_intersect and test_candidate_without_geometry_does_not_match. They now expect a link, because the address is unique. Add tests: a unique full-width address match links without geometry overlap. Two full-width matches use geometry to pick one. Two full-width matches that both intersect raise the ambiguous error. A short-prefix candidate with disjoint geometry gives nil. Run: ruby -Itest -e 'Dir["test/unit/bdl/result_builder*_test.rb", "test/unit/geo/*_test.rb"].each { |f| require "./" + f }'. Run the full unit suite with ruby -Itest over test/unit/**/*_test.rb with 0 failures. bundle exec rubocop and reek report 0 offenses on the scoped files. Measure the Warsaw result build time the same way as task 0e27fe20 (before 22.0 s). Report format: STATUS, COMMITS, TESTS line, RUBOCOP, REEK, BUILD time before and after, and the count of stands linked by address alone versus by geometry in the Warsaw build

## Outcome

- Signal: corrected
- Correction: Acceptance must include ruby test/run.rb --unit. A single-process require loop hides missing requires in one test file.