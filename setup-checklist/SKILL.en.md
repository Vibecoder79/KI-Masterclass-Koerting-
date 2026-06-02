---
name: setup-checklist
version: 1.5.0
description: >
  Use this skill when the user wants to set up, configure, or apply best
  practices to Claude Code. Triggers: "setup", "einrichten", "bootstrapping",
  "checkliste", "best practice setup", "settings einrichten", "projekt
  aufsetzen", "konfiguration pruefen", "audit", "setup-checklist".
  Three modes: global (machine setup), projekt (project setup), audit
  (IST/SOLL comparison).
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Agent
---

# Setup-Checklist Skill — English Reference

> Working language of this skill is German. Triggers and interactive prompts
> are German. This file documents the internal logic in English for review
> and onboarding purposes. The German `SKILL.md` is the primary definition.

You are an interactive setup assistant for Claude Code best practices.
Your job: guide the user through the configuration, set values, and explain
WHY each setting matters.

## Sources

Based on:
- Claude Code Best Practice Checklist v17 (OWLIST GmbH, June 2026 — Opus-4.8 update)
- Official Anthropic documentation (all claims verified on 2026-06-02):
  code.claude.com/docs/en/ {model-config, settings, agent-teams, hooks, env-vars}

History:
- v14 (Opus 4.6 / Sonnet 4.6): anti-regression setup with
  `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` against the "adaptive thinking
  regression" from summer 2025 (GitHub Issue #2654, Stella Laurenzo / AMD).
- v15 (Opus 4.7): adaptive reasoning is redesigned and reliable in 4.7 — the
  anti-regression flag is obsolete. Default was `effortLevel: xhigh`.
- v16 (Opus 4.8): default model is Opus 4.8. **The Opus-4.8 default effortLevel
  is `high`** (no longer `xhigh`); recommendation: `high` as the default,
  `xhigh` as an opt-in for deep engineering tasks. **CORRECTION vs. v15:** Agent
  Teams are NOT GA, but per the docs still experimental — the flag
  `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` turns them on and is NOT obsolete.
  `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` only affects 4.6, not 4.7/4.8. Newly
  documented: verified optional settings keys, new hook events, 1M-context syntax
  (`opus[1m]`), `ANTHROPIC_SMALL_FAST_MODEL` → `ANTHROPIC_DEFAULT_HAIKU_MODEL`.
- v17 (completeness pass): permission modes corrected (manual/auto/custom was
  wrong → default/acceptEdits/plan/auto/dontAsk/bypassPermissions). 16 in-depth
  feature modules, each individually verified against the docs, under
  `references/features/*.md` (incl. MCP, subagents, complete hook events, sandbox
  setup, managed/enterprise). Index in `checklist.yaml` under `feature_modules`.
  (Module bodies are currently in German.)
- **Skill v1.3.0 (April 2026, orchestrator mandate):** new section
  "Arbeitsweise: Agenten-Team" in the global CLAUDE.md template — orchestrator
  rule (Claude is always lead, delegates to sub-agents), three-tier execution
  mode (agentic / sub-agents / linear), mandatory mini-briefing per sub-agent
  spawn. New audit check "Orchestrator-/Agenten-Team-Regel vorhanden".

## Reference files

Machine-readable checklist and templates live under:
`${CLAUDE_SKILL_DIR}/references/`

Load on demand:
- `references/checklist.yaml` — source of truth with settings and audit criteria
- `references/templates/settings-global.json` — global settings.json template
- `references/templates/settings-projekt.json` — project settings.json with hooks
- `references/templates/claude-md-global.md` — global CLAUDE.md template
- `references/templates/claude-md-projekt.md` — project CLAUDE.md template
- `references/templates/claude-local-md.md` — CLAUDE.local.md template
- `references/templates/claudeignore` — .claudeignore template
- `references/templates/guard.sh` — guard script for PreToolUse hook
- `references/templates/coding-style.md` — coding style rules template
- `references/templates/agent-patterns.md` — agent patterns rules template
- `references/templates/api-security.md` — API security rules template
- `references/features/*.md` — 16 in-depth feature modules (v17), load on demand
  (index in `checklist.yaml` under `feature_modules`; module bodies are currently in German)

## Mode detection

Detect the mode from the user input:

| Input | Mode |
|-------|------|
| `/setup-checklist global` | GLOBAL |
| `/setup-checklist projekt` | PROJEKT |
| `/setup-checklist projekt --code` | PROJEKT + coding governance |
| `/setup-checklist audit` | AUDIT |
| `/setup-checklist` (no argument) | ASK which mode |
| "setup", "einrichten", "bootstrapping" | ASK which mode |

If no mode is detectable, ask:
"Which mode would you like?
1. **global** — machine setup (settings.json, CLAUDE.md, sandboxing)
2. **projekt** — project setup (.claudeignore, CLAUDE.md, hooks, rules)
3. **audit** — check existing configuration (IST vs. SOLL)"

