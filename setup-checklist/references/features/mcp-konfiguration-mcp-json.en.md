# MCP Configuration (.mcp.json)

> **Mode:** project+global · **Priority:** critical · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic documentation (code.claude.com/docs).

## Configuring MCP servers (.mcp.json)

MCP servers give Claude Code direct access to external tools, databases, and APIs (e.g. GitHub, Sentry, a Postgres DB) — instead of constantly copying data into the chat by hand. For a pragmatic setup, three decisions are enough: scope, transport, secrets.

**1. Choose the scope — where does the server live?** There are three scopes. `local` (default) is private and only for you in the current project, stored in `~/.claude.json`. `user` is also private, but across all your projects (likewise in `~/.claude.json`). `project` is the team scope: the configuration ends up in a `.mcp.json` at the project root and is checked into version control — so everyone on the team has the same tools. WHY this matters: team-relevant servers belong in `project` (shared, reproducible), experimental or credential-bearing servers in `local` (private, not in the repo). On naming conflicts, `local` wins over `project` over `user` — and the entire entry from the highest source is used; there is no merging across scopes.

**2. Add a server — CLI instead of manual work.** The fastest way is via `claude mcp add`. For cloud services use the HTTP transport (`claude mcp add --transport http <name> <url>`), for local tools with system access use stdio (`claude mcp add [options] <name> -- <command> [args...]`). You control the scope with `--scope project|local|user`. Important: all options must come BEFORE the server name, and `--` separates the name from the actual command. The `.mcp.json` always has the top-level key `mcpServers`; stdio entries use `command`/`args`/`env`, HTTP entries use `type`/`url`/`headers` (`type` accepts `http` or the alias `streamable-http`; `sse` is deprecated).

**3. Never hardcode secrets.** In `.mcp.json`, Claude Code supports env variable expansion: `${API_KEY}` or with a fallback `${API_BASE_URL:-https://api.example.com}` — allowed in `command`, `args`, `env`, `url`, and `headers`. This lets you commit the config to the repo without concern, while real tokens stay as environment variables (if a variable is missing without a default, parsing the config fails). For remote servers with OAuth, no token belongs in the config at all: on the first 401/403, Claude Code flags the server, the login runs through `/mcp` in the browser, tokens are stored securely (system keychain on macOS or a credentials file) and renewed automatically. OAuth works with HTTP servers; with stdio servers there is no OAuth flow.

**4. Set approval deliberately.** For security reasons, Claude Code asks for confirmation before using project servers from a `.mcp.json` — because a shared repo could contain a malicious server. If you want to control this for a trusted project, use in `.claude/settings.json` (NOT in `.mcp.json`) either `enabledMcpjsonServers` as an allowlist (e.g. `["github"]`) or, if you really want to approve them all wholesale, `enableAllProjectMcpServers: true`. You reset approval decisions you have already made with `claude mcp reset-project-choices`. WHY prefer the allowlist: it is the lightweight, safe middle ground — you specifically approve what you know, instead of blindly approving everything.

## Reference (machine-readable)

