#!/bin/bash
# SessionStart hook: flags when no Paperless instance is configured at all, so
# Claude can offer to run manage-paperless-instances instead of the user
# hitting a silent/failed MCP connection.
set -euo pipefail

input=$(cat)

claude_json_path="${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json"

any_instance_configured() {
  if [ ! -f "$claude_json_path" ]; then
    return 1
  fi
  python3 -c '
import json, re, sys
try:
    with open(sys.argv[1]) as f:
        servers = json.load(f)["mcpServers"]
    ok = any(re.match(r"^paperless([-_].+)?$", k) for k in servers)
except Exception:
    ok = False
sys.exit(0 if ok else 1)
' "$claude_json_path"
}

if any_instance_configured; then
  exit 0
fi

session_id=$(printf '%s' "$input" | python3 -c 'import json, sys; print(json.load(sys.stdin).get("session_id", ""))')

# UserPromptSubmit fires on every message; SessionStart and UserPromptSubmit
# both run this script. Only surface the reminder once per session (whichever
# fires first) instead of re-nagging on every prompt until an instance lands.
if [ -n "$session_id" ]; then
  marker="${TMPDIR:-/tmp}/paperless-plugin-credential-notice-${session_id}"
  if [ -e "$marker" ]; then
    exit 0
  fi
  touch "$marker"
fi

context="No Paperless instance is configured: no paperless/paperless-<label> entry exists in ${claude_json_path}'s mcpServers, so there's no MCP connection to authenticate. Proactively offer to run the paperless:manage-paperless-instances skill with the user now (collects the paperless-mcp URL and an API token or OAuth login for a new instance and registers it via 'claude mcp add' for this installation), unless they are already mid-task on something unrelated."

printf '%s' "$input" | python3 -c '
import json, sys

hook_input = json.load(sys.stdin)
event_name = hook_input.get("hook_event_name", "SessionStart")
context = sys.argv[1]
print(json.dumps({"hookSpecificOutput": {"hookEventName": event_name, "additionalContext": context}}))
' "$context"
