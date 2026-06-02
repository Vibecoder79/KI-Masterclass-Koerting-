# Skills (.claude/skills/) — Folder structure, Skills vs. Subagents, Skill settings

> **Mode:** ? · **Priority:** ? · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic documentation (code.claude.com/docs).

## Step: Set up Skills (.claude/skills/)

Skills extend what Claude can do: you create a SKILL.md with instructions, and Claude adds it to its repertoire — either automatically (when the `description` matches) or directly via `/skill-name`. The key advantage over CLAUDE.md: the skill body only loads when the skill is actually used. Long reference procedures therefore cost almost no tokens until they are needed. Rule of thumb: as soon as you repeatedly paste the same checklist or multi-step procedure into the chat — or a CLAUDE.md section has grown from a fact into a procedure — it belongs in a skill.

Place skills in two locations. Global (`~/.claude/skills/<name>/SKILL.md`) for anything you need across projects; per project (`.claude/skills/<name>/SKILL.md`, checked into version control) for project-specific workflows that the whole team should share. In case of a name collision: enterprise overrides personal, personal overrides project; plugin skills use a `plugin-name:skill-name` namespace and do not collide. Each skill is a folder in which only SKILL.md is mandatory; detailed docs, examples, and scripts sit alongside it as companion files and are only loaded on demand. Important: the command name comes from the folder name, not from the frontmatter field `name`.

In the SKILL.md, only the `description` is really recommended — it decides when Claude pulls the skill on its own, so put the key use case first. WHY the discipline: descriptions are loaded into the context and, with many skills, are trimmed to a budget; a vague description is then the first to be dropped. Control the invocation logic deliberately: `disable-model-invocation: true` (default false) for actions with side effects (deploy, commit) that only you should trigger; `user-invocable: false` (default true) for pure background knowledge that never makes sense as a command.

Decide skill vs. subagent based on isolation: a normal skill runs inline in the current context (good for knowledge and conventions). If a skill should run sealed off and without your chat history, set `context: fork` and choose the subagent type with `agent:` (without a value, `general-purpose`) — but only if the SKILL.md contains a concrete task, otherwise the subagent gets guidelines without an assignment and delivers nothing.

Four settings are relevant: `skillOverrides` controls the visibility of individual skills from within the settings (values on / name-only / user-invocable-only / off; missing skills count as on) — handy for foreign or checked-in skills whose SKILL.md you do not want to edit; `skillListingBudgetFraction` raises the description budget (scales by default to 1% of the context window, documented example 0.02 for 2%); `maxSkillDescriptionChars` caps each entry (doc cap value 1,536 characters); `disableSkillShellExecution` disables the !`cmd` shell injection (replaced by `[shell command execution disabled by policy]`; bundled and managed skills excepted) and is mainly useful in managed settings, where users cannot override it. In case of problems, `/doctor` shows whether the budget overflows and which skills are affected.

## Reference (machine-readable)

