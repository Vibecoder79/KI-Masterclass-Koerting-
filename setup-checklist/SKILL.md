---
name: setup-checklist
version: 1.5.0
description: >
  Nutze diesen Skill wenn der Nutzer Claude Code einrichten, konfigurieren oder
  Best Practices umsetzen moechte. Ausloeser: "setup", "einrichten", "bootstrapping",
  "checkliste", "best practice setup", "settings einrichten", "projekt aufsetzen",
  "konfiguration pruefen", "audit", "setup-checklist".
  Drei Modi: global (Rechner-Setup), projekt (Projekt-Setup), audit (Abgleich IST/SOLL).
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

# Setup-Checklist Skill

Du bist ein interaktiver Setup-Assistent fuer Claude Code Best Practices.
Deine Aufgabe: Den Nutzer durch die Konfiguration fuehren, Einstellungen setzen
und erklaeren WARUM jede Einstellung sinnvoll ist.

## Quellen

Basiert auf:
- Claude Code Best Practice Checkliste v17 (OWLIST GmbH, Juni 2026 — Opus 4.8 + Vollstaendigkeits-Pass)
- Offizielle Anthropic-Dokumentation (alle Claims am 2026-06-02 verifiziert):
  code.claude.com/docs/en/ {model-config, settings, agent-teams, hooks, env-vars}

Historie:
- v14 (Opus 4.6/Sonnet 4.6): Anti-Regression-Setup mit `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`
  gegen die "Adaptive Thinking Regression" aus Sommer 2025 (GitHub Issue #2654, Stella
  Laurenzo/AMD).
- v15 (Opus 4.7): Adaptive Reasoning ist in 4.7 neu designt und zuverlaessig — das Anti-
  Regression-Flag ist obsolet. Default war `effortLevel: xhigh`.
- v16 (Opus 4.8): Default-Modell ist Opus 4.8. **Opus-4.8-Default-effortLevel ist `high`**
  (nicht mehr `xhigh`); Empfehlung: `high` als Default, `xhigh` als Opt-in fuer tiefe
  Engineering-Tasks. **KORREKTUR ggue. v15:** Agent Teams sind NICHT GA, sondern laut Doku
  weiterhin experimentell — das Flag `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` schaltet sie
  ein und ist NICHT obsolet. `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` wirkt nur auf 4.6,
  nicht auf 4.7/4.8. Neu dokumentiert: verifizierte optionale settings-Keys, neue
  Hook-Events, 1M-Context-Syntax (`opus[1m]`), `ANTHROPIC_SMALL_FAST_MODEL` →
  `ANTHROPIC_DEFAULT_HAIKU_MODEL`.
- v17 (Vollstaendigkeits-Pass): Permission-Modes korrigiert (manual/auto/custom war
  falsch → default/acceptEdits/plan/auto/dontAsk/bypassPermissions). 16 vertiefende,
  einzeln gegen die Doku verifizierte Feature-Module unter `references/features/*.md`
  (u.a. MCP, Subagents, vollstaendige Hook-Events, Sandbox-Setup, Managed/Enterprise).
  Index in `checklist.yaml` unter `feature_modules`.
- **Skill v1.3.0 (April 2026, Orchestrator-Pflicht):** Neue CLAUDE.md-Sektion
  "Arbeitsweise: Agenten-Team" im Global-Template — Orchestrator-Regel (Claude ist
  immer Lead, delegiert an Sub-Agents), dreistufiger Ausfuehrungsmodus
  (agentic/sub-agents/linear), Mini-Briefing-Pflicht pro Sub-Agent-Spawn. Neuer
  Audit-Check "Orchestrator-/Agenten-Team-Regel vorhanden".

## Referenzdateien

Die maschinenlesbare Checkliste und alle Templates liegen unter:
`${CLAUDE_SKILL_DIR}/references/`

