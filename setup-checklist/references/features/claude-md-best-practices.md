# CLAUDE.md Best Practices

> **Modus:** projekt · **Prioritaet:** wichtig · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## CLAUDE.md fuer das Projekt anlegen

Lege im Projekt-Root eine `CLAUDE.md` an (alternativ `./.claude/CLAUDE.md` — beide Orte sind gleichwertig). Diese Datei gibt Claude bei jedem Session-Start die feststehenden Projekt-Fakten mit: Build- und Test-Befehle, Coding-Standards, Architektur-Entscheidungen, Naming-Konventionen und gaengige Workflows. Sie wird ueber die Versionskontrolle mit dem ganzen Team geteilt — schreib also Projekt-Standards hinein, keine persoenlichen Vorlieben.

WARUM: CLAUDE.md wird in jeder Session vollstaendig in das Kontextfenster geladen und verbraucht dort Tokens. Deshalb gilt: kurz, spezifisch, strukturiert. Ziel sind unter 200 Zeilen — laengere Dateien kosten mehr Kontext und senken, wie zuverlaessig Claude die Regeln befolgt. Nutze Markdown-Header und Bullets statt dichter Absaetze und formuliere konkret und pruefbar ("Use 2-space indentation" statt "Format code properly", "Run `npm test` before committing" statt "Test your changes"). Achte darauf, dass sich Regeln nicht widersprechen — bei Konflikten waehlt Claude willkuerlich eine.

Den schnellsten Start liefert `/init`: Claude analysiert die Codebase und erzeugt eine erste CLAUDE.md mit erkannten Build-Befehlen, Test-Anweisungen und Konventionen. Existiert bereits eine, schlaegt `/init` Verbesserungen vor statt zu ueberschreiben. Danach verfeinerst du manuell um das, was Claude nicht selbst entdecken kann.

Fuer persoenliche, projekt-spezifische Notizen (z.B. eigene Sandbox-URLs oder bevorzugte Testdaten) lege eine `CLAUDE.local.md` am Projekt-Root an und trage sie in `.gitignore` ein, damit sie nicht committet wird (die Personal-Option von `/init` erledigt das automatisch). Sie laedt neben der CLAUDE.md und wird gleich behandelt.

Wenn die Datei zu gross wird, lagere Themen in `.claude/rules/*.md` aus — mit `paths:`-Frontmatter (Glob) laden einzelne Regeln nur, wenn Claude an passenden Dateien arbeitet, und sparen so Kontext. `@path/to/import` bindet zwar weitere Dateien ein, spart aber keinen Kontext (importierte Dateien laden beim Start voll mit) — nutze es nur zur Organisation. Mit `/memory` pruefst du jederzeit, welche Memory-Dateien wirklich geladen sind.

Falls dein Repo bereits eine `AGENTS.md` fuer andere Coding-Agents nutzt: Claude liest `AGENTS.md` nicht direkt, sondern nur `CLAUDE.md`. Lege daher eine `CLAUDE.md` an, die `@AGENTS.md` importiert (oder einen Symlink), und schreibe Claude-spezifische Regeln unter den Import.

## Referenz (maschinenlesbar)

