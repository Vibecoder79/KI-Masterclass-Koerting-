# Hook types (command/http/mcp_tool/prompt/agent) and matcher syntax

> **Mode:** project+global · **Priority:** nice-to-have · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Choosing hook types (command / http / mcp_tool / prompt / agent)

Before you create a hook, make a deliberate choice about the `type` field — it determines HOW the hook runs, and each type has its own required fields. The official docs (https://code.claude.com/docs/en/hooks) define five types:

- `command`: runs a shell line. The event JSON arrives on stdin, and you return the response via exit code and stdout. Required field: `command`. This is the default for local scripts (linting, formatting, validation).
- `http`: posts the event JSON (Content-Type: application/json) to a URL. Required field: `url`. Useful when an external service should make the decision.
- `mcp_tool`: calls a tool of an already connected MCP server. Required fields: `server` and `tool` (optional `input`, which supports `${path}` substitution from the hook input). Use this when the logic already exists as an MCP tool.
- `prompt`: sends a prompt to a Claude model for a single-turn evaluation and gets a yes/no decision back as JSON. Required field: `prompt` (optional `model`, default is a fast model). With `$ARGUMENTS` you bring the hook input JSON into the prompt.
- `agent`: spawns a subagent that may use tools such as Read, Grep, Glob before deciding. Required field: `prompt` (optional `model`). IMPORTANT: the docs explicitly mark agent hooks as experimental ("Agent hooks are experimental and may change") — they may change. Only use them if you accept that instability.

WHY this matters: The wrong type misses the goal or wastes tokens unnecessarily. For deterministic, fast checks use `command` (no model call). Only reach for `prompt`/`agent` when a model-based assessment is truly needed — and prefer the lighter `prompt` over the experimental `agent`.

WHEN a hook fires is controlled by the `matcher`. The tool events `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` and `PermissionDenied` match on the tool name. Events such as `UserPromptSubmit`, `Stop` or `PostToolBatch` have no matcher and always fire (a matcher that is set is silently ignored). Matcher rule: `"*"`/empty/omitted matches everything; if they consist only of letters, digits, `_` and `|`, they are exact names or `|`-lists (`"Edit|Write"`); as soon as another character appears, the matcher is evaluated as a JavaScript regex (`"mcp__memory__.*"`). MCP tools are named `mcp__<server>__<tool>`; to hit all tools of a server, the `.*` must be appended (`mcp__memory__.*`) — `mcp__memory` alone contains only letters/`_` and is compared as an exact string, so it matches no tool. Hooks work both in the global (`~/.claude/settings.json`) and in the project settings (`.claude/settings.json`) — place them wherever the scope fits.

## Reference (machine-readable)

```yaml
# Hook types — the "type" value in a hook entry determines HOW the hook is executed.
# Source: https://code.claude.com/docs/en/hooks (verified)
# Placement: project (.claude/settings.json) OR global (~/.claude/settings.json) — both support hooks.
hooks:
  # 1) command — runs a shell command; event JSON arrives on stdin, result via exit code/stdout.
  #    Required field: command
  type_command:
    type: command
    command: "deine-shell-zeile"

  # 2) http — sends the event JSON as an HTTP POST (Content-Type: application/json) to a URL.
  #    Required field: url
  type_http:
    type: http
    url: "https://example.com/endpoint"

  # 3) mcp_tool — calls a tool of an already connected MCP server.
  #    Required fields: server, tool  (optional: input with ${path} substitution)
  type_mcp_tool:
    type: mcp_tool
    server: "my_server"
    tool: "security_scan"
    input: { file_path: "${tool_input.file_path}" }

  # 4) prompt — sends a prompt to a Claude model for single-turn evaluation; model returns yes/no as JSON.
  #    Required field: prompt  (optional: model, default = fast model). Placeholder $ARGUMENTS = hook input JSON.
  type_prompt:
    type: prompt
    prompt: "Pruefe ... Nutze $ARGUMENTS als Platzhalter fuer das Hook-Input-JSON"
    model: "optional-model-name"   # optional, default = fast model

  # 5) agent — spawns a subagent that may use tools (Read/Grep/Glob) before deciding.
  #    Required field: prompt  (optional: model). CAUTION: per docs EXPERIMENTAL ("experimental and may change").
  type_agent:
    type: agent
    prompt: "... $ARGUMENTS ..."
    model: "optional-model-name"   # optional

# --- Matcher syntax (controls WHEN a hook fires) ---
# Tool events match on the tool name:
#   PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied
# NO matcher support (always fire, matcher is silently ignored):
#   UserPromptSubmit, PostToolBatch, Stop, CwdChanged, WorktreeCreate, WorktreeRemove
matcher_regeln:
  alle: '"*"  /  ""  /  weglassen  -> matcht alles'
  exakt_oder_liste: 'nur Buchstaben/Ziffern/_/| -> exakter Name oder |-Liste, z.B. "Bash" oder "Edit|Write"'
  regex: 'sobald ein anderes Zeichen vorkommt -> JavaScript-Regex, z.B. "^Notebook" oder "mcp__memory__.*"'
  mcp_naming: 'MCP-Tools heissen mcp__<server>__<tool>; "mcp__memory__.*" matcht alle Tools des Servers. WICHTIG: das ".*" ist Pflicht — "mcp__memory" allein enthaelt nur Buchstaben/_ und wird als exakter String verglichen, matcht also KEIN Tool.'
```

## Audit criteria

- Every hook entry has a valid type field from {command, http, mcp_tool, prompt, agent}
- command hooks have the required field command; http hooks the required field url
- mcp_tool hooks have both required fields server AND tool
- prompt and agent hooks have the required field prompt
- agent hooks are used deliberately (docs: experimental, may change) and not for trivial checks
- Matchers are only set on tool events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied), not on matcher-less events (where the matcher is silently ignored)
- MCP tool matchers follow the schema mcp__<server>__<tool> and use .* to hit all tools of a server (mcp__memory__.*); a matcher without .* (e.g. mcp__memory) matches no tool
