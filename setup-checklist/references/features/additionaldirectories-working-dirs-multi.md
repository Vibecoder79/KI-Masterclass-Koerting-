# additionalDirectories / Working Dirs (Multi-Verzeichnis-Zugriff)

> **Modus:** global+projekt · **Prioritaet:** wichtig · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Working Directories: Zugriff ueber das Start-Verzeichnis hinaus

Standardmaessig sieht Claude Code nur Dateien in dem Verzeichnis, aus dem es gestartet wurde. Sobald du an mehreren Repos oder einer gemeinsamen Library parallel arbeitest, brauchst du zusaetzliche Arbeitsverzeichnisse — sonst muss Claude jede Datei ausserhalb des Start-Ordners umstaendlich anfragen oder kommt gar nicht heran.

Die Doku nennt drei Wege, den Zugriff zu erweitern:

- **Persistent (empfohlen fuer dauerhaftes Setup):** Trage die Pfade unter `permissions.additionalDirectories` in eine `settings.json` ein — global in `~/.claude/settings.json` fuer projektuebergreifende Pfade, projektbezogen in `.claude/settings.json` fuer Repo-Nachbarn. (Hinweis: Die Permissions-Seite zeigt kein konkretes Code-Beispiel fuer den Wert; ob relative oder nur absolute Pfade zulaessig sind, ist dort nicht spezifiziert — im Zweifel die Settings-Referenz pruefen.)
- **Beim Start (einmalig):** Starte mit `--add-dir <path>`.
- **Mitten in der Session:** Tippe `/add-dir`, um einen Ordner zur laufenden Session zu ergaenzen.

Dateien in zusaetzlichen Verzeichnissen folgen denselben Permission-Regeln wie das Start-Verzeichnis: Sie werden ohne Nachfrage lesbar, und Edits richten sich nach dem aktuellen Permission-Mode. Im `acceptEdits`-Mode werden Datei-Edits und gaengige Filesystem-Befehle fuer Pfade im Start-Verzeichnis oder in `additionalDirectories` automatisch akzeptiert; ein `cd` in einen Pfad innerhalb dieser Verzeichnisse gilt als read-only.

**Wichtiger Stolperstein (laut Doku):** Ein zusaetzliches Verzeichnis gewaehrt Datei-Zugriff, macht den Ordner aber nicht zur vollwertigen Konfigurations-Wurzel. Nur `--add-dir`/`/add-dir` laden begrenzte Konfiguration nach (Skills aus `.claude/skills/` mit Live-Reload; Plugin-Settings beschraenkt auf `enabledPlugins` und `extraKnownMarketplaces`; CLAUDE.md, `.claude/rules/` und `CLAUDE.local.md` nur wenn die Umgebungsvariable `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` gesetzt ist — `CLAUDE.local.md` verlangt zusaetzlich die `local`-Setting-Quelle, die per Default aktiv ist). Pfade in `permissions.additionalDirectories` laden davon nichts — sie geben ausschliesslich Datei-Zugriff. Wenn du also erwartest, dass Skills oder CLAUDE.md aus einem Nachbar-Repo greifen, reicht der settings.json-Eintrag allein nicht.

## Referenz (maschinenlesbar)

