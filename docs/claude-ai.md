# Use on claude.ai

The skills work on claude.ai (and in the Claude desktop and mobile apps) too. There is no plugin there: you connect the server as a connector and upload the skills one by one. The skill texts are the same as in the Claude Code plugin.

## 1. Connect paperless-mcp as a connector

Claude.ai signs in with OAuth, so the server needs `MCP_BASE_URL` and `MCP_OAUTH_SECRET` set and a public HTTPS URL. Then add it as a custom connector: see [Claude.ai](https://paperless-mcp.marceltov.de/claude-ai/) in the paperless-mcp docs for the steps.

## 2. Download the skills

Every [release](https://github.com/Marceltov/paperless-plugin/releases/latest) has one zip per skill, for example `paperless-clean-up-inbox.zip`. Each holds the skill folder with its `SKILL.md` and the shared rules it relies on.

`paperless-manage-instances` is not included: on claude.ai the connector replaces it.

## 3. Upload them

In claude.ai, open *Customize → Skills*, click **+**, choose *Create skill → Upload a skill*, and upload a zip. Repeat for each skill you want, and make sure each is switched on. Upload the ones you want; they don't depend on each other.

On Team and Enterprise plans an admin can provide the skills to the whole organization instead, so members don't upload them themselves.

!!! note "Updating"

    Uploaded skills don't update themselves. After a new release, upload the changed zips again.

## What's different from Claude Code

- **No subagents.** `paperless-clean-up-inbox` works through large inboxes in batches itself instead of splitting them across parallel agents.
- **Large results.** Claude Code saves oversized tool results to a file and reads them with `jq`; on claude.ai the skills fetch fewer documents per call instead.
- **Mail lookups** for document dates need a mail connector (for example Gmail) switched on in the same chat.
