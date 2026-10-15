# Install and connect

## 1. Deploy paperless-mcp

The plugin talks to Paperless through a running [paperless-mcp](https://paperless-mcp.marceltov.de/) server. Set that up first with its [quick start](https://paperless-mcp.marceltov.de/getting-started/). Then either copy your API token from Paperless (*My Profile → API Auth Token*), or enable the OAuth login on the server to sign in with your Paperless username and password.

## 2. Install the plugin

In Claude Code:

```
/plugin marketplace add Marceltov/paperless-plugin
/plugin install paperless
```

## 3. Connect your Paperless

Start a new Claude Code session. If no Paperless is configured, the plugin's `SessionStart` hook flags it and Claude offers to run the `manage-paperless-instances` skill. It offers this once per installation, in the first session after you install the plugin; after that, ask for it yourself whenever you like, for example "set up the Paperless plugin".

The skill asks for the paperless-mcp URL and how you sign in, and registers the instance under the name `paperless`, scoped to your user so every project sees it. Configure instances only through this skill, so the names match what the other skills look for.

Restart Claude Code afterwards: a newly registered server only connects on the next launch.

!!! note "Already connected through claude.ai?"

    If your Paperless is added as a connector on claude.ai, its tools are already available and the skills use them. The hook can't see connectors, so it may still offer a setup once; the skill notices the existing connection and stops, and you aren't asked again.

If you use several Claude Code installations (separate `CLAUDE_CONFIG_DIR`s), each is configured on its own.
