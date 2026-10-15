<h1 align="center"><a href="https://github.com/Marceltov/paperless-ngx-plugin">paperless-ngx-plugin</a></h1>

<p align="center">
  <a href="https://github.com/Marceltov/paperless-ngx-mcp">
    <img alt="requires a running Paperless-ngx MCP server" src="https://img.shields.io/badge/requires-paperless--ngx--mcp_sidecar_running-critical">
  </a>
  <a href="https://paperless-ngx-plugin.marceltov.de/">
    <img alt="Documentation" src="https://img.shields.io/badge/docs-paperless--ngx--plugin.marceltov.de-2f7a27">
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

A [Claude Code](https://code.claude.com) plugin for [Paperless-ngx](https://docs.paperless-ngx.com): skills for working with your document archive, plus the MCP connection to a running [Paperless-ngx MCP server](https://github.com/Marceltov/paperless-ngx-mcp).

> [!IMPORTANT]  
> This plugin does **not** run, host, or bundle the MCP server. It's a thin client: it only works if you already have a [Paperless-ngx MCP server](https://github.com/Marceltov/paperless-ngx-mcp) deployed and reachable as a **container sidecar** next to your Paperless-ngx instance (see its [quick start](https://paperless-ngx-mcp.marceltov.de/getting-started/)). Without a running Paperless-ngx MCP server and valid credentials, every tool call fails.

**Full documentation: [paperless-ngx-plugin.marceltov.de](https://paperless-ngx-plugin.marceltov.de/)**

- [Install and connect](https://paperless-ngx-plugin.marceltov.de/install/): install the plugin and register your Paperless-ngx instance
- [Multiple instances](https://paperless-ngx-plugin.marceltov.de/multiple-instances/): home and work Paperless-ngx instances side by side
- [Skills](https://paperless-ngx-plugin.marceltov.de/skills/): everything the plugin can do

## Install

```
/plugin install paperless-ngx --marketplace Marceltov/paperless-ngx-plugin
```

On Claude Code before 2.1.275, add the marketplace first:

```
/plugin marketplace add Marceltov/paperless-ngx-plugin
/plugin install paperless-ngx
```

Then start a new session: Claude offers to connect your Paperless-ngx instance if none is configured.

**On claude.ai?** Connect the Paperless-ngx MCP server as a connector, then add this repository under *Customize → Plugins → Add → Add marketplace* and add `paperless-ngx`. See [Use on claude.ai](https://paperless-ngx-plugin.marceltov.de/claude-ai/).

## What the skills do

- **Clean up the inbox**: real titles instead of email subjects and scanner names, the document's own date instead of the import day, correct correspondents, types and tags, and a report of what needs your attention (open payment reminders, documents nobody could classify). Every correction also trains Paperless-ngx's automatic matching.
- **Find duplicates** from repeated imports and trash them after you confirm.
- **Unlock password-protected PDFs** so Paperless-ngx can read them.
- **Search** without flooding the context with OCR text, **edit metadata** without the API's traps, and **tidy** correspondents, types and tags.

## Related project

This plugin is the **client half**: skills that call MCP tools. The [Paperless-ngx MCP server](https://github.com/Marceltov/paperless-ngx-mcp) is the **server half**, the container sidecar that exposes the Paperless-ngx REST API as those tools. You need both.

## License

MIT, see [LICENSE](LICENSE).
