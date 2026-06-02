# Subagent definitions (.claude/agents/)

> **Mode:** project · **Priority:** critical · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic documentation (code.claude.com/docs).

## Subagent definitions (.claude/agents/)

Recurring specialized tasks — code review, research, test runs — you offload into dedicated sub-agent definitions. Store these as Markdown files under `.claude/agents/` in the project and check them into version control so the whole team uses the same reviewer or researcher. User-wide sub-agents that should be available across all projects belong in `~/.claude/agents/` instead. The most convenient way to create them is the `/agents` command; manually created files are only loaded after a session restart.

WHY: Each sub-agent runs in its own context window with its own system prompt and its own tool permissions. This keeps verbose output (search results, logs, file contents) out of your main conversation — only the summary comes back. At the same time you can restrict permissions (e.g. a reviewer without `Write`/`Edit`) and cut costs by routing routine tasks to faster models like Haiku.

Structure of a file: YAML frontmatter at the top, the body below is the system prompt. Only two fields are required — `name` (unique, lowercase, hyphens; the filename does not have to match) and `description` (controls when Claude delegates automatically; write it precisely). Optionally you control behavior via `tools` (allowlist; without a value all tools are inherited), `model` (`sonnet`/`opus`/`haiku`, full model ID or `inherit` — default is `inherit`), `effort` (`low`/`medium`/`high`/`xhigh`/`max`, depending on the model), `mcpServers` (dedicated MCP servers for this agent only), as well as `skills`, `memory`, `permissionMode`, `disallowedTools`, `hooks`, `maxTurns`, `color`, `background`, `isolation` and `initialPrompt`. For sub-agents loaded from plugins, `hooks`, `mcpServers` and `permissionMode` are ignored.

The folders `.claude/agents/` and `~/.claude/agents/` are scanned recursively — so you can place definitions in subfolders like `agents/review/`. The subfolder path does not affect identity or invocation, because identity comes solely from the `name` field. Keep `name` values unique across the entire tree: two files with the same name in one scope cause one to be discarded without warning.

Minimal example `.claude/agents/code-reviewer.md`:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Tip on model choice: If you want to temporarily override the model of all sub-agents (e.g. for a cheap CI run), set the environment variable `CLAUDE_CODE_SUBAGENT_MODEL` — it takes precedence over the `model` frontmatter (order: env > per-invocation `model` > `model` frontmatter > model of the main conversation). Best practices per the docs: focused sub-agents (one task per agent), detailed descriptions, minimal tool permissions, and into version control with them.

## Reference (machine-readable)

```yaml
# Subagent definitions — project-specific sub-agents as Markdown files
# Source: https://code.claude.com/docs/en/sub-agents (as of 2026-06-02)
subagents:
  # Location: store project sub-agents in .claude/agents/ (check into version control).
  # User-wide sub-agents go into ~/.claude/agents/. Folders are scanned recursively
  # (subfolders like agents/review/ allowed; identity comes ONLY from the name field).
  speicherort_projekt: ".claude/agents/"
  speicherort_user: "~/.claude/agents/"
  # File format: Markdown with YAML frontmatter. Body = system prompt of the sub-agent.
  format: "Markdown (.md) mit YAML-Frontmatter, Body = System-Prompt"

  # Frontmatter fields. ONLY name and description are required; all others optional.
  frontmatter:
    name:        "PFLICHT. Eindeutiger Bezeichner, lowercase + Bindestriche. Dateiname muss NICHT passen."
    description: "PFLICHT. Wann Claude an diesen Sub-Agent delegieren soll (steuert Auto-Delegation)."
    tools:       "Optional. Erlaubte Tools (Allowlist). Ohne Angabe: erbt alle Tools der Hauptkonversation."
    disallowedTools: "Optional. Tools-Denylist (wird vor tools angewendet; ein in beiden gelistetes Tool wird entfernt)."
    # model values: sonnet | opus | haiku | full model ID (e.g. claude-opus-4-8) | inherit
    model:       "Optional. Default: inherit (gleiches Modell wie Hauptkonversation)."
    # effort values: low | medium | high | xhigh | max (available levels depend on the model)
    effort:      "Optional. Effort-Level wenn Sub-Agent aktiv; ueberschreibt Session-Effort. Default: erbt von Session."
    # mcpServers: per entry either a server name (reference) or an inline definition (.mcp.json schema)
    mcpServers:  "Optional. MCP-Server nur fuer diesen Sub-Agent. Bei Plugin-Sub-Agents ignoriert."
    permissionMode: "Optional. default | acceptEdits | auto | dontAsk | bypassPermissions | plan. Bei Plugin-Sub-Agents ignoriert."
    skills:      "Optional. Skills, die beim Start in den Kontext vorgeladen werden (voller Inhalt)."
    memory:      "Optional. Persistenter Speicher: user | project | local."
    maxTurns:    "Optional. Max. agentische Turns bis Stopp."
    hooks:       "Optional. Lifecycle-Hooks nur fuer diesen Sub-Agent. Bei Plugin-Sub-Agents ignoriert."
    color:       "Optional. red|blue|green|yellow|purple|orange|pink|cyan."
    background:  "Optional. true = immer als Background-Task. Default: false."
    isolation:   "Optional. worktree = isolierter Repo-Klon in temporaerem git worktree."
    initialPrompt: "Optional. Wird als erster User-Turn auto-submitted, wenn der Agent als Haupt-Session laeuft (--agent / agent-Setting)."

# Model resolution (order): CLAUDE_CODE_SUBAGENT_MODEL (env) > per-invocation model
# > model frontmatter > model of the main conversation.
env:
  CLAUDE_CODE_SUBAGENT_MODEL: "Env-Var. Hat hoechste Prioritaet bei der Modell-Wahl fuer Sub-Agents."

# Minimal example .claude/agents/code-reviewer.md:
# ---
# name: code-reviewer
# description: Reviews code for quality and best practices
# tools: Read, Glob, Grep
# model: sonnet
# ---
# You are a code reviewer. ...
```

## Audit criteria

- Do project sub-agents live under .claude/agents/ (not elsewhere) and are they checked into version control?
- Does every sub-agent file have YAML frontmatter with the required fields name and description?
- Are the name values unique across the entire folder tree (lowercase + hyphens)? Duplicate names within a scope are discarded without warning.
- Is tools (allowlist) or disallowedTools set to restrict permissions to what is necessary (e.g. a reviewer without Write/Edit)?
- If model is set: does it use a valid value (sonnet/opus/haiku, full model ID or inherit)?
- If effort is set: does it use a valid level (low/medium/high/xhigh/max)?