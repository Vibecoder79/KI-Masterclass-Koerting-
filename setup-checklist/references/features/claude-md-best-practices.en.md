# CLAUDE.md Best Practices

> **Mode:** project · **Priority:** important · **Status:** include
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Create a CLAUDE.md for the project

Create a `CLAUDE.md` at the project root (alternatively `./.claude/CLAUDE.md` — both locations are equivalent). At every session start, this file gives Claude the fixed project facts: build and test commands, coding standards, architecture decisions, naming conventions, and common workflows. It is shared with the whole team via version control — so write project standards into it, not personal preferences.

WHY: CLAUDE.md is loaded in full into the context window in every session and consumes tokens there. Therefore: keep it short, specific, structured. Aim for under 200 lines — longer files cost more context and reduce how reliably Claude follows the rules. Use Markdown headers and bullets instead of dense paragraphs, and phrase things concretely and verifiably ("Use 2-space indentation" instead of "Format code properly", "Run `npm test` before committing" instead of "Test your changes"). Make sure rules don't contradict each other — on conflicts Claude arbitrarily picks one.

The fastest start is `/init`: Claude analyzes the codebase and generates an initial CLAUDE.md with detected build commands, test instructions, and conventions. If one already exists, `/init` suggests improvements instead of overwriting. Afterwards you refine manually for what Claude cannot discover on its own.

For personal, project-specific notes (e.g. your own sandbox URLs or preferred test data), create a `CLAUDE.local.md` at the project root and add it to `.gitignore` so it isn't committed (the Personal option of `/init` does this automatically). It loads alongside CLAUDE.md and is treated the same way.

When the file gets too big, move topics into `.claude/rules/*.md` — with `paths:` frontmatter (glob), individual rules load only when Claude works on matching files, thereby saving context. `@path/to/import` does pull in additional files, but saves no context (imported files load in full at startup) — use it only for organization. With `/memory` you can check at any time which memory files are actually loaded.

If your repo already uses an `AGENTS.md` for other coding agents: Claude doesn't read `AGENTS.md` directly, only `CLAUDE.md`. So create a `CLAUDE.md` that imports `@AGENTS.md` (or a symlink), and write Claude-specific rules below the import.

## Reference (machine-readable)

```yaml
# CLAUDE.md Best Practices (project scope)
# Source: https://code.claude.com/docs/en/memory (as of 2026-06-02)
claude_md:

  # WHERE the project CLAUDE.md may live (one of the two variants)
  speicherort:
    - "./CLAUDE.md"          # project root, team-shared via version control
    - "./.claude/CLAUDE.md"  # alternative in the .claude folder, equivalent
    # Note: Loaded in full in EVERY session (consumes context tokens)

  # Memory hierarchy / scopes (load order: broad -> specific)
  scopes:
    managed_policy: "macOS /Library/Application Support/ClaudeCode/CLAUDE.md ; Linux/WSL /etc/claude-code/CLAUDE.md ; Windows C:\\Program Files\\ClaudeCode\\CLAUDE.md"  # org-wide, cannot be excluded
    user: "~/.claude/CLAUDE.md"          # personal preferences, all projects
    projekt: "./CLAUDE.md oder ./.claude/CLAUDE.md"  # team-shared
    local: "./CLAUDE.local.md"           # personal, project-specific, in .gitignore

  # Writing guidance for effective instructions
  schreib_guidance:
    groesse: "Ziel < 200 Zeilen pro Datei (laengere Dateien senken die Befolgung)"
    struktur: "Markdown-Header + Bullets, verwandte Regeln gruppieren"
    spezifitaet: "Konkret und pruefbar formulieren, z.B. 'Use 2-space indentation' statt 'Format code properly'"
    konsistenz: "Widerspruechliche Regeln vermeiden (Claude waehlt sonst willkuerlich eine)"
    inhalt: "Build-/Test-Befehle, Konventionen, Projekt-Layout, 'always do X'-Regeln"
    wartung_kommentare: "Block-Level <!-- HTML-Kommentare --> werden vor Injektion aus dem Kontext entfernt (Notizen fuer Menschen, kostet keine Tokens); Kommentare in Code-Bloecken bleiben erhalten"

  # @-import syntax for additional files
  imports:
    syntax: "@path/to/import"                      # relative OR absolute allowed
    relativ_basis: "relativ zur importierenden Datei, nicht zum Arbeitsverzeichnis"
    rekursion: "max. 4 Hops Tiefe"
    home_import: "@~/.claude/my-project-instructions.md"  # for personal rules across worktrees
    achtung: "Importierte Dateien laden beim Start voll mit -> sparen KEINEN Kontext, nur Organisation"
    approval: "Externe Imports zeigen beim ersten Mal einen Genehmigungsdialog (bei Ablehnung dauerhaft deaktiviert)"

  # CLAUDE.local.md (personal, do NOT commit)
  local_md:
    pfad: "./CLAUDE.local.md am Projekt-Root"
    zweck: "persoenliche Praeferenzen: Sandbox-URLs, bevorzugte Testdaten"
    gitignore: "PFLICHT in .gitignore eintragen (/init mit Personal-Option macht das automatisch)"
    laden: "laedt neben CLAUDE.md, wird gleich behandelt"

  # AGENTS.md interop (Claude reads ONLY CLAUDE.md, not AGENTS.md)
  agents_md:
    loesung: "CLAUDE.md anlegen die @AGENTS.md importiert (oder Symlink)"
    claude_spezifisch: "Claude-eigene Regeln unter den Import schreiben"

  # Loading mechanics: walking up the directory tree
  laden:
    baum: "CLAUDE.md + CLAUDE.local.md werden durch Hochlaufen des Verzeichnisbaums geladen und konkateniert (Root -> Arbeitsverzeichnis, naeher dran wird zuletzt gelesen)"
    subdir: "CLAUDE.md in Unterverzeichnissen laden bedarfsweise, wenn Claude dort Dateien liest"

  # Tooling
  befehle:
    init: "/init generiert Start-CLAUDE.md aus Codebase-Analyse; existiert sie, schlaegt /init Verbesserungen vor statt zu ueberschreiben"
    memory: "/memory listet geladene CLAUDE.md/CLAUDE.local.md/rules-Dateien, oeffnet sie zum Editieren und toggelt Auto-Memory"
    schnell_merken: "Im Chat 'add this to CLAUDE.md' sagen -> Claude traegt es ein"

  # Optional for large projects instead of one huge CLAUDE.md
  skalierung:
    rules_dir: ".claude/rules/*.md  # je Datei ein Thema, rekursiv erkannt; ohne paths-Frontmatter mit gleicher Prioritaet wie .claude/CLAUDE.md geladen"
    path_scoped: "YAML-Frontmatter 'paths:' (Glob) -> Regel laedt nur bei passenden Dateien (spart Kontext)"
```

## Audit criteria

- Does a CLAUDE.md exist at the project root or under ./.claude/CLAUDE.md?
- Is the CLAUDE.md under 200 lines (otherwise move content into .claude/rules/)?
- Does the CLAUDE.md contain concrete build/test commands instead of vague instructions?
- Is CLAUDE.local.md (if present) entered in .gitignore and not committed?
- Are there no contradictory rules across CLAUDE.md, nested CLAUDE.md, and .claude/rules/?
- If AGENTS.md exists: does a CLAUDE.md import it via @AGENTS.md (Claude doesn't read AGENTS.md directly)?
- Do @-import chains stay within the max. 4 hops depth?
