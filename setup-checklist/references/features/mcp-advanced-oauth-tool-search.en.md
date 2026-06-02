# MCP Advanced (OAuth, Tool Search)

> **Mode:** global+project · **Priority:** nice-to-have · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## MCP Advanced: OAuth, Tool Search and Limits

Remote MCP servers (Sentry, GitHub, Notion, etc.) usually require sign-in. Claude Code supports OAuth 2.0: after `claude mcp add`, run `/mcp` in Claude Code once and complete the browser login. The tokens are then stored securely and refreshed automatically. Via the `/mcp` menu you can also revoke the sign-in with "Clear authentication". WHY: This keeps long-lived bearer tokens out of `.mcp.json` and version control. If a server requires a fixed, pre-registered redirect URI, pin the port with `--callback-port 8080` (form `http://localhost:PORT/callback`); this flag can be used on its own (with Dynamic Client Registration) or together with `--client-id`. Servers without Dynamic Client Registration need pre-configured credentials via `--client-id` and `--client-secret` (the secret is prompted masked and stored in the system keychain or a credentials file, not in the config; alternatively via `MCP_CLIENT_SECRET` for CI). These flags apply only to HTTP and SSE transports and have no effect on stdio servers. Security teams can restrict the requested permissions to an approved subset via `oauth.scopes` in `.mcp.json` (space-separated string, takes precedence over `authServerMetadataUrl` and over `/.well-known` discovery).

Tool Search is active by default and should stay active. Instead of loading all MCP tool definitions into the context at session start, they are deferred and only discovered on demand via a search tool. WHY: This way each additional MCP server costs almost no context window, and only the tools actually used take up space. Controlled via the environment variable `ENABLE_TOOL_SEARCH` (in the `env` block of `settings.json` or as a shell variable): unset/`true` = everything deferred, `auto` or `auto:N` = threshold mode (load tools upfront only if they fit within N percent of the context, default 10%, the rest deferred), `false` = load everything upfront. Note: `ENABLE_TOOL_SEARCH=true` sends the beta header on Vertex/proxy too, but requests then fail on Vertex models before Sonnet 4.5/Opus 4.5 or on proxies without `tool_reference` support. Tool Search generally needs a model with `tool_reference` support (Sonnet 4+ / Opus 4+, no Haiku). Individual servers whose tools are needed on every turn can be exempted from deferral with `alwaysLoad: true` in the server entry (from v2.1.121) — use sparingly, since it costs context again and blocks startup until connect (max. 5-second connect timeout).

For large tool outputs, Claude Code warns starting at 10,000 tokens; the default maximum is 25,000 tokens. For servers that deliver large datasets or reports, raise the limit via `MAX_MCP_OUTPUT_TOKENS` (e.g. `MAX_MCP_OUTPUT_TOKENS=50000`). The server startup timeout can be set with `MCP_TIMEOUT` (e.g. `MCP_TIMEOUT=10000 claude` for 10 seconds). The tool execution timeout is controlled by `MCP_TOOL_TIMEOUT` globally; per server, a `timeout` field (in milliseconds) in the `.mcp.json` entry takes precedence, e.g. `"timeout": 600000` for ten minutes — values below 1000 are floored to one second. These three variables are documented on the mcp page (not on the env-vars page).

## Reference (machine-readable)

