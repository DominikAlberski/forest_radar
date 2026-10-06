# Sinatra instead of the Ruby standard library

The first draft of this project recommended the Ruby standard library with a hand-written server, to match the two earlier challenge projects. The author chose Sinatra instead. The project needs views, i18n, and conventional request routing, and hand-writing those parts costs more than one small framework dependency.

## Considered options

- **Standard library.** No gems at runtime. More code to write and to test.
- **Rails.** Far more structure than a one-page demo needs.
- **Sinatra.** Small, conventional, and it brings the view layer and the i18n integration with it.

The rejected alternatives are recorded because the standard-library option was the original recommendation. A later reader would otherwise ask why the plan changed.