# Decision: read BDL pages by offset, not by next links

- Date: 2026-10-10
- Decision: Read the first BDL page at offset zero. Use its `numberMatched` value to request later pages by explicit offset.
- Reason: BDL reduces `numberMatched` by the offset on each page. BDL builds next links from that reduced count. The links stop before the complete result.
- Check: Verify each page's count and feature number against the first page's total. Return an incomplete-data error if a check fails.
- Timing: Four parallel page reads take about 43 seconds for a full search within the 60-second BDL budget.
- Request bound: Start the 29-second card deadline after the BDL search. One card request can take about 89 seconds.
