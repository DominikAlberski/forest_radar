# Serve the model description unchanged

The user changed the card requirements on 2026-10-10.
This decision replaces the earlier model output and content validation requirements.

Send BDL forest summaries with one Polish question about forest area, walking access, animals, plants, and mushrooms.
Include all BDL forest ranges in the model input, even when OpenStreetMap has no trail evidence.
Make one Ollama request per BDL forest to the configured Bielik model.
Send only that forest's stands and district in each request.
Show each forest in a separate card with its own Google Maps link.
Give each model request its own deadline.
Use one shared FIFO model queue for browser searches in the server process.
Start the deadline when the queued request starts.
Serve the complete response without section checks, phrase checks, rewriting, trimming, or content retries.

Show an AI hallucination disclaimer before the description.
Show the fixed mushroom warning after the description.
Keep the sanitary station link with the warning.
Do not show the source fact tables on the card.
Print the complete description, even when the card needs more than one page.

Keep transport error handling and the request deadline.
Read local model settings from the root `.env` file outside the test environment.
Ignore the older stub fallback setting.
Use `client: stub` only when explicitly configured.
