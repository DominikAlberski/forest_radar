# Decision: OpenStreetMap as trail fallback

Date: 2026-10-08
Status: accepted by the user

## Context
BDL tourism services hold no walking-trail data. Only horse trails exist.

## Decision
Use OpenStreetMap as the fallback source for walking trails.
BDL stays the source for districts, ranges, stands, and bans.
If OpenStreetMap also gives no trail, the card lists no walk areas and says why.

## Consequences
The program calls one more public service. Cache the answers.
Tests use recorded fixtures. No live call in tests.
The card names OpenStreetMap as the trail source.
