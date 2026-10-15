# Skills

One skill per subdirectory. Every folder is complete on its own, so the same folder works as part of the Claude Code plugin and, zipped, as a skill on claude.ai:

```
skills/
  <skill-name>/
    SKILL.md
    reference/shared-rules.md   generated copy of ../../shared/rules.md, committed
    .claude-code-only           optional marker: not built for claude.ai
```

- **`paperless-ngx-manage-instances`**: in Claude Code, configures the connection to one or more Paperless-ngx instances by asking the user and registering each with `claude mcp add`; on claude.ai it checks for the connector and explains how to add one. Offered once per installation by the `SessionStart` hook in `hooks/`, in the first session without a configured instance.
- **`paperless-ngx-search-documents`**: finds documents by text, metadata or ID while keeping results small (the archive's OCR text is huge).
- **`paperless-ngx-edit-document-metadata`**: changes title, date, correspondent, type, tags and custom fields on one or many documents, with the API's traps spelled out.
- **`paperless-ngx-clean-up-inbox`**: reviews the inbox (or any selection) document by document: real title, real date, correct correspondent, type and tags, plus a follow-up report. Can fan out to parallel subagents where the client supports them.
- **`paperless-ngx-find-duplicates`**: finds byte-identical and same-content copies, picks which one to keep, and trashes the rest after confirmation.
- **`paperless-ngx-unlock-pdfs`**: removes the password from encrypted PDFs so Paperless-ngx can read their text.
- **`paperless-ngx-tidy-metadata`**: merges duplicate correspondents, document types and tags, and cleans up unused ones.

## Writing skills here

- Names start with `paperless-`, so they stay recognizable among other skills on claude.ai.
- The rules every skill shares (instance resolution, confirmation before destructive calls, keeping results small) live in [`shared/rules.md`](../shared/rules.md). Edit only that file and run `scripts/sync-shared.sh`; CI fails when a copy is out of date. Skills link to their own copy as `reference/shared-rules.md`.
- Write for both platforms. Where they differ, phrase it as a condition ("if you can start subagents", "if the result was saved to a file") instead of assuming Claude Code.
- A skill that only makes sense in Claude Code gets an empty `.claude-code-only` file; the claude.ai build skips it.

See the [Claude Code plugin docs](https://code.claude.com/docs/en/plugins) for the `SKILL.md` format.