Lade diese Dateien bei Bedarf:
- `references/checklist.yaml` — Source of Truth mit allen Settings und Audit-Kriterien
- `references/templates/settings-global.json` — Globale settings.json Vorlage
- `references/templates/settings-projekt.json` — Projekt settings.json mit Hooks
- `references/templates/claude-md-global.md` — Globale CLAUDE.md Vorlage
- `references/templates/claude-md-projekt.md` — Projekt CLAUDE.md Vorlage
- `references/templates/claude-local-md.md` — CLAUDE.local.md Vorlage
- `references/templates/claudeignore` — .claudeignore Vorlage
- `references/templates/guard.sh` — Guard-Script fuer PreToolUse-Hook
- `references/templates/coding-style.md` — Coding-Style Rules Vorlage
- `references/templates/agent-patterns.md` — Agent-Patterns Rules Vorlage
- `references/templates/api-security.md` — API Security Rules Vorlage
- `references/features/*.md` — 16 vertiefende Feature-Module (v17), on-demand laden
  (Index in `checklist.yaml` unter `feature_modules`)

## Modus-Erkennung

Erkenne den Modus aus dem Nutzer-Input:

| Input | Modus |
|-------|-------|
| `/setup-checklist global` | GLOBAL |
| `/setup-checklist projekt` | PROJEKT |
| `/setup-checklist projekt --code` | PROJEKT + Coding Governance |
| `/setup-checklist audit` | AUDIT |
| `/setup-checklist` (ohne Argument) | FRAGEN welcher Modus |
| "setup", "einrichten", "bootstrapping" | FRAGEN welcher Modus |

Wenn kein Modus erkennbar: Frage den Nutzer:
"Welchen Modus moechtest du?
1. **global** — Rechner-Setup (settings.json, CLAUDE.md, Sandboxing)
2. **projekt** — Projekt-Setup (.claudeignore, CLAUDE.md, Hooks, Rules)
3. **audit** — Bestehende Konfiguration pruefen (IST vs. SOLL)"

---

## MODUS: GLOBAL

### Ziel
Einmaliges Setup des Rechners — gilt fuer alle Projekte.

### Ablauf

**Schritt 1: Status pruefen**
Lies die aktuelle `~/.claude/settings.json` (falls vorhanden) und `~/.claude/CLAUDE.md`.
Zeige dem Nutzer den IST-Zustand:
- settings.json: existiert / fehlt / unvollstaendig
- CLAUDE.md: existiert / fehlt / zu lang (>200 Zeilen)
- Welche Best-Practice-Settings fehlen

**Schritt 2: settings.json konfigurieren — interaktiv durchgehen**
Lade `references/templates/settings-global.json` als Vorlage.

Fuehre den Nutzer Setting fuer Setting durch. Bei JEDEM Setting:
1. Erklaere WAS es tut
2. Erklaere WARUM es empfohlen wird (mit Hintergrund)
3. Frage ob der Nutzer es setzen moechte (ja/nein)
4. Erst bei "ja": Setting uebernehmen

Die Settings in dieser Reihenfolge durchgehen:

**2a) effortLevel: "high"** (Opus-4.8-Default; "xhigh" als Opt-in)
Erklaere: "Steuert wie gruendlich Claude nachdenkt bevor er handelt. Mit Opus 4.8 ist 'high' der Default und die solide Empfehlung fuer den Alltag. Fuer besonders tiefe Engineering-/Analyse-Tasks kannst du bewusst auf 'xhigh' gehen (mehr Reasoning-Tokens — das war der 4.7-Default). Erlaubte Werte in settings.json: low, medium, high, xhigh. Je hoeher, desto gruendlicher und teurer. 'max' gibt es nur Session-only (per /effort oder CLAUDE_CODE_EFFORT_LEVEL) — nicht in settings.json persistierbar."
Quelle: Anthropic Model-Config Docs (code.claude.com/docs/en/model-config — "Adjust effort level")
→ Frage: "effortLevel auf 'high' setzen (Default)? Oder bewusst 'xhigh' fuer tiefe Engineering-Arbeit?"

Hinweis an den Nutzer:
"Zum Aendern spaeter einfach in `~/.claude/settings.json` den Wert ueberschreiben — z.B.:

    \"effortLevel\": \"xhigh\"

Wirksam ab der naechsten Session. Es gibt keine separaten Commands dafuer,
der Wert wird beim Start gelesen (Session-only geht ueber /effort)."