```yaml
# ============================================================
# Skills (.claude/skills/) — Best-Practice-Baustein v17
# Quelle: https://code.claude.com/docs/en/skills (live geprueft 2026-06-02)
# Platzierung: global (~/.claude/skills/) UND projekt (.claude/skills/)
# ============================================================

skills:
  # --- Folder structure ---------------------------------------
  struktur:
    # Each skill is a folder; SKILL.md is the mandatory entry point.
    pflicht_datei: "SKILL.md"            # only mandatory component per skill
    # Personal/global: applies to ALL of your own projects
    pfad_global: "~/.claude/skills/<skill-name>/SKILL.md"
    # Project: applies only to this project (check into version control)
    pfad_projekt: ".claude/skills/<skill-name>/SKILL.md"
    # Optional companion files (loaded only on demand):
    optionale_dateien:
      - "reference.md / examples.md"      # detail docs, loaded on demand
      - "scripts/<datei>"                 # executable, not loaded into context
      - "template.md"                     # template to fill in
    # Command name = folder name (NOT the frontmatter field 'name'):
    # .claude/skills/deploy-staging/ -> /deploy-staging
    # Precedence on name collision: enterprise > personal > project
    # (Plugin skills use plugin-name:skill-name namespace, do not collide)
    tipp_groesse: "SKILL.md unter 500 Zeilen halten; Details auslagern"

  # --- SKILL.md frontmatter (all fields optional) ----------
  frontmatter:
    description: "empfohlen — Was + WANN; Schluessel-Use-Case zuerst"   # cap 1,536 characters
    name: "optional — Anzeigename in Listings; Default = Ordnername"
    when_to_use: "optional — Trigger-Phrasen; zaehlt zum 1.536-Zeichen-Cap"
    disable-model-invocation: false      # true = user only (/name), not Claude (default false)
    user-invocable: true                 # false = Claude only, not in the /-menu (default true)
    allowed-tools: ""                    # tools without confirmation while skill is active
    context: ""                          # "fork" = isolated subagent context (without chat history)
    agent: ""                            # subagent type with context: fork (default general-purpose)
    paths: ""                            # glob pattern: auto-activation only for matching files

  # --- Skills vs. Subagents ---------------------------------
  # Skill = instructions/knowledge, runs INLINE in the current context.
  # Subagent = isolated execution in its own context.
  # Run a skill in a subagent: set 'context: fork' + 'agent: <typ>'.
  #   -> only useful for skills with a concrete TASK, not for pure guidelines.
  # Conversely: a subagent with a 'skills' field preloads skills as reference.

  # --- Relevant settings (settings.json / .local.json) -----
  settings:
    # Override visibility per skill without editing SKILL.md.
    # Values: "on" | "name-only" | "user-invocable-only" | "off"
    # Missing skills count as "on". The /skills menu writes to
    # .claude/settings.local.json. Plugin skills are not affected.
    skillOverrides:
      # beispiel-skill: "name-only"
    # Budget for skill descriptions (scales by default to 1% of the
    # context window). The value is a fraction; documented example:
    skillListingBudgetFraction: 0.02     # 0.02 = 2% (example from the docs, not the default)
    # Upper limit per skill entry (description + when_to_use).
    # Doc cap value: 1,536 characters (setting default not quantified on the page).
    maxSkillDescriptionChars: 1536
    # Disables !`cmd` shell injection in skills/commands (policy).
    # Default behavior: execution active. Most useful in managed settings.
    # Replaces each command with [shell command execution disabled by policy];
    # bundled and managed skills are excepted.
    disableSkillShellExecution: false
```

## Audit criteria

- Per skill there is exactly one SKILL.md in the folder ~/.claude/skills/<name>/ or .claude/skills/<name>/
- Every SKILL.md has a description with the key use case first (description + when_to_use under 1,536 characters)
- SKILL.md under 500 lines; detail docs offloaded into companion files
- Skills with side effects (deploy/commit) have disable-model-invocation: true
- Project skills under .claude/skills/ are checked into version control
- Skills with context: fork contain a concrete task (no pure guidelines)
- If a disableSkillShellExecution policy is desired: set in managed settings so users cannot override it
- /doctor shows no overflow of the skill listing budget (otherwise raise skillListingBudgetFraction or set entries to name-only)

## Removed / softened by the verifier (not documented)

- maxSkillDescriptionChars default 1,536 characters — the docs confirm 1,536 only as the cap value of the combined description+when_to_use and say the cap is 'configurable with maxSkillDescriptionChars'. They do NOT confirm that 1,536 is also the settings default. Comment corrected from 'Default 1,536' to 'cap value 1,536, configurable' (no content removed, only made more precise).
- disableSkillShellExecution default false — the docs only describe the behavior when true and that execution is the default behavior; 'Default: false' does not appear literally on the page. Comment accordingly corrected from 'Default false' to 'default behavior: execution active (no explicit default on the page)'.
- skillListingBudgetFraction numeric default — the docs mention only '1% of the context window', no numeric default fraction. The entered value 0.02 is explicitly only the documented example (= 2%), not the default. Was already correctly marked as an example in the draft, kept.