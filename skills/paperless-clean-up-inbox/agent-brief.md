# Paperless cleanup brief (template)

Fill in everything in `<angle brackets>`, save the result to a temporary file (in Claude Code: the session's scratchpad directory) and pass its path to each subagent together with its list of document IDs.

---

You clean up the metadata of Paperless-ngx documents via the `<tool prefix, e.g. mcp__paperless__>` tools (load them with ToolSearch first if they are deferred). Changes apply to the real archive immediately. Many documents have wrong dates (the import day <import date> or OCR nonsense), wrong auto-assigned correspondents, types and tags, and useless titles (email subjects, scanner names like `BRW…_000905`).

## Hard rules

- NEVER delete or trash anything. NEVER run `bulk_edit` methods that change files (`delete`, `merge`, `split`, `rotate`, `reprocess`, `edit_pdf`, `delete_pages`, `remove_password`).
- <Documents that must not change, e.g. "Documents tagged <id> (booked in accounting): only add the review tag.">
- Keep tag <inbox tag id> (inbox)<, and <other tags to keep>>. Add tag <review tag id> (`<review tag name>`) to every document you reviewed. `tags` in `documents_partial_update` replaces the list, so always send the full list.
- `null` in `documents_partial_update` does NOT clear a field. To clear correspondent or type, use `bulk_edit` `set_correspondent` / `set_document_type` with `{"correspondent": null}` / `{"document_type": null}`.
- Not sure about a correspondent? Clear it rather than leave a wrong one.
- Suspected duplicates: don't delete, list them in the report.

## Reading cheaply

Request 8 to 10 documents at once with `documents_list` `id__in=[…]` and `fields=["id","title","created","correspondent","document_type","tags","original_file_name","custom_fields","content"]`. The result usually overflows into a file; read it with jq:

    jq -r '.results[] | "=== \(.id) | \(.title) | \(.original_file_name) | created=\(.created) corr=\(.correspondent) type=\(.document_type) tags=\(.tags) rel=\(.custom_fields|map(.value)|tostring)\n\(.content[0:1000])"' FILE

Read more of a document only when needed. <Custom field <id> links attachments of the same email; use it for context.> `documents_partial_update` echoes the full document back; that's unavoidable.

## What to set

- **title**: <language>, short: `<sender> <kind of document> <identifier or period>`. <Style rules, e.g. "no em or en dashes".> Keep an existing title if it is good.
- **created**: the document's own date. If there is none and the current date is the import day or implausible, find the email date with <mail search tool> (distinctive subject words or order numbers, `has:attachment`, metadata-only view). Leave a plausible date alone if you can't determine it.
- **correspondent**: the real sender. Search `correspondents_list name__icontains=…` before creating; other agents work in parallel, so check right before creating. New ones get `matching_algorithm: 6`.
- **document_type**: best existing type; create one only if nothing fits.
- **tags**: thematic tags from the list below; remove wrong auto-assigned ones. Assigning a child tag adds its parents automatically.

## IDs

Tags: <id name, … with hierarchy notes and what each is for, e.g. who a person tag refers to>
Correspondents created for this run: <id name, …>
Existing correspondents worth knowing: <id name, …; mark the ones that are often wrongly auto-assigned>
Document types: <id name, …; mark the ones that are often wrongly auto-assigned>
<Business rules, e.g. "anything for example.com → tags <id>, <id>; example.org is private">

## Report back (compact)

1. One line per document: `id | title | created | correspondent | type | tags` (names, not IDs).
2. Correspondents, types and tags you created.
3. Suspected duplicates, documents you could not classify, possible business receipts not yet handled, open payment reminders, and anything else the user should look at.
