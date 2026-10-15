# Shared rules for the Paperless-ngx skills

<!-- Single source. Copied into every skills/*/reference/shared-rules.md by scripts/sync-shared.sh; edit this file, not the copies. -->

These skills call the tools of a [Paperless-ngx MCP server](https://github.com/Marceltov/paperless-ngx-mcp) (`documents_list`, `documents_retrieve`, `documents_partial_update`, `bulk_edit`, …), not the Paperless-ngx REST API directly. The tool names come from Paperless-ngx's own OpenAPI operation IDs, so they are the same on every deployment; only the prefix in front of them differs.

## Working with multiple instances

A Paperless-ngx instance can be connected in several ways, and each connection namespaces its tools differently:

- Claude Code, registered with `claude mcp add`: `mcp__paperless-ngx__documents_list` for the default instance, `mcp__paperless-ngx-work__documents_list` for one labeled `work`.
- A connector on claude.ai (or in Claude Code through claude.ai): the connector's name, for example `mcp__claude_ai_Paperless-NGX__documents_list`.

Resolve which instance to use like this:

1. Note which Paperless-ngx tool sets are available in this conversation: any tools whose names end in the Paperless-ngx MCP server's tool set (`documents_list`, `bulk_edit`, `tags_list`, …), grouped by prefix.
2. Exactly one: use it, no question asked.
3. More than one: check whether the user already named an instance (by label, or something identifying like "the work one") and match it.
4. Still ambiguous: ask once which instance, listing the options.
5. Use that one instance for every tool call for the rest of the task.

If no Paperless-ngx tools are available at all, say so and explain how to connect: in Claude Code with the `paperless-ngx-manage-instances` skill (from the Paperless-ngx plugin), on claude.ai by adding the Paperless-ngx MCP server as a custom connector.

## Rules for every skill

- **Changes are live.** Every write hits the real archive at once. Before anything destructive (`bulk_edit` with `delete`, `merge`, `split`, `rotate`, `delete_pages`, `edit_pdf`; `documents_delete`, `trash_create`, `…_destroy`, `bulk_edit_objects` with `delete`), say what will be affected and get the user's confirmation.
- **Never page through the archive.** Filter on the server, ask for `fields` without `content`, keep `page_size` small, and read `count` to answer "how many".
- **Large results.** Asking for `content` of several documents at once can exceed the tool-result limit. If the client saves the oversized result to a file (Claude Code does), read that file with `jq` and cut each document's text to its first ~1000 characters. If it doesn't, request fewer documents per call (3 to 5) instead.
- **IDs, not names.** Correspondents, document types, tags, storage paths and custom fields are referenced by ID everywhere. Look them up with the matching `…_list` tool and `name__icontains` first.
