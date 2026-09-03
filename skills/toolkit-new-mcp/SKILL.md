---
name: toolkit-new-mcp
description: Guide to wiring an MCP server into a project via .mcp.json — project-scoped vs user scope, stdio vs http transport, and env-var expansion so credentials never get hard-coded into a committed file. Use when a team wants to connect Claude Code to an internal system or third-party tool over MCP.
---

# Toolkit MCP Starter

`.mcp.json` is the standard way teams wire Claude Code into internal systems and third-party tools. It's project-scoped and meant to be committed — credentials go through environment-variable expansion, not literal values in the file.

## Template

Copy `skills/toolkit-new-mcp/templates/mcp.json.example` to `.mcp.json` at your project root and edit it:

```json
{
  "mcpServers": {
    "example-stdio": {
      "command": "npx",
      "args": ["-y", "@example-org/example-mcp-server"],
      "env": {
        "EXAMPLE_API_TOKEN": "${EXAMPLE_API_TOKEN}"
      }
    },
    "example-http": {
      "type": "http",
      "url": "https://mcp.example.com/${MCP_WORKSPACE:-default}",
      "headers": {
        "Authorization": "Bearer ${EXAMPLE_API_TOKEN}"
      }
    }
  }
}
```

## Transport types

- **`stdio`** (default when `command` is set) — Claude Code spawns a local process and talks over stdin/stdout. Good for CLI-wrapped tools and local servers.
- **`http`** (`"type": "http"`) — talks to a remote server over HTTP, supports OAuth. This is the current, supported remote transport.
- **`sse`** — deprecated in favor of `http`. Don't use it in new configs; if you're migrating an old one, swap `"type": "sse"` for `"type": "http"`.

## Env-var expansion for secrets

`${VAR}` and `${VAR:-default}` are expanded from the environment at runtime — never write a real token or URL directly into a committed `.mcp.json`. Set the actual values in your shell profile, a `.env` file loaded outside git, or your team's secrets manager.

## Scope: project vs user

- **Project scope** (`.mcp.json` at repo root, committed): the whole team gets the same servers automatically when they open the project. Use this for anything the team should share.
- **User scope** (`claude mcp add --scope user ...`, or a server defined only in your own `~/.claude` config): personal servers you don't want to impose on teammates.

Default to project scope for anything team-relevant; reach for user scope only for personal tooling.

## See Also

- Claude Code MCP docs: https://code.claude.com/docs/en/mcp
- Model Context Protocol spec: https://modelcontextprotocol.io/specification/2025-03-26