```yaml
# MCP Advanced — OAuth, Tool Search, output and timeout limits
# Placement: global (env vars via settings.json env) + project (.mcp.json)
# Source: https://code.claude.com/docs/en/mcp (live-checked 2026-06-02)
mcp_advanced:

  # --- OAuth for remote servers (HTTP/SSE) ---
  oauth:
    # Authentication against OAuth 2.0 servers: after `claude mcp add`, run
    # the command /mcp in Claude Code and complete the browser login.
    # Tokens are stored securely and refreshed automatically.
    auth_command: "/mcp"                 # Login + "Clear authentication" to revoke
    # Fixed callback port if the server requires a pre-registered redirect URI
    # (http://localhost:PORT/callback). Usable on its own (with Dynamic
    # Client Registration) or together with --client-id:
    callback_port_flag: "--callback-port 8080"
    # Servers without Dynamic Client Registration: pre-configured credentials.
    # --client-secret prompts masked for the secret (or MCP_CLIENT_SECRET as env).
    preconfigured_creds: "claude mcp add --transport http --client-id <id> --client-secret --callback-port 8080 <name> <url>"
    # Note: --client-id/--client-secret/--callback-port apply only to
    # HTTP and SSE transports; no effect on stdio servers.
    # Optional oauth fields in .mcp.json (server entry):
    json_oauth_fields:
      clientId: "your-client-id"
      callbackPort: 8080
      # Pin scopes to the subset approved by the security team
      # (space-separated string, takes precedence over authServerMetadataUrl
      # and over discovery via /.well-known):
      scopes: "channels:read chat:write search:read"
      # Override the discovery chain (https:// only, from v2.1.64):
      authServerMetadataUrl: "https://auth.example.com/.well-known/openid-configuration"

  # --- Tool Search (default on) ---
  # Reduces context consumption: MCP tool definitions are loaded deferred
  # and only discovered on demand via ToolSearch. Default = active.
  # Requires a model with tool_reference (Sonnet 4+/Opus 4+; no Haiku).
  tool_search:
    env_var: "ENABLE_TOOL_SEARCH"        # in settings.json env or as shell env
    values:
      unset: "Alle MCP-Tools deferred, on demand (Default). Faellt auf Upfront-Laden zurueck auf Vertex AI oder bei nicht-first-party ANTHROPIC_BASE_URL"
      "true": "Alle deferred; Beta-Header wird auch auf Vertex/Proxy gesendet. Requests SCHLAGEN FEHL auf Vertex-Modellen vor Sonnet 4.5/Opus 4.5 oder auf Proxies ohne tool_reference-Support"
      "auto": "Schwellenwert: Tools upfront laden wenn sie in <10% Context passen, Rest deferred"
      "auto:N": "Schwellenwert mit eigenem Prozentsatz (N = 0-100), z.B. auto:5"
      "false": "Alle Tools upfront geladen, kein Deferral"
    # Keep an individual server always visible (in the .mcp.json server entry):
    always_load: "alwaysLoad: true"      # from v2.1.121; blocks startup until connect (max 5s)
    # Forbid the ToolSearch tool entirely (settings.json):
    deny_tool: '{ "permissions": { "deny": ["ToolSearch"] } }'

  # --- Output and timeout limits (env vars) ---
  # Note: these three variables are documented on the mcp page, but do
  # NOT appear on the env-vars page (as of 2026-06-02).
  limits:
    # Warning from 10,000 tokens of tool output; default maximum 25,000 tokens.
    MAX_MCP_OUTPUT_TOKENS: 50000         # raise for large data volumes/reports
    # Startup timeout for MCP servers in ms (example only, no documented default):
    MCP_TIMEOUT: 10000                   # e.g. MCP_TIMEOUT=10000 claude (= 10s)
    # Global tool execution timeout; overridable per server via .mcp.json "timeout" (ms).
    # Values below 1000 are floored to 1 second.
    MCP_TOOL_TIMEOUT: 600000             # example only; per-server "timeout": 600000 takes precedence
```

## Audit criteria

- OAuth servers: Are tokens authenticated only via /mcp and NOT stored as static bearer headers in .mcp.json/version control?
- Tool Search: Is ENABLE_TOOL_SEARCH not accidentally set to false (default behavior = deferred is preserved)?
- alwaysLoad: true set only for a few servers that are truly needed on every turn (no context waste)?
- Does the model in use support tool_reference (Sonnet 4+/Opus 4+, no Haiku) if ENABLE_TOOL_SEARCH=true is forced? (On Vertex additionally: Sonnet 4.5+/Opus 4.5+)
- oauth.scopes pinned to an approved subset when the server offers more scopes than needed?
- MAX_MCP_OUTPUT_TOKENS deliberately set for servers with large outputs (default 25,000, warning from 10,000)?

## Removed / softened by the verifier (not documented)

- env-vars page question clarified: MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT and MCP_TOOL_TIMEOUT do NOT appear on https://code.claude.com/docs/en/env-vars (confirmed via WebFetch). However, all three are documented verbatim on the mcp page. The draft claim #15 (verified:false) is therefore correct; no content needs to be removed, only the source attribution made more precise.
- No documented default numeric value for MCP_TIMEOUT (startup) and MCP_TOOL_TIMEOUT (global). The docs only state example values 10000 and 600000 respectively. The YAML values are therefore to be treated as examples and not as defaults (already marked as such in the draft, kept).
- Clarification instead of removal: The ENABLE_TOOL_SEARCH=true description 'beta header on Vertex/proxy too' was incomplete. The docs add that requests FAIL on Vertex models before Sonnet 4.5 / Opus 4.5 or on proxies without tool_reference support. Corrected.