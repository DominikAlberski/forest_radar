# Decision: remove the entry ban check

Date: 2026-10-09
Status: accepted by the user

## Context
The live BDL service has no working entry ban layer. Layer 0 returns HTTP 400.
The old WMS layer is gone. The ban data may be a leftover of the 2020 coronavirus period.
The card showed "unknown" for every live search.

## Decision
Remove the entry ban check from the program and from the card.
This closes the open items BAN-R1 and BAN-R2.

## Consequences
The card makes no statement about entry bans. It does not claim "no ban".
Remove the ban client, its tests, its fixtures, and its strings in pl.yml and en.yml.
Update the docs: PLAN.md, README.md, and docs/data-sources.md.
