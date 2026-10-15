# Separate forest cards

Date: 2026-10-10

The user requested separate cards instead of one combined forest description.
The main checkout now sends one Ollama request per BDL forest.
Each request contains only that forest's BDL summary, stands, and district.
Each card shows its forest name, unchanged model response, map link, disclaimer, and mushroom warning.
Cards appear in distance order.
The app generates descriptions sequentially.
Each model request has its own current 89-second deadline.
The API returns a `cards` array.
The API retains `card` as the first card for compatibility.

Implementation: `lib/card/collection.rb` and `public/app.js`.
Model response validation remains disabled.
