---
hide:
  - toc
---

<div class="tm-hero" markdown>

# Skills for your Paperless-ngx archive in Claude Code

<p class="tm-hero__lead">paperless-plugin gives Claude Code ready-made skills for Paperless-ngx: clean up the inbox, find and remove duplicates, unlock password-protected PDFs, search, edit metadata and tidy correspondents, types and tags. It also sets up the connection to your paperless-mcp server for you.</p>

[Install it](install.md){ .md-button .md-button--primary } [Browse the skills](skills.md){ .md-button }

</div>

```
/plugin marketplace add Marceltov/paperless-plugin
/plugin install paperless
```

!!! warning "Needs a running paperless-mcp server"

    This plugin is only the client half. It does not run or bundle the MCP server: you need [paperless-mcp](https://paperless-mcp.marceltov.de/) deployed next to your Paperless first (see its [quick start](https://paperless-mcp.marceltov.de/getting-started/)). Without it, every tool call fails.

## What it does

- **Sets up the connection.** If no Paperless is configured, a `SessionStart` hook notices in your first session and Claude offers, once, to register one: it asks for the URL and either an API token or an OAuth login, and runs `claude mcp add` for you.
- **Cleans up after imports.** Mail rules and scanners leave email subjects as titles, the import day as date, and guessed correspondents and tags. The inbox skill reads each document, fixes all of it, marks what it reviewed, and reports what needs your attention. Large inboxes can be split across parallel subagents.
- **Knows the API's traps.** Clearing a field, replacing tag lists, parent tags, OCR text flooding the context: the skills handle them so Claude doesn't learn them the hard way.
- **Asks before destructive changes.** Trashing duplicates, deleting correspondents or tags and rewriting files are confirmed with you first.
- **Handles several instances.** Connect a home and a work Paperless side by side. See [Multiple instances](multiple-instances.md).