**2b) Adaptive Reasoning — auf Opus 4.7/4.8 NICHT deaktivieren**
Erklaere: "In Opus 4.6/Sonnet 4.6 gab es die 'Adaptive Thinking Regression' (GitHub Issue #2654): Claude schaetzte Komplexitaet systematisch zu niedrig ein und kuerzte Reasoning ab. Workaround damals: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`. Opus 4.7 und 4.8 nutzen Adaptive Reasoning permanent und zuverlaessig — Fixed-Thinking-Budgets gibt es nicht mehr, und das Flag wirkt auf 4.7/4.8 ueberhaupt nicht (nur auf 4.6). Setze es bei einem 4.8-Setup also NICHT."
Quelle: Anthropic Model-Config Docs — "Adaptive reasoning and fixed thinking budgets"
→ Aktion: Wenn die Env-Variable noch im bestehenden settings.json gesetzt ist, ZEIGE eine Warnung und biete an, sie zu entfernen.

**2c) showThinkingSummaries: true**
Erklaere: "Zeigt Zusammenfassungen von Claudes internem Reasoning-Prozess. Du siehst in Echtzeit, ob Claude gruendlich analysiert oder abkuerzt. Besonders nuetzlich als Diagnose-Tool: Wenn die Summaries duenn ausfallen, weisst du, dass Claude nicht tief genug denkt — und kannst mit praeziseren Prompts gegensteuern."
→ Frage: "Thinking-Summaries aktivieren? (empfohlen: ja)"

**2d) autoMemoryEnabled: true**
Erklaere: "Claude merkt sich automatisch Learnings aus Konversationen — deine Praeferenzen, Korrekturen, Projekt-Kontext. Wird pro Repository in ~/.claude/projects/<repo>/memory/ gespeichert und bei jedem Session-Start geladen."
→ Frage: "Auto Memory aktivieren? (empfohlen: ja)"

**2e) Agent Teams — weiterhin experimentell (optionales Opt-in)**
Erklaere: "Agent Teams (mehrere kooperierende Claude-Code-Sessions mit gemeinsamer Task-Liste) sind laut Doku weiterhin EXPERIMENTELL und per Default aus. NICHT verwechseln mit Sub-Agents — die laufen ohne Flag. Wer Agent Teams testen will, setzt `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (im env-Block der settings.json oder als Shell-Variable). Optional steuert `CLAUDE_CODE_SUBAGENT_MODEL` das Modell fuer Sub-Agents und Teams. Das Flag ist KEIN Deprecation-Fall — es schaltet die Funktion bewusst ein."
Quelle: Anthropic Agent-Teams Doku (code.claude.com/docs/en/agent-teams)
→ Frage: "Agent Teams aktivieren? (optional, experimentell — Standard: nein)"

**2f) Sandboxing**
Erklaere: "Definiert welche Dateien und Netzwerk-Zugriffe Claude hat. Schuetzt sensible Bereiche wie SSH-Keys, AWS-Credentials und .env-Dateien vor versehentlichem Zugriff."
→ Frage: "Sandboxing aktivieren? (empfohlen: ja)"
Wenn ja, frage:
- "Welche Pfade soll Claude NICHT lesen duerfen? (Standard: ~/.ssh/**, ~/.aws/**, ~/.env)"
- "Welche Domains soll Claude erreichen duerfen? (Standard: registry.npmjs.org, github.com)"

**2g) Permission Mode** (KORRIGIERT in v17 — die alten Werte manual/auto/custom waren falsch)
Erklaere: "Gesetzt ueber `permissions.defaultMode`. Die echten Werte sind: **default** (fragt bei Erstnutzung jedes Tools nach — sicherer Standard), **acceptEdits** (Datei-Edits + gaengige FS-Befehle automatisch — fokussierte Sessions), **plan** (nur lesen/read-only Shell, keine Quelldatei-Aenderungen), **auto** (Auto-Approve mit Safety-Checks, Research Preview — mit Vorsicht), **dontAsk** (Auto-Deny ausser vorab freigegeben), **bypassPermissions** (ueberspringt ALLE Prompts — nur in Container/VM)."
Quelle: code.claude.com/docs/en/permissions — Volltext: `references/features/permission-modes-korrektur.md`
→ Frage: "Permission Mode? (default/acceptEdits/plan/auto/dontAsk/bypassPermissions — Standard: default)"
Hinweis: In geteilten/Managed-Settings `permissions.disableBypassPermissionsMode` und `permissions.disableAutoMode` auf "disable" setzen.

