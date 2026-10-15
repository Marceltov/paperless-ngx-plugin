---
name: edit-document-metadata
description: Change the title, date, correspondent, document type, storage path, tags or custom fields of one or many Paperless-ngx documents with documents_partial_update and bulk_edit, avoiding the API's traps (null not clearing fields, tag lists being replaced, parent tags added automatically). Use when the user asks to rename, re-date, re-tag, recategorize or otherwise correct documents, or when another skill needs to write metadata.
---

# Edit Document Metadata

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](../README.md#working-with-multiple-instances).

## Which tool

| Change | One document | Many documents |
| ------ | ------------ | -------------- |
| Title, created date, serial number | `documents_partial_update` | `documents_partial_update` per document |
| Correspondent, document type, storage path | `documents_partial_update` | `bulk_edit` `set_correspondent` / `set_document_type` / `set_storage_path` |
| **Clear** correspondent, type or storage path | `bulk_edit` with `null` (see traps) | same |
| Add or remove tags without touching others | `bulk_edit` `add_tag` / `remove_tag` / `modify_tags` | same |
| Replace the whole tag list | `documents_partial_update` `tags` | – |
| Custom fields | `documents_partial_update` `custom_fields` (full list) | `bulk_edit` `modify_custom_fields` |

`bulk_edit` takes `documents=[ids]`, `method` and `parameters`, and returns only `{"result": "OK"}`. It is the cheap choice whenever the change is the same for every document.

## Traps

- **`null` does not clear a field in `documents_partial_update`.** Sending `correspondent: null` returns success but leaves the old value. Clear with `bulk_edit` `set_correspondent` `{"correspondent": null}` (same for `set_document_type`, `set_storage_path`), then verify.
- **`tags` and `custom_fields` replace the whole list.** Read the document's current tags first and send the complete new list, or use `bulk_edit` `modify_tags {add_tags, remove_tags}`.
- **Parent tags come along.** Assigning a child tag also assigns its parents (for example a "Papa" tag under "Eltern" under "Familie"). Check the hierarchy with `tags_list` before tagging, and don't use a child tag for its literal name if its parent means something else (a "Kempten" tag nested under "Freunde" is a friends group, not a city).
- **`documents_partial_update` echoes the whole document back**, including the full OCR text. That's unavoidable; don't request the document again just to check the write, the echo already shows the result.
- **Dates.** `created` is the document's own date (invoice date, letter date). `added` is the import time and can't be changed. Send `created` as `YYYY-MM-DD`.
- **Title limit** is 128 characters.

## Choosing good values

- **Title**: short and descriptive, `<sender> <kind of document> <identifier or period>`, for example `ACME Invoice 2024-0815` or `City Utilities Final Electricity Bill 2025`. Write titles in the language the user's archive already uses. Keep an existing title if it is already good.
- **Created**: the date printed on the document. If it has none, use the date it was sent (for imported emails, the email's date; see `clean-up-inbox` for looking it up). Don't keep a date that is obviously the import day or nonsense (1970, 1994-07-04 style OCR misreads).
- **Correspondent**: who issued the document. Reuse an existing correspondent (search with `name__icontains`, also for spelling variants) before creating one. When unsure, clear the field: an empty correspondent is better than a wrong one, because Paperless's automatic matching learns from what you assign.
- **Document type and tags**: reuse the archive's existing ones (list them once per task). Create new ones only when nothing fits, with `matching_algorithm: 6` (automatic) so Paperless learns them.

## After editing

Report what changed per document, with names instead of IDs. If you cleared or replaced an automatically assigned value, mention that Paperless's auto-matching will learn from the correction over time.
