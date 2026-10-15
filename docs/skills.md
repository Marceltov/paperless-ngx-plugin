# Skills

Claude picks a skill automatically when your request matches it, so you just ask in plain words ("clean up my Paperless inbox"). Each skill calls the [paperless-mcp](https://paperless-mcp.marceltov.de/) tools rather than the REST API directly.

## Connection

- **`paperless-manage-instances`** (Claude Code only): Configures the connection to one or more Paperless instances: add, list or remove them, each registered with `claude mcp add`, with an API token or an OAuth login. Offered once by the `SessionStart` hook, in the first session without a configured instance.

## Everyday

- **`paperless-search-documents`**: Finds documents by full text, title, correspondent, type, tag, date or custom field, and keeps results small: the OCR text of an archive is far too large to page through.
- **`paperless-edit-document-metadata`**: Changes title, date, correspondent, type, tags and custom fields on one or many documents. Knows the traps: `null` doesn't clear a field in a partial update, tag lists are replaced, parent tags come along.

## Cleanup

- **`paperless-clean-up-inbox`**: Reviews the inbox (or any selection) document by document. It agrees on conventions with you first (how to mark reviewed documents, what to do with duplicates and newsletters), then sets real titles, the document's own date (looked up in your mail if a mail connector is available), and correct correspondents, types and tags. It ends with a report of open payment reminders, possible business expenses, duplicates and documents that need you. For a few hundred documents it can split the work across parallel subagents, using a brief template so they all follow the same rules.
- **`paperless-find-duplicates`**: Finds byte-identical copies (typical after a mail rule ran twice) and same-content copies (scan and PDF of one invoice), keeps the curated or referenced copy, and trashes the rest after you confirm.
- **`paperless-unlock-pdfs`**: Removes the password from encrypted PDFs, stored as a new version of the same document, so Paperless can read them. Finds the password scheme in the email that delivered the file.
- **`paperless-tidy-metadata`**: Merges duplicate correspondents, types and tags, removes unused ones, and keeps marker tags out of automatic matching.

The sources are in [`skills/`](https://github.com/Marceltov/paperless-plugin/tree/main/skills), one `SKILL.md` per skill.
