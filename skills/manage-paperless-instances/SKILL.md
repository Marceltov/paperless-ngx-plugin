---
name: manage-paperless-instances
description: Configure connections to one or more paperless-mcp deployments: add a new instance (URL plus API token or OAuth login, optionally labeled), list which are configured and connected, or remove one. Every instance is registered as a user-scoped MCP server via `claude mcp add` (no settings.json editing, no bundled .mcp.json). Use when the paperless MCP server is unconfigured, disconnected or missing credentials (including when a SessionStart hook flags this), when the user asks to set up, configure or connect the Paperless plugin, or when they want to add, remove or list additional Paperless instances.
---

# Manage Paperless Instances

Every Paperless instance, including the first/default one, is its own MCP server registered with the `claude mcp add` CLI command, scoped `user` so it's available to every project under the current Claude Code installation. The default instance is named `paperless`; each additional one is `paperless-<label>` (e.g. `paperless-work`). Instances registered as `paperless_<label>` still count. Claude Code exposes each server's tools under its own prefix (`mcp__paperless__*`, `mcp__paperless-work__*`, …); skills resolve which prefix to use per task, see [Working with multiple instances](../README.md#working-with-multiple-instances).

**This skill is the only way instances get configured.** Go through `claude mcp add`/`list`/`get`/`remove` only. Never write an `mcpServers` block into settings.json (it rejects the key) and never create a `.mcp.json`.

## Determine the operation

Figure out from the request whether the user wants to **add** a new instance, **list** what's configured, or **remove** one. Default to **add** when the trigger is a missing-credentials nudge and the user hasn't said otherwise.

## Add an instance

1. **Check whether Paperless is already reachable before asking anything.** Any of these means it is:
   - `mcp__paperless__*` tools are listed as available in this session.
   - A claude.ai connector already provides the paperless-mcp tools (for example `mcp__claude_ai_Paperless-NGX__documents_list`). The SessionStart hook can't see connectors, so it may nudge anyway.
   - `claude mcp get paperless` exits 0 (its output shows scope and connection status, never the token).

   If so, **stop**: report what's already configured and finish. Only continue if the user explicitly wants an *additional* instance, or none of these is true.

2. **For an additional instance (not the first), ask for a label**, a short name like `work` or `home`. Sanitize it: lowercase, replace every run of characters outside `[a-z0-9]` with `-`, strip leading/trailing `-`. If the result is empty, ask again. Run `claude mcp get paperless-<label>`: exit 0 means the name is taken (a miss lists every configured server, useful for suggesting a free label); ask for another label instead of overwriting.

   Skip this step for the first/default instance; it stays unlabeled (server name `paperless`).

3. **Ask for the remaining values**, one at a time:
   - The paperless-mcp URL, ending in `/mcp`. `http://localhost:8081/mcp` is the default port of a local paperless-mcp container; offer it as a suggestion but still ask.
   - How to authenticate:
     - **API token** (Paperless: *My Profile → API Auth Token*). Never print it back or log it.
     - **OAuth login** with the Paperless username and password, if the server has `MCP_BASE_URL` and `MCP_OAUTH_SECRET` set. No token is needed; Claude Code opens the login on first use.

4. **Register the instance**:

       # API token
       claude mcp add --transport http <name> "<url>" -H "Authorization: <token>" -s user
       # OAuth
       claude mcp add --transport http <name> "<url>" -s user

   `<name>` is `paperless` or `paperless-<label>`. The token appears in the command's arguments; there's no other way to pass it, so don't print or log it anywhere else.

5. **Tell the user to restart Claude Code** (or start a new session). A newly added server only connects on the next launch. With OAuth, the first tool call opens the login.

## List instances

1. Run `claude mcp list`; it health-checks every configured server.
2. Keep only lines whose server name matches `paperless([-_].+)?`. Each ends with a connection status.
3. Report label (or "default" for `paperless`) and connected or not. Mention claude.ai connectors with Paperless tools too, if any are loaded in this session. Never print tokens.

## Remove an instance

1. Ask which instance if not already clear.
2. Run `claude mcp remove <name>` with the exact server name.
3. Tell the user to restart Claude Code for the removal to take effect.