```yaml
# Working Directories / additionalDirectories — Zugriff ueber das Start-Verzeichnis hinaus
# Quelle: https://code.claude.com/docs/en/permissions (Abschnitt "Working directories")
# Standard: Claude hat nur Zugriff auf das Verzeichnis, in dem es gestartet wurde.
# Drei Wege, diesen Zugriff zu erweitern:

working_directories:
  # 1) Persistente Konfiguration in den settings.json (global ~/.claude/ oder projekt .claude/)
  additionalDirectories:
    key: permissions.additionalDirectories   # Eintrag in einer settings-Datei
    wirkung: >-
      Zusaetzliche Verzeichnisse folgen denselben Permission-Regeln wie das
      Start-Verzeichnis: sie werden ohne Nachfrage lesbar, und Datei-Edits folgen
      dem aktuellen Permission-Mode. ACHTUNG: gewaehrt NUR Datei-Zugriff, KEINE
      Konfigurations-Discovery (keine Skills/CLAUDE.md/Hooks aus diesen Verzeichnissen).
    # HINWEIS: Die Permissions-Doku zeigt KEIN Code-Beispiel fuer den Wert.
    # Form (Liste von Pfaden) ist aus dem Text stark naheliegend, aber auf dieser
    # Seite nicht woertlich belegt. Ob relative oder nur absolute Pfade zulaessig
    # sind, ist hier NICHT spezifiziert — vor Nutzung Settings-Referenz pruefen.

  # 2) Beim Start: CLI-Flag (temporaer fuer die Session)
  add_dir_cli: "--add-dir <path>"   # erweitert Zugriff beim Programmstart

  # 3) Waehrend der Session: Slash-Command
  add_dir_command: "/add-dir"       # fuegt ein Verzeichnis zur laufenden Session hinzu

# WICHTIGER UNTERSCHIED (laut Doku):
# Die folgenden Konfigurations-Ausnahmen gelten NUR fuer Verzeichnisse, die per
# --add-dir Flag oder /add-dir Command hinzugefuegt wurden:
#   - Skills aus .claude/skills/ (mit Live-Reload)
#   - Plugin-Settings aus .claude/settings.json (nur enabledPlugins + extraKnownMarketplaces)
#   - CLAUDE.md / .claude/rules/ / CLAUDE.local.md NUR wenn ENV
#     CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 gesetzt ist
#     (CLAUDE.local.md verlangt zusaetzlich die 'local' Setting-Quelle, default aktiv)
# Verzeichnisse aus permissions.additionalDirectories (settings.json) laden davon
# NICHTS — nur Datei-Zugriff.

# permission_mode_bezug (laut Doku):
#   - acceptEdits akzeptiert Datei-Edits und gaengige Filesystem-Befehle automatisch
#     fuer Pfade im Start-Verzeichnis ODER in additionalDirectories.
#   - Ein 'cd' in einen Pfad innerhalb Start-/Zusatz-Verzeichnis gilt als read-only.
```

## Audit-Kriterien

- settings.json pruefen: Wenn an mehreren Repos/einer geteilten Library gearbeitet wird, ist permissions.additionalDirectories gesetzt (Liste von Pfaden)
- Pfade in additionalDirectories existieren tatsaechlich und zeigen auf die beabsichtigten Verzeichnisse
- Erwartung pruefen: Wird aus einem Zusatz-Verzeichnis Skill-/CLAUDE.md-Discovery erwartet? Dann --add-dir/-/add-dir noetig (ggf. CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1) statt nur settings.json
- Keine sensiblen/zu breiten Pfade (z.B. ganzes Home) in additionalDirectories, da Inhalte ohne Nachfrage lesbar werden

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- Konkrete Beispiel-Pfade im YAML/JSON-Beispiel ('../shared-lib', '/abs/pfad/zu/anderem/repo'): Die Permissions-Doku zeigt KEIN Code-Beispiel fuer den Wert von permissions.additionalDirectories. Weder ein Array-von-Strings-Snippet noch konkrete Pfade sind auf dieser Seite belegt. Die genannten Beispielpfade sind erfunden und wurden durch generische Platzhalter ersetzt bzw. als nicht-belegt gekennzeichnet.
- Zulaessigkeit relativer Pfade (z.B. '../shared-lib') in additionalDirectories: auf dieser Seite NICHT spezifiziert. Entfernt, da nicht belegbar (die Settings-Referenzseite koennte dies klaeren, wurde aber nicht herangezogen).
- Schema-Form 'Array von Strings' als belegte Tatsache: Aus dem Text nur stark naheliegend (Plural 'Directories listed in permissions.additionalDirectories'), aber kein woertliches Code-Beispiel auf dieser Seite. Im bereinigten Beispiel als plausibel-aber-nicht-woertlich-belegt gekennzeichnet.
