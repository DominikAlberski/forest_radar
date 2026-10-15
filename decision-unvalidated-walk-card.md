# Unvalidated walk card

Date: 2026-10-10

The user requested single-agent work after the MAF model output changes.
The user replaced the strict model output contract.

Send BDL summaries with one Polish question about forest area, walking access, animals, plants, and mushrooms.
Display the complete Bielik response without content validation, rewriting, or content retries.
Show an AI hallucination disclaimer and the fixed mushroom warning.
Preserve the full response in print.
Use all BDL ranges for model input, including ranges without OpenStreetMap trail evidence.

Main checkout implementation: `docs/decisions/0010-unvalidated-walk-description.md`.
The main checkout reads the model host from the root `.env` file.
The main checkout ignores the old stub fallback setting.
Transport errors and the request deadline remain.

The previous section checks, fact echo checks, forbidden phrase checks, and D6 content checks are obsolete.
Do not restore those checks from the unfinished MAF worktrees.
