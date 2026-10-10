# Contributing

## Language rule

The user interface uses i18n. The Polish locale is complete. The English locale exists with the same keys and empty values.

- All user-facing strings live in [pl.yml](../config/locales/pl.yml) and [en.yml](../config/locales/en.yml).
- Never hardcode a user-facing string in a view or in Ruby code.
- The Polish locale is the source of truth. Add a key there first.
- The English locale is a placeholder for a later translation. Leave the values empty.
- Write the documents and the code comments in English.
