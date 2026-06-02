# Hook events (complete)

> **Mode:** project+global · **Priority:** critical · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Know the hook events and set them deliberately

Hooks are custom handlers (type `command`, `http`, `mcp_tool`, `prompt`, or `agent`) that Claude Code runs automatically at fixed points in the lifecycle. They are configured under the key `"hooks"` in `settings.json` — globally under `~/.claude/settings.json` (all projects, local to your machine only), shareable per project under `.claude/settings.json` (committable), or privately under `.claude/settings.local.json` (gitignored). Beyond these, the docs list further sources: managed policy settings (org-wide), plugin `hooks.json`, and skill/agent frontmatter. WHY this matters: hooks are the mechanism for deterministic, enforced behavior — the harness runs them, not the model. A rule in CLAUDE.md is a request; a hook is a guarantee.

Step 1 — Understand which events exist. The docs list (as of retrieval 2026-06-02) exactly 30 events. Groups: session lifecycle (`SessionStart`, `Setup`, `SessionEnd`), prompt processing (`UserPromptSubmit`, `UserPromptExpansion`), tool calls (`PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`), stop (`Stop`, `StopFailure`), subagents/tasks/teams (`SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`), context/config/files (`InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`), worktrees (`WorktreeCreate`, `WorktreeRemove`), compaction (`PreCompact`, `PostCompact`), MCP elicitation (`Elicitation`, `ElicitationResult`), display/notification (`Notification`, `MessageDisplay`).

Step 2 — Choose blocking vs. observe-only events deliberately. The docs carry a dedicated "Can block?" column. CAN block: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation`, `ElicitationResult`. Purely informational (ideal for logging/automation without blocking risk): among others `SessionStart`, `Setup`, `SessionEnd`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `MessageDisplay`, `SubagentStart`, `StopFailure`, `InstructionsLoaded`, `CwdChanged`, `FileChanged`, `WorktreeRemove`, `PostCompact`, `PermissionDenied`. The most common guardrails in practice: `PreToolUse` (prevents risky tool calls such as `rm -rf` or writes to protected paths), `UserPromptSubmit` (validates/blocks prompts before processing), `Stop` (holds Claude before its answer counts as finished).

Step 3 — Understand the block mechanism. Exit code 0 = success (Claude parses stdout for JSON output fields; JSON is only processed on exit 0). Exit code 2 = blocking error (stdout and JSON are ignored, stderr is fed back to Claude as an error message; the exact effect depends on the event). Any other non-zero exit = non-blocking error (only logged, execution continues). NOTE per the docs warning: for most events ONLY exit code 2 blocks — exit code 1 does NOT block, even though 1 is the usual Unix error code. For policy enforcement, therefore, you must use `exit 2` (or emit the appropriate decision JSON on exit 0). For pure side effects (notify, log, format) use exit 0 without a decision.

Step 4 — Set the `matcher` correctly. `"*"`, empty, or omitted = all. Only letters/digits/`_`/`|` are treated as an exact string or a `|`-separated list (e.g. `"Edit|Write"`); any other character turns the matcher into a JavaScript regex (e.g. `"mcp__.*"`). For tool events the matcher filters on the tool name. Important for MCP: `mcp__<server>__.*` needs the trailing `.*` — `mcp__memory` alone counts as an exact string and matches no tool. Not every event supports a matcher (e.g. `UserPromptSubmit`, `Stop`, `CwdChanged`); `FileChanged` uses its own watch logic with literal file names.

## Reference (machine-readable)

```yaml
# ============================================================
# Hook-Events (Claude Code) — Referenz
# Quelle: https://code.claude.com/docs/en/hooks (Abruf 2026-06-02, vollstaendig)
# Platzierung: projekt (.claude/settings.json) + global (~/.claude/settings.json)
# Konfiguriert unter dem Key "hooks" in settings.json
# Blocken: Fuer die meisten Events blockiert NUR Exit-Code 2 (Exit 1 = nicht-blockierend!).
#          Alternativ JSON-Output bei Exit 0 (event-spezifische Felder).
# ============================================================

