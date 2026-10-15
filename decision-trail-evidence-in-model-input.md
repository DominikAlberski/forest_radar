# Trail evidence in model input

Date: 2026-10-10

The user requested OpenStreetMap trail evidence in each forest's model input.
The app now passes existing Overpass evidence into each forest card collection.
The selector retains evidence for all checked ranges, beyond the three-item shortlist.
Each prompt contains only the matching forest's trail names, references, route types, and evidence status.
Statuses distinguish mapped crossings, no mapped crossings, unavailable evidence, and unchecked forests.
The prompt explains that a Maps link identifies a forest location rather than a verified walking route.
Cards show OpenStreetMap attribution.

Model response validation remains disabled.
The shared FIFO queue remains in use.
