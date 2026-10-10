---
type: "query"
date: "2026-10-10T12:56:33.337641+00:00"
question: "Review empty box fix and order test in commit 494885a on task/0e27fe20"
contributor: "graphify"
outcome: "useful"
---

# Q: Review empty box fix and order test in commit 494885a on task/0e27fe20

## Answer

Goal: Review only the delta of fix task a350c705. Command: git show 494885a. Check the merge too: git diff 1fb4656 de325e5 must hold only the lines that task 0e27fe20 changed. Inputs: your warnings W1 and W2 on task d8f390ec, the TESTS line on task a350c705. Check these points. merge_boxes returns nil for an empty list. A nil box never raises in spatial_match?, boxes_overlap?, point_in_box?, ring_position, or rings_cross?. A ring with no edges counts as outside. A polygon with a mix of valid and edgeless rings keeps its old result. The order test fails without positions.sort. Out of scope: minors m1-m7, build speed, all files outside the 4 scoped files. Do not run tests. Acceptance: you read the diff and the TESTS line. Report format: VERDICT approve or changes, then findings as critical, warning, or minor with file and line.
VERDICT: approve. Scope: fix commit 494885a and merge de325e5 on task/0e27fe20. Worker TESTS line on a350c705: scoped 57 pass, unit 202 pass, rake unavailable. The TESTS line is present and has no failures. RuboCop on the 4 files at 494885a: 0 offenses. Reek on the 2 lib files: 0 warnings. Graph: fresh. Merge check: git diff 1fb4656 de325e5 equals git diff 1fb4656...28089b9 byte for byte. The merge holds only the 0e27fe20 changes. Checks, all pass. 1. merge_boxes returns nil for an empty list after compact (lib/geo/geometry.rb line 169). 2. Nil boxes do not raise. boxes_overlap? returns false on nil (line 18). point_in_box? returns false on nil (line 214). ring_position returns :outside before it reads ring[2] (line 198). rings_cross? goes through boxes_overlap?. spatial_match? returns false on a nil box (lib/bdl/result_builder.rb line 33). 3. A ring with no edges gets a nil box, so ring_position treats it as outside. 4. Mixed polygon, valid outer ring with an edgeless hole: the old inside_ring? gave false for the hole, and the new path gives :outside. contains? keeps the old result. The polygon box comes from the valid rings only, because merg

## Outcome

- Signal: useful