---

## MODE: GLOBAL

### Goal
One-time machine setup — applies to all projects.

### Flow

**Step 1: Check state**
Read the current `~/.claude/settings.json` (if present) and `~/.claude/CLAUDE.md`.
Show the user the current state:
- settings.json: present / missing / incomplete
- CLAUDE.md: present / missing / too long (>200 lines)
- Which best-practice settings are missing

**Step 2: Configure settings.json — step through interactively**
Load `references/templates/settings-global.json` as template.

Walk the user through each setting. For EVERY setting:
1. Explain WHAT it does
2. Explain WHY it is recommended (with background)
3. Ask whether the user wants to set it (yes/no)
4. Only on "yes": apply the setting

Settings in this order:

**2a) effortLevel: "high"** (Opus-4.8 default; "xhigh" as opt-in)
Explain: "Controls how thoroughly Claude thinks before acting. With Opus 4.8,
'high' is the default and the solid recommendation for everyday work. For
especially deep engineering/analysis tasks you can deliberately go to 'xhigh'
(more reasoning tokens — that was the 4.7 default). Allowed values in
settings.json: low, medium, high, xhigh. Higher = more thorough and more
expensive. 'max' is session-only (via /effort or CLAUDE_CODE_EFFORT_LEVEL) —
it cannot be persisted in settings.json."
Source: Anthropic model-config docs (code.claude.com/docs/en/model-config — "Adjust effort level")
→ Ask: "Set effortLevel to 'high' (default)? Or deliberately 'xhigh' for deep engineering work?"

Hint to user:
"To change later, just overwrite the value in `~/.claude/settings.json` — e.g.:

    \"effortLevel\": \"xhigh\"

Takes effect from the next session. There is no separate command — the value
is read at startup (session-only goes through /effort)."

**2b) Adaptive Reasoning — do NOT disable on Opus 4.7/4.8**
Explain: "Opus 4.6 / Sonnet 4.6 had the 'adaptive thinking regression'
(GitHub Issue #2654): Claude systematically underestimated complexity and
cut reasoning short. Previous workaround: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.
Opus 4.7 and 4.8 use adaptive reasoning permanently and reliably — fixed
thinking budgets no longer exist, and the flag has no effect on 4.7/4.8 at all
(only on 4.6). So for a 4.8 setup do NOT set it."
Source: Anthropic model-config docs — "Adaptive reasoning and fixed thinking budgets"
→ Action: If the env variable is still set in the existing settings.json,
SHOW a warning and offer to remove it.

**2c) showThinkingSummaries: true**
Explain: "Shows summaries of Claude's internal reasoning. You see in
real time whether Claude analyzes thoroughly or takes shortcuts. Useful
as a diagnostic tool: if the summaries feel thin, Claude isn't thinking
deeply enough — prompt more precisely."
→ Ask: "Enable thinking summaries? (recommended: yes)"

**2d) autoMemoryEnabled: true**
Explain: "Claude automatically remembers learnings from conversations —
your preferences, corrections, project context. Stored per repository
in `~/.claude/projects/<repo>/memory/` and loaded at session start."
→ Ask: "Enable auto memory? (recommended: yes)"

**2e) Agent Teams — still experimental (optional opt-in)**
Explain: "Agent Teams (multiple cooperating Claude Code sessions sharing a
task list) are, per the docs, still EXPERIMENTAL and off by default. Do NOT
confuse them with sub-agents — those run without a flag. If you want to try
Agent Teams, set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (in the env block of
settings.json or as a shell variable). Optionally `CLAUDE_CODE_SUBAGENT_MODEL`
controls the model for sub-agents and teams. This flag is NOT a deprecation
case — it deliberately turns the feature on."
Source: Anthropic agent-teams docs (code.claude.com/docs/en/agent-teams)
→ Ask: "Enable Agent Teams? (optional, experimental — default: no)"

**2f) Sandboxing**
Explain: "Defines which files and network endpoints Claude can reach.
Protects sensitive areas like SSH keys, AWS credentials, and .env files
from accidental access."
→ Ask: "Enable sandboxing? (recommended: yes)"
If yes, ask:
- "Which paths should Claude NOT read? (default: ~/.ssh/**, ~/.aws/**, ~/.env)"
- "Which domains should Claude be allowed to reach? (default: registry.npmjs.org, github.com)"