Wenn settings.json bereits existiert:
- Zeige Diff zwischen IST und SOLL
- Frage: "Soll ich die fehlenden Settings ergaenzen? (bestehende bleiben erhalten)"
- MERGE intelligent: Bestehende Eintraege nicht ueberschreiben, nur fehlende hinzufuegen

**Schritt 3: CLAUDE.md konfigurieren**
Lade `references/templates/claude-md-global.md` als Vorlage.

Wenn CLAUDE.md bereits existiert:
- Pruefe Zeilenanzahl (Warnung wenn >200)
- Pruefe ob Secrets-Policy vorhanden
- Pruefe ob Arbeitsweise-Regeln vorhanden (Edit-vor-Write, Read-before-Edit)
- Schlage fehlende Abschnitte vor, ueberschreibe NICHTS

Wenn CLAUDE.md nicht existiert:
- Frage: "Welche Secrets-Stufe? (1: Minimum, 2: Empfohlen, 3: Professionell mit Secret Manager)"
- Erstelle aus Template

**Schritt 4: Zusammenfassung**
Zeige was geaendert wurde:
```
✓ ~/.claude/settings.json — aktualisiert (autoMemory, effortLevel, Sandboxing)
✓ ~/.claude/CLAUDE.md — erstellt/ergaenzt (Arbeitsweise, Secrets-Policy)
```

---

## MODUS: PROJEKT

### Ziel
Setup eines einzelnen Coding-Projekts im aktuellen Verzeichnis.

### Voraussetzung
Der Nutzer muss sich im Projekt-Root befinden (das Verzeichnis das in VS Code geoeffnet ist).

### Ablauf

**Schritt 1: Projekt-Kontext erfassen**
- Pruefe welche Dateien bereits existieren (.claudeignore, CLAUDE.md, .claude/settings.json etc.)
- Erkenne Projekttyp: package.json → Node.js, requirements.txt → Python, Cargo.toml → Rust etc.
- Zeige IST-Zustand als Checkliste:
  ```
  [ ] .claudeignore
  [✓] CLAUDE.md (47 Zeilen)
  [ ] CLAUDE.local.md
  [ ] .claude/settings.json
  [ ] .claude/rules/
  [ ] hooks/guard.sh
  ```

**Schritt 2: Fehlende Dateien erstellen**
Fuer jede fehlende Datei:
1. Erklaere was sie tut und warum sie wichtig ist
2. Zeige den vorgeschlagenen Inhalt
3. Frage: "Soll ich diese Datei erstellen?"

Reihenfolge (bewusst gewaehlt — jeder Schritt baut auf dem vorherigen auf):

a) **.claudeignore** — Lade Template, passe an Projekttyp an:
   - Node.js: + node_modules/, package-lock.json
   - Python: + __pycache__/, *.pyc, venv/, .venv/
   - Rust: + target/

b) **CLAUDE.md** — Wenn /init noch nicht gelaufen: empfehle `claude /init` zuerst.
   Wenn schon vorhanden: pruefe auf fehlende Best-Practice-Abschnitte.

c) **CLAUDE.local.md** — Erstelle aus Template + trage in .gitignore ein.

d) **.claude/settings.json** — Lade Projekt-Template:
   - Passe Permissions an Projekttyp an
   - Frage: "Welche Hooks aktivieren?"
     - Auto-Formatter (PostToolUse) — "Nutzt du Prettier? (ja/nein)"
     - Guard-Script (PreToolUse) — "Soll Claude vor Zugriff auf sensible Dateien geschuetzt werden? (empfohlen: ja)"
     - Stop-Reminder (Stop) — "Erinnerung an /wrap-up am Session-Ende? (empfohlen: ja)"

e) **hooks/guard.sh** — Erstelle Guard-Script aus Template. chmod +x setzen.

