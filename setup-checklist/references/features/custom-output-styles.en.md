# Custom Output Styles

> **Mode:** project+global · **Priority:** important · **Status:** include
> Verified 2026-06-02 against the official Anthropic documentation (code.claude.com/docs).

## Setting up Custom Output Styles

Output Styles change HOW Claude responds (role, tone, output format), not WHAT Claude knows. They directly modify the system prompt. Use them when you keep repeating the same style or format every turn, or when Claude should do something other than software engineering (e.g. writing assistant, data analyst). For project conventions and codebase knowledge, the content belongs in CLAUDE.md instead, not in an Output Style.

WHY: Anyone who has to re-prompt the same style over and over wastes tokens and attention. An Output Style anchors that style permanently in the system prompt, so it applies to every response.

Step 1 — Check the built-ins: Claude Code ships with four built-in styles. Default is the normal engineering prompt; alongside it there are Proactive (acts immediately, makes assumptions, action before planning), Explanatory (delivers educational insights while coding) and Learning (learn-by-doing, places TODO(human) markers for you to code yourself). Set a style via `/config` -> "Output style"; the selection ends up in `.claude/settings.local.json` (local project level). Alternatively, set the `outputStyle` field directly in a settings file, e.g. `"outputStyle": "Explanatory"`.

Step 2 — Create your own style (optional): A Custom Style is a Markdown file with frontmatter plus instructions. Depending on its scope, place it under `~/.claude/output-styles` (global, all projects) or `.claude/output-styles` (project-specific); there is also the managed policy level `.claude/output-styles` in the managed settings directory. The file name becomes the style name, unless you set a `name` in the frontmatter. The most important decision: `keep-coding-instructions: true` if Claude should keep coding normally but communicate differently (the default is false, in which case the built-in engineering instructions are dropped). Further fields: `description` (shown in the /config picker) and `name`.

Step 3 — Activate: Choose the style via `/config` -> "Output style". Since the style is part of the system prompt and is only read once at session start, the change only takes effect after `/clear` or in a new session.

Note: The former standalone command `/output-style` no longer exists (deprecated in v2.1.73, removed in v2.1.91) — use `/config` or set `outputStyle` directly.

## Reference (machine-readable)

```yaml
# Custom Output Styles — adjusts system prompt (role/tone/format), not the knowledge
# Source: https://code.claude.com/docs/en/output-styles (as of 2026-06-02)
output_styles:

  # outputStyle setting in a settings file. /config -> "Output style" saves
  # to .claude/settings.local.json (local project level). Can be set directly:
  setting:
    key: outputStyle           # value = name of a built-in or custom style
    beispiel: |
      {
        "outputStyle": "Explanatory"
      }
    hinweis: "Part of the system prompt, read once at session start -> only takes effect after /clear or a new session"

  # Built-in styles (Default = existing system prompt for software engineering)
  builtin:
    - Proactive      # executes immediately, makes assumptions, action before planning
    - Explanatory    # delivers educational "insights" while coding
    - Learning       # learn-by-doing, places TODO(human) markers for you to code yourself

  # Custom styles = Markdown file: frontmatter + instructions for the system prompt
  # File name becomes the style name, unless a name is set in the frontmatter
  custom:
    pfade:
      user:           ~/.claude/output-styles          # global, all projects
      projekt:        .claude/output-styles            # project-specific
      managed_policy: .claude/output-styles            # in the managed settings directory
    frontmatter:
      name:                     # optional, otherwise file name
      description:              # shown in the /config picker
      keep-coding-instructions: # true = keep coding instructions (default: false)
      force-for-plugin:         # plugin styles only, default: false
    beispiel: |
      ---
      name: Diagrams first
      description: Lead every explanation with a diagram
      keep-coding-instructions: true
      ---
      When explaining code, start with a Mermaid diagram, then explain in prose.

  # Management
  commands:
    - /config        # "Output style" menu for selection
  hinweis_deprecated: "/output-style: deprecated in v2.1.73, removed in v2.1.91 -> /config or outputStyle directly"

  # Plugins can ship styles in an output-styles/ directory
```

## Audit criteria

- Check whether the outputStyle setting is set (settings.json / settings.local.json) and points to a valid built-in or custom style name
- If custom styles exist: are they located under ~/.claude/output-styles (global) or .claude/output-styles (project)?
- Check the custom-style frontmatter: deliberate decision about keep-coding-instructions (true when still coding, otherwise omit) and a present description for the /config picker
- Ensure that project conventions live in CLAUDE.md and have not drifted into an Output Style

## Removed / softened by the verifier (not documented)
