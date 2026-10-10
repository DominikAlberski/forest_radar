# OGC test fixtures

Every file here is synthetic. A person wrote each file by hand. None comes from a live BDL response.
The IDs and region codes are invented. Recorded live responses are in `test/fixtures/sources/`.

| File | Case |
|---|---|
| `rdlp-page1.json` | First of three pages. Remaining count 3, one feature, and a valid `next` link. |
| `rdlp-page2.json` | Second page. Remaining count 2, one feature, and no early `next` link. |
| `rdlp-page3.json` | Last page. Remaining count 1, one feature, and no `next` link. |
| `rdlp-page1-foreign.json` | First page whose `next` link points to a foreign host. |
| `rdlp-page2-count-changed.json` | Second page that repeats count 3 instead of the expected remaining count 2. |
| `malformed-page.json` | Valid JSON where `features` is a string, not a list. |
| `truncated-page.json` | JSON cut off in the middle of a feature. |
| `rdlp-links-null.json` | Empty page with `links` set to null. |