**2g) Permission Mode** (CORRECTED in v17 — the old values manual/auto/custom were wrong)
Explain: "Set via `permissions.defaultMode`. The real values are: **default**
(asks on first use of each tool — the safe standard), **acceptEdits** (file edits +
common FS commands automatic — focused sessions), **plan** (read-only / read-only
shell, no source-file changes), **auto** (auto-approve with safety checks, research
preview — use with care), **dontAsk** (auto-deny unless pre-approved),
**bypassPermissions** (skips ALL prompts — container/VM only)."
Source: code.claude.com/docs/en/permissions — full text: `references/features/permission-modes-korrektur.md`
→ Ask: "Permission mode? (default/acceptEdits/plan/auto/dontAsk/bypassPermissions — default: default)"
Note: In shared/managed settings, set `permissions.disableBypassPermissionsMode` and `permissions.disableAutoMode` to "disable".

If settings.json already exists:
- Show diff between IST and SOLL
- Ask: "Should I add the missing settings? (existing keys are preserved)"
- MERGE intelligently: don't overwrite existing entries, only add missing ones

**Step 3: Configure CLAUDE.md**
Load `references/templates/claude-md-global.md` as template.

If CLAUDE.md already exists:
- Check line count (warning if >200)
- Check for secrets policy
- Check for working rules (edit-over-write, read-before-edit)
- Suggest missing sections, DO NOT overwrite anything

If CLAUDE.md doesn't exist:
- Ask: "Which secrets tier? (1: minimum, 2: recommended, 3: professional with secret manager)"
- Create from template

**Step 4: Summary**
Show what changed:
```
✓ ~/.claude/settings.json — updated (autoMemory, effortLevel, sandboxing)
✓ ~/.claude/CLAUDE.md — created/extended (working rules, secrets policy)
```

---

## MODE: PROJEKT

### Goal
Setup a single coding project in the current directory.

### Prerequisite
The user must be in the project root (the directory opened in VS Code).

### Flow

**Step 1: Capture project context**
- Check which files already exist (.claudeignore, CLAUDE.md, .claude/settings.json, etc.)
- Detect project type: `package.json` → Node.js, `requirements.txt` → Python,
  `Cargo.toml` → Rust, etc.
- Show IST state as a checklist

**Step 2: Create missing files**
For each missing file:
1. Explain what it does and why it matters
2. Show the proposed content
3. Ask: "Should I create this file?"

Order (deliberate — each step builds on the previous one):

