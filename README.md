<h1 align="center"><a href="https://github.com/Marceltov/paperless-plugin">paperless-plugin</a></h1>

<p align="center">
  <a href="https://github.com/Marceltov/paperless-mcp">
    <img alt="requires paperless-mcp sidecar" src="https://img.shields.io/badge/requires-paperless--mcp_sidecar_running-critical">
  </a>
  <a href="https://paperless-plugin.marceltov.de/">
    <img alt="Documentation" src="https://img.shields.io/badge/docs-paperless--plugin.marceltov.de-2f7a27">
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

A [Claude Code](https://code.claude.com) plugin for [Paperless-ngx](https://docs.paperless-ngx.com): skills for working with your document archive, plus the MCP connection to a running [paperless-mcp](https://github.com/Marceltov/paperless-mcp) server.

> [!IMPORTANT]  
> This plugin does **not** run, host, or bundle the MCP server. It's a thin client: it only works if you already have [`paperless-mcp`](https://github.com/Marceltov/paperless-mcp) deployed and reachable as a **container sidecar** next to your Paperless instance (see its [quick start](https://paperless-mcp.marceltov.de/getting-started/)). Without a running `paperless-mcp` and valid credentials, every tool call fails.

**Full documentation: [paperless-plugin.marceltov.de](https://paperless-plugin.marceltov.de/)**

- [Install and connect](https://paperless-plugin.marceltov.de/install/): install the plugin and register your Paperless
- [Multiple instances](https://paperless-plugin.marceltov.de/multiple-instances/): home and work Paperless side by side
- [Skills](https://paperless-plugin.marceltov.de/skills/): everything the plugin can do

## Install

```
/plugin install paperless --marketplace Marceltov/paperless-plugin
```

On Claude Code before 2.1.275, add the marketplace first:

```
/plugin marketplace add Marceltov/paperless-plugin
/plugin install paperless
```

Then start a new session: Claude offers to connect your Paperless if none is configured.

## What the skills do

- **Clean up the inbox**: real titles instead of email subjects and scanner names, the document's own date instead of the import day, correct correspondents, types and tags, and a report of what needs your attention (open payment reminders, documents nobody could classify). Every correction also trains Paperless's automatic matching.
- **Find duplicates** from repeated imports and trash them after you confirm.
- **Unlock password-protected PDFs** so Paperless can read them.
- **Search** without flooding the context with OCR text, **edit metadata** without the API's traps, and **tidy** correspondents, types and tags.

## Related project

This plugin is the **client half**: skills that call MCP tools. [`paperless-mcp`](https://github.com/Marceltov/paperless-mcp) is the **server half**, the container sidecar that exposes the Paperless-ngx REST API as those tools. You need both.

## License

MIT, see [LICENSE](LICENSE).
