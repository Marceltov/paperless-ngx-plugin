# Skills

This directory holds the plugin's skills, one per subdirectory:

```
skills/
  <skill-name>/
    SKILL.md
```

- **`manage-paperless-instances`**: configures the connection to one or more Paperless instances by asking the user and registering each with `claude mcp add`. Offered once per installation by the `SessionStart` hook in `hooks/`, in the first session without a configured instance.
- **`search-documents`**: finds documents by text, metadata or ID while keeping results small (the archive's OCR text is huge).
- **`edit-document-metadata`**: changes title, date, correspondent, type, tags and custom fields on one or many documents, with the API's traps spelled out.
- **`clean-up-inbox`**: reviews the inbox (or any selection) document by document: real title, real date, correct correspondent, type and tags, plus a follow-up report. Can fan out to parallel subagents for large inboxes.
- **`find-duplicates`**: finds byte-identical and same-content copies, picks which one to keep, and trashes the rest after confirmation.
- **`unlock-pdfs`**: removes the password from encrypted PDFs so Paperless can read their text.
- **`tidy-metadata`**: merges duplicate correspondents, document types and tags, and cleans up unused ones.

See the [Claude Code plugin docs](https://code.claude.com/docs/en/plugins) for the `SKILL.md` format.

Skills call the MCP tools exposed by [paperless-mcp](https://github.com/Marceltov/paperless-mcp) (`documents_list`, `documents_retrieve`, `documents_partial_update`, `bulk_edit`, …) rather than the Paperless REST API directly. The tool names come from Paperless's own OpenAPI operation IDs, so they are the same on every paperless-mcp deployment.

## Working with multiple instances

A user may have more than one Paperless connected at once. Each shows up as its own MCP server, so tool names are namespaced per instance: `mcp__paperless__documents_list` for the default instance, `mcp__paperless-work__documents_list` for one labeled `work`, and so on (see `manage-paperless-instances`). A Paperless connected as a claude.ai connector shows up under its connector name instead (for example `mcp__claude_ai_Paperless-NGX__documents_list`); treat it like any other instance. Every skill that calls Paperless tools resolves which instance to use like this:

1. Note which Paperless tool prefixes are actually available this session: `mcp__paperless([-_].+)?__*`, plus any connector whose tools are the paperless-mcp set (`documents_list`, `bulk_edit`, …).
2. Exactly one exists: use it, no question asked.
3. More than one exists: check whether the user already named an instance in the conversation (by label, or something identifying like "the work one") and match it to the corresponding prefix.
4. Still ambiguous: ask once which instance, listing the available labels.
5. Use that one resolved prefix for every tool call for the rest of the current task.

## Shared rules for all skills

- **Changes are live.** Every write hits the real archive at once. Before anything destructive (`bulk_edit` with `delete`, `merge`, `split`, `rotate`, `delete_pages`, `edit_pdf`; `documents_delete`, `trash_create`, `…_destroy`, `bulk_edit_objects` delete), say what will be affected and get the user's confirmation.
- **Never page through the archive.** Filter on the server, ask for `fields` without `content`, keep `page_size` small, and read `count` to answer "how many".
- **Reading content that overflows.** A `documents_list` call with `content` for several documents often exceeds the tool-result limit and lands in a file. Read that file with `jq`, cut each document's text to its first ~1000 characters, and only read more of a document when you need it.
- **IDs, not names.** Correspondents, document types, tags, storage paths and custom fields are referenced by ID everywhere. Look them up with the matching `…_list` tool and `name__icontains` first.