```yaml
# CLAUDE.md Best Practices (Projekt-Scope)
# Quelle: https://code.claude.com/docs/en/memory (Stand 2026-06-02)
claude_md:

  # WO die Projekt-CLAUDE.md liegen darf (eine von beiden Varianten)
  speicherort:
    - "./CLAUDE.md"          # Projekt-Root, team-geteilt via Versionskontrolle
    - "./.claude/CLAUDE.md"  # Alternative im .claude-Ordner, gleichwertig
    # Hinweis: Wird in JEDER Session voll geladen (verbraucht Kontext-Tokens)

  # Memory-Hierarchie / Scopes (Ladereihenfolge: breit -> spezifisch)
  scopes:
    managed_policy: "macOS /Library/Application Support/ClaudeCode/CLAUDE.md ; Linux/WSL /etc/claude-code/CLAUDE.md ; Windows C:\\Program Files\\ClaudeCode\\CLAUDE.md"  # org-weit, nicht ausschliessbar
    user: "~/.claude/CLAUDE.md"          # persoenliche Praeferenzen, alle Projekte
    projekt: "./CLAUDE.md oder ./.claude/CLAUDE.md"  # team-geteilt
    local: "./CLAUDE.local.md"           # persoenlich, projekt-spezifisch, in .gitignore

  # Schreib-Guidance fuer wirksame Instruktionen
  schreib_guidance:
    groesse: "Ziel < 200 Zeilen pro Datei (laengere Dateien senken die Befolgung)"
    struktur: "Markdown-Header + Bullets, verwandte Regeln gruppieren"
    spezifitaet: "Konkret und pruefbar formulieren, z.B. 'Use 2-space indentation' statt 'Format code properly'"
    konsistenz: "Widerspruechliche Regeln vermeiden (Claude waehlt sonst willkuerlich eine)"
    inhalt: "Build-/Test-Befehle, Konventionen, Projekt-Layout, 'always do X'-Regeln"
    wartung_kommentare: "Block-Level <!-- HTML-Kommentare --> werden vor Injektion aus dem Kontext entfernt (Notizen fuer Menschen, kostet keine Tokens); Kommentare in Code-Bloecken bleiben erhalten"

  # @-Import-Syntax fuer zusaetzliche Dateien
  imports:
    syntax: "@path/to/import"                      # relativ ODER absolut erlaubt
    relativ_basis: "relativ zur importierenden Datei, nicht zum Arbeitsverzeichnis"
    rekursion: "max. 4 Hops Tiefe"
    home_import: "@~/.claude/my-project-instructions.md"  # fuer Worktree-uebergreifende persoenliche Regeln
    achtung: "Importierte Dateien laden beim Start voll mit -> sparen KEINEN Kontext, nur Organisation"
    approval: "Externe Imports zeigen beim ersten Mal einen Genehmigungsdialog (bei Ablehnung dauerhaft deaktiviert)"

  # CLAUDE.local.md (persoenlich, NICHT committen)
  local_md:
    pfad: "./CLAUDE.local.md am Projekt-Root"
    zweck: "persoenliche Praeferenzen: Sandbox-URLs, bevorzugte Testdaten"
    gitignore: "PFLICHT in .gitignore eintragen (/init mit Personal-Option macht das automatisch)"
    laden: "laedt neben CLAUDE.md, wird gleich behandelt"

  # AGENTS.md Interop (Claude liest NUR CLAUDE.md, nicht AGENTS.md)
  agents_md:
    loesung: "CLAUDE.md anlegen die @AGENTS.md importiert (oder Symlink)"
    claude_spezifisch: "Claude-eigene Regeln unter den Import schreiben"

  # Lade-Mechanik: Verzeichnisbaum hochlaufen
  laden:
    baum: "CLAUDE.md + CLAUDE.local.md werden durch Hochlaufen des Verzeichnisbaums geladen und konkateniert (Root -> Arbeitsverzeichnis, naeher dran wird zuletzt gelesen)"
    subdir: "CLAUDE.md in Unterverzeichnissen laden bedarfsweise, wenn Claude dort Dateien liest"

  # Tooling
  befehle:
    init: "/init generiert Start-CLAUDE.md aus Codebase-Analyse; existiert sie, schlaegt /init Verbesserungen vor statt zu ueberschreiben"
    memory: "/memory listet geladene CLAUDE.md/CLAUDE.local.md/rules-Dateien, oeffnet sie zum Editieren und toggelt Auto-Memory"
    schnell_merken: "Im Chat 'add this to CLAUDE.md' sagen -> Claude traegt es ein"

  # Optional fuer grosse Projekte statt einer riesigen CLAUDE.md
  skalierung:
    rules_dir: ".claude/rules/*.md  # je Datei ein Thema, rekursiv erkannt; ohne paths-Frontmatter mit gleicher Prioritaet wie .claude/CLAUDE.md geladen"
    path_scoped: "YAML-Frontmatter 'paths:' (Glob) -> Regel laedt nur bei passenden Dateien (spart Kontext)"
```

## Audit-Kriterien

- Existiert eine CLAUDE.md am Projekt-Root oder unter ./.claude/CLAUDE.md?
- Ist die CLAUDE.md unter 200 Zeilen (sonst Inhalte in .claude/rules/ auslagern)?
- Enthaelt die CLAUDE.md konkrete Build-/Test-Befehle statt vager Anweisungen?
- Ist CLAUDE.local.md (falls vorhanden) in .gitignore eingetragen und nicht committet?
- Sind keine widerspruechlichen Regeln zwischen CLAUDE.md, verschachtelten CLAUDE.md und .claude/rules/ vorhanden?
- Falls AGENTS.md existiert: importiert eine CLAUDE.md via @AGENTS.md (Claude liest AGENTS.md nicht direkt)?
- Bleiben @-Importketten innerhalb der max. 4 Hops Tiefe?
