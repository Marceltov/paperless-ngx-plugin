# Install and connect

## 1. Deploy the Paperless-ngx MCP server

The plugin talks to Paperless-ngx through a running [Paperless-ngx MCP server](https://paperless-ngx-mcp.marceltov.de/). Set that up first with its [quick start](https://paperless-ngx-mcp.marceltov.de/getting-started/). Then either copy your API token from Paperless-ngx (*My Profile → API Auth Token*), or enable the OAuth login on the server to sign in with your Paperless-ngx username and password.

## 2. Install the plugin

In Claude Code:

```
/plugin marketplace add Marceltov/paperless-ngx-plugin
/plugin install paperless-ngx
```

## 3. Connect your Paperless-ngx instance

Start a new Claude Code session. If no Paperless-ngx instance is configured, the plugin's `SessionStart` hook flags it and Claude offers to run the `paperless-ngx-manage-instances` skill. It offers this once per installation, in the first session after you install the plugin; after that, ask for it yourself whenever you like, for example "set up the Paperless-ngx plugin".

The skill asks for the Paperless-ngx MCP server URL and how you sign in, and registers the instance under the name `paperless-ngx`, scoped to your user so every project sees it. Configure instances only through this skill, so the names match what the other skills look for.

Restart Claude Code afterwards: a newly registered server only connects on the next launch.

!!! note "Already connected through claude.ai?"

    If your Paperless-ngx MCP server is added as a connector on claude.ai, its tools are already available and the skills use them. The hook can't see connectors, so it may still offer a setup once; the skill notices the existing connection and stops, and you aren't asked again.

If you use several Claude Code installations (separate `CLAUDE_CONFIG_DIR`s), each is configured on its own.