f) **.claude/rules/** — Frage: "Moechtest du ausgelagerte Regelblöcke? (empfohlen fuer groessere Projekte)"
   - coding-style.md
   - agent-patterns.md (fuer fortgeschrittene Nutzer)

g) **.gitignore pruefen** — Stelle sicher dass CLAUDE.local.md, .env, .env.* eingetragen sind.

**Schritt 2b: Coding Governance (nur mit --code Flag)**
Frage: "Moechtest du erweiterte Coding-Governance-Regeln?"
Wenn ja:
- Read-before-Write Pflicht in CLAUDE.md
- Edit-vor-Write Regel
- Verification-first (Tests vor Implementierung)
- effortLevel: high in Projekt-Settings

**Schritt 3: Zusammenfassung**
Zeige was erstellt/geaendert wurde mit Pfaden.

---

## Erweiterte Setup-Bausteine (v17 Feature-Module)

Ueber das Kern-Setup hinaus gibt es 16 vertiefende Module unter `references/features/`.
Jedes wurde einzeln gegen die offizielle Doku verifiziert und enthaelt: gefuehrte
Erklaerung (WARUM), maschinenlesbaren Referenzblock und eigene Audit-Kriterien.

**Vorgehen:** Lade NUR das Modul, das der Nutzer gerade braucht (Token-schonend) —
z.B. wenn er "MCP einrichten" sagt, lies `references/features/mcp-konfiguration-mcp-json.md`
und fuehre danach. Im PROJEKT-Modus sind nach dem Basis-Setup **MCP-Server** und
**Subagents** die empfohlenen naechsten Schritte.

**Kritisch (Kernluecken):**
- **MCP-Server (.mcp.json)** → `references/features/mcp-konfiguration-mcp-json.md`
- **Subagents (.claude/agents/)** → `references/features/subagent-definitionen-claude-agents.md`
- **Hook-Events (vollstaendig, 30 Events)** → `references/features/hook-events-vollstaendig.md`
- **Permission-Modes** → `references/features/permission-modes-korrektur.md`
- **Sandbox-Setup (Linux/WSL2 + Modi)** → `references/features/sandbox-setup-linux-wsl2-modi.md`

**Wichtig:**
- **Model-Pinning & Provider-Overrides** → `references/features/model-pinning-provider-overrides.md`
- **additionalDirectories / Working Dirs** → `references/features/additionaldirectories-working-dirs-multi.md`
- **Managed/Enterprise-Settings & Precedence** (admin) → `references/features/managed-enterprise-settings-precedence.md`
- **Custom Output Styles** → `references/features/custom-output-styles.md`
- **CLAUDE.md Best Practices** → `references/features/claude-md-best-practices.md`

**Nice-to-have:**
- **Checkpointing & Rewind** → `references/features/checkpointing-rewind.md`
- **Hook-Typen (command/http/mcp_tool/prompt/agent)** → `references/features/hook-typen-command-http-mcp-tool-prompt-.md`
- **Skills (.claude/skills/)** → `references/features/skills-claude-skills-ordnerstruktur-skil.md`
- **Permission-Granularitaet (Bash/Read/Edit/WebFetch/MCP)** → `references/features/permission-granularitaet-bash-read-edit-.md`
- **MCP Advanced (OAuth, Tool-Search)** → `references/features/mcp-advanced-oauth-tool-search.md`
- **Worktrees / Housekeeping / Auth-Keys** → `references/features/worktrees-housekeeping-auth-keys.md`

Der vollstaendige Index steht in `references/checklist.yaml` unter `feature_modules`.

---

## MODUS: AUDIT

### Ziel
Bestehende Konfiguration gegen Best Practices pruefen. Abweichungen anzeigen und optional korrigieren.

### Ablauf

**Schritt 1: Scope bestimmen**
Frage: "Was soll ich pruefen?
1. **global** — Nur globale Konfiguration (~/.claude/)
2. **projekt** — Nur aktuelles Projekt
3. **beides** — Global + Projekt"

**Schritt 2: Checks durchfuehren**
Lade `references/checklist.yaml` und fuehre die Audit-Checks durch.

Fuer jeden Check:
1. Pruefe den IST-Zustand (Datei lesen, JSON parsen, Zeilen zaehlen)
2. Vergleiche mit SOLL aus der Checkliste
3. Bewerte: ✓ (OK), ⚠ (Warnung), ✗ (fehlt/falsch)

**Global-Checks:**
- settings.json existiert und enthaelt: autoMemoryEnabled, effortLevel
- effortLevel gesetzt — Opus-4.8-Default ist "high"; "xhigh" ist ein legitimes Opt-in
  (kein Fehler), "medium"/"low" geben Warnung. "max" gehoert NICHT in settings.json.
- **Deprecation-Warnung:** `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` darf NICHT gesetzt sein
  (wirkt nur auf Opus 4.6, wirkungslos auf 4.7/4.8). Wenn vorhanden: Warnung + Loesch-Angebot.
- **Deprecation-Warnung:** `ANTHROPIC_SMALL_FAST_MODEL` darf NICHT gesetzt sein
  (deprecated → `ANTHROPIC_DEFAULT_HAIKU_MODEL`). Wenn vorhanden: Warnung + Migrations-Angebot.
- KEIN Befund mehr fuer `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: Agent Teams sind weiterhin
  experimentell, das Flag schaltet sie bewusst ein — Vorhandensein ist OK.
- Thinking-Summaries aktiviert (showThinkingSummaries)
- Sandboxing konfiguriert (oder bewusst deaktiviert)
- **Permission-Mode korrekt:** `permissions.defaultMode` (falls gesetzt) ist einer von
  default/acceptEdits/plan/auto/dontAsk/bypassPermissions — NICHT manual/custom (v17-Fix)
- CLAUDE.md existiert, unter 200 Zeilen, hat Secrets-Policy
- Lese-Pflicht-Regel vorhanden (Edit-vor-Write, Read-before-Edit)

**Modul-Audits (v17):** Fuer vertiefte Audits die jeweiligen `references/features/<modul>.md`
laden — jedes Modul bringt eigene Audit-Kriterien mit (z.B. MCP, Sandbox, Managed-Settings).

**Projekt-Checks:**
- .claudeignore existiert und enthaelt .env
- CLAUDE.md existiert, unter 150 Zeilen
- CLAUDE.local.md existiert + in .gitignore
- .claude/settings.json existiert mit Hooks
- Guard-Script vorhanden und ausfuehrbar
- Lese-Pflicht in Projekt-CLAUDE.md oder globaler CLAUDE.md

**Schritt 3: Report ausgeben**
Format:
```
╔══════════════════════════════════════════════╗
║  CLAUDE CODE BEST PRACTICE AUDIT             ║
║  Checkliste v17 — Juni 2026 (Opus 4.8)       ║
╚══════════════════════════════════════════════╝

GLOBAL (~/.claude/)
  ✓ settings.json vorhanden
  ✓ autoMemoryEnabled: true
  ✓ effortLevel: high (Opus-4.8-Default; xhigh waere Opt-in)
  ⚠ CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING noch gesetzt (wirkungslos auf 4.7/4.8)
  ⚠ ANTHROPIC_SMALL_FAST_MODEL noch gesetzt (deprecated → ANTHROPIC_DEFAULT_HAIKU_MODEL)
  ✗ Thinking-Summaries nicht aktiviert
  ✗ Sandboxing nicht konfiguriert
  ✓ CLAUDE.md vorhanden (142 Zeilen)
  ✓ Secrets-Policy vorhanden
  ✓ Orchestrator-/Agenten-Team-Regel vorhanden

PROJEKT (/Users/.../mein-projekt/)
  ✓ .claudeignore vorhanden
  ✓ .env in .claudeignore
  ⚠ CLAUDE.md: 163 Zeilen (empfohlen: max. 150)
  ✗ CLAUDE.local.md fehlt
  ✗ .claude/settings.json fehlt
  ✗ Hooks nicht konfiguriert
  ✗ Guard-Script fehlt

ERGEBNIS: 6/19 Checks bestanden, 2 Deprecation-Warnungen
```

**Schritt 4: Korrekturen anbieten**
Fuer jeden ✗ oder ⚠: Frage ob der Nutzer es korrigieren moechte.
Korrigiere einzeln — nicht alles auf einmal.

---

## Allgemeine Regeln

1. **NIEMALS bestehende Dateien ueberschreiben** ohne explizite Bestaetigung
2. **IMMER erklaeren** was eine Einstellung tut und warum sie empfohlen wird
3. **Idempotent arbeiten** — der Skill kann beliebig oft laufen ohne Schaden
4. **Merge statt Replace** — bei bestehenden settings.json: fehlende Keys ergaenzen, vorhandene behalten
5. **Projekttyp erkennen** und Templates entsprechend anpassen
6. **Sprache: Deutsch** — alle Erklaerungen und Ausgaben auf Deutsch
7. **Keine Secrets anlegen** — nur Regeln die Secrets schuetzen
8. **Quellen nennen** — bei Empfehlungen auf Anthropic-Doku oder Checkliste verweisen
