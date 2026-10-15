# Multiple instances

You can connect more than one Paperless-ngx instance, for example a home and a work archive. Each needs its own [Paperless-ngx MCP server container](https://paperless-ngx-mcp.marceltov.de/getting-started/) and is registered under its own name:

| Instance | MCP server name | Tool prefix |
| -------- | --------------- | ----------- |
| Default | `paperless-ngx` | `mcp__paperless-ngx__*` |
| Labeled, e.g. `work` | `paperless-ngx-work` | `mcp__paperless-ngx-work__*` |
| claude.ai connector | the connector's name | e.g. `mcp__claude_ai_Paperless-NGX__*` |

## Add, list or remove one

Ask Claude, for example "add my work Paperless-ngx instance" or "which Paperless-ngx instances are connected?". The `paperless-ngx-manage-instances` skill handles it:

- **Add:** asks for a label (like `work` or `home`), the URL and how you sign in, then registers `paperless-ngx-<label>`. Restart Claude Code so it connects.
- **List:** shows every configured instance and whether it's connected.
- **Remove:** unregisters the instance you name.

## Which instance a skill uses

With one instance connected, skills just use it. With several, a skill first checks whether you already named one ("in my work archive"); if not, it asks once which instance you mean and sticks with it for the rest of the task.
