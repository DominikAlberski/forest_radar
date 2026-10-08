# OGC test fixtures

Every file here is synthetic. A person wrote each file by hand. None comes from a live BDL response.
The IDs and region codes are invented. Recorded live responses are in `test/fixtures/sources/`.

| File | Case |
|---|---|
| `rdlp-page1.json` | First page of two. Count 2, one feature, a valid `next` link on the BDL host. |
| `rdlp-page2.json` | Last page of two. Count 2, one feature, no `next` link. |
| `rdlp-page1-foreign.json` | First page whose `next` link points to a foreign host. |
| `rdlp-page2-count-changed.json` | Second page that reports count 3 where page 1 reported 2. |
| `malformed-page.json` | Valid JSON where `features` is a string, not a list. |
| `truncated-page.json` | JSON cut off in the middle of a feature. |
| `rdlp-links-null.json` | Empty page with `links` set to null. |