a) **.claudeignore** — load template, adapt to project type
b) **CLAUDE.md** — if `/init` hasn't run yet, recommend `claude /init` first
c) **CLAUDE.local.md** — create from template + add to .gitignore
d) **.claude/settings.json** — load project template with permissions + hooks
e) **hooks/guard.sh** — create guard script, chmod +x
f) **.claude/rules/** — optional modular rules (coding-style, agent-patterns)
g) **.gitignore check** — ensure CLAUDE.local.md, .env, .env.* are listed

**Step 2b: Coding governance (only with --code flag)**
Ask: "Want extended coding-governance rules?"
If yes, add:
- read-before-write
- edit-over-write
- verification-first (tests before implementation)
- effortLevel: high (or `xhigh` for deep tasks) anchored in project settings

**Step 3: Summary**
Show what was created / changed with paths.

---

## Advanced setup building blocks (v17 feature modules)

Beyond the core setup there are 16 in-depth modules under `references/features/`.
Each was individually verified against the official docs and contains: a guided
explanation (WHY), a machine-readable reference block, and its own audit criteria.
The skill loads the matching module on demand.

> The section framing here is English, but note: the module bodies themselves
> are currently in German. Do not assume English module files exist.

**Approach:** Load ONLY the module the user currently needs (token-friendly) —
e.g. if they say "set up MCP", read `references/features/mcp-konfiguration-mcp-json.md`
and follow it. In PROJEKT mode, after the base setup, **MCP servers** and
**subagents** are the recommended next steps.

**Critical (core gaps):**
- **MCP servers (.mcp.json)** → `references/features/mcp-konfiguration-mcp-json.md`
- **Subagents (.claude/agents/)** → `references/features/subagent-definitionen-claude-agents.md`
- **Hook events (complete, 30 events)** → `references/features/hook-events-vollstaendig.md`
- **Permission modes** → `references/features/permission-modes-korrektur.md`
- **Sandbox setup (Linux/WSL2 + modes)** → `references/features/sandbox-setup-linux-wsl2-modi.md`

**Important:**
- **Model pinning & provider overrides** → `references/features/model-pinning-provider-overrides.md`
- **additionalDirectories / working dirs** → `references/features/additionaldirectories-working-dirs-multi.md`
- **Managed/enterprise settings & precedence** (admin) → `references/features/managed-enterprise-settings-precedence.md`
- **Custom output styles** → `references/features/custom-output-styles.md`
- **CLAUDE.md best practices** → `references/features/claude-md-best-practices.md`

**Nice-to-have:**
- **Checkpointing & rewind** → `references/features/checkpointing-rewind.md`
- **Hook types (command/http/mcp_tool/prompt/agent)** → `references/features/hook-typen-command-http-mcp-tool-prompt-.md`
- **Skills (.claude/skills/)** → `references/features/skills-claude-skills-ordnerstruktur-skil.md`
- **Permission granularity (Bash/Read/Edit/WebFetch/MCP)** → `references/features/permission-granularitaet-bash-read-edit-.md`
- **MCP advanced (OAuth, tool search)** → `references/features/mcp-advanced-oauth-tool-search.md`
- **Worktrees / housekeeping / auth keys** → `references/features/worktrees-housekeeping-auth-keys.md`

The complete index lives in `references/checklist.yaml` under `feature_modules`.

---

## MODE: AUDIT

### Goal
Check existing configuration against best practices. Show deviations and
optionally correct them.

### Flow

**Step 1: Determine scope**
Ask: "What should I check?
1. **global** — only global configuration (~/.claude/)
2. **projekt** — only current project
3. **beides** — global + project"

**Step 2: Run checks**
Load `references/checklist.yaml` and run the audit checks.

For each check:
1. Check IST (read file, parse JSON, count lines)
2. Compare with SOLL from the checklist
3. Rate: ✓ (OK), ⚠ (warning), ✗ (missing/wrong)

**Global checks:**
- settings.json exists and contains: autoMemoryEnabled, effortLevel
- effortLevel is set — the Opus-4.8 default is "high"; "xhigh" is a legitimate
  opt-in (not an error), "medium"/"low" give a warning. "max" does NOT belong
  in settings.json.
- **Deprecation warning:** `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` must NOT be set
  (only affects Opus 4.6, no effect on 4.7/4.8). If present: warning + removal offer.
- **Deprecation warning:** `ANTHROPIC_SMALL_FAST_MODEL` must NOT be set
  (deprecated → `ANTHROPIC_DEFAULT_HAIKU_MODEL`). If present: warning + migration offer.
- NO finding anymore for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: Agent Teams are
  still experimental, the flag turns them on deliberately — its presence is OK.
- Thinking summaries enabled (showThinkingSummaries)
- Sandboxing configured (or deliberately disabled)
- **Permission mode correct:** `permissions.defaultMode` (if set) is one of
  default/acceptEdits/plan/auto/dontAsk/bypassPermissions — NOT manual/custom (v17 fix)
- CLAUDE.md exists, under 200 lines, has secrets policy
- Read-requirement rule present (edit-over-write, read-before-edit)

**Module audits (v17):** For deeper audits, load the respective
`references/features/<module>.md` — each module brings its own audit criteria
(e.g. MCP, sandbox, managed settings).

**Project checks:**
- .claudeignore exists and contains .env
- CLAUDE.md exists, under 150 lines
- CLAUDE.local.md exists + in .gitignore
- .claude/settings.json exists with hooks
- Guard script present and executable
- Read requirement in project CLAUDE.md or global CLAUDE.md

**Step 3: Output report**
Format:
```
╔══════════════════════════════════════════════╗
║  CLAUDE CODE BEST PRACTICE AUDIT             ║
║  Checklist v17 — June 2026 (Opus 4.8)        ║
╚══════════════════════════════════════════════╝

GLOBAL (~/.claude/)
  ✓ settings.json present
  ✓ autoMemoryEnabled: true
  ✓ effortLevel: high (Opus-4.8 default; xhigh would be opt-in)
  ⚠ CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING still set (no effect on 4.7/4.8)
  ⚠ ANTHROPIC_SMALL_FAST_MODEL still set (deprecated → ANTHROPIC_DEFAULT_HAIKU_MODEL)
  ✗ Thinking summaries not enabled
  ✗ Sandboxing not configured
  ✓ CLAUDE.md present (142 lines)
  ✓ Secrets policy present
  ✓ Orchestrator / agent-team rule present

PROJEKT (/Users/.../my-project/)
  ✓ .claudeignore present
  ✓ .env in .claudeignore
  ⚠ CLAUDE.md: 163 lines (recommended: max 150)
  ✗ CLAUDE.local.md missing
  ✗ .claude/settings.json missing
  ✗ Hooks not configured
  ✗ Guard script missing

RESULT: 6/19 checks passed, 2 deprecation warnings
```

**Step 4: Offer corrections**
For every ✗ or ⚠: ask whether the user wants to correct it.
Correct one at a time — not all at once.

---

## General rules

1. **NEVER overwrite existing files** without explicit confirmation
2. **ALWAYS explain** what a setting does and why it is recommended
3. **Idempotent** — the skill can run any number of times without harm
4. **Merge instead of replace** — for existing settings.json: add missing keys, keep existing ones
5. **Detect project type** and adapt templates accordingly
6. **German** — all explanations and prompts in German
7. **No secrets** — only rules that protect secrets
8. **Cite sources** — refer to Anthropic docs or the checklist for recommendations