hooks:
  # ---- Session lifecycle ----
  SessionStart:        # fires when the session begins/resumes — NO block (stdout becomes context)
  Setup:               # fires on --init-only / --init / --maintenance (-p mode, CI) — NO block
  SessionEnd:          # fires when the session terminates — NO block

  # ---- Prompt processing ----
  UserPromptSubmit:    # fires when the user submits a prompt, before processing — CAN block (exit 2 deletes the prompt)
  UserPromptExpansion: # fires when a typed command expands into a prompt — CAN block (exit 2 blocks the expansion)

  # ---- Tool calls ----
  PreToolUse:          # fires before tool execution — CAN block (exit 2 blocks the tool call)
  PermissionRequest:   # fires when the permission dialog appears — CAN block (exit 2 denies the permission)
  PermissionDenied:    # fires when the auto-mode classifier rejects a tool — NO block; JSON hookSpecificOutput.retry:true possible
  PostToolUse:         # fires after a successful tool call — NO block (shows stderr to Claude)
  PostToolUseFailure:  # fires after a failed tool call — NO block (shows stderr to Claude)
  PostToolBatch:       # fires after a parallel tool batch completes, before the next model call — CAN block (exit 2 stops the loop)

  # ---- Display / notification ----
  Notification:        # fires when Claude Code sends a notification — NO block
  MessageDisplay:      # fires while assistant text is displayed — NO block (the original text is shown)

  # ---- Subagents / tasks / teams ----
  SubagentStart:       # fires when a subagent is spawned — NO block
  SubagentStop:        # fires when a subagent finishes — CAN block (exit 2 prevents the subagent stop)
  TaskCreated:         # fires when a task is created via TaskCreate — CAN block (exit 2 rolls back the creation)
  TaskCompleted:       # fires when a task is marked done — CAN block (exit 2 prevents completion)
  TeammateIdle:        # fires when an agent-team teammate is about to go idle — CAN block (exit 2 prevents going idle)

  # ---- Stop ----
  Stop:                # fires when Claude finishes its answer — CAN block (exit 2 continues the conversation)
  StopFailure:         # fires when the turn ends due to an API error — NO block (output/exit code ignored)

  # ---- Context / config / files ----
  InstructionsLoaded:  # fires when CLAUDE.md or .claude/rules/*.md is loaded into context — NO block (exit code ignored)
  ConfigChange:        # fires when a config file changes during the session — CAN block (exit 2, except policy_settings)
  CwdChanged:          # fires when the working directory changes — NO block (no matcher)
  FileChanged:         # fires when a watched file changes on disk — NO block (matcher = literal file names)

  # ---- Worktrees ----
  WorktreeCreate:      # fires when a worktree is created via --worktree / isolation:"worktree" — CAN block (any non-zero exit)
  WorktreeRemove:      # fires when a worktree is removed — NO block (errors only logged in debug)

  # ---- Compaction ----
  PreCompact:          # fires before context compaction — CAN block (exit 2 blocks compaction)
  PostCompact:         # fires after compaction completes — NO block

  # ---- MCP Elicitation ----
  Elicitation:         # fires when an MCP server requests user input during a tool call — CAN block (exit 2 denies)
  ElicitationResult:   # fires after the user has responded to an MCP elicitation, before it is sent back — CAN block (exit 2 = decline)

# ------------------------------------------------------------
# Structure of a hook entry (settings.json):
#   "hooks": { "<EventName>": [ { "matcher": "<pattern>",
#              "hooks": [ { "type": "command|http|mcp_tool|prompt|agent", ... } ] } ] }
# matcher: "*"/""/omitted = all; only letters/digits/_/| = exact or |-list; otherwise JavaScript regex
# For tool events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied)
#   the matcher filters on the tool name (e.g. Bash, Edit|Write, mcp__<server>__.* — '.*' is required for MCP wildcards)
# Some events have no matcher (e.g. UserPromptSubmit, Stop, CwdChanged); FileChanged follows its own watch logic.
# Additional scopes per the docs: Managed Policy (org-wide), Plugin (hooks.json), skill/agent frontmatter.
# ------------------------------------------------------------
```

## Audit criteria

- settings.json: Does a 'hooks' key even exist (global OR project)? If production guardrails are expected but none exists -> flag it.
- Every configured event name is an event documented in the official docs (no typo/invented name like 'PreTool' instead of 'PreToolUse'). Reference: the 30 documented events.
- Blocking guardrail hooks (e.g. PreToolUse for rm -rf / protected paths) use exit code 2 (or the event-specific decision JSON on exit 0) — NOT exit 1: per the docs, exit 1 does NOT block. A pure log command without exit 2 is ineffective as a guardrail.
- Tool events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied) have a meaningful matcher on the tool name instead of a blind '*' when only specific tools are meant; MCP wildcards end in '.*'.
- The hook scope matches the intent: machine-wide rules in ~/.claude/settings.json, project-specific shareable rules in .claude/settings.json, secret/machine-specific things in .claude/settings.local.json (gitignored).
- A guardrail event with Can-block=No (e.g. PostToolUse, PermissionDenied, Notification) is NOT mistaken for a blocker — these cannot prevent the action, only react/log.

## Removed / softened by the verifier (not documented)

- No invented event names found — all 30 events appear verbatim in the official docs. Corrections concern only incomplete/misleading block annotations in the draft, not invented content:
- DRAFT ERROR (corrected, not removed): YAML comment 'SubagentStop: fires when a subagent finishes' without a block note — docs: CAN block (exit 2 prevents the subagent stop).
- DRAFT ERROR (corrected): 'TaskCreated' and 'TaskCompleted' listed without a block note — docs: both CAN block (exit 2 rolls back task creation / prevents completion).
- DRAFT ERROR (corrected): 'TeammateIdle' without a block note — docs: CAN block (exit 2 prevents going idle).
- DRAFT ERROR (corrected): 'ConfigChange' without a block note — docs: CAN block (exit 2 blocks the config change, except policy_settings).
- DRAFT ERROR (corrected): 'PreCompact' without a block note — docs: CAN block.
- DRAFT ERROR (corrected): 'Elicitation'/'ElicitationResult' without a block note — docs: both CAN block.
- DRAFT ERROR (corrected): 'PostToolBatch' without a block note — docs: CAN block (exit 2 stops the agentic loop before the next model call).
- DRAFT ERROR (corrected): 'WorktreeCreate' without a block note — docs: CAN block (any non-zero exit makes worktree creation fail).
- DRAFT WEAKNESS (corrected): skill_section step 2 named only PreToolUse/UserPromptSubmit/Stop as blocking — the docs' 'Can block?' column lists clearly more blocking events (see above); the description was expanded.
- NOT VERBATIM DOCUMENTED (softened): The exact JSON field name 'permissionDecision: deny' for PreToolUse was not visible verbatim in the retrieved doc content (only the exit-2 mechanics and 'hookSpecificOutput' generically). The audit check was reworded accordingly to the documented exit-2 mechanics.