```yaml
# ---------------------------------------------------------------
# MCP configuration (.mcp.json) — best-practice setup
# Source: https://code.claude.com/docs/en/mcp + /docs/en/settings
# ---------------------------------------------------------------
mcp_konfiguration:

  # The three scopes determine WHERE a server is stored
  # and whether it is shared with the team.
  scopes:
    local:    # Default. Only you, only this project. Stored in ~/.claude.json
    project:  # Team-shared via .mcp.json at the project root (in version control)
    user:     # Only you, but across ALL projects. Stored in ~/.claude.json
    # Precedence (highest first): local > project > user > plugins > claude.ai connectors
    # Whole server entry from the highest source is used; NO merge across scopes.

  # Add servers via CLI (options MUST come before the name,
  # "--" separates server name from command/args).
  cli:
    # Remote HTTP server (recommended for cloud services)
    http:  'claude mcp add --transport http <name> <url>'
    # Local stdio server (local process, system access)
    stdio: 'claude mcp add [options] <name> -- <command> [args...]'
    scope: 'claude mcp add --scope project|local|user ...'   # Default: local
    env:   'claude mcp add --env KEY=value ...'              # environment variables
    json:  "claude mcp add-json <name> '<json>'"            # directly from JSON
    list:  'claude mcp list'                                 # show all servers
    get:   'claude mcp get <name>'                           # details of one server

  # .mcp.json — team-shared, top-level key is ALWAYS "mcpServers".
  # Belongs at the project root and in version control.
  mcp_json_struktur:
    # stdio transport (local process)
    stdio_beispiel: |
      {
        "mcpServers": {
          "shared-server": {
            "command": "/path/to/server",
            "args": [],
            "env": {}
          }
        }
      }
    # HTTP transport (remote). type accepts "http"
    # (alias "streamable-http"). SSE ("sse") is deprecated.
    # WebSocket is a SEPARATE transport (type "ws"), only via .mcp.json / add-json.
    http_beispiel: |
      {
        "mcpServers": {
          "api-server": {
            "type": "http",
            "url": "${API_BASE_URL:-https://api.example.com}/mcp",
            "headers": {
              "Authorization": "Bearer ${API_KEY}"
            }
          }
        }
      }

  # Env variable expansion in .mcp.json: do NOT hardcode secrets,
  # reference them instead. Allowed in command, args, env, url, headers.
  env_expansion:
    syntax_var:     '${VAR}'            # value of the environment variable
    syntax_default: '${VAR:-default}'   # fallback when VAR is not set
    # Missing variable without default => config parse fails

  # OAuth for remote servers: token NOT in config.
  # Triggered automatically on 401/403; login via /mcp in interactive mode.
  # OAuth works with HTTP servers (flags apply only to HTTP/SSE, not stdio).
  oauth:
    befehl: '/mcp'              # start OAuth flow in the browser
    speicher: 'System-Keychain (macOS) bzw. Credentials-Datei, Auto-Refresh'
    scopes_pinnen: 'oauth.scopes (Leerzeichen-getrennter String) in .mcp.json begrenzt Berechtigungen'

  # Approval/auto-approve for project servers from .mcp.json.
  # CAUTION: these keys belong in .claude/settings.json (NOT in .mcp.json).
  # Default behavior: Claude Code asks before using project servers.
  approval_settings:
    enableAllProjectMcpServers: false   # boolean — auto-approve ALL project servers (wholesale)
    enabledMcpjsonServers: []           # string[] — allowlist: approve only these servers, e.g. ["memory","github"]
    disabledMcpjsonServers: []          # string[] — blocklist: reject these servers, e.g. ["filesystem"]
    reset: 'claude mcp reset-project-choices'   # reset approval decisions
```

## Audit criteria

- If a .mcp.json exists: top-level key is named 'mcpServers' (no other key)
- No plaintext secrets (API keys/tokens) in .mcp.json — use ${VAR} or ${VAR:-default} expansion instead (allowed in command, args, env, url, headers)
- HTTP server entries have a 'type' field with value 'http' or alias 'streamable-http'; 'sse' only if unavoidable (deprecated). Note: WebSocket is a separate transport (type 'ws'), NOT an HTTP type value
- Approval keys (enableAllProjectMcpServers / enabledMcpjsonServers / disabledMcpjsonServers) are in .claude/settings.json, NOT in .mcp.json
- If enableAllProjectMcpServers=true is set: was it a deliberate decision? Otherwise prefer a targeted allowlist via enabledMcpjsonServers
- A project-shared .mcp.json is in version control; local/experimental servers live in the local scope (~/.claude.json), not in the repo

## Removed / softened by the verifier (not documented)

- NO unsupported claims found. All 16 listed claims are documented by the official documentation (mcp page or settings page). Only two precision errors were corrected, no fabrications: (1) In one audit_check, 'ws' was incorrectly listed as a valid value of the HTTP 'type' field. According to the documentation, 'ws' is a SEPARATE transport (WebSocket), not an HTTP type value; the HTTP 'type' field accepts 'http' or the alias 'streamable-http'. (2) The OAuth token storage was shortened to 'Keychain' in the skill_section; the documentation states more precisely 'system keychain (macOS) or a credentials file' — aligned in the skill_section (the YAML block was already correct).