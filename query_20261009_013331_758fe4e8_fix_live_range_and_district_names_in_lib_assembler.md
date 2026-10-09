---
type: "query"
date: "2026-10-09T01:33:31.643136+00:00"
question: "Fix live range and district names in lib/assembler/facts.rb and the ban WMS layer in lib/wms/ban_client.rb: The ban client used REST identify on layer 0. Identify returns an empty result everywhere, so every card shows no_known_ban. This claims safety that the source cannot prove. Use layer 0 query, so the live 400 gives unknown."
contributor: "graphify"
outcome: "dead_end"
---

# Q: Fix live range and district names in lib/assembler/facts.rb and the ban WMS layer in lib/wms/ban_client.rb: The ban client used REST identify on layer 0. Identify returns an empty result everywhere, so every card shows no_known_ban. This claims safety that the source cannot prove. Use layer 0 query, so the live 400 gives unknown.

## Answer

The ban client used REST identify on layer 0. Identify returns an empty result everywhere, so every card shows no_known_ban. This claims safety that the source cannot prove. Use layer 0 query, so the live 400 gives unknown.

## Outcome

- Signal: dead_end