# Datei-Templates für neues Projekt

Alle Templates mit {{PLATZHALTER}} müssen mit den gesammelten Projekt-Infos befüllt werden.

---

## config.js

```javascript
// lib/config.js — Single Source of Truth
'use strict';

const VERSION = '{{VERSION_START}}';

// Dokumentationsdateien — Self-Healing überwacht Versions-Sync
const DOC_FILES = {
  'CLAUDE.md': {
    path: 'CLAUDE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'SYSTEM_ARCHITECTURE.md': {
    path: 'SYSTEM_ARCHITECTURE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'ARCHITECTURE_DESIGN.md': {
    path: 'ARCHITECTURE_DESIGN.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'COMPONENT_INVENTORY.md': {
    path: 'COMPONENT_INVENTORY.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'DEVELOPMENT_PROCESS.md': {
    path: 'DEVELOPMENT_PROCESS.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'GOVERNANCE.md': {
    path: 'GOVERNANCE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  }
};

// Projekt-spezifische Config (anpassen)
const CONFIG = {
  PROJECT_NAME: '{{PROJECT_NAME}}',
  ISSUE_PREFIX: '{{ISSUE_PREFIX}}',
  GITHUB_REPO: '{{GITHUB_REPO}}',
};

module.exports = { VERSION, DOC_FILES, CONFIG };
```

---

## CLAUDE.md (Minimum)

```markdown
# {{PROJECT_NAME}} — AI System Reference

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}
**Repository:** {{GITHUB_REPO}}

## Identität

{{PROJECT_DESC}}

## Regeln (NIEMALS)

1. **NIEMALS** Code ändern ohne Linear Issue
2. **NIEMALS** Code ändern ohne Spec-File (`specs/{{PREFIX}}XXX.md`)
3. **NIEMALS** Issue schließen ohne Git Push + Changelog
4. **NIEMALS** API Keys im Chat — User trägt direkt in .env ein
5. **NIEMALS** Issue ohne Labels anlegen
6. **NIEMALS** `config.js` VERSION erhöhen ohne alle DOC_FILES zu bumpen
7. **NIEMALS** Sub-Task direkt von Backlog → Done — immer zuerst "In Progress"
8. **NIEMALS** neue Datei anlegen ohne Eintrag in `ARCHITECTURE_DESIGN.md §Referenzen` + `INDEX.md`
9. **NIEMALS** Issue schließen ohne Integration-Test-Check (neue Komponente abgedeckt?)
10. [Projektspezifische Regeln ergänzen]

## Governance-Hooks

Zwei automatische Git-Hooks sind aktiv:
- **spec-gate.sh**: Blockiert Commits mit Issue-Referenz wenn `specs/{{PREFIX}}XXX.md` fehlt
  oder `## Agent-Pattern` nicht ausgefüllt ist
- **doc-version-sync.sh**: Blockiert Commits wenn `config.js` VERSION erhöht wurde
  aber DOC_FILES-Einträge noch die alte Version haben

## Agent-Pattern (PFLICHT vor jeder Story)

Vor dem Start jeder Story deklarieren:
- **Solo** — 1 klar abgegrenzte Story, <5 Dateien
- **Subagent** — isolierter Task / Einzelrecherche
- **Agent-Team** — >3 unabhängige Tasks ODER Debugging mit unklarer Ursache
- **Parallel-Subagents** — mehrere unabhängige Recherchen gleichzeitig

Entscheidung in `specs/{{PREFIX}}XXX.md` unter `## Agent-Pattern` eintragen — wird von spec-gate.sh erzwungen.

## System-Architektur

[Kurze Übersicht der wichtigsten Komponenten — nach und nach ergänzen]

## Config-Werte

Alle Config-Werte kommen aus `lib/config.js`. VERSION ist dort SSoT.

## Handoff-Prozess

Nach Feature-Entwicklung:
1. Code committen + pushen
2. CLAUDE.md + Changelog updaten
3. Operator informieren: "Feature X fertig"
```

---

## ARCHITECTURE_DESIGN.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Architecture Design

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

## Übersicht

{{PROJECT_DESC}}

## Quality Attributes

| Attribut | Priorität | Beschreibung |
|----------|-----------|-------------|
| Reliability | Hoch | [Ausfallsicherheit, Retry-Logik] |
| Data Integrity | Hoch | [Konsistenz, Validierung] |
| Security | Hoch | [Auth, Secrets-Handling] |
| Performance | Mittel | [Latenz, Throughput] |
| Observability | Mittel | [Logging, Monitoring] |
| Maintainability | Mittel | [Code-Qualität, Doku] |

## ADRs (Architecture Decision Records)

| Nr | Datum | Titel | Status |
|----|-------|-------|--------|
| ADR-01 | {{TODAY}} | Initial Architecture | Active |

## Referenzen (alle Dateien)

> **Pflicht:** Jede neue Datei sofort hier eintragen — vor dem git commit.

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | AI-Kontext, Regeln, Governance |
| `SYSTEM_ARCHITECTURE.md` | Komponenten, Flows, Konfiguration |
| `ARCHITECTURE_DESIGN.md` | ADRs, Quality Attributes, Referenzen |
| `INDEX.md` | Alle Docs kategorisiert |
| `COMPONENT_INVENTORY.md` | Alle Komponenten mit Status |
| `GOVERNANCE.md` | Entwicklungs-Prozess, Governance-Regeln |
| `SECURITY.md` | Security-Policy, API-Key-Regeln |
| `CHANGELOG.md` | Version-History |
| `lib/config.js` | SSoT alle Parameter |
| `specs/TEMPLATE.md` | Story-Template |
```

---

## INDEX.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Docs Index

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

> Alle Dokumente des Projekts kategorisiert.
> **Pflicht:** Jede neue Datei sofort hier eintragen — vor dem git commit.

## Core

| Datei | Zweck | Aktualisiert |
|-------|-------|-------------|
| `CLAUDE.md` | AI-Kontext, Regeln, Governance | v{{VERSION_START}} |
| `SYSTEM_ARCHITECTURE.md` | Komponenten, Agent-Liste, Flows | v{{VERSION_START}} |
| `ARCHITECTURE_DESIGN.md` | ADRs, Quality Attributes | v{{VERSION_START}} |
| `INDEX.md` | Dieses Verzeichnis | v{{VERSION_START}} |

## Governance

| Datei | Zweck |
|-------|-------|
| `GOVERNANCE.md` | Entwicklungs-Prozess, Regeln |
| `SECURITY.md` | Security-Policy |
| `CHANGELOG.md` | Version-History |
| `specs/TEMPLATE.md` | Story-Template |

## Komponenten

| Datei | Zweck |
|-------|-------|
| `COMPONENT_INVENTORY.md` | Alle Komponenten mit Status |
| `lib/config.js` | SSoT Konfiguration |
```

---

## SYSTEM_ARCHITECTURE.md (Minimum)

```markdown
# {{PROJECT_NAME}} — System Architecture

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

## Komponenten

[Hier Komponenten eintragen wenn System wächst]

## Config

Alle Parameter in `lib/config.js`. VERSION ist SSoT.
```

---

## COMPONENT_INVENTORY.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Component Inventory

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

| Komponente | Datei | Status | Beschreibung |
|-----------|-------|--------|-------------|
| Config | `lib/config.js` | Active | SSoT alle Parameter |
```

---

## specs/TEMPLATE.md

```markdown
---
story_id: {{ISSUE_PREFIX}}XXX
estimate: <SP, gesetzt von /ideation Schritt 5b>
token_estimate: <absolute Tokens, gesetzt von /ideation Schritt 5b>
execution_mode: <linear | sub-agents | agentic, gesetzt von /ideation Schritt 5b>
estimation_basis: |
  <Prosa: Files-Anzahl, Diff-Groesse, Tests, Doku, Cross-Skill, References, L3-Faktor>
---

# {Feature Name}

> **Issue:** {{ISSUE_PREFIX}}XXX | **Erstellt:** {Datum} | **Status:** Draft / Approved / Done

## Agent-Pattern

> **PFLICHT — vor dem Start ausfuellen. Wird von spec-gate.sh erzwungen.**

- [ ] **Solo** — 1 klar abgegrenzte Story, <5 Dateien, keine parallelen Komponenten
- [ ] **Subagent** — isolierter Task / Einzelrecherche / Explore-Auftrag
- [ ] **Agent-Team** — >3 unabhaengige Tasks ODER Debugging mit unklarer Ursache ODER Cross-Layer
- [ ] **Parallel-Subagents** — mehrere unabhaengige Recherchen gleichzeitig

**Gewähltes Pattern:** [Solo / Subagent / Agent-Team / Parallel-Subagents]
**Begründung:** [Warum dieses Pattern? Tasks zaehlen, Trigger-Bedingung benennen]
**Team-Komposition:** [Nur bei Agent-Team: z.B. "Lead (Sonnet) + Explore (Haiku) + Plan (Sonnet)" — sonst "n/a"]

---

## Why

[1-2 Saetze: Welches Problem wird geloest? Warum jetzt?]

## What

[Konkretes Deliverable. Woran erkennt man, dass es fertig ist?]

## Constraints

### Must
- [Bestehende Patterns/Conventions einhalten]
- [Config SSoT in lib/config.js]

### Must Not
- [Keine neuen Dependencies ohne Begruendung]
- [Kein Code ausserhalb des Scopes aendern]
- [Keine Hardcoded Values — alles ueber config.js]
- [Keine Secrets in Code/Logs]

### Out of Scope
- [Explizit ausgeschlossene Features/Aenderungen]

## Current State

**Relevante Dateien:**
- `path/to/file.js` — [was die Datei tut, warum relevant]

**Bestehende Patterns:**
- [Konvention die eingehalten werden muss, mit Beispiel-Datei]

**Architektur-Dimensionen (betroffen):**
- [Welche Dimensionen sind relevant? Kurze Einschaetzung]

## Tasks

> Jeder Task: max 3 Dateien, unter 30min, unabhaengig committbar.
> Tasks die zusammen ausgeliefert werden muessen → gruppieren.
> Letzter Task = IMMER Dokumentation + Config.

### T0: Prozesskatalog-Check
- [ ] Gibt es einen aehnlichen Prozess der erweitert werden kann? (Referenz)
- [ ] Welche bestehenden Dateien werden beruehrt?

### T1: [Erster Task]
- [ ] [Konkrete Aufgabe]
- [ ] Verify: [Wie pruefen wir dass T1 korrekt ist?]

### T2: [Zweiter Task]
- [ ] [Konkrete Aufgabe]
- [ ] Verify: [Wie pruefen wir dass T2 korrekt ist?]

### T_last: Dokumentation + Config
- [ ] ARCHITECTURE_DESIGN.md §Referenzen um neue Dateien ergaenzen
- [ ] INDEX.md um neue Dateien ergaenzen
- [ ] COMPONENT_INVENTORY.md aktualisieren
- [ ] CHANGELOG.md Eintrag
- [ ] config.js VERSION bumpen
- [ ] Alle DOC_FILES auf neue VERSION setzen

## Rollout

> **PFLICHT fuer AI-generierte Stories — wird von spec-gate.sh erzwungen.**
> Fuer reine Doku-Aenderungen ohne neuen Code-Pfad: `**Feature-Flag:** n/a — [Begruendung]` eintragen.

**Feature-Flag:** `flag.{{STORY_ID}}` — Default: `false`

**Implementierung (Projekt-Groesse):**
- Kleines Projekt: Env-Variable `FLAG_{{STORY_ID}}=true/false`
- Mittleres Projekt: `config/flags.json` (hot-reloadable)
- Grosses Projekt: Externes Tool (LaunchDarkly / Unleash) — ADR anlegen

**Stufen:**
- [ ] Stufe 1: 5 % Nutzer / 24h — Erfolgs-Kriterium: keine Fehler im Log
- [ ] Stufe 2: 50 % Nutzer / 24h — Erfolgs-Kriterium: P95 ≤ Baseline × 1.05
- [ ] Stufe 3: 100 % Nutzer — Flag nach 72h stabilem Betrieb entfernen

**Rollback-Kommando:** `FLAG_{{STORY_ID}}=false` (Config-Reload, keine Code-Aenderung noetig)

**AI-Markierung:** Alle in dieser Story hinzugefuegten Code-Pfade erhalten Kommentar `// AI-generated: {{STORY_ID}}` (Rollback-Identifikation, BOO-17).

---

## Dokumentations-Impact

| Datei | Was aendern |
|-------|-------------|
| `ARCHITECTURE_DESIGN.md` | §Referenzen: neue Datei eintragen |
| `INDEX.md` | Neue Datei eintragen |
| `CHANGELOG.md` | Version-Eintrag |

## Abhaengigkeiten

- **Blockiert durch:** —
- **Blockiert:** —

## Acceptance Criteria

- [ ] [Messbares Kriterium 1]
- [ ] [Messbares Kriterium 2]
- [ ] spec-gate.sh + doc-version-sync.sh gruen (kein blockierter Commit)
- [ ] Integration-Test-Skill: Neue Komponente abgedeckt oder Skill erweitert
- [ ] ESLint: 0 Errors (Warnings dokumentiert)
- [ ] Obsidian Change-Log Eintrag

## Session-Referenz

> Wird von `/implement` Schritt 5 automatisch befuellt (BOO-19).

**Session-Timestamp:** {automatisch}
**Session-ID:** `{automatisch}` (best-effort — neueste Session beim Commit)
**Session-Log:** `~/.claude/projects/.../sessions/{session-id}.jsonl`
**Commit-SHA:** `{automatisch nach Git Commit}`
**Audit-Trace:** `bash .claude/scripts/audit-trace.sh {SPEC_ID}` (braucht jq)
```

---

## spec-gate.sh (Hook-Template)

> Anpassen: WORKSPACE-Pfad + ISSUE_PREFIX + CONTAINER_CMD (optional, nur bei Agent-Systemen).

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  SPEC-GATE — Governance Hook
#  Blockiert git commit wenn specs/{PREFIX}XXX.md fehlt oder Agent-Pattern fehlt.
#
#  Claude Code PreToolUse Hook (Bash)
#  Input: JSON via stdin: {"tool_input": {"command": "..."}}
#  Exit 1 → Tool-Call blockiert | Exit 0 → erlaubt
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

WORKSPACE="{{PROJECT_PATH}}"
ISSUE_PREFIX="{{ISSUE_PREFIX}}"  # z.B. "PROJ-"

# JSON parsen → Command extrahieren
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Nur git commit Befehle prüfen
if ! echo "$CMD" | grep -qE 'git commit'; then
  exit 0
fi

# {PREFIX}XXX aus Commit-Message extrahieren (dynamisch)
PREFIX_ESC=$(echo "$ISSUE_PREFIX" | sed 's/[-]/\\-/g')
ISSUE=$(echo "$CMD" | grep -oP "${PREFIX_ESC}[0-9]+" | head -1 || echo "")
if [ -z "$ISSUE" ]; then
  exit 0  # Kein Issue referenziert → kein Gate
fi

# Spec-File prüfen
SPEC_FILE="$WORKSPACE/specs/${ISSUE}.md"
if [ ! -f "$SPEC_FILE" ]; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: specs/${ISSUE}.md fehlt!           "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Nächste Schritte:"
  echo "  1. specs/TEMPLATE.md lesen"
  echo "  2. specs/${ISSUE}.md erstellen + befüllen"
  echo "  3. git add specs/${ISSUE}.md && git commit -m 'docs: specs/${ISSUE}.md'"
  echo ""
  exit 1
fi

# Agent-Pattern prüfen — Sektion vorhanden?
if ! grep -q "## Agent-Pattern" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: Agent-Pattern fehlt in Spec!        "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Nächste Schritte:"
  echo "  1. specs/${ISSUE}.md öffnen"
  echo "  2. ## Agent-Pattern Sektion aus specs/TEMPLATE.md einfügen"
  echo "  3. Gewähltes Pattern ausfüllen"
  echo ""
  exit 1
fi

# Agent-Pattern prüfen — nicht leer/TBD
PATTERN=$(grep "^\*\*Gewähltes Pattern:\*\*" "$SPEC_FILE" | sed 's/\*\*Gewähltes Pattern:\*\* //' | tr -d '[:space:]' || echo "")
if [ -z "$PATTERN" ] || [ "$PATTERN" = "TBD" ] || echo "$PATTERN" | grep -q "\["; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: Agent-Pattern nicht ausgefüllt!     "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Erlaubte Werte: Solo | Subagent | Agent-Team | Parallel-Subagents"
  echo ""
  exit 1
fi

# Agent-Team: Team-Komposition prüfen
if echo "$PATTERN" | grep -qi "Agent-Team"; then
  TEAM=$(grep "^\*\*Team-Komposition:\*\*" "$SPEC_FILE" | sed 's/\*\*Team-Komposition:\*\* //' | tr -d '[:space:]' || echo "")
  if [ -z "$TEAM" ] || [ "$TEAM" = "n/a" ] || echo "$TEAM" | grep -q "\["; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  🚫  GOVERNANCE-SPERRE: Team-Komposition fehlt!             "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Pattern 'Agent-Team' gewählt aber Team-Komposition ist leer."
    echo "  Beispiel: Lead (Sonnet) + Explore (Haiku) + Plan (Sonnet)"
    echo ""
    exit 1
  fi
fi

# Rollout-Sektion prüfen (BOO-17 — Feature-Flag-Konvention)
if ! grep -q "## Rollout" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: ## Rollout fehlt in Spec!           "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Naechste Schritte:"
  echo "  1. specs/${ISSUE}.md oeffnen"
  echo "  2. ## Rollout Sektion aus specs/TEMPLATE.md einfuegen"
  echo "  3. Feature-Flag-Name und Rollout-Stufen ausfuellen"
  echo "     (Fuer reine Doku-Stories: '**Feature-Flag:** n/a' genügt)"
  echo ""
  exit 1
fi

exit 0
```

---

## doc-version-sync.sh (Hook-Template)

> Anpassen: WORKSPACE-Pfad.

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  DOC-VERSION-SYNC — Governance Hook
#  Blockiert git commit wenn lib/config.js VERSION erhöht wurde,
#  aber DOC_FILES noch die alte Version haben.
#
#  Escape-Hatch: git commit --no-verify
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

WORKSPACE="{{PROJECT_PATH}}"

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

if ! echo "$CMD" | grep -qE 'git commit'; then exit 0; fi
if echo "$CMD" | grep -q "\-\-no-verify"; then exit 0; fi

cd "$WORKSPACE" 2>/dev/null || exit 0
STAGED=$(git diff --staged --name-only 2>/dev/null || echo "")
if ! echo "$STAGED" | grep -q "lib/config.js"; then exit 0; fi

RESULT=$(node -e "
const { execSync } = require('child_process');
const { readFileSync, existsSync } = require('fs');
const path = require('path');
const BASE = '$WORKSPACE';

try {
  const staged = execSync('git show :lib/config.js', { cwd: BASE }).toString();
  let head = '';
  try { head = execSync('git show HEAD:lib/config.js', { cwd: BASE }).toString(); } catch {}

  const newVer = (staged.match(/const VERSION\s*=\s*'([\d.]+)'/) || [])[1];
  const oldVer = (head.match(/const VERSION\s*=\s*'([\d.]+)'/)  || [])[1] || '';
  if (!newVer || newVer === oldVer) { process.exit(0); }

  const docRe = /'[^']+\.md'\s*:\s*\{\s*path:\s*'([^']+)'\s*,\s*versionPattern:\s*(\/[^/\n]+\/[gimsuy]*)/g;
  const mismatches = [];
  let m;
  while ((m = docRe.exec(staged)) !== null) {
    const relPath = m[1];
    const patStr  = m[2];
    const fullPath = path.join(BASE, relPath);
    if (!existsSync(fullPath)) continue;
    const parts = patStr.match(/^\/(.+)\/([gimsuy]*)$/);
    if (!parts) continue;
    const pat = new RegExp(parts[1], parts[2]);
    const content = readFileSync(fullPath, 'utf8');
    const match = content.match(pat);
    if (!match || match[1] === newVer) continue;
    mismatches.push(relPath + '|||' + match[1]);
  }

  if (mismatches.length === 0) { process.exit(0); }
  process.stdout.write('MISMATCH:' + newVer + ':' + oldVer + ':' + mismatches.join(':::'));
} catch (e) { process.exit(0); }
" 2>/dev/null || echo "")

if [ -z "$RESULT" ] || [[ "$RESULT" != MISMATCH:* ]]; then exit 0; fi

NEW_VER=$(echo "$RESULT" | cut -d: -f2)
OLD_VER=$(echo "$RESULT" | cut -d: -f3)
ENTRIES=$(echo "$RESULT" | cut -d: -f4-)

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚫  DOC-VERSION-SYNC: Doku nicht auf v${NEW_VER} aktualisiert!"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  lib/config.js VERSION: ${OLD_VER} → ${NEW_VER}"
echo "  Folgende Doku-Dateien haben noch die alte Version:"
echo ""
echo "$ENTRIES" | tr ':::' '\n' | while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  FILE=$(echo "$entry" | cut -d'|' -f1)
  OLDV=$(echo "$entry" | cut -d'|' -f4)
  echo "    ❌  ${FILE}  (hat: ${OLDV})"
done
echo ""
echo "  Escape-Hatch: git commit --no-verify"
echo ""
exit 1
```

---

## .gitignore

```
node_modules/
.env
*.log
*.pid
*.lock
.DS_Store
dist/
build/
__pycache__/
*.pyc
.venv/
venv/

# BOO-36: lokale Iteration-Outputs aus /implement Schritt 6
# (ESLint-SARIF, Test-JUnit-XML, Coverage-JSON, Semgrep-SARIF, meta.json pro Run)
# Werden NICHT committed — /sprint-review aggregiert sie in journal/sprint-{date}.md.
journal/reports/local/
```

---

## journal/reports/local/<RUN_DIR>/meta.json (BOO-36 — Implement-Run-Metadaten)

> Jeder `/implement`-Run schreibt am Ende dieser Datei. Schema fix, von `/sprint-review` parsbar.

```json
{
  "story_id": "BOO-15",
  "started_at": "2026-04-27T14:30:00Z",
  "completed_at": "2026-04-27T14:34:00Z",
  "iterations": {
    "eslint": 3,
    "tests": 2,
    "semgrep": 1,
    "coverage": 1
  },
  "final_status": "passed",
  "environment": "mac",
  "pre_flight_warning": null
}
```

**Feld-Konvention:**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `story_id` | string | Issue-Key aus Linear (z.B. `BOO-36`) |
| `started_at` | ISO-8601 UTC | Run-Start (`date -u +%Y-%m-%dT%H:%M:%SZ`) |
| `completed_at` | ISO-8601 UTC | Run-Ende |
| `iterations.eslint` | int | Anzahl ESLint-Iterationen (0 wenn Gate uebersprungen) |
| `iterations.tests` | int | Anzahl Test-Iterationen |
| `iterations.semgrep` | int | Anzahl Semgrep-Iterationen |
| `iterations.coverage` | int | Anzahl Coverage-Iterationen |
| `final_status` | enum | `passed` \| `failed` \| `stopped_iteration_limit` |
| `environment` | enum | `mac` \| `vps` \| `ci` \| `unknown` (aus `.claude/environment.json`) |
| `pre_flight_warning` | string \| null | Gesetzt von `/implement` Schritt 0b (BOO-40) wenn Operator trotz Projektion > 80% weitergemacht hat. Format: `"projection 90%, user proceeded"`. `null` bei normalem Run. Wird von `/sprint-review` ausgewertet — wenn Session tatsaechlich gecompacted hat, fliesst die Lesson zurueck nach L3 fuer BOO-39-Kalibrierung. |

**Pfad-Konvention:**
- Run-Verzeichnis: `journal/reports/local/{YYYY-MM-DD_HHMM}_{STORY-ID}/`
- Verzeichnis ist gitignored (siehe `.gitignore`-Block oben)
- Weitere Dateien im selben Verzeichnis:
  - `eslint-iter{N}.sarif` — pro ESLint-Iteration
  - `tests-iter{N}.junit.xml` — pro Test-Iteration
  - `coverage-final.json` — Coverage-Endstand
  - `semgrep-final.sarif` — Semgrep-Endstand

**Verantwortlichkeit (BOO-36):**
- **Schreiben:** `/implement` (raw Outputs + meta.json)
- **Lesen + aggregieren:** `/sprint-review` (in `journal/sprint-{date}.md`)
- **L3-DB-Write:** ausschliesslich `/sprint-review` zweite Phase in `journal/learnings.db` — Implement schreibt NICHT direkt in die L3-DB.

---

## .env.example

```bash
# Linear
LINEAR_API_KEY=

# Telegram (optional)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Research (optional)
OPENROUTER_API_KEY=

# Automation Daemon (optional)
LINEAR_WEBHOOK_SECRET=
DAEMON_PORT=3001

# Claude Code
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

---

## CHANGELOG.md

```markdown
# Changelog — {{PROJECT_NAME}}

## v{{VERSION_START}} — {{TODAY}}

- Initial project setup with Code-Crash Framework
- Governance hooks installed: spec-gate.sh, doc-version-sync.sh
- Base skills installed
```

---

## eslint.config.mjs (Node.js / Full-Stack)

**Industriestandard-Set seit BOO-2 (2026-05-01):** ESLint Recommended + Airbnb Base + Security + SonarJS. Alles MIT-Lizenz, kein Cloud-Service, keine Lizenzkosten.

**npm-Installation:**
```bash
npm install --save-dev eslint @eslint/js eslint-config-airbnb-base \
  eslint-plugin-security eslint-plugin-sonarjs @eslint/compat
```

(`@eslint/compat` ueberbrueckt Configs, die noch keine native Flat-Config-Form haben — z.B. eslint-config-airbnb-base. Bei Projekten, die ausschliesslich Flat-Config-native Plugins nutzen, kann das Paket entfallen.)

```javascript
// eslint.config.mjs — ESLint v9+ Flat Config (Industriestandard, BOO-2)
import js from '@eslint/js';
import { FlatCompat } from '@eslint/compat';
import securityPlugin from 'eslint-plugin-security';
import sonarjsPlugin from 'eslint-plugin-sonarjs';

const compat = new FlatCompat();

export default [
  // Layer 1 — ESLint Recommended (Syntax, no-undef, no-unreachable etc.)
  js.configs.recommended,

  // Layer 2 — Airbnb Base (Industriestandard fuer Code-Stil + Best Practices)
  ...compat.extends('eslint-config-airbnb-base'),

  // Layer 3 — Security-Plugin (eval, child_process, RegExp DoS, unsafe Buffer ...)
  securityPlugin.configs.recommended,

  // Layer 4 — SonarJS (Code Smells, Cognitive Complexity, duplicate Logic)
  sonarjsPlugin.configs.recommended,

  // Hausregeln (ueberschreiben/ergaenzen die obigen Configs gezielt)
  {
    files: ['**/*.js', '**/*.mjs'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'readonly',
        exports: 'readonly',
        process: 'readonly',
        console: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        Buffer: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-console': 'off',
      'semi': ['error', 'always'],
      'no-undef': 'error',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**'],
  },
];
```

**Mit React:** statt `eslint-config-airbnb-base` das Paket `eslint-config-airbnb` verwenden (zieht React-spezifische Regeln mit, plus `eslint-plugin-react` und `eslint-plugin-jsx-a11y` als Peer Deps).

**Iteration im Implement-Skill:** `/implement` Schritt 6a iteriert deklarativ ueber den ESLint-Output bis 0 Errors (max. 5 Iterationen, dann Stopp mit Hinweis). Compound Engineering Mechanik #1 nach Schrader Code Crash.

---

## .prettierrc (Frontend / Full-Stack)

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

---

## pyproject.toml (Python)

**Industriestandard-Set seit BOO-2 (2026-05-01):** Ruff mit `S` (flake8-bandit, Security) als zusaetzliches Regelset — erkennt `eval`, `exec`, unsichere Hashes, Shell-Injection-Pattern, hardcoded Passwords etc. Plus `B` (flake8-bugbear, haeufige Python-Bugs) und `C4` (flake8-comprehensions, idiomatischere Listen-/Dict-Comprehensions).

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = [
  "E",   # pycodestyle Errors
  "W",   # pycodestyle Warnings
  "F",   # Pyflakes (unused imports/vars)
  "I",   # isort (Import-Reihenfolge)
  "B",   # flake8-bugbear (Bug-Patterns)
  "C4",  # flake8-comprehensions (idiomatische Listen/Dicts)
  "S",   # flake8-bandit (Security)
]
ignore = []

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]          # `assert` in Tests erlaubt
"migrations/*" = ["S608"]     # raw SQL in Migrations erlaubt

[tool.black]
line-length = 100
target-version = ["py311"]
```

**Iteration im Implement-Skill:** `/implement` Schritt 6a iteriert deklarativ auch ueber Ruff-Findings bis 0 Errors (gleiche 5-Iterations-Heuristik wie ESLint).

---

## .semgrep.yml (alle Stacks)

**SAST-Default-Set seit BOO-3 (2026-05-06):** Drei-Layer-Aufbau — Layer 1 ist universelle Pflicht (security-audit, secrets), Layer 2 ist sprach-spezifisch (auto-erkannt aus `package.json` / `pyproject.toml`), Layer 3 ist optional fuer Web-Projekte (`p/owasp-top-ten`, manuell einkommentieren). Alle Pakete vom Semgrep Registry, MIT-Lizenz, lokal lauffaehig.

> [!important] Manifest-File, kein Semgrep-Native-Config
> `.semgrep.yml` ist hier ein **Manifest-File** — Semgrep's nativer `include`-Key ist eigentlich fuer File-Patterns, nicht fuer Pack-Namen. Pack-Loading laeuft ausschliesslich ueber `--config p/...`-Flags der CLI. Das Manifest wird in BOO-4 vom Pre-Commit-Hook gelesen, der die `include:`-Liste in entsprechende `--config`-Flags umsetzt. `--validate` laeuft durch (das File ist YAML-konform), ein direkter `--config=.semgrep.yml`-Lauf liefert "No config given" — das ist erwartet. Bis BOO-4 done ist, laufen die Packs manuell via z.B. `semgrep --config p/security-audit --config p/secrets`.

**Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` oder `pip install semgrep`).

```yaml
# .semgrep.yml — SAST-Default fuer Governance v2 (BOO-3, v3.2.3)
# Konsumiert von Pre-Commit-Hook (BOO-4) und CI (kuenftig).
rules: []
include:
  # Layer 1 — Pflicht (alle Stacks)
  - p/security-audit
  - p/secrets

  # Layer 2 — Sprach-spezifisch (auto-erkannt aus package.json / pyproject.toml)
  # - p/javascript        # bei Node-/Frontend-Projekten
  # - p/python            # bei Python-Projekten

  # Layer 3 — Optional fuer Web-Projekte (manuell einkommentieren)
  # - p/owasp-top-ten     # bei Web-Frontend, REST-APIs, GraphQL
```

**Sprach-Auto-Erkennung im Auto-Setup:** `migrate_boo_3()` aktiviert `p/javascript` automatisch wenn `package.json` im Repo-Root liegt, `p/python` wenn `pyproject.toml` liegt. Layer 3 bleibt immer kommentiert — Operator entscheidet bewusst pro Projekt.

**Iteration im Implement-Skill:** Geplant in BOO-4 — `/implement` ergaenzt Schritt 6 um einen Semgrep-Pass nach dem ESLint-Pass (gleiche 5-Iterations-Heuristik). Bis BOO-4 done ist, laeuft Semgrep nur als manueller Befehl `semgrep --config=.semgrep.yml`.

---

## .semgrepignore (alle Stacks)

```
# .semgrepignore — Default-Excludes fuer Governance v2 (BOO-3)
node_modules/
dist/
build/
journal/reports/
.venv/
__pycache__/
```

**Begruendung:** `node_modules/` und `.venv/` sind Dependencies (nicht eigener Code), `dist/` und `build/` sind Build-Artefakte (haben eigene Lint-Stage). `journal/reports/` ist vom Self-Healing-Loop generiert (kein Source-Code). `__pycache__/` ist Python-Bytecode-Cache.

---

## .git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)

**Lokal blockierender Pre-Commit-Hook seit BOO-4 (2026-05-06):** Zweite Stufe der Drei-Layer-Quality-Gate-Architektur (ADR vom 2026-04-27). Layer 2 ist der lokale Hook, Layer 3 ist die GitHub Action (`semgrep.yml`, naechster Block). Identische Manifest-Reader-Logik in beiden Layern — `.semgrep.yml` ist die Single Source of Truth fuer aktive Packs.

> [!important] Manifest-Reader, kein Native-Config-Lauf
> Der Hook liest `.semgrep.yml` (Manifest aus BOO-3) zeilenweise mit `grep` + `sed`, extrahiert die aktiven Pack-Namen (Zeilen, die mit `- p/` beginnen — auskommentierte Zeilen mit `# - p/` werden ignoriert) und konstruiert daraus `--config p/...`-Flags. KEIN `yq`, kein YAML-Parser — bewusst nur Bash-Bordmittel, damit der Hook ohne Zusatz-Dependencies laeuft. Wer den Hook via `--no-verify` umgeht, wird im CI-Layer 3 (siehe naechster Block) gefangen.

**Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` auf Mac, `pip install semgrep` auf Linux/VPS). Mac-Operatoren installieren manuell, VPS-Operatoren bekommen Auto-Install in BOO-44.

**Husky-Alternative:** Bei reinen Node-Projekten kann statt `.git/hooks/pre-commit` auch `.husky/pre-commit` verwendet werden — Inhalt identisch. Default ist Native-Hook, weil sprachneutral.

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit — Quality-Gate-Architektur Layer 2 (lokal, blockierend)
# DE: Konsumiert eslint.config.mjs (BOO-2) und .semgrep.yml (BOO-3 Manifest).
# EN: Consumes eslint.config.mjs (BOO-2) and .semgrep.yml (BOO-3 manifest).
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# --- ESLint-Gate (BOO-2) ---
if [[ -f "eslint.config.mjs" ]]; then
    CHANGED_JS=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|mjs|jsx|ts|tsx)$' || true)
    if [[ -n "$CHANGED_JS" ]]; then
        echo "[PRE-COMMIT] ESLint auf $(echo "$CHANGED_JS" | wc -l | tr -d ' ') Datei(en)"
        echo "$CHANGED_JS" | xargs npx eslint --max-warnings=0 || {
            echo "[PRE-COMMIT] ESLint-Gate BLOCKIERT. Findings beheben oder bewusste Ausnahme dokumentieren."
            exit 1
        }
    fi
fi

# --- Semgrep-Gate (BOO-4, Manifest-Reader-Logik) ---
if [[ -f ".semgrep.yml" ]]; then
    # Manifest-Reader: extrahiert aktive Pack-Namen (Layer 1 Pflicht + Layer 2/3 wenn nicht auskommentiert)
    PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//' || true)
    if [[ -n "$PACKS" ]]; then
        ARGS=""
        for pack in $PACKS; do
            ARGS="$ARGS --config $pack"
        done
        echo "[PRE-COMMIT] Semgrep mit Packs: $(echo "$PACKS" | tr '\n' ' ')"
        if ! command -v semgrep >/dev/null 2>&1; then
            echo "[PRE-COMMIT] Semgrep CLI nicht installiert — 'brew install semgrep' (Mac) oder 'pip install semgrep' (Linux)"
            exit 1
        fi
        # shellcheck disable=SC2086
        if ! semgrep $ARGS --error --quiet 2>&1; then
            echo "[PRE-COMMIT] Semgrep-Gate BLOCKIERT. High/Critical Findings beheben."
            exit 1
        fi
    else
        echo "[PRE-COMMIT] .semgrep.yml hat keine aktiven Packs — Gate uebersprungen"
    fi
fi

exit 0
```

**Two-Layer-Logik:** Wer `--no-verify` umgeht, wird im CI-Layer 3 (`.github/workflows/semgrep.yml`) gefangen. Beide Layer lesen dasselbe Manifest — Drift unmoeglich.

---

## .github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)

**CI-Layer seit BOO-4 (2026-05-06):** Dritte Stufe der Drei-Layer-Quality-Gate-Architektur. Spiegel zum Pre-Commit-Hook — identische Manifest-Reader-Logik, identische Pack-Auswahl. Blockiert Merge via Branch-Protection (siehe BOO-29 — Required Status Check `Semgrep`).

**SARIF-Output:** Die GitHub Action schreibt das Ergebnis als SARIF nach `.ci-reports/semgrep.sarif` und uploaded es zusaetzlich als CodeQL-Sarif (GitHub Security-Tab) und als Artefakt (Hermes-Konsumtion in BOO-32).

**Husky-Hinweis:** Husky betrifft nur den Pre-Commit-Layer 2 — die GitHub Action ist davon unabhaengig.

```yaml
# .github/workflows/semgrep.yml — Quality-Gate Layer 3 (CI, blockiert Merge)
# DE: Liest dasselbe .semgrep.yml-Manifest wie der Pre-Commit-Hook.
# EN: Reads the same .semgrep.yml manifest as the pre-commit hook.
name: Semgrep
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container: returntocorp/semgrep
    steps:
      - uses: actions/checkout@v4

      - name: Read manifest and run Semgrep
        run: |
          mkdir -p .ci-reports
          ARGS=""
          while IFS= read -r line; do
              pack=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')
              ARGS="$ARGS --config $pack"
          done < <(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml)
          if [[ -z "$ARGS" ]]; then
              echo "::error::No active packs in .semgrep.yml"
              exit 1
          fi
          # shellcheck disable=SC2086
          semgrep $ARGS --error --sarif --output=.ci-reports/semgrep.sarif

      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: .ci-reports/semgrep.sarif
        if: always()

      - uses: actions/upload-artifact@v4
        with:
          name: semgrep-report
          path: .ci-reports/semgrep.sarif
```

**Two-Layer-Logik:** Beide Layer lesen `.semgrep.yml`. Wenn der Operator den Hook via `--no-verify` umgeht, blockiert spaetestens diese Action den Merge. Wenn die Action gestrippt wird, blockiert der Hook den Commit lokal. Belt-and-Suspenders.

---

## .github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)

**CI-Layer seit BOO-28 (2026-05-12):** Dritter Layer der Quality-Gate-Architektur fuer Linting (Pendant zur Semgrep-Action, anderer Tool-Klasse). Wird in Phase 4.4 des Bootstrap-Flows fuer Stacks `a) Node.js Backend`, `b) Frontend` und `c) Full-Stack` angelegt. Pendant fuer Python ist `ruff.yml` (naechster Block).

**SARIF-Output (Pflicht):** Die Action schreibt das Ergebnis als SARIF nach `.ci-reports/eslint.sarif` und uploaded es via `github/codeql-action/upload-sarif@v3` in den GitHub-Security-Tab. SARIF-Output ist Pflicht — wird in BOO-32 (CI-Output-Standardisierung) fuer Hermes-Konsumtion gelesen.

**SARIF-Formatter:** `@microsoft/eslint-formatter-sarif` muss als devDependency installiert sein — `npm install --save-dev @microsoft/eslint-formatter-sarif`. Wird vom `npm ci`-Step im Workflow automatisch installiert, sobald die devDependency in `package.json` vorhanden ist.

**Branch-Protection:** Required Status Check `eslint` wird in BOO-29 aktiviert — ohne gruene Action kein Merge in `main`.

```yaml
name: ESLint
on: [push, pull_request]
jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: .ci-reports/eslint.sarif }
        if: always()
```

**Two-Layer-Logik:** Pre-Commit-Hook (Layer 2, Phase 4.6) blockiert lokal via `npx eslint --max-warnings=0`, diese Action (Layer 3) blockiert CI. Wer den Hook via `--no-verify` umgeht, wird in Layer 3 gefangen.

---

## .github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)

**CI-Layer seit BOO-28 (2026-05-12):** Python-Pendant zur ESLint-Action (vorheriger Block). Wird in Phase 4.4 des Bootstrap-Flows fuer Stack `d) Python` angelegt.

**SARIF-Output (Pflicht):** Ruff hat seit Version 0.5 nativen SARIF-Support via `--output-format=sarif`. Die Action schreibt nach `.ci-reports/ruff.sarif` und uploaded via `github/codeql-action/upload-sarif@v3`. Wird in BOO-32 fuer Hermes-Konsumtion gelesen.

**Branch-Protection:** Required Status Check `ruff` wird in BOO-29 aktiviert (analog `eslint` fuer Node-Projekte).

```yaml
name: Ruff
on: [push, pull_request]
jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install ruff
      - run: |
          mkdir -p .ci-reports
          ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: .ci-reports/ruff.sarif }
        if: always()
```

**Two-Layer-Logik:** Analog zu ESLint — Pre-Commit-Hook (Layer 2) ruft `ruff check` lokal auf, diese Action (Layer 3) blockiert CI.

---

## hooks/dependency-check.sh (BOO-12 — Slopsquatting-Schutz)

**Drittes Gate im Pre-Commit-Hook seit BOO-12 (2026-05-06):** Eigenstaendiges Bash-Skript unter `.claude/hooks/dependency-check.sh`, vom Pre-Commit-Hook (BOO-4) als drittes Gate nach ESLint und Semgrep aufgerufen. Pruefung neu hinzugefuegter Dependencies in drei Stufen: Existenz (Halluzinations-Block), Age (Typosquatter-Warnung), CVE (Vulnerability-Block).

> [!important] Schrader Code Crash Kap. 3-4
> 19,7 % der KI-empfohlenen Pakete existieren nicht — Slopsquatting ist ein eigener Angriffsvektor. Angreifer registrieren typosquatted oder von KI halluzinierte Package-Namen mit Malware. ESLint und Semgrep pruefen Code, aber nicht die Supply Chain — dieser Hook schliesst diese Luecke vor dem Commit.

**Voraussetzungen:** `curl` ist Standard auf Mac/Linux (vorhanden). Optional: `npm` (Node-Projekte — fuer schnelleren Existenz-/Age-Lookup und CVE-Pruefung), `pip-audit` (Python — fuer CVE-Pruefung). Bei fehlendem Tool faellt das Skript auf einen curl-Fallback gegen die Registry-API zurueck. KEIN `yq`, KEIN `jq` — bewusst nur Bash-Bordmittel + `grep`/`sed`/`awk`.

**Performance:** Hook laeuft nur, wenn `package.json`, `requirements.txt`, `pyproject.toml` oder `Cargo.toml` im Diff der gestagten Files ist. Bei reinen Code-Commits sofort `exit 0` — kein Registry-Roundtrip.

**Cargo-Status:** Aktuell nur Erkennung mit Operator-Hinweis (`cargo audit` manuell). Cargo-Vollunterstuetzung folgt in zukuenftiger Iteration.

```bash
#!/usr/bin/env bash
# hooks/dependency-check.sh — Slopsquatting-Schutz (BOO-12)
# DE: Drei-Stufen-Check fuer neu hinzugefuegte Dependencies — Existenz, Age, CVE.
#     Schrader Code Crash Kap. 3-4: 19,7% der KI-empfohlenen Pakete existieren nicht.
# EN: Three-stage check for newly added dependencies — existence, age, CVE.
#     Schrader Code Crash ch. 3-4: 19.7% of AI-recommended packages don't exist.
set -euo pipefail

# --- Trigger-Detection: laeuft nur wenn Manifest-Datei im Diff ---
CHANGED=$(git diff --cached --name-only --diff-filter=ACMR)
TRIGGERS_NPM=$(echo "$CHANGED" | grep -E '^package\.json$' || true)
TRIGGERS_PIP=$(echo "$CHANGED" | grep -E '^(requirements\.txt|pyproject\.toml)$' || true)
TRIGGERS_CARGO=$(echo "$CHANGED" | grep -E '^Cargo\.toml$' || true)

if [[ -z "$TRIGGERS_NPM" && -z "$TRIGGERS_PIP" && -z "$TRIGGERS_CARGO" ]]; then
    exit 0  # Kein Manifest-Diff — Hook ueberspringen
fi

AGE_THRESHOLD_DAYS=30
BLOCKED=0

# --- Helfer: extrahiert NEU hinzugefuegte Dependency-Namen aus package.json-Diff ---
extract_new_npm_deps() {
    # POSIX-konform (BSD-grep/sed-kompatibel): match nur "+"-Zeilen mit
    # "key": "version-wert" — Wert muss mit Versionsnummer beginnen
    # (optional ^, ~, >=, <= prefix). Filtert Top-Level-"version" raus.
    git diff --cached package.json 2>/dev/null \
        | grep -E '^\+[[:space:]]+"[^"]+":[[:space:]]*"[~^>=<]?[0-9]' \
        | sed -E 's/^\+[[:space:]]+"([^"]+)":.*/\1/' \
        | grep -vE '^(version)$' \
        || true
}

extract_new_pypi_deps() {
    # requirements.txt: extrahiert NEU hinzugefuegte Zeilen (Paket==version oder Paket>=version)
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "requirements.txt"; then
        git diff --cached requirements.txt 2>/dev/null \
            | grep -E '^\+[a-zA-Z]' \
            | sed -E 's/^\+([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
    # pyproject.toml: extrahiert dependencies/optional-dependencies
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "pyproject.toml"; then
        git diff --cached pyproject.toml 2>/dev/null \
            | grep -E '^\+[[:space:]]+"[a-zA-Z]' \
            | sed -E 's/^\+[[:space:]]+"([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
}

# --- Check 1: Existenz ---
check_npm_existence() {
    local pkg="$1"
    if command -v npm >/dev/null 2>&1; then
        if npm view "$pkg" name >/dev/null 2>&1; then
            return 0  # existiert
        else
            return 1  # 404
        fi
    else
        # curl-Fallback
        if curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

check_pypi_existence() {
    local pkg="$1"
    if curl -fsSL --max-time 5 "https://pypi.org/pypi/$pkg/json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# --- Check 2: Age ---
check_npm_age() {
    local pkg="$1"
    local created
    if command -v npm >/dev/null 2>&1; then
        created=$(npm view "$pkg" time.created 2>/dev/null || echo "")
    else
        created=$(curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" 2>/dev/null \
            | grep -oE '"created":"[^"]+"' | head -1 | sed -E 's/"created":"([^"]+)"/\1/' || echo "")
    fi
    [[ -z "$created" ]] && return 0  # kein Datum — kein Warn
    local pkg_epoch
    pkg_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%.*}" +"%s" 2>/dev/null || \
                date -d "$created" +"%s" 2>/dev/null || echo "0")
    [[ "$pkg_epoch" == "0" ]] && return 0
    local now_epoch days
    now_epoch=$(date +"%s")
    days=$(( (now_epoch - pkg_epoch) / 86400 ))
    if (( days < AGE_THRESHOLD_DAYS )); then
        echo "[DEP-CHECK] WARNUNG: Paket '$pkg' ist nur $days Tage alt — Typosquatter-Risiko, manuell verifizieren"
    fi
    return 0
}

# --- Check 3: CVE ---
check_npm_cve() {
    if command -v npm >/dev/null 2>&1 && [[ -f "package-lock.json" ]]; then
        local audit_output
        audit_output=$(npm audit --audit-level=high 2>&1 || true)
        if echo "$audit_output" | grep -qE 'high|critical'; then
            echo "[DEP-CHECK] BLOCK: npm audit meldet High/Critical Vulnerabilities. Lauf 'npm audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

check_pypi_cve() {
    if command -v pip-audit >/dev/null 2>&1; then
        local audit_output
        audit_output=$(pip-audit --strict 2>&1 || true)
        if echo "$audit_output" | grep -qiE 'vulnerability|cve'; then
            echo "[DEP-CHECK] BLOCK: pip-audit meldet Vulnerabilities. Lauf 'pip-audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

# --- Hauptlauf ---
echo "[DEP-CHECK] Slopsquatting-Schutz aktiv"

if [[ -n "$TRIGGERS_NPM" ]]; then
    NEW_NPM=$(extract_new_npm_deps)
    for pkg in $NEW_NPM; do
        if ! check_npm_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: npm-Paket '$pkg' existiert nicht in der Registry — Halluzination?"
            BLOCKED=1
        else
            check_npm_age "$pkg"
        fi
    done
    check_npm_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_PIP" ]]; then
    NEW_PYPI=$(extract_new_pypi_deps)
    for pkg in $NEW_PYPI; do
        if ! check_pypi_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: PyPI-Paket '$pkg' existiert nicht — Halluzination?"
            BLOCKED=1
        fi
    done
    check_pypi_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_CARGO" ]]; then
    echo "[DEP-CHECK] HINWEIS: Cargo-Diff erkannt — Cargo-Check wird in zukuenftiger Iteration ergaenzt. Operator: 'cargo audit' manuell laufen lassen."
fi

if (( BLOCKED == 1 )); then
    echo "[DEP-CHECK] Gate BLOCKIERT. Slopsquatting-Risiko vermeiden — Pakete verifizieren, dann erneut committen."
    exit 1
fi

echo "[DEP-CHECK] Gate bestanden"
exit 0
```

**Drei-Layer-Architektur erweitert:** Quality-Gate Layer 2 (`.git/hooks/pre-commit`) bekommt mit BOO-12 einen vierten Aufruf nach ESLint und Semgrep: `bash .claude/hooks/dependency-check.sh`. Layer 3 (CI) bleibt unveraendert — Slopsquatting-Schutz ist bewusst pre-commit-only, weil ein Halluzinations-Paket gar nicht erst in den Branch gelangen soll.

**Anti-Patterns:**
- KEIN Auto-Install von `pip-audit` oder `npm` — Operator-Verantwortung. Hook bleibt sprachneutral.
- KEINE Pflicht-Dependency wie `yq`/`jq` — Bash + `grep`/`sed`/`awk` + `curl` reichen.
- KEIN Block bei Cargo-Diff — nur Hinweis, weil Cargo-Vollunterstuetzung in spaeterer Iteration.

---

## hooks/coverage-check.sh (BOO-15 — Coverage-Gate >=80% fuer neuen Code)

**Viertes Gate seit BOO-15 (2026-05-06), aber NICHT im Pre-Commit-Hook:** Eigenstaendiges Bash-Skript unter `.claude/hooks/coverage-check.sh`, vom `/implement`-Skill in Schritt 6a-quart aufgerufen — nicht vom Pre-Commit-Hook, weil ein voller Test-Lauf das 10s-Budget des Hooks sprengen wuerde. Das Skript korreliert die NEU hinzugefuegten Zeilen aus `git diff --cached -U0` mit Coverage-Daten aus `coverage/coverage-final.json` (c8) bzw. `coverage.json` (pytest-cov) und entscheidet anhand drei Schwellwerten.

> [!important] Schrader Code Crash Kap. 3 §Production Readiness — Gate 2
> Testabdeckung >=80 % auf neuem Code, nicht Gesamt-Coverage. Gesamt-Coverage auf Legacy-Repos ist unfair: ein gut getestetes Feature kann durch grosse ungetestete Altlasten unter den Schwellwert rutschen. Diff-Coverage misst nur das, wofuer der aktuelle Commit verantwortlich ist.

**Voraussetzungen:** Test-Tooling lauffaehig — `npx c8 npm test` (Node) oder `pytest --cov` (Python) muss vor dem Hook gelaufen sein und JSON-Output erzeugt haben. `python3` wird fuer das JSON-Parsing verwendet (Standard auf Mac/Linux). KEIN `jq`, KEIN `yq`, KEINE npm/pip-Coverage-Dependency wie `@connectis/diff-test-coverage` oder `diff-cover` — Custom-Bash-Parser plus Python-Helfer fuer JSON.

**Drei Schwellwerte (env-overridable):**
- `COVERAGE_PASS=80` — Diff-Coverage >=80% bestanden, weiter zu 6b.
- `COVERAGE_WARN=60` — 60-80% Warnung, Operator-Freigabe mit Begruendung im Linear-Kommentar.
- `<60%` — Gate BLOCKIERT, Tests hinzufuegen oder Story splitten.
- Keine Test-Infra (kein JSON-Coverage-File): Gate uebersprungen mit Hinweis "/bootstrap nachziehen".

**Performance:** Skript-Lauf <2 Sekunden auch bei groesseren Diffs (serielle Per-File-Coverage-Lookups, gecached pro File). Test-Lauf selbst kann mehrere Minuten dauern — daher bewusst aus dem Pre-Commit-Hook ausgelagert.

**Konfigurierbar:** `COVERAGE_PASS=90 COVERAGE_WARN=70 bash .claude/hooks/coverage-check.sh` ueberschreibt die Defaults pro Lauf.

```bash
#!/usr/bin/env bash
# hooks/coverage-check.sh — Diff-Coverage-Gate (BOO-15)
# DE: Misst Coverage nur auf NEU hinzugefuegten Zeilen (git diff --added)
#     gegen coverage-final.json (c8) bzw. coverage.json (pytest-cov).
#     Schrader Code Crash Kap. 3: Gesamt-Coverage auf Legacy-Repos ist unfair.
# EN: Measures coverage only on NEWLY added lines (git diff --added) against
#     coverage-final.json (c8) or coverage.json (pytest-cov). Schrader Code
#     Crash ch. 3: total coverage on legacy repos is unfair.
set -euo pipefail

# --- Konfiguration (env-overridable) ---
COVERAGE_PASS="${COVERAGE_PASS:-80}"
COVERAGE_WARN="${COVERAGE_WARN:-60}"

# --- Coverage-File-Detection ---
COVERAGE_FILE=""
COVERAGE_TOOL=""

if [[ -f "coverage/coverage-final.json" ]]; then
    COVERAGE_FILE="coverage/coverage-final.json"
    COVERAGE_TOOL="c8"
elif [[ -f "coverage.json" ]]; then
    COVERAGE_FILE="coverage.json"
    COVERAGE_TOOL="pytest-cov"
elif [[ -f ".coverage" || -f "coverage/.coverage" ]]; then
    echo "[COVERAGE] HINWEIS: pytest-cov-SQLite gefunden, aber kein JSON-Export. Lauf 'pytest --cov --cov-report=json' fuer Diff-Coverage."
    exit 0
else
    echo "[COVERAGE] Keine Coverage-Daten gefunden — Gate uebersprungen."
    echo "[COVERAGE] Hinweis: Test-Setup fehlt — ggf. /bootstrap nachziehen oder 'npx c8 npm test' / 'pytest --cov --cov-report=json' laufen lassen."
    exit 0
fi

echo "[COVERAGE] Tool: $COVERAGE_TOOL, Datei: $COVERAGE_FILE, Schwellwerte: pass=$COVERAGE_PASS%, warn=$COVERAGE_WARN%"

# --- Added-Lines extrahieren (nur "+"-Zeilen, NICHT modifizierte) ---
# git diff -U0 zeigt nur die geanderten Zeilen ohne Kontext.
# diff-filter=A waere strenger (nur neue Files), aber wir wollen auch
# neue Funktionen in alten Files erfassen → wir nehmen alle "+"-Zeilen
# (ohne den +++/--- Header).

# Format: file_path:line_number pro Zeile
extract_added_lines() {
    git diff --cached -U0 --no-color 2>/dev/null \
        | awk '
            /^\+\+\+ b\// { file = substr($0, 7); next }
            /^@@ / {
                # @@ -old,oldcount +new,newcount @@
                n = split($0, parts, " ")
                for (i = 1; i <= n; i++) {
                    if (parts[i] ~ /^\+[0-9]+/) {
                        sub(/^\+/, "", parts[i])
                        split(parts[i], nums, ",")
                        start = nums[1] + 0
                        count = (nums[2] == "") ? 1 : (nums[2] + 0)
                        for (j = 0; j < count; j++) print file ":" (start + j)
                        break
                    }
                }
                next
            }
        '
}

# --- Per-File-Coverage aus JSON parsen (Python-Helper, weil JSON in Bash schmerzhaft) ---
# c8 Format: { "file_path": { "s": {"0": 1, "1": 0, ...}, "statementMap": {"0": {"start": {"line": N}}}}}
# pytest-cov Format: { "files": { "file_path": { "executed_lines": [...], "missing_lines": [...] }}}

parse_covered_lines_c8() {
    local file="$1"
    python3 - "$COVERAGE_FILE" "$file" <<'PYEOF'
import json, sys
cov_file, target = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(cov_file))
except Exception as e:
    sys.exit(0)
target_abs = target.lstrip("./")
for k, v in data.items():
    if k.endswith(target_abs) or k.endswith(target):
        stmts = v.get("statementMap", {})
        counts = v.get("s", {})
        for stmt_id, loc in stmts.items():
            line = loc.get("start", {}).get("line")
            if line and counts.get(stmt_id, 0) > 0:
                print(line)
        break
PYEOF
}

parse_covered_lines_pytest() {
    local file="$1"
    python3 - "$COVERAGE_FILE" "$file" <<'PYEOF'
import json, sys
cov_file, target = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(cov_file))
except Exception:
    sys.exit(0)
files = data.get("files", {})
target_norm = target.lstrip("./")
for k, v in files.items():
    if k.endswith(target_norm) or k.endswith(target):
        for line in v.get("executed_lines", []):
            print(line)
        break
PYEOF
}

# --- Hauptlauf ---
ADDED=$(extract_added_lines)

if [[ -z "$ADDED" ]]; then
    echo "[COVERAGE] Keine neu hinzugefuegten Zeilen im Diff — Gate uebersprungen."
    exit 0
fi

TOTAL_ADDED=0
COVERED_ADDED=0

# Per-File aggregieren
declare -A FILES_SEEN
while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    file="${entry%:*}"
    line="${entry##*:}"

    # Nur Source-Files: js/mjs/ts/tsx/jsx/py — nicht Tests, nicht Configs
    if ! echo "$file" | grep -qE '\.(js|mjs|ts|tsx|jsx|py)$'; then
        continue
    fi
    if echo "$file" | grep -qE '(^test|/test|_test\.|\.test\.|\.spec\.|tests/|__tests__|conftest\.py)'; then
        continue
    fi

    # Per-File einmal Coverage-Daten holen (cache)
    if [[ -z "${FILES_SEEN[$file]:-}" ]]; then
        if [[ "$COVERAGE_TOOL" == "c8" ]]; then
            FILES_SEEN[$file]="$(parse_covered_lines_c8 "$file" | tr '\n' ' ')"
        else
            FILES_SEEN[$file]="$(parse_covered_lines_pytest "$file" | tr '\n' ' ')"
        fi
    fi

    TOTAL_ADDED=$(( TOTAL_ADDED + 1 ))
    if echo " ${FILES_SEEN[$file]} " | grep -qw "$line"; then
        COVERED_ADDED=$(( COVERED_ADDED + 1 ))
    fi
done <<< "$ADDED"

if (( TOTAL_ADDED == 0 )); then
    echo "[COVERAGE] Keine bewertbaren neuen Zeilen (alles Tests/Configs) — Gate uebersprungen."
    exit 0
fi

# --- Verhaeltnis berechnen + Gate ---
PCT=$(( (COVERED_ADDED * 100) / TOTAL_ADDED ))

echo "[COVERAGE] Diff-Coverage: $COVERED_ADDED / $TOTAL_ADDED added lines = ${PCT}%"

if (( PCT >= COVERAGE_PASS )); then
    echo "[COVERAGE] Gate bestanden (>=${COVERAGE_PASS}%)"
    exit 0
elif (( PCT >= COVERAGE_WARN )); then
    echo "[COVERAGE] WARNUNG: Diff-Coverage ${PCT}% liegt unter ${COVERAGE_PASS}% (Pass-Schwelle), aber ueber ${COVERAGE_WARN}% (Warn-Schwelle)."
    echo "[COVERAGE] Operator-Freigabe moeglich mit Begruendung im Linear-Kommentar."
    exit 0
else
    echo "[COVERAGE] Gate BLOCKIERT: Diff-Coverage ${PCT}% liegt unter ${COVERAGE_WARN}% (Warn-Schwelle)."
    echo "[COVERAGE] Tests hinzufuegen oder Story splitten."
    exit 1
fi
```

**Anti-Patterns:**
- KEINE `@connectis/diff-test-coverage` als npm-Dependency — Custom-Bash-Parser bleibt sprachneutral.
- KEINE `diff-cover` als Python-Dependency — selber Grund.
- KEIN Aufruf im Pre-Commit-Hook (`.git/hooks/pre-commit`) — Tests dauern zu lange, sprengen das 10s-Budget. Wird ausschliesslich vom `/implement`-Skill in Schritt 6a-quart aufgerufen.
- KEIN Block bei nur-Test-/Config-/Doc-Diffs — Gate uebersprungen.

---

## .claude/environment.json (BOO-34 — Skill-Umgebungs-Awareness)

**Single Source of Truth fuer Umgebung, Tooling und Pfade seit BOO-34 (2026-05-06):** Ein Manifest pro Projekt, das jeder Skill in einem Schritt-0-Read auswertet, statt selbst Detection-Logik zu fahren. Drei Umgebungen (`mac` | `vps` | `ci`), eine Tool-Verfuegbarkeitsmatrix (eslint, semgrep, Test-Framework, SonarQube), Default-Pfade fuer Journal/Reports/Lessons/Specs.

> [!important] Warum eine Datei statt Detection pro Skill?
> Vor BOO-34 hat jeder Skill (implement, sprint-review, breakfix, ...) `uname` / `command -v` selbst aufgerufen — duplizierte Logik, inkonsistent gewartet. Mit `.claude/environment.json` fragt der Skill nur noch `cat .claude/environment.json | grep '"semgrep"'`. Generiert wird die Datei einmalig vom Bootstrap-Skill in Phase 4.4e und kann jederzeit per `--force` neu erzeugt werden, wenn sich die Umgebung aendert (z.B. Mac-Operator pusht erstmals auf VPS, Tooling neu installiert).

**Schema (Single Source of Truth fuer Felder und Werte):**

```json
{
  "environment": "mac",
  "tools_available": {
    "eslint": true,
    "semgrep": true,
    "tests": "vitest",
    "sonarqube_ide_plugin": false,
    "sonarqube_cloud": true
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "2026-05-06T14:30:00Z",
    "bootstrap_version": "3.3.0",
    "stack": "node-typescript"
  }
}
```

**Felder:**

| Feld | Typ | Werte / Beschreibung |
|------|-----|---------------------|
| `environment` | string | `mac` (Darwin), `vps` (Linux ohne `$CI`), `ci` (env-var `CI` gesetzt — egal welcher Wert) |
| `tools_available.eslint` | bool | true wenn `command -v eslint` ODER lokal in `node_modules` (via `npm ls eslint`) |
| `tools_available.semgrep` | bool | true wenn `command -v semgrep` |
| `tools_available.tests` | string\|null | `"vitest"` / `"jest"` / `"mocha"` / `"pytest"` / `null` — erkannt aus `package.json` bzw. `pyproject.toml` |
| `tools_available.sonarqube_ide_plugin` | bool | Default `false`. CLI nicht erkennbar — Operator setzt manuell auf `true` wenn SonarLint VS-Code-Plugin aktiv. |
| `tools_available.sonarqube_cloud` | bool | Hardcoded `true` — Cloud-API ist von ueberall erreichbar. Zeigt nur "darf der Skill SonarCloud rufen?". Manuell auf `false` setzen wenn Projekt SonarCloud nicht nutzt. |
| `paths.*` | string | Default-Pfade relativ zum Projekt-Root. Skills lesen ueber diese Keys statt hardcoded Strings. |
| `thresholds.architecture_doc_freshness_days` | int | Default `30`. Maximales Alter (in Tagen) der `ARCHITECTURE_DESIGN.md`, bevor `/ideation` Schritt 0a einen weichen Pre-Flight-Reminder zeigt. Schnell evolvierende Systeme: 14. Stabile Systeme: 90. |
| `thresholds.token_warn_threshold` | int | Default `70`. Prozentwert des Context-Windows, ab dem `/implement` Schritt 0b einen weichen Hinweis zeigt ("noch eine kleine Story passt rein"). |
| `thresholds.token_hard_threshold` | int | Default `80`. Prozentwert ab dem `/implement` Schritt 0b Sprint-Ende empfiehlt (Sprint-Box-Grenze laut HANDBUCH Anhang G). Operator kann mit bewusster Entscheidung weiter — Vermerk landet in `meta.json.pre_flight_warning`. |
| `metadata.created_at` | string | ISO-8601 UTC, gesetzt beim ersten Generator-Lauf. |
| `metadata.bootstrap_version` | string | Aktive Bootstrap-Version zum Generator-Zeitpunkt. |
| `metadata.stack` | string | `node-typescript` / `node-javascript` / `python` / `mixed` / `unknown` — analog BOO-3-Stack-Detection. |

**Reihenfolge der `environment`-Detection ist entscheidend:** CI-Check ZUERST, dann Mac, dann VPS — ein CI-Runner kann Linux **oder** Mac sein. Wuerde der Skill zuerst auf Darwin pruefen, wuerde ein Mac-CI-Job faelschlich als `mac` markiert.

**Konsumiert von:** Allen Sub-Skills via Schritt-0-Read (Rollout in BOO-34 Sub-Agent #2). Beispiel-Pattern fuer einen Skill:

```bash
# Schritt 0: Environment lesen
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
    REPORTS_DIR=$(grep '"reports_local"' "$ENV_FILE" | sed -E 's/.*: "([^"]+)".*/\1/')
fi
```

**Anti-Patterns:**
- KEIN `jq` als Pflicht-Dependency — `grep` + `sed` reichen fuer die wenigen Reads, die ein Skill braucht. `jq` ist auf VPS/CI nicht garantiert, auf Mac muss `brew install jq` laufen. (Im HANDBUCH wird `jq` als optionaler Reader-Komfort erwaehnt.)
- KEIN Auto-Refresh bei Skill-Lauf — die Datei wird nur vom Bootstrap und manuellem `--force` geschrieben. Skills lesen ausschliesslich.
- KEIN Schreiben aus Sub-Skills heraus — Single Source of Truth bleibt der Generator. Sub-Agent #2 baut nur Reads ein.

---

## .claude/generate-environment-json.sh (BOO-34)

**Bash-Generator fuer das Environment-Manifest, BSD- und Linux-kompatibel.** Wird vom Bootstrap-Skill in Phase 4.4e aufgerufen, kann manuell mit `--force` neu erzeugt werden. Idempotent: schreibt nur, wenn die Datei fehlt oder `--force` gesetzt ist.

> [!important] Keine externen Dependencies
> Nur `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date` (POSIX-Standard) — explizit KEIN `jq`, KEIN `yq`, KEIN `python3`. JSON wird per Heredoc geschrieben. Damit laeuft der Generator auf jedem Mac-Operator-Geraet und jedem VPS/CI-Linux ohne Setup.

**BSD-Kompatibilitaet (PFLICHT):** `[[:space:]]+` statt `\s+`, `[[:digit:]]` statt `\d`, `grep -E` statt `grep -P`, `sed` ohne `-i` (wir schreiben Tempfile via Heredoc statt In-Place-Edit). Lauft auf macOS Darwin **und** Linux.

```bash
#!/usr/bin/env bash
# .claude/generate-environment-json.sh — Environment-Awareness-Generator (BOO-34)
# DE: Erzeugt .claude/environment.json mit Detection von Mac/VPS/CI, verfuegbaren
#     Tools (eslint, semgrep, Test-Framework) und Standard-Pfaden. BSD- und
#     Linux-kompatibel, ohne Abhaengigkeiten ausser bash, uname, command, cat,
#     grep, sed, date.
# EN: Generates .claude/environment.json with Mac/VPS/CI detection, available
#     tools (eslint, semgrep, test framework) and default paths. BSD- and
#     Linux-compatible, no deps beyond bash, uname, command, cat, grep, sed, date.
set -euo pipefail

# --- CLI-Flags ---
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --help|-h)
            cat <<'HLP'
Usage: bash .claude/generate-environment-json.sh [--force]
  --force   Overwrite existing .claude/environment.json
HLP
            exit 0 ;;
    esac
done

OUT=".claude/environment.json"
mkdir -p .claude

if [[ -f "$OUT" && $FORCE -eq 0 ]]; then
    echo "[ENV] $OUT existiert bereits — Skip (use --force to overwrite)."
    exit 0
fi

# --- environment: ci > mac > vps ---
# CI-Check ZUERST: ein CI-Runner kann Linux ODER Mac sein.
if [[ -n "${CI:-}" ]]; then
    ENVIRONMENT="ci"
elif [[ "$(uname -s)" = "Darwin" ]]; then
    ENVIRONMENT="mac"
else
    ENVIRONMENT="vps"
fi

# --- tools_available ---
# eslint: command -v ODER lokal in node_modules
HAS_ESLINT="false"
if command -v eslint >/dev/null 2>&1; then
    HAS_ESLINT="true"
elif [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
    if npm ls eslint --silent >/dev/null 2>&1; then
        HAS_ESLINT="true"
    fi
fi

# semgrep: nur via command -v (PATH)
HAS_SEMGREP="false"
if command -v semgrep >/dev/null 2>&1; then
    HAS_SEMGREP="true"
fi

# tests: erkennen aus package.json (vitest/jest/mocha) oder pyproject.toml (pytest)
TESTS="null"
if [[ -f "package.json" ]]; then
    if grep -q '"vitest"' package.json 2>/dev/null; then
        TESTS='"vitest"'
    elif grep -q '"jest"' package.json 2>/dev/null; then
        TESTS='"jest"'
    elif grep -q '"mocha"' package.json 2>/dev/null; then
        TESTS='"mocha"'
    fi
fi
if [[ "$TESTS" = "null" && -f "pyproject.toml" ]]; then
    if grep -qE '(pytest|^\[tool\.pytest)' pyproject.toml 2>/dev/null; then
        TESTS='"pytest"'
    fi
fi

# sonarqube_ide_plugin: nicht erkennbar via CLI — Default false, Operator ergaenzt manuell auf Mac.
SONAR_IDE="false"

# sonarqube_cloud: true wenn sonar-project.properties im Projekt-Root vorhanden.
# Bootstrap setzt es auf false wenn D.5 abgelehnt. Auf true wenn sonar-project.properties existiert.
if [ -f "sonar-project.properties" ]; then
  SONAR_CLOUD="true"
else
  SONAR_CLOUD="false"
fi

# --- metadata.stack: analog BOO-3 Semgrep-Stack-Erkennung ---
HAS_PKG=0
HAS_PY=0
[[ -f "package.json" ]] && HAS_PKG=1
[[ -f "pyproject.toml" ]] && HAS_PY=1

if [[ $HAS_PKG -eq 1 && $HAS_PY -eq 1 ]]; then
    STACK="mixed"
elif [[ $HAS_PKG -eq 1 ]]; then
    # TS vs JS: tsconfig.json oder "typescript" als devDep
    if [[ -f "tsconfig.json" ]] || grep -q '"typescript"' package.json 2>/dev/null; then
        STACK="node-typescript"
    else
        STACK="node-javascript"
    fi
elif [[ $HAS_PY -eq 1 ]]; then
    STACK="python"
else
    STACK="unknown"
fi

# --- metadata.created_at: ISO-8601 UTC ---
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# --- metadata.bootstrap_version: aktuelle Bootstrap-Version ---
BOOTSTRAP_VERSION="3.3.0"

# --- JSON via Heredoc (kein jq noetig) ---
cat > "$OUT" <<EOF
{
  "environment": "${ENVIRONMENT}",
  "tools_available": {
    "eslint": ${HAS_ESLINT},
    "semgrep": ${HAS_SEMGREP},
    "tests": ${TESTS},
    "sonarqube_ide_plugin": ${SONAR_IDE},
    "sonarqube_cloud": ${SONAR_CLOUD}
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "${CREATED_AT}",
    "bootstrap_version": "${BOOTSTRAP_VERSION}",
    "stack": "${STACK}"
  }
}
EOF

echo "[ENV] $OUT geschrieben (environment=${ENVIRONMENT}, stack=${STACK})."
```

**Tests-Hinweis:** Skript muss auf macOS Darwin **und** Linux laufen, ohne externe Deps ausser `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`. **Kein** `jq` (nicht ueberall installiert) — JSON wird per Heredoc geschrieben.

**Re-Generierung:** Wenn sich die Tooling-Lage aendert (z.B. `brew install semgrep` nachinstalliert, Test-Framework gewechselt von Jest auf Vitest), `bash .claude/generate-environment-json.sh --force` ausfuehren. Die Datei selbst sollte committed werden — `metadata.created_at` ist Audit-Spur fuer "wann hat dieses Projekt mit welcher Tooling-Annahme gearbeitet".

**Anti-Patterns:**
- KEIN automatisches Re-Run bei jedem Skill-Lauf — Datei ist Snapshot, nicht Live-Detection.
- KEIN `git add` aus dem Generator heraus — Operator entscheidet bewusst, ob committed oder gitignored.
- KEINE projekt-spezifischen Pfad-Overrides im Generator — Defaults sind Defaults; wenn ein Projekt eigene Pfade braucht, editiert der Operator die Datei nach dem ersten Generate.

---

## observability.md (BOO-14 — Observability-Skelett)

**Zentrale Observability-Doku im Projekt-Root**, eine Sektion pro Service. Definiert Logging-Schema, Metrics-Endpoint-Konvention, Alert-Rules-Verzeichnis und konkrete Beispiele fuer Node.js und Python. Wird beim Bootstrap einmalig angelegt und mit jedem neuen Service erweitert.

> [!important] Warum eine zentrale Datei?
> Operator und Skills brauchen einen einzigen Ort, an dem "was wird geloggt, was wird gemetrict, was alarmiert" steht. Pro-Service-Sektionen statt verstreute READMEs in jedem Service-Ordner — sonst driftet das Schema auseinander, sobald zwei Services sich unterscheiden duerfen ("bei uns ist das halt so"). Single Source of Truth, vom `architecture-review`-Skill und vom Operator gleichermassen lesbar.

**Stack-Scope:** nur Node.js und Python. Frontend hat keinen Server-Metrics-Endpoint — Frontend-Logs gehen ueber das Backend (oder Sentry / vergleichbar) und werden nicht in `observability.md` als eigener Service dokumentiert. Hinweis im Template (siehe unten).

```markdown
---
purpose: Observability-Skelett (Logging, Metrics, Alerts) pro Service
services: [auth-service]
last_updated: {{TODAY}}
metrics_port_base: 9091
logging_schema_version: 1
---

# Observability — {{PROJECT_NAME}}

Diese Datei dokumentiert das Observability-Skelett: **Logging-Schema**, **Metrics-Endpoint-Konvention** und **Alert-Rules** pro Service. Eine Sektion pro Service — Schema bleibt fuer alle Services identisch.

> [!note] Frontend
> Frontend-Apps haben **keinen** Server-Metrics-Endpoint. Frontend-Fehler und -Events gehen ueber das Backend (strukturierte Logs mit `service: "<frontend-app>"` plus `client_session_id`) oder ueber einen externen Error-Tracker (Sentry, Bugsnag, ...). Frontend wird daher hier **nicht** als eigene Pro-Service-Sektion gefuehrt.

---

## Logging-Schema (Pflicht-Felder)

Jeder Log-Eintrag (egal ob Node.js oder Python) ist **strukturiertes JSON** mit folgenden Pflicht-Feldern:

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `timestamp` | string (ISO 8601) | UTC, Millisekunden-Praezision (`2026-05-07T14:30:00.123Z`) |
| `level` | string | `debug` \| `info` \| `warn` \| `error` \| `fatal` |
| `service` | string | Service-Name aus dem Architecture-Block (z.B. `auth-service`) |
| `trace_id` | string | UUID v4 ODER W3C Trace Context Trace-ID — pro Request konstant |
| `message` | string | kurze, human-readable Zusammenfassung (kein Stacktrace) |
| `context` | object | strukturiertes JSON-Objekt mit zusaetzlichen Feldern (user_id, request_path, error_code, ...) |

**Beispiel-Output (eine Zeile, hier formatiert):**

```json
{
  "timestamp": "2026-05-07T14:30:00.123Z",
  "level": "error",
  "service": "auth-service",
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Login failed: invalid credentials",
  "context": {
    "user_id": "u_42",
    "request_path": "/api/login",
    "error_code": "INVALID_CREDENTIALS",
    "ip": "203.0.113.5"
  }
}
```

> [!important] Keine Klartext-Logs
> Logger werden **niemals** mit `console.log` / `print` / unstrukturiertem Format konfiguriert — Aggregation und Suche brechen sonst zusammen. Pflicht: pino (Node) bzw. structlog (Python) mit JSON-Renderer (siehe Stack-Beispiele unten).

---

## Metrics-Endpoint (Port-Konvention)

Jeder Service exponiert einen Prometheus-kompatiblen Metrics-Endpoint unter `GET /metrics`. **Port-Konvention:** `9090 + N`, wobei N pro Service hochgezaehlt wird.

| Service | Port | Metrics-URL |
|---------|------|-------------|
| (erster Service) | `9091` | `http://localhost:9091/metrics` |
| (zweiter Service) | `9092` | `http://localhost:9092/metrics` |
| (n-ter Service) | `9090 + n` | ... |

> [!note] Operator-Hinweis
> Wenn ein neuer Service hinzukommt, naechsten freien Port aus der Tabelle nehmen und den Eintrag pflegen. Prometheus-`scrape_configs` greift auf diese Tabelle als Single Source of Truth zu.

**Pflicht-Metriken pro Service:**

| Metrik | Typ | Labels | Zweck |
|--------|-----|--------|-------|
| `{service}_up` | Gauge (0/1) | — | Liveness-Heartbeat — `1` wenn Service-Prozess laeuft, sonst `0`. |
| `{service}_requests_total` | Counter | `method`, `route`, `status` | HTTP-Request-Zaehler nach Methode, Route-Template (nicht volle URL) und Status-Code. |
| `{service}_request_duration_seconds` | Histogram | `method`, `route` | Request-Dauer mit Default-Buckets `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`. |
| `{service}_errors_total` | Counter | `error_type` | Fehler-Zaehler nach Typ (`validation`, `db`, `upstream_timeout`, `internal`, ...). |

`{service}` ist der Service-Name in `snake_case` (z.B. `auth_service`, nicht `auth-service`) — Prometheus-Convention.

---

## Alert-Rules (Pflicht-Alerts)

Pro Service drei Pflicht-Alerts unter `observability/alerts/<service>.yml` (siehe Template). Alle Alerts sind **routing-agnostisch** — Severity-Labels steuern, wohin Alertmanager sie weiterreicht (siehe `observability/.env.observability`).

| Alert | Bedingung | `for:` | Severity |
|-------|-----------|--------|----------|
| `{service}_down` | `up{service="..."} == 0` | `2m` | `critical` |
| `{service}_error_rate_high` | `rate(errors_total[5m]) / rate(requests_total[5m]) > 0.05` | `5m` | `warning` |
| `{service}_p95_slow` | `histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m])) > 1` | `5m` | `warning` |

PromQL-Beispiele und Rule-Skeleton siehe `observability/alerts/<service>.yml` (Template weiter unten in dieser Datei).

> [!important] Validierung
> Alle Alert-Rule-Files muessen die Promtool-Validierung bestehen:
> ```bash
> promtool check rules observability/alerts/*.yml
> ```
> CI-Job soll diesen Check ausfuehren — Bootstrap legt nur die Rules an, fuegt den CI-Hook aber nicht automatisch hinzu (Operator-Entscheidung, je nach CI-Provider).

---

## Pro-Service-Sektion (Template)

Eine Sektion pro Service — beim Anlegen eines neuen Services duplizieren und ausfuellen. Beispiel hier: `auth-service`.

### auth-service

- **Sprache / Stack:** Node.js (TypeScript)
- **Metrics-Endpoint:** `http://localhost:9091/metrics`
- **Alert-Rules:** `observability/alerts/auth-service.yml`
- **Logger:** pino mit JSON-Renderer (`level: 'info'` in Production, `'debug'` lokal)
- **Trace-Propagation:** W3C Trace Context Header (`traceparent`) — `trace_id` aus Header oder neu generieren
- **Service-Label fuer Prometheus:** `auth_service` (snake_case)
- **Bekannte error_type-Werte:** `validation`, `db`, `upstream_timeout`, `internal`

---

## Stack-Beispiele

### Node.js — pino + prom-client

`package.json`-Dependencies (current major):

```json
{
  "dependencies": {
    "pino": "^9",
    "prom-client": "^15"
  }
}
```

Logger-Setup (`src/lib/logger.ts`):

```typescript
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: { service: 'auth-service' },
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level: (label) => ({ level: label }),
  },
});

// Usage
logger.error(
  { trace_id, context: { user_id, error_code: 'INVALID_CREDENTIALS' } },
  'Login failed: invalid credentials'
);
```

Metrics-Setup (`src/lib/metrics.ts`):

```typescript
import { Counter, Gauge, Histogram, register } from 'prom-client';

export const up = new Gauge({
  name: 'auth_service_up',
  help: '1 if auth-service is running, 0 otherwise',
});
up.set(1);

export const requests = new Counter({
  name: 'auth_service_requests_total',
  help: 'HTTP requests',
  labelNames: ['method', 'route', 'status'] as const,
});

export const requestDuration = new Histogram({
  name: 'auth_service_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'] as const,
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

export const errors = new Counter({
  name: 'auth_service_errors_total',
  help: 'Errors by type',
  labelNames: ['error_type'] as const,
});

// /metrics endpoint (Express)
// app.get('/metrics', async (_req, res) => {
//   res.set('Content-Type', register.contentType);
//   res.end(await register.metrics());
// });
```

### Python — structlog + prometheus_client

`pyproject.toml`-Dependencies (current major):

```toml
[project]
dependencies = [
  "structlog>=24",
  "prometheus_client>=0.20",
]
```

Logger-Setup (`app/logger.py`):

```python
import logging
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True, key="timestamp"),
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)

logger = structlog.get_logger().bind(service="auth-service")

# Usage
logger.error(
    "Login failed: invalid credentials",
    trace_id=trace_id,
    context={"user_id": user_id, "error_code": "INVALID_CREDENTIALS"},
)
```

Metrics-Setup (`app/metrics.py`):

```python
from prometheus_client import Counter, Gauge, Histogram, start_http_server

up = Gauge("auth_service_up", "1 if auth-service is running, 0 otherwise")
up.set(1)

requests_total = Counter(
    "auth_service_requests_total",
    "HTTP requests",
    ["method", "route", "status"],
)

request_duration = Histogram(
    "auth_service_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "route"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10),
)

errors_total = Counter(
    "auth_service_errors_total",
    "Errors by type",
    ["error_type"],
)

# Expose /metrics on configured port (9091 for auth-service)
# start_http_server(9091)
```

---

## Validierung

```bash
# Prometheus-Rules pruefen (Pflicht vor Merge)
promtool check rules observability/alerts/*.yml
```

Falls `promtool` lokal nicht verfuegbar ist: per Docker (`docker run --rm -v "$PWD/observability/alerts:/rules" prom/prometheus promtool check rules /rules`) oder im CI-Job pruefen. Operator-Entscheidung, wo der Check zuhause ist — Bootstrap legt die Rules an, der Check selbst ist Teil des Quality-Gates.
```

**Anti-Patterns:**
- KEINE Klartext-/`console.log`-/`print`-Logs in produktionsreifem Code — JSON-Renderer ist Pflicht.
- KEIN volles URL-Pfad-Templating als Label (z.B. `/users/12345`) — explodiert die Cardinality. Stattdessen Route-Template (`/users/:id`).
- KEINE `service`-Labels mit `Bindestrich` in Prometheus-Metrik-Namen — Prometheus erlaubt nur `[a-zA-Z_][a-zA-Z0-9_]*`. Service-Name in Logs `auth-service`, in Metrik-Namen `auth_service`.
- KEINE Frontend-Apps als eigene Pro-Service-Sektion — Frontend logged ueber Backend oder externen Error-Tracker.

---

## observability/alerts/<service>.yml (BOO-14)

**Prometheus-Alert-Rule-Template pro Service.** Drei Pflicht-Alerts (`{service}_down`, `{service}_error_rate_high`, `{service}_p95_slow`) mit Severity-Labels und Annotations. Routing-agnostisch — Alertmanager entscheidet anhand der Severity-Labels, wohin der Alert geht (siehe `.env.observability`).

> [!important] Service-Name ersetzen
> `{{SERVICE_NAME}}` ist die Heredoc-Variable und muss vom Bootstrap-Skill (oder manuell beim Anlegen) durch den Service-Namen in `snake_case` ersetzt werden — z.B. `auth_service`. Dateiname bleibt `auth-service.yml` (Kebab-Case fuers Filesystem), die Metrik-Praefixe drin sind `snake_case`.

```yaml
# observability/alerts/{{SERVICE_NAME_KEBAB}}.yml
# Prometheus Alert Rules fuer Service {{SERVICE_NAME}} (snake_case fuer Metrik-Namen).
# Validierung: promtool check rules observability/alerts/*.yml
groups:
  - name: {{SERVICE_NAME}}_alerts
    rules:
      - alert: {{SERVICE_NAME}}_down
        expr: {{SERVICE_NAME}}_up == 0
        for: 2m
        labels:
          severity: critical
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} is down"
          description: |
            Service {{SERVICE_NAME}} reports up == 0 for more than 2 minutes.
            Check process, container or scrape target.

      - alert: {{SERVICE_NAME}}_error_rate_high
        expr: |
          (
            sum(rate({{SERVICE_NAME}}_errors_total[5m]))
            /
            sum(rate({{SERVICE_NAME}}_requests_total[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} error rate above 5%"
          description: |
            Error rate (errors_total / requests_total over 5m) is above 5%
            for more than 5 minutes. Inspect recent deploys and upstream
            dependencies.

      - alert: {{SERVICE_NAME}}_p95_slow
        expr: |
          histogram_quantile(
            0.95,
            sum(rate({{SERVICE_NAME}}_request_duration_seconds_bucket[5m])) by (le)
          ) > 1
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} p95 latency above 1s"
          description: |
            95th percentile request duration is above 1 second for more
            than 5 minutes. Check DB, upstream calls or recent code changes.
```

**Severity-Konvention:**
- `critical` — Service ist nicht erreichbar (Down, Crash). Pager / Telegram / sofortige Aktion.
- `warning` — Service laeuft, aber degradiert (Errors hoch, Latenz hoch). Slack / Email / nicht-blockierend.

**Anti-Patterns:**
- KEINE Pflicht-Alerts loeschen — wer `_down` wegnimmt, kriegt keinen Alarm wenn der Service stirbt.
- KEINE Alert-Schwellen "weicher" stellen ohne Begruendung im Spec — `> 0.05` und `> 1s` sind konservative Defaults; wer sie aendert, dokumentiert das Warum.
- KEIN routing-spezifisches Detail in der Rule-Datei (Telegram-Channel-IDs, Slack-Webhooks, ...) — gehoert in Alertmanager-Config, nicht in die Rule.

---

## observability/.env.observability (BOO-14)

**Routing-Config fuer Alertmanager-Receiver.** Listet Generic-Receiver-Konfiguration plus **Telegram als konkretes Beispiel**. Slack, Discord, Email, PagerDuty werden analog konfiguriert — siehe Alertmanager-Doku.

> [!warning] Secrets — gehoert in `.gitignore`
> Diese Datei enthaelt Bot-Tokens, Webhook-URLs, API-Keys. **Niemals** committen. Bootstrap-Skill traegt `.env.observability` automatisch in `.gitignore` ein. Eine `.env.observability.example` ohne echte Werte kann committed werden, falls Operator das wuenscht.

```bash
# observability/.env.observability
# Alertmanager-Receiver-Routing fuer {{PROJECT_NAME}}.
# Diese Datei NIEMALS committen — sie enthaelt Tokens und Webhooks.
# Telegram ist hier als konkretes Beispiel hinterlegt; Slack, Discord,
# Email, PagerDuty werden analog konfiguriert (siehe Alertmanager-Doku).

# --- Generic Receiver Routing (Pflicht) ---
# Welcher Receiver soll Alerts kriegen? Muss in alertmanager.yml als
# `receivers[].name` definiert sein.
ALERTMANAGER_RECEIVER="default"

# URL, unter der Alertmanager erreichbar ist (Prometheus-Side).
ALERTMANAGER_URL="http://localhost:9093"

# --- Telegram (Beispiel-Routing — eines von vielen) ---
# Bot-Token von @BotFather (https://core.telegram.org/bots#botfather).
TELEGRAM_BOT_TOKEN=""

# Chat-ID, an die Alerts gehen sollen (negativ fuer Gruppen).
TELEGRAM_CHAT_ID=""

# --- Andere Receiver-Typen (Platzhalter) ---
# Slack: SLACK_WEBHOOK_URL=""
# Discord: DISCORD_WEBHOOK_URL=""
# Email: SMTP_HOST="", SMTP_USER="", SMTP_PASS=""
# PagerDuty: PAGERDUTY_INTEGRATION_KEY=""
#
# Konfiguration aller Receiver siehe Alertmanager-Doku:
# https://prometheus.io/docs/alerting/latest/configuration/#receiver
```

**Anti-Patterns:**
- KEIN Commit dieser Datei — `.gitignore`-Eintrag ist Pflicht.
- KEIN Klartext-Token im Repo, auch nicht "kurz zum Testen".
- KEIN Hardcoding von Telegram als einzigem Receiver in Skills oder Hooks — `.env.observability` und Alertmanager-Config sind die Single Source of Truth fuer Routing, nicht ein Skill.

---

## Performance-Baseline-Gate (BOO-16 — P95 + 20%-Rueckfall-Alarm)

Zweiter Arm der Performance-Saeule. BOO-14 hat bereits den **Production-Alarm** etabliert (`{service}_p95_slow` ueber Prometheus, schlaegt an wenn der Live-Service p95 > 1s laeuft). BOO-16 ergaenzt den **Pre-Production-Gate**: bevor ein PR mergt, wird der Service in CI gegen eine **lebende Baseline** gebenchmarkt. Steigt p95 um mehr als 20 % gegenueber der Baseline, blockiert das Gate den Merge — Operator kann mit dokumentiertem Override ziehen, sonst muss die Regression vor Merge geklaert werden.

> [!important] Schrader, Code Crash, Kap. 3 §Production Readiness (Gate 3: Performance Baseline)
> Performance ist kein "messen wir spaeter mal" — sie ist ein Gate. Ohne Baseline kein Vergleich, ohne Vergleich keine Regression sichtbar. BOO-16 setzt die Baseline als versioniertes Architektur-Artefakt im Repo, nicht als fluechtigen Test-Output.

**Stack-Scope:** Node.js (a/c) und Python (d). Frontend (b) hat keinen Server-Endpoint — fuer Frontend-Performance laeuft Lighthouse CI getrennt (Folge-Issue, nicht BOO-16-Scope). Stack `e (Anderes)`: Operator entscheidet, Tool muss JSON-Output mit p50/p95/p99 produzieren.

**Vier Artefakte (in dieser Reihenfolge angelegt):**

1. `journal/perf-baseline.json` — lebende Baseline pro Service (committed)
2. `bench/<service>.bench.js` (Node) ODER `bench/<service>_bench.py` (Python) — Service-Benchmark
3. `.github/workflows/perf.yml` — CI-Gate, vergleicht aktuellen Bench-Lauf gegen Baseline
4. `journal/reports/perf/overrides.log` — append-only Operator-Override-Spur (entsteht erst beim ersten Override)

---

## journal/perf-baseline.json (BOO-16 — Living Performance Baseline)

**Lebende Baseline, ein Eintrag pro Service.** Wird beim Bootstrap initial leer (`services: []`) angelegt und nach dem ersten erfolgreichen Bench-Lauf vom Operator manuell befuellt. Wird bei jedem Release nach Operator-Freigabe aktualisiert — niemals automatisch ueberschrieben.

> [!important] Baseline ist Architektur-Artefakt, nicht Test-Output
> Diese Datei wird committed und reviewed wie jede andere Architektur-Entscheidung. Neue Werte pro Release manuell ersetzen — der CI-Gate liest, schreibt aber nie zurueck. Wer die Baseline anhebt, traegt das im Commit-Message als ADR-Begruendung ein ("Baseline angehoben weil neue Persistierungs-Schicht +15% kostet, akzeptiert weil X").

**Schema (ein Eintrag pro Service):**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `service` | string | Service-Name in Kebab-Case, identisch zur `observability.md`-Sektion |
| `p50_ms` | number | Median-Latenz in Millisekunden |
| `p95_ms` | number | 95-Percentile-Latenz in Millisekunden (siehe Anti-Patterns: bei autocannon Approximation via p97_5) |
| `p99_ms` | number | 99-Percentile-Latenz in Millisekunden |
| `req_per_sec` | number | Mittlerer Durchsatz waehrend des Bench-Laufs |
| `recorded_at` | string (ISO 8601) | UTC-Zeitstempel der Messung |
| `commit_sha` | string | Git-Commit-SHA (40 Zeichen), unter dem die Baseline gemessen wurde |
| `bench_tool` | string | `autocannon` \| `pytest-benchmark` \| `other` |

```json
{
  "$schema_version": 1,
  "services": [
    {
      "service": "auth-service",
      "p50_ms": 12.4,
      "p95_ms": 38.7,
      "p99_ms": 84.2,
      "req_per_sec": 2150.0,
      "recorded_at": "2026-05-07T14:30:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    },
    {
      "service": "api-gateway",
      "p50_ms": 8.1,
      "p95_ms": 22.3,
      "p99_ms": 51.0,
      "req_per_sec": 3400.0,
      "recorded_at": "2026-05-07T14:32:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    }
  ]
}
```

> [!note] Erstbefuellung
> Beim Bootstrap legt der Skill `services: []` an. Erst nach dem ersten gruenen CI-Lauf laed der Operator das `journal/reports/perf/<service>-bench-<sha>.json`-Artefakt herunter, kopiert die p50/p95/p99/req_per_sec-Werte in die Baseline und committed sie als "BOO-16: initial baseline for <service>". Davor laeuft der Comparator-Step im Gate-Modus "Baseline fehlt — Fail", was bei einem frischen Repo erwartet ist.

**Anti-Patterns:**
- KEINE automatische Ueberschreibung der Baseline durch CI — nur Operator. Sonst ist das Gate sinnlos (Baseline waechst mit jeder Regression mit).
- KEINE Baseline ohne `commit_sha` — der SHA ist die Auditspur, ohne die niemand spaeter rekonstruieren kann, mit welchem Code-Stand gemessen wurde.
- KEINE Mittelwerte ueber mehrere Laeufe einkippen ohne Doku — wenn Baseline aus 3 Laeufen entsteht, dann im Commit-Message benennen ("avg of 3 runs, stddev=Xms").

---

## bench/<service>.bench.js (BOO-16 — Node.js Service-Benchmark mit autocannon)

**Service-Benchmark fuer Node.js-Services mit autocannon (programmatische API).** Schreibt einen JSON-Report in `journal/reports/perf/<service>-bench-<sha>.json` mit demselben Schema wie ein Eintrag in `perf-baseline.json` — der Comparator-Step in `perf.yml` liest das ohne Konvertierung.

**Devdep:**

```bash
npm install --save-dev autocannon
```

(autocannon 7.x — generische programmatische API, siehe `mcollina/autocannon` README).

> [!important] Kein nativer p95 in autocannon
> autocannon's `result.latency` ist ein `hdr-histogram-percentiles-obj` und exponiert die Percentile `p2_5, p50, p75, p90, p97_5, p99, p99_9, p99_99, p99_999` — **es gibt kein direktes `p95`**. Wir nutzen `p97_5` als konservative Approximation (worst-case Bias nach oben — eine echte Regression wird trotzdem erkannt, harmlose Schwankungen werden ggf. groesser dargestellt). Das ist explizite Operator-Choice, dokumentiert in der Baseline als `bench_tool: "autocannon"`.

**Naming-Konventionen:**
- Datei: Kebab-Case, identisch zum Service-Namen — `bench/auth-service.bench.js`
- Service-Name in JSON-Output: Kebab-Case (`"service": "auth-service"`) — identisch zu `observability.md`
- Report-Pfad: `journal/reports/perf/<service>-bench-<short-sha>.json` (short-sha = erste 7 Zeichen des Git-SHA)

```javascript
// bench/{{SERVICE_NAME_KEBAB}}.bench.js
// BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
// Voraussetzung: Service laeuft auf {{PORT}} unter {{PATH}} (siehe README).

const autocannon = require('autocannon');
const fs = require('node:fs');
const path = require('node:path');
const { execSync } = require('node:child_process');

const SERVICE_NAME = '{{SERVICE_NAME_KEBAB}}';
const TARGET_URL = process.env.BENCH_URL || 'http://localhost:{{PORT}}{{PATH}}';
const CONNECTIONS = Number(process.env.BENCH_CONNECTIONS || 10);
const DURATION = Number(process.env.BENCH_DURATION || 30); // Sekunden

async function main() {
  // Warmup: 5 Sekunden, Resultat verworfen — schuetzt vor JIT-/Cache-Effekten in der Messung.
  await autocannon({ url: TARGET_URL, connections: CONNECTIONS, duration: 5 });

  const result = await autocannon({
    url: TARGET_URL,
    connections: CONNECTIONS,
    duration: DURATION,
  });

  // autocannon hat kein natives p95 — p97_5 ist die naechste verfuegbare Percentile (>=95).
  // Konservative Approximation, dokumentiert in journal/perf-baseline.json -> bench_tool: "autocannon".
  const sha = execSync('git rev-parse HEAD').toString().trim();
  const shortSha = sha.slice(0, 7);

  const report = {
    service: SERVICE_NAME,
    p50_ms: result.latency.p50,
    p95_ms: result.latency.p97_5, // Approximation, siehe Kommentar oben
    p99_ms: result.latency.p99,
    req_per_sec: result.requests.average,
    recorded_at: new Date().toISOString(),
    commit_sha: sha,
    bench_tool: 'autocannon',
  };

  const outDir = path.join('journal', 'reports', 'perf');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${SERVICE_NAME}-bench-${shortSha}.json`);
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  console.log(`[BOO-16] Bench-Report: ${outPath}`);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('[BOO-16] Bench failed:', err);
  process.exit(1);
});
```

> [!note] Service-Start ist Operator-Choice
> Das Bench-Skript erwartet einen laufenden Service auf `BENCH_URL`. Ob der Service in CI per `npm run start:{{SERVICE_NAME}} &`, per Docker-Compose oder per `node dist/server.js &` gestartet wird, entscheidet der Operator pro Projekt. Im Workflow-Template (siehe `perf.yml` weiter unten) ist der Service-Start als Platzhalter mit Kommentar markiert.

**Anti-Patterns:**
- KEINE Microbench-Tools (`tinybench`, `benchmark.js`) als HTTP-Service-Bench einsetzen — die messen Funktions-Latenz im Prozess, nicht den vollen Stack inkl. Netzwerk-Stack, Serialisierung und Middleware.
- KEINE Bench-Laeufe ohne Warmup — JIT-Compilation und Cache-Effekte verzerren die ersten Sekunden um Faktor 2-5.
- KEINE 1-Sekunden-Messungen — die Statistik ist nicht stabil, p95 schwankt um +/-50 %. Mindestens 30s, besser 60s.
- KEINE Bench-Laeufe gegen Production-URL aus CI — fuehrt zu DDoS-Verdacht und Kosten-Explosion. Service muss lokal im Runner gestartet werden.

---

## bench/<service>_bench.py (BOO-16 — Python Service-Benchmark mit pytest-benchmark)

**Service-Benchmark fuer Python-Services mit pytest-benchmark + httpx.** pytest-benchmark misst Funktions-Latenz statistisch sauber (mehrere Rounds, Median, Stddev), wir wrappen einen HTTP-Call gegen den lokalen Service.

**Devdeps (`pyproject.toml`):**

```toml
[project.optional-dependencies]
test = [
  "pytest>=8",
  "pytest-benchmark>=5",
  "httpx>=0.27",
]
```

> [!important] pytest-benchmark misst Latenz, nicht Throughput
> pytest-benchmark exportiert per Default `min, max, mean, stddev, median, iqr, outliers, rounds, iterations` — also keine echten Quantile, sondern Verteilungs-Statistiken. Wir mappen `p50 = median` direkt. Fuer `p95` gibt es zwei Wege:
> - **Operator-Choice A (Default, empfohlen):** Approximation `p95 ≈ mean + 1.645 * stddev` (Normalverteilungs-Annahme). Schnell, robust bei homogenen Latenzen, biased nach oben bei Long-Tail-Verteilungen.
> - **Operator-Choice B:** Eigene Histogram-Aufzeichnung in der Test-Function (siehe Snippet unten), liefert echte Quantile, kostet aber Boilerplate. Empfohlen wenn der Service bekanntermassen Long-Tail-Latenzen hat (z.B. DB-Queries mit Cache-Miss-Spikes).
>
> Wahl wird in `journal/perf-baseline.json` ueber `bench_tool: "pytest-benchmark"` dokumentiert. Wer Choice B nimmt, traegt zusaetzlich `bench_tool: "pytest-benchmark+histogram"` ein.

**Throughput-Caveat:** pytest-benchmark misst pro Round eine einzelne Funktions-Ausfuehrung — daraus laesst sich `req_per_sec` nur **synthetisch** ableiten (`1000 / mean_ms`). Fuer echten Concurrent-Throughput (mehrere Connections parallel) braucht es ein separates Tool wie `locust` oder `wrk` — bewusst aus BOO-16-Scope ausgeschlossen, ggf. Folge-Issue BOO-XX.

```python
# bench/{{SERVICE_NAME_SNAKE}}_bench.py
# BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
# Aufruf: pytest bench/ --benchmark-json=journal/reports/perf/{{SERVICE_NAME_KEBAB}}-bench.json

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import httpx
import pytest

SERVICE_NAME = "{{SERVICE_NAME_KEBAB}}"
TARGET_URL = os.environ.get("BENCH_URL", "http://localhost:{{PORT}}{{PATH}}")


@pytest.fixture(scope="module")
def client():
    with httpx.Client(timeout=10.0) as c:
        # Warmup: 50 Requests, Resultat verworfen.
        for _ in range(50):
            c.get(TARGET_URL).raise_for_status()
        yield c


def test_request_latency(benchmark, client):
    """Misst Latenz pro HTTP-Call. p50 = median, p95 ueber Approximation (siehe Header)."""
    result = benchmark(lambda: client.get(TARGET_URL).raise_for_status())
    # pytest-benchmark schreibt stats automatisch via --benchmark-json.
    # Der Comparator-Step in perf.yml konvertiert stats -> p50/p95/p99 (siehe perf.yml).
    return result


# Optional: Operator-Choice B — eigene Histogram-Aufzeichnung fuer echte Quantile.
# Aktivieren durch Auskommentieren und in perf.yml den Konvertierungs-Pfad anpassen.
#
# def test_request_latency_with_histogram(client):
#     import time
#     samples_ms: list[float] = []
#     for _ in range(1000):
#         t0 = time.perf_counter()
#         client.get(TARGET_URL).raise_for_status()
#         samples_ms.append((time.perf_counter() - t0) * 1000)
#     samples_ms.sort()
#     report = _build_report(
#         p50=samples_ms[len(samples_ms) // 2],
#         p95=samples_ms[int(len(samples_ms) * 0.95)],
#         p99=samples_ms[int(len(samples_ms) * 0.99)],
#         req_per_sec=1000.0 / (sum(samples_ms) / len(samples_ms) / 1000),
#     )
#     _write_report(report, bench_tool="pytest-benchmark+histogram")


def _build_report(p50: float, p95: float, p99: float, req_per_sec: float) -> dict:
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    return {
        "service": SERVICE_NAME,
        "p50_ms": p50,
        "p95_ms": p95,
        "p99_ms": p99,
        "req_per_sec": req_per_sec,
        "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "commit_sha": sha,
        "bench_tool": "pytest-benchmark",
    }


def _write_report(report: dict, bench_tool: str = "pytest-benchmark") -> None:
    report["bench_tool"] = bench_tool
    out_dir = Path("journal/reports/perf")
    out_dir.mkdir(parents=True, exist_ok=True)
    short_sha = report["commit_sha"][:7]
    out_path = out_dir / f"{SERVICE_NAME}-bench-{short_sha}.json"
    out_path.write_text(json.dumps(report, indent=2))
```

> [!note] Konvertierungs-Schritt
> Der Default-Pfad (Choice A) erzeugt einen pytest-benchmark-JSON-Output (`--benchmark-json=...`). Der Comparator-Step in `perf.yml` macht dann eine Konvertierung `stats.median -> p50_ms`, `stats.mean + 1.645*stats.stddev -> p95_ms`, `stats.max -> p99_ms` (Approximation: max ist konservative obere Schranke fuer p99 bei kleinen Sample-Groessen). Wer Choice B aktiviert, schreibt direkt das Baseline-Schema und ueberspringt die Konvertierung.

**Anti-Patterns:**
- KEINE pytest-benchmark fuer Throughput-Messungen einsetzen — `rounds` ist sequentiell, nicht concurrent. `req_per_sec` aus Mean-Latenz ist Single-Connection-Approximation, nicht Multi-Connection-Capacity.
- KEINE pytest-benchmark gegen Production-URL — siehe Node.js-Anti-Pattern, Service muss im Runner laufen.
- KEINE Test-Functions mit `assert response.status_code == 200` und `benchmark()` zugleich — der Assert wird N-mal ausgefuehrt, das verfaelscht die Messung. Stattdessen `raise_for_status()` im Lambda.

---

## .github/workflows/perf.yml (BOO-16 — CI-Performance-Gate)

**Pre-Production-Gate**, laeuft auf jedem PR gegen `main` plus manuell via `workflow_dispatch`. Drei Schwellen, eine Override-Mechanik, Bench-Output als Artefakt.

> [!important] GitHub-Hosted-Runner-Varianz
> GitHub-Hosted-Runner sind Shared-Hardware mit Noisy-Neighbor-Effekt. Empirische Messungen zeigen +/- 30 % Varianz zwischen identischen Laeufen. Der **20%-Threshold** in BOO-16 ist absichtlich generoes gewaehlt, um diesen Noise zu absorbieren — eine echte Regression sticht erst bei >20 % heraus. Empfehlung als Folge-Issue (BOO-XX): **Self-Hosted-Runner** mit reservierter CPU/Memory, dort kann der Threshold auf 10 % geschaerft werden. Bis dahin ist der 20%-Threshold der pragmatische Default.

**Schwellen (Comparator-Logik, ratio = current_p95 / baseline_p95):**

| Ratio | Outcome | Mechanik |
|-------|---------|----------|
| `<= 1.05` | PASS | Gruene Ausgabe, exit 0 |
| `> 1.05 && <= 1.20` | WARNING | PR-Comment via `actions/github-script@v7`, exit 0 |
| `> 1.20` | FAIL | exit 1 — ausser Operator-Override (siehe unten) |
| Baseline fehlt | FAIL | exit 1, Hinweis "Baseline fehlt — manuell aus Bench-Output uebernehmen + Operator-Freigabe" |

**Override-Mechanik (zwei Wege, beide loggen in `journal/reports/perf/overrides.log`):**
- PR-Label `perf-override` setzen (Web-UI, schneller Path)
- Commit-Message-Trailer `Perf-Override: <begruendung>` (Audit-freundlicher Path, im Git-History sichtbar)

```yaml
# .github/workflows/perf.yml
# BOO-16 Performance-Baseline-Gate — vergleicht aktuellen Bench-Lauf gegen
# journal/perf-baseline.json. Schwellen: <=5% PASS, 5-20% WARNING, >20% FAIL.

name: Performance

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  bench:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Operator pflegt Service-Liste hier — synchron zu observability.md.
        service: [auth-service]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # --- Stack-Setup: eines von beiden, je nach Stack-Choice (Block A) ---
      - name: Setup Node.js
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Setup Python
        if: ${{ hashFiles('pyproject.toml') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install deps (Node)
        if: ${{ hashFiles('package.json') != '' }}
        run: npm ci

      - name: Install deps (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        run: pip install -e '.[test]'

      # --- Service starten — Operator passt Command pro Projekt an ---
      # Annahme: Service horcht auf Port 8080. Fuer Multi-Service-Projekte
      # pro Service einen eigenen Workflow-Job mit eigenem Port.
      - name: Start service (background)
        run: |
          # TODO Operator: hier den Start-Command fuer ${{ matrix.service }} eintragen.
          # Beispiele:
          #   Node:   npm run start:${{ matrix.service }} &
          #   Python: python -m {{MODULE}} &
          echo "Operator: Start-Command fuer ${{ matrix.service }} hier eintragen" && exit 1

      - name: Wait for service
        run: |
          for i in $(seq 1 30); do
            if curl -sf http://localhost:8080/health > /dev/null; then
              echo "Service ready"; exit 0
            fi
            sleep 1
          done
          echo "Service did not start within 30s"; exit 1

      # --- Bench laufen lassen (eines von beiden) ---
      - name: Run bench (Node)
        if: ${{ hashFiles('package.json') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
          BENCH_DURATION: '30'
        run: node bench/${{ matrix.service }}.bench.js

      - name: Run bench (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
        run: |
          mkdir -p journal/reports/perf
          pytest bench/ \
            --benchmark-json=journal/reports/perf/${{ matrix.service }}-bench-raw.json

      # --- Comparator: Ratio current_p95 / baseline_p95 ---
      - name: Compare against baseline
        id: compare
        env:
          SERVICE: ${{ matrix.service }}
          PR_LABELS: ${{ toJson(github.event.pull_request.labels.*.name) }}
          COMMIT_MSG: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          SHORT_SHA=$(git rev-parse --short HEAD)
          REPORT_PATH="journal/reports/perf/${SERVICE}-bench-${SHORT_SHA}.json"

          # Python-Stack: stats -> Baseline-Schema konvertieren (Operator-Choice A).
          if [ -f "journal/reports/perf/${SERVICE}-bench-raw.json" ] && [ ! -f "$REPORT_PATH" ]; then
            python3 - <<PY
          import json, subprocess
          from datetime import datetime, timezone
          raw = json.load(open("journal/reports/perf/${SERVICE}-bench-raw.json"))
          stats = raw["benchmarks"][0]["stats"]
          sha = subprocess.check_output(["git","rev-parse","HEAD"]).decode().strip()
          mean_ms = stats["mean"] * 1000
          stddev_ms = stats["stddev"] * 1000
          report = {
            "service": "${SERVICE}",
            "p50_ms": stats["median"] * 1000,
            "p95_ms": mean_ms + 1.645 * stddev_ms,
            "p99_ms": stats["max"] * 1000,
            "req_per_sec": 1000.0 / mean_ms if mean_ms > 0 else 0.0,
            "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00","Z"),
            "commit_sha": sha,
            "bench_tool": "pytest-benchmark",
          }
          json.dump(report, open("${REPORT_PATH}","w"), indent=2)
          PY
          fi

          if [ ! -f "$REPORT_PATH" ]; then
            echo "FAIL: Bench-Report fehlt: $REPORT_PATH"; exit 1
          fi

          CURRENT=$(python3 -c "import json; print(json.load(open('$REPORT_PATH'))['p95_ms'])")
          BASELINE=$(python3 -c "
          import json, sys
          data = json.load(open('journal/perf-baseline.json'))
          for s in data.get('services', []):
              if s['service'] == '${SERVICE}':
                  print(s['p95_ms']); sys.exit(0)
          sys.exit(2)
          " || echo "MISSING")

          if [ "$BASELINE" = "MISSING" ]; then
            echo "FAIL: Baseline fuer ${SERVICE} fehlt in journal/perf-baseline.json."
            echo "Bench-Output: $REPORT_PATH — Werte manuell uebernehmen + Operator-Freigabe."
            exit 1
          fi

          RATIO=$(python3 -c "print(${CURRENT} / ${BASELINE})")
          echo "ratio=${RATIO}" >> "$GITHUB_OUTPUT"
          echo "current=${CURRENT}" >> "$GITHUB_OUTPUT"
          echo "baseline=${BASELINE}" >> "$GITHUB_OUTPUT"

          PASS=$(python3 -c "print('1' if ${RATIO} <= 1.05 else '0')")
          WARN=$(python3 -c "print('1' if ${RATIO} > 1.05 and ${RATIO} <= 1.20 else '0')")
          FAIL=$(python3 -c "print('1' if ${RATIO} > 1.20 else '0')")

          if [ "$PASS" = "1" ]; then
            echo "PASS: p95 ratio ${RATIO} (<= 1.05)"; exit 0
          fi
          if [ "$WARN" = "1" ]; then
            echo "WARNING: p95 ratio ${RATIO} (5-20% above baseline)"
            echo "outcome=warning" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          # FAIL-Pfad — Override pruefen
          if echo "$PR_LABELS" | grep -q '"perf-override"' \
             || git log -1 --pretty=%B | grep -qi '^Perf-Override:'; then
            echo "FAIL overridden by operator. Logging to overrides.log."
            mkdir -p journal/reports/perf
            REASON=$(git log -1 --pretty=%B | grep -i '^Perf-Override:' | head -1 || echo "via PR label")
            echo "$(date -u +%FT%TZ) | ${SERVICE} | ratio=${RATIO} | sha=$(git rev-parse HEAD) | ${REASON}" \
              >> journal/reports/perf/overrides.log
            exit 0
          fi
          echo "FAIL: p95 ratio ${RATIO} > 1.20 (no override)"
          exit 1

      - name: Comment on PR (warning only)
        if: steps.compare.outputs.outcome == 'warning' && github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const ratio = '${{ steps.compare.outputs.ratio }}';
            const current = '${{ steps.compare.outputs.current }}';
            const baseline = '${{ steps.compare.outputs.baseline }}';
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `BOO-16 Perf-Warning: \`${{ matrix.service }}\` p95 ratio **${ratio}** ` +
                    `(current ${current} ms vs baseline ${baseline} ms). ` +
                    `Below 1.20 FAIL-Threshold but above 1.05 PASS-Threshold — review recommended.`
            });

      - name: Upload bench artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-bench-${{ matrix.service }}
          path: journal/reports/perf/
          retention-days: 30
```

> [!warning] Override-Log ist append-only Audit-Spur
> `journal/reports/perf/overrides.log` wird vom CI-Job angehaengt und committed (manuell durch den Operator beim Merge — der CI-Job kann nicht in den PR pushen). Wer ein Override zieht, ist im Log fuer immer sichtbar. Das ist Absicht: Override darf einfach sein, aber niemals unsichtbar.

**Anti-Patterns:**
- KEIN Bench-Lauf in einem Container ohne reservierte Ressourcen (Standard-GitHub-Hosted-Runner sind shared) ohne entsprechend generoese Schwellen — sonst flackert das Gate zwischen PASS und FAIL bei identischem Code.
- KEINE Schwellen unter 5 % auf Hosted-Runnern — der Noise-Floor allein ist 10-30 %.
- KEINE Override-Mechanik ohne Logging — sonst verkommt das Gate zu einer "skip if annoying"-Geste, und die Baseline driftet stillschweigend nach oben.
- KEIN automatisches Update der Baseline durch den Comparator-Step — siehe `perf-baseline.json`-Sektion. Baseline-Update ist immer Operator-Decision mit ADR-Begruendung.
- KEIN Bench-Lauf gegen Production-URL aus CI — Service muss lokal im Runner laufen.

---

## lighthouserc.json (BOO-45 — Frontend-Performance-Budgets)

Wird von `/bootstrap` A.1b generiert wenn `LIGHTHOUSE_CHOICE=yes` und `STACK_CHOICE` in `b` oder `c`.
Pendant zu BOO-16 `perf-baseline.json`, aber fuer Browser-Apps statt Backend-Services.

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.9}],
        "categories:seo": ["warn", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "journal/reports/ci/lighthouse-out"
    }
  }
}
```

**Operator-Tasks beim Setup (manuell, im HANDBUCH Anhang H dokumentiert):**
- `ci.collect.url` pro Environment eintragen (preview-deploy, staging, prod) — die Default-URL `http://localhost:3000/` ist nur fuer den ersten Smoke-Test
- `ci.collect.settings.preset` auswaehlen: `desktop` (kein Throttling) vs. `mobile` (Lighthouse-default 3G-slow + 4x CPU-Throttle)
- Performance-Budgets justieren: Defaults sind branchenueblich, aber bei viel Drittanbieter-Code (Analytics, Ads) sind 2.5s LCP eng. Operator entscheidet `minScore` + `maxNumericValue` pro Projekt-Realitaet
- `ci.upload.target` umstellen wenn Lighthouse-Server-Backend gewuenscht (default `filesystem` schreibt in `journal/reports/ci/lighthouse-out/`)

---

## .github/workflows/lighthouse.yml (BOO-45 — Lighthouse-CI Frontend-Performance-Gate)

```yaml
name: Lighthouse CI

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Install dependencies
        run: npm ci

      - name: Build frontend
        run: npm run build

      - name: Start preview server in background
        run: |
          # Operator: an Build-Output anpassen — z.B. 'npx serve dist' oder 'npm run preview'
          npx serve -s dist -l 3000 &
          # Auf Server warten
          npx wait-on http://localhost:3000 --timeout 60000

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.14.x
          lhci autorun --config=./lighthouserc.json
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

      - name: Collect reports for Hermes (BOO-32)
        if: always()
        run: |
          mkdir -p journal/reports/ci/run-${{ github.run_id }}
          cp -rf journal/reports/ci/lighthouse-out/* journal/reports/ci/run-${{ github.run_id }}/ 2>/dev/null || true
          # Aggregierte Score-Summary als lighthouse.json
          if [ -f "journal/reports/ci/lighthouse-out/manifest.json" ]; then
            cp -f journal/reports/ci/lighthouse-out/manifest.json journal/reports/ci/run-${{ github.run_id }}/lighthouse.json
          fi

      - name: Upload reports as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ci-reports-${{ github.run_id }}
          path: journal/reports/ci/run-${{ github.run_id }}/
          retention-days: 30
```

**Operator-Tasks (im HANDBUCH Anhang H):**
- Build-Command pro Stack anpassen — `npm run build` ist Default, aber Vite/Astro/Next haben andere Outputs
- Preview-Server-Command anpassen (Zeile `npx serve -s dist -l 3000`) — bei Next.js z.B. `npm run start`
- Bei statischem Hosting (Deploy auf Netlify/Vercel) kann der Step entfallen, Lighthouse direkt gegen die Preview-Deploy-URL laufen
- `LHCI_GITHUB_APP_TOKEN` Secret optional — nur fuer Lighthouse-CI-Server-Status-Checks (sonst Filesystem-Reports)

**Hermes-Konsumtion:** `lighthouse.json` ist die aggregierte Score-Summary (`manifest.json` von Lighthouse-CI), `journal/reports/ci/lighthouse-out/*.json` sind die Roh-Reports pro URL+Run.

---

## Reliability-Skelett (BOO-25 — 5 Invarianten Idempotenz/Retry/Circuit-Breaker/Graceful-Degradation/SLO)

Sechste Saeule des Schrader-Modells: Reliability als Architektur-Eigenschaft, nicht als Hoffnung. Die Saeule besteht aus fuenf Invarianten, die jeder produktive Service erfuellen sollte:

1. **Idempotenz** — schreibende Endpunkte koennen ohne Schaden wiederholt werden (Idempotency-Key-Middleware).
2. **Retry mit Backoff + Jitter** — transiente Fehler werden begrenzt automatisch wiederholt, kein Thundering Herd.
3. **Circuit Breaker / Bulkhead** — externe Abhaengigkeiten failen schnell, statt den Caller zu blockieren.
4. **Graceful Degradation** — bei Teilausfall liefert der Service ein reduziertes, aber definiertes Verhalten.
5. **SLO + Error Budget** — die Reliability-Erwartung ist gemessen, nicht versprochen.

> [!important] Schrader, Code Crash, Kap. 4 §Run the System (Saeule 6 Reliability)
> Reliability ist die Differenz zwischen "es lief beim Start" und "es laeuft Monat zwei". Sie entsteht nicht durch Glueck, sondern durch vier Code-Patterns plus ein Mess-Manifest. Wer sie weglaesst, baut einen Demo, kein System.

**Stack-Scope:** Node.js (a/c) und Python (d) bekommen vier konkrete Skelett-Dateien (Idempotency, Retry, Circuit Breaker, SLO). Frontend (b) hat keinen serverseitigen Idempotency-/Retry-/Breaker-Layer — Backend uebernimmt das. Stack `e (Anderes)`: Operator-Choice, SLO-Manifest bleibt aber Pflicht (Tool-unabhaengig).

**Vier Artefakte (in dieser Reihenfolge angelegt):**

1. `docs/SLO.md` — Service Level Objective Manifest (committed, alle Stacks).
2. `lib/idempotency.{js,py}` — Idempotency-Key-Middleware fuer schreibende Endpunkte.
3. `lib/retry.{js,py}` — Retry-Helper mit Backoff + Jitter.
4. `lib/circuit-breaker.{js,py}` — Circuit-Breaker-Wrapper, ein Breaker pro externe Abhaengigkeit.

> [!note] Optionalitaet
> Nicht jeder Service braucht alle vier Skelette ab Tag 0. Ein reiner Read-only-Lookup-Service braucht keinen Idempotency-Layer. Die Phase 4.4h im Bootstrap fragt explizit pro Skelett ab — siehe `SKILL.md` Phase 4.4h. Empfehlung fuer Backend-Services mit externer Abhaengigkeit: alle vier setzen.

---

## docs/SLO.md (BOO-25 — Service Level Objective Manifest)

**Reliability-Erwartung als versioniertes Architektur-Artefakt.** Beschreibt pro Service drei SLIs (Service Level Indicators) und die zugehoerigen SLOs (Objectives), inklusive Error-Budget-Tabelle pro Quartal mit Verbrauchs-Tracker. Wird in `/sprint-review` einmal monatlich gegengelesen — verbleibendes Budget entscheidet, ob Reliability-Investment vor Feature-Investment kommt.

> [!important] SLO ist Architektur-Artefakt, kein Marketing-Versprechen
> Wer "99,99 % Verfuegbarkeit" in den Vertrag schreibt, ohne Multi-Region oder Active-Passive-Failover zu betreiben, ist unehrlich — die Mathematik laesst das auf Single-Region-Hardware nicht zu. Default-Empfehlungen: **99,9 %** fuer Single-Region-Service (43,8 min Downtime/Monat), **99,95 %** mit dokumentiertem Failover (21,9 min/Monat), **99,99 %** nur mit Multi-Region + regelmaessigen Chaos-Tests (4,4 min/Monat). Hoeher ist eine Luege, bis das Gegenteil bewiesen ist.

**Mess-Methode:** Die drei SLIs lesen aus dem Prometheus-Metrics-Endpoint, der in BOO-14 (`observability.md` §Metrics-Endpoint) bereits angelegt wurde. Keine separaten Mess-Tools — Single Source of Truth.

```markdown
# SLO — {{SERVICE_NAME}}

> Architektur-Artefakt nach BOO-25 (Saeule 6 Reliability). Dieses Dokument
> definiert die gemessene Reliability-Erwartung. Aenderungen sind ADR-pflichtig
> und werden im Commit-Message begruendet ("SLO erhoeht von X auf Y weil ...").

## Service

- **Name:** {{SERVICE_NAME}}
- **Owner:** {{OWNER}}
- **Stack:** {{STACK}}
- **Metrics-Endpoint:** `/metrics` (Port {{PORT}}) — siehe `observability.md`
- **Status:** draft | active | deprecated

## Service Level Objectives

| SLI | Mess-Methode (PromQL) | Ziel (SLO) | Mess-Fenster |
|-----|----------------------|-----------|--------------|
| **Availability** | `(1 - rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100` | >= 99.9 % | rolling 30d |
| **Latency P95** | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | < 1.0 s | rolling 30d |
| **Error Rate** | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100` | < 0.5 % | rolling 30d |

## Error-Budget-Tabelle

Bei SLO 99.9 % Availability = 0.1 % Error-Budget = **43,8 min Downtime / 30 Tage**.

| Quartal | Budget total | Verbraucht | Verbleibend | Status |
|---------|-------------|------------|-------------|--------|
| Q1 {{YEAR}} | 131,4 min | 0 min | 131,4 min | green |
| Q2 {{YEAR}} | 131,4 min | — | — | — |
| Q3 {{YEAR}} | 131,4 min | — | — | — |
| Q4 {{YEAR}} | 131,4 min | — | — | — |

**Verbrauch-Tracker:** Jeder Incident, der Availability unter den SLO-Wert druckt, wird hier eingetragen — Datum, Dauer, Ursache, ADR-Link.

| Datum (UTC) | Dauer | Ursache | ADR / Postmortem |
|-------------|-------|---------|------------------|
| — | — | — | — |

## Review-Cadence

- **Monatlich** in `/sprint-review` — Budget-Verbrauch ablesen, gegen Ziel halten.
- **Bei Budget < 25 % verbleibend:** naechstes Sprint-Slot fuer Reliability-Arbeit reservieren (kein Feature).
- **Bei Budget < 0:** Feature-Freeze bis Budget wiederhergestellt — siehe Schrader, Code Crash, Kap. 4 §Run the System.

## Verlauf / Aenderungen

- {{YYYY-MM-DD}} — Initial-Setup ueber `/bootstrap` Phase 4.4h.
```

**Anti-Patterns:**
- KEIN SLO ohne Error-Budget — der SLO-Wert allein ist Marketing, das Budget ist der Hebel.
- KEIN SLO ohne Mess-Methode (PromQL/Query) — sonst wird die Zahl gefuehlt, nicht gemessen.
- KEIN 99.99 %-SLO ohne Multi-Region und Chaos-Tests — die Hardware-Mathematik gibt das auf einer Single-Region nicht her.
- KEIN Auto-Update der Verbrauch-Tabelle aus Monitoring — Incident-Eintraege brauchen Operator-Review (Ursache + ADR-Link). Auto-Append macht aus dem Manifest ein Log und niemand liest es.

---

## lib/idempotency.{js,py} (BOO-25 — Idempotency-Key-Middleware)

**Schreibende Endpunkte gegen Wiederholung absichern.** Liest den Header `Idempotency-Key` (UUID v4), persistiert Request-Hash + Response in Redis (Default) oder Postgres (Fallback) fuer 24h TTL. Bei Wiederholung mit gleichem Key: cached Response zurueck (kein erneutes Schreiben). Bei gleichem Key + abweichendem Body: HTTP 422 (Conflict — Client hat Bug).

> [!important] Idempotency NUR fuer schreibende Endpunkte
> Anwenden auf POST / PUT / PATCH / DELETE. NICHT auf GET — GET ist per HTTP-Spec idempotent, ein Layer ist Overhead ohne Nutzen. Auch nicht global fuer alle Routes — nur dort, wo Side-Effects passieren (Datenbank-Writes, externe API-Calls, Geld-Bewegung).

**Stack-Scope:** Node.js (a/c) als Express-Middleware, Python (d) als FastAPI-Dependency. Frontend (b) hat keinen serverseitigen Endpoint — Backend uebernimmt. Stack e: Operator-Choice, gleiche Logik in eigenes Framework portieren.

### Node.js — `lib/idempotency.js`

**Devdep:**

```bash
npm install redis
```

(redis 5.x — offizieller Node-Client, siehe `redis/node-redis` README.)

```javascript
// lib/idempotency.js
// BOO-25 Idempotency-Key-Middleware fuer Express.
// Wird NUR auf schreibenden Routes (POST/PUT/PATCH/DELETE) registriert,
// nicht global. Beispiel: app.post('/orders', idempotency(), createOrder)

const crypto = require('node:crypto');
const { createClient } = require('redis');

const TTL_SECONDS = 24 * 60 * 60; // 24h
const KEY_PREFIX = 'idem:';
const UUID_V4_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

let _redis;
async function getRedis() {
  if (!_redis) {
    _redis = createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });
    _redis.on('error', (err) => console.error('[idempotency] redis error', err));
    await _redis.connect();
  }
  return _redis;
}

function hashBody(body) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(body || {}))
    .digest('hex');
}

function idempotency() {
  return async function idempotencyMiddleware(req, res, next) {
    const key = req.header('Idempotency-Key');
    if (!key) {
      return res.status(400).json({
        error: 'idempotency_key_required',
        message: 'Idempotency-Key header is required for write operations',
      });
    }
    if (!UUID_V4_REGEX.test(key)) {
      return res.status(400).json({
        error: 'idempotency_key_invalid',
        message: 'Idempotency-Key must be UUID v4',
      });
    }

    const redis = await getRedis();
    const storeKey = `${KEY_PREFIX}${key}`;
    const bodyHash = hashBody(req.body);
    const cached = await redis.get(storeKey);

    if (cached) {
      const entry = JSON.parse(cached);
      if (entry.bodyHash !== bodyHash) {
        return res.status(422).json({
          error: 'idempotency_key_conflict',
          message: 'Same Idempotency-Key used with different request body',
        });
      }
      // Replay cached response.
      res.status(entry.status).set(entry.headers).send(entry.body);
      return;
    }

    // Capture response to cache after handler runs.
    const originalSend = res.send.bind(res);
    res.send = function captureSend(body) {
      // Persist async, do not block response.
      redis
        .setEx(
          storeKey,
          TTL_SECONDS,
          JSON.stringify({
            bodyHash,
            status: res.statusCode,
            headers: res.getHeaders(),
            body: typeof body === 'string' ? body : JSON.stringify(body),
          }),
        )
        .catch((err) => console.error('[idempotency] store error', err));
      return originalSend(body);
    };

    next();
  };
}

module.exports = { idempotency };
```

### Python — `lib/idempotency.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "redis>=5.0",
  "fastapi>=0.110",
]
```

(redis-py >=5.0 — offizieller Python-Client mit asyncio-Support.)

```python
# lib/idempotency.py
# BOO-25 Idempotency-Key-Dependency fuer FastAPI.
# Wird NUR an schreibenden Routes (POST/PUT/PATCH/DELETE) gebunden,
# nicht global. Beispiel:
#     @app.post("/orders", dependencies=[Depends(idempotency)])
#     async def create_order(...): ...

import hashlib
import json
import os
import re
from typing import Any

import redis.asyncio as redis_asyncio
from fastapi import HTTPException, Request

TTL_SECONDS = 24 * 60 * 60  # 24h
KEY_PREFIX = "idem:"
UUID_V4_REGEX = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    re.IGNORECASE,
)

_redis: redis_asyncio.Redis | None = None


async def _get_redis() -> redis_asyncio.Redis:
    global _redis
    if _redis is None:
        url = os.environ.get("REDIS_URL", "redis://localhost:6379")
        _redis = redis_asyncio.from_url(url, decode_responses=True)
    return _redis


def _hash_body(body: Any) -> str:
    payload = json.dumps(body, sort_keys=True, default=str).encode()
    return hashlib.sha256(payload).hexdigest()


async def idempotency(request: Request) -> None:
    """FastAPI dependency. Raises HTTPException on conflict, replays on hit."""
    key = request.headers.get("Idempotency-Key")
    if not key:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_required",
                "message": "Idempotency-Key header is required for write operations",
            },
        )
    if not UUID_V4_REGEX.match(key):
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_invalid",
                "message": "Idempotency-Key must be UUID v4",
            },
        )

    body_bytes = await request.body()
    try:
        body_json = json.loads(body_bytes) if body_bytes else {}
    except json.JSONDecodeError:
        body_json = {"_raw": body_bytes.decode(errors="replace")}
    body_hash = _hash_body(body_json)

    r = await _get_redis()
    store_key = f"{KEY_PREFIX}{key}"
    cached = await r.get(store_key)

    if cached:
        entry = json.loads(cached)
        if entry["bodyHash"] != body_hash:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "idempotency_key_conflict",
                    "message": "Same Idempotency-Key used with different request body",
                },
            )
        # Replay: stash cached response on request.state — handler reads it.
        request.state.idempotency_replay = entry
        return

    # First seen — handler runs; response capture happens in middleware/wrapper.
    request.state.idempotency_key = store_key
    request.state.idempotency_body_hash = body_hash


async def store_response(request: Request, status: int, body: Any) -> None:
    """Call from a response middleware after the handler returns."""
    store_key = getattr(request.state, "idempotency_key", None)
    body_hash = getattr(request.state, "idempotency_body_hash", None)
    if not store_key or not body_hash:
        return
    r = await _get_redis()
    await r.setex(
        store_key,
        TTL_SECONDS,
        json.dumps({
            "bodyHash": body_hash,
            "status": status,
            "body": body if isinstance(body, str) else json.dumps(body),
        }),
    )
```

**Anti-Patterns:**
- KEIN Idempotency-Layer fuer GET — GET ist per HTTP-Spec idempotent, der Layer ist Overhead ohne Nutzen.
- KEIN globaler Layer fuer alle Routes — nur fuer schreibende Endpunkte mit Side-Effects (DB-Writes, externe Calls, Geld). Sonst Cache-Pollution und 422-Konflikte bei harmlosen Read-Replays.
- KEIN Speicher in Process-Memory (`Map`, `dict`) — geht beim Restart verloren, skaliert nicht ueber mehrere Instanzen. Redis oder Postgres, sonst gar nicht.
- KEINE TTL > 7 Tage — Keys werden ewig gespeichert, Speicher waechst monoton. 24h ist der Default, max 7d mit Begruendung.
- KEINE eigene UUID-Generierung server-seitig — Idempotency-Key kommt vom Client, sonst ist die ganze Idee kaputt (Client kann nicht erkennen ob ein Retry ein neuer oder ein wiederholter Call ist).

---

## lib/retry.{js,py} (BOO-25 — Retry-Helper mit exponential Backoff + Jitter)

**Transiente Fehler werden begrenzt automatisch wiederholt.** Default: max 3 Retries, exponential Backoff (Faktor 2), Jitter zur Vermeidung von Thundering Herd. **Hard Constraint:** Retry NUR bei transienten Fehlern (5xx, Timeout, Connection-Reset). KEIN Retry bei 4xx (Client-Fehler), 422 (Validation) oder Idempotency-Konflikten — die werden durch Wiederholung nicht besser.

> [!important] Retry-Policy ist Status-Code-spezifisch
> Ein 500 lohnt einen Retry (Server-Hickup). Ein 400 nicht (Client-Bug — derselbe Request scheitert wieder). Ein 422 schon gar nicht (Validation-Fehler — der Body ist falsch, nicht das Netzwerk). Der Wrapper unten filtert explizit, was retry-faehig ist.

### Node.js — `lib/retry.js`

**Devdep:**

```bash
npm install p-retry
```

(p-retry 8.x — Wrapper um `retry` mit AbortSignal-Support. ESM-only, daher in Node.js-Projekten mit `import` oder dynamischem `require`.)

```javascript
// lib/retry.js
// BOO-25 Retry-Wrapper mit exponential Backoff + Jitter.
// Default: 3 Retries, factor=2, minTimeout=100ms, maxTimeout=10000ms, randomize=true.
// HARD CONSTRAINT: nur transiente Fehler werden retried — siehe shouldRetry().

// p-retry ist ESM-only — in CommonJS via dynamic import.
const TRANSIENT_STATUS = new Set([408, 429, 500, 502, 503, 504]);

function isTransientError(err) {
  // Network / timeout
  if (err && (err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT' || err.code === 'ENOTFOUND')) {
    return true;
  }
  // HTTP-status-coded errors (axios/fetch wrapper convention)
  const status = err?.response?.status ?? err?.status;
  if (typeof status === 'number') {
    return TRANSIENT_STATUS.has(status);
  }
  // Unknown -> conservative: do not retry, surface immediately.
  return false;
}

async function withRetry(fn, options = {}) {
  const { default: pRetry, AbortError } = await import('p-retry');
  const opts = {
    retries: options.retries ?? 3,
    factor: options.factor ?? 2,
    minTimeout: options.minTimeout ?? 100,
    maxTimeout: options.maxTimeout ?? 10000,
    randomize: options.randomize ?? true, // Jitter
    onFailedAttempt: options.onFailedAttempt,
  };

  return pRetry(async () => {
    try {
      return await fn();
    } catch (err) {
      // Non-transient -> AbortError stops retry loop immediately.
      if (!isTransientError(err)) {
        throw new AbortError(err);
      }
      throw err;
    }
  }, opts);
}

module.exports = { withRetry, isTransientError };
```

### Python — `lib/retry.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "tenacity>=9.0",
]
```

(tenacity >=9.0 — siehe `jd/tenacity` README, aktuelle Major-Linie.)

```python
# lib/retry.py
# BOO-25 Retry-Wrapper mit exponential Backoff + Jitter via tenacity.
# Default: 3 Versuche, exponential mit Multiplikator 0.1s, max 10s.
# HARD CONSTRAINT: nur transiente Fehler werden retried — siehe is_transient().

import logging
from typing import Any, Callable

import httpx
from tenacity import (
    retry,
    retry_if_exception,
    stop_after_attempt,
    wait_random_exponential,
)

log = logging.getLogger(__name__)
TRANSIENT_STATUS = {408, 429, 500, 502, 503, 504}


def is_transient(exc: BaseException) -> bool:
    """True if the exception represents a retryable, transient failure."""
    # Network / timeout layer
    if isinstance(exc, (httpx.ConnectError, httpx.ReadTimeout, httpx.WriteTimeout)):
        return True
    # HTTP-status-coded layer
    if isinstance(exc, httpx.HTTPStatusError):
        return exc.response.status_code in TRANSIENT_STATUS
    # Unknown -> conservative: do not retry.
    return False


def with_retry(
    fn: Callable[..., Any] | None = None,
    *,
    attempts: int = 3,
    multiplier: float = 0.1,
    max_wait: float = 10.0,
):
    """Decorator factory: retry transient failures with exponential backoff + jitter."""
    decorator = retry(
        stop=stop_after_attempt(attempts),
        wait=wait_random_exponential(multiplier=multiplier, max=max_wait),
        retry=retry_if_exception(is_transient),
        before_sleep=lambda rs: log.warning(
            "retry attempt=%s waiting=%.2fs reason=%s",
            rs.attempt_number,
            rs.next_action.sleep if rs.next_action else 0,
            rs.outcome.exception() if rs.outcome else None,
        ),
        reraise=True,
    )
    if fn is None:
        return decorator
    return decorator(fn)
```

**Anti-Patterns:**
- KEIN unendlicher Retry — Default ist 3 Versuche, hart begrenzt. "Retry bis es klappt" macht aus einem 30-Sekunden-Outage einen 3-Stunden-Outage und blockt den Caller.
- KEIN Retry ohne Jitter — alle Clients retryen synchron, der wieder hochfahrende Backend-Server bekommt N-faches Load-Spike (Thundering Herd).
- KEIN Retry bei 4xx/422 — Client-Fehler werden durch Wiederholung nicht besser. Der Status-Code-Filter ist Pflicht.
- KEIN Retry bei Idempotency-Key-Konflikten (HTTP 422 aus `lib/idempotency.{js,py}`) — der Server sagt explizit "anderer Body mit gleichem Key", Wiederholung verschlimmert nichts, aber loest auch nichts.
- KEIN Retry-Wrapper um nicht-idempotente Operationen ohne Idempotency-Key — sonst entsteht beim ersten Retry der Doppel-Charge / die Doppel-Buchung. Retry und Idempotency sind ein Paar.

---

## lib/circuit-breaker.{js,py} (BOO-25 — Circuit-Breaker-Wrapper pro externe Abhaengigkeit)

**Externe Abhaengigkeit failed schnell statt langsam.** Ein Circuit Breaker um jeden Aufruf zu DB / externer API / Message Bus. Drei Zustaende: **Closed** (Normal), **Open** (Fehler erkannt — sofortiger Fail ohne Call), **Half-Open** (nach Reset-Timeout: Test-Anfragen, ob die Abhaengigkeit wieder lebt).

> [!important] Pro externe Abhaengigkeit ein eigener Breaker
> KEIN globaler Breaker fuer "alles externe". Wenn die DB langsam ist und der Auth-Service schnell ist, soll Auth nicht mit-failen, weil DB den globalen Breaker oeffnet. Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate Instanzen mit eigenen Schwellen. Schwellen pro Abhaengigkeit anpassen: DB darf langsamer sein als Auth-Service.

> [!note] Bulkhead-Pattern als Folge
> Ein Breaker pro Abhaengigkeit ist die Light-Variante eines Bulkheads — die Abhaengigkeiten sind voneinander isoliert. Echtes Bulkhead-Pattern (separate Thread-Pools / Connection-Pools pro Abhaengigkeit) ist eine Stufe darueber und nicht Teil von BOO-25 — Folge-Issue, wenn der Service mehrere parallele Pools rechtfertigt.

### Node.js — `lib/circuit-breaker.js`

**Devdep:**

```bash
npm install opossum
```

(opossum 9.x — siehe `nodeshift/opossum` README, aktuelle Major-Linie.)

```javascript
// lib/circuit-breaker.js
// BOO-25 Circuit-Breaker-Wrapper. Eine Instanz pro externer Abhaengigkeit.
// Beispiel:
//   const dbBreaker = createBreaker(callDb, { name: 'db', timeout: 2000 });
//   const result = await dbBreaker.fire(query);

const CircuitBreaker = require('opossum');

const DEFAULTS = {
  timeout: 3000,                  // ms — wenn Call laenger braucht, gilt er als Fehler
  errorThresholdPercentage: 50,   // % Fehler -> Open
  resetTimeout: 30000,            // ms in Open, dann Half-Open
  volumeThreshold: 10,            // min Calls bevor Fehler-Quote zaehlt
};

function createBreaker(fn, options = {}) {
  const name = options.name || fn.name || 'anonymous';
  const breaker = new CircuitBreaker(fn, { ...DEFAULTS, ...options });

  breaker.on('open', () =>
    console.warn(`[circuit-breaker] OPEN dependency=${name}`));
  breaker.on('halfOpen', () =>
    console.info(`[circuit-breaker] HALF_OPEN dependency=${name}`));
  breaker.on('close', () =>
    console.info(`[circuit-breaker] CLOSED dependency=${name}`));
  breaker.on('reject', () =>
    console.warn(`[circuit-breaker] REJECT dependency=${name} (open, fail-fast)`));

  // Fallback ist Operator-Choice — pro Breaker setzen falls Graceful Degradation moeglich.
  // Beispiel: dbBreaker.fallback(() => cachedResult);
  return breaker;
}

module.exports = { createBreaker };
```

### Python — `lib/circuit-breaker.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "pybreaker>=1.0",
  # Fuer asyncio-Stacks alternativ: "aiobreaker>=1.2" (eigener Wrapper notwendig)
]
```

(pybreaker 1.x — siehe `danielfm/pybreaker` README. Fuer reine asyncio-Workloads ist `aiobreaker` eine separate Lib mit kompatibler API; Operator-Choice.)

```python
# lib/circuit_breaker.py
# BOO-25 Circuit-Breaker-Wrapper. Eine Instanz pro externer Abhaengigkeit.
# Beispiel:
#     db_breaker = create_breaker(name="db", fail_max=5, reset_timeout=30)
#
#     @db_breaker
#     def query_db(...): ...

import logging
from typing import Iterable

import pybreaker

log = logging.getLogger(__name__)


class _Listener(pybreaker.CircuitBreakerListener):
    def __init__(self, name: str) -> None:
        self.name = name

    def state_change(self, cb, old_state, new_state):
        log.warning(
            "circuit_breaker dependency=%s old=%s new=%s",
            self.name,
            getattr(old_state, "name", old_state),
            getattr(new_state, "name", new_state),
        )

    def failure(self, cb, exc):
        log.info("circuit_breaker dependency=%s failure=%r", self.name, exc)


def create_breaker(
    name: str,
    *,
    fail_max: int = 5,
    reset_timeout: int = 30,
    exclude: Iterable[type[BaseException]] = (),
) -> pybreaker.CircuitBreaker:
    """One breaker per external dependency. Schwellen je nach Abhaengigkeit anpassen."""
    return pybreaker.CircuitBreaker(
        fail_max=fail_max,
        reset_timeout=reset_timeout,
        exclude=list(exclude),
        listeners=[_Listener(name)],
        name=name,
    )
```

**Graceful Degradation als Fallback-Hook:** Wenn der Breaker `Open` ist, geht jeder Call sofort in den Fallback. Der Fallback ist Operator-Choice pro Abhaengigkeit:

- **Cache-Read** statt DB-Read (Stale-Daten ok kurz).
- **Default-Wert** statt externer API (Beispiel: leere Empfehlungen statt 500).
- **Queue + Async-Verarbeitung** statt Sync-Call (Anfrage spaeter zustellen).
- **HTTP 503 + `Retry-After`-Header** wenn keine andere Strategie passt — mindestens dem Client signalisieren.

**Anti-Patterns:**
- KEIN globaler Breaker fuer alle externen Calls — siehe Header-Callout. Pro Abhaengigkeit eine Instanz.
- KEIN Breaker fuer interne Funktion-Calls (in-Process) — Breaker schuetzen vor langsamen externen Aufrufen, nicht vor lokalen Fehlern. Lokale Fehler sind Bugs und sollen sofort sichtbar sein.
- KEINE einheitliche Konfig fuer alle Breaker — DB darf langsamer sein als Auth-Service. Schwellen pro Abhaengigkeit, dokumentiert im Code.
- KEIN Breaker ohne Logging — der State-Wechsel (Closed -> Open -> Half-Open) muss in den Logs erscheinen, sonst ist der Breaker ein Black Box. Logging via Pino (Node) / structlog (Python) aus BOO-14.
- KEIN Breaker ohne Fallback und ohne 503-Antwort — sonst ist "Open" fuer den Client ununterscheidbar von "Service kaputt". Mindestens 503 mit `Retry-After` zurueckgeben.

---

## Decisions/ADR-Template

Vorlage fuer eine einzelne Entscheidungs-Datei unter `Decisions/` (Obsidian) oder `docs/decisions/` (Repo-only).

```markdown
---
title: "[Kurztitel der Entscheidung]"
datum: {{TODAY}}
status: offen  # offen | entschieden | verworfen
type: entscheidung  # entscheidung | fachliche-entscheidung
---

# ADR-XX: [Titel]

## Kontext

[Was ist der Hintergrund? Warum muss diese Entscheidung getroffen werden?]

## Optionen

1. **[Option A]** — [Kurzbeschreibung + Pro/Contra]
2. **[Option B]** — [Kurzbeschreibung + Pro/Contra]

## Entscheidung

[Welche Option wurde gewaehlt und warum?]

## Konsequenzen

- [Was aendert sich durch diese Entscheidung?]
- [Welche Folge-Issues entstehen?]
```

---

### `sonar-project.properties (BOO-5 — SonarQube Cloud Config)`

Wird von `/bootstrap` Block D §D.5 generiert wenn SonarQube Cloud aktiviert.
Platzierung: Projekt-Root.

```properties
# SonarQube Cloud — generiert von /bootstrap BOO-5
# Anpassen: sonar.projectKey und sonar.organization auf deine GitHub-Org und Repo setzen.

sonar.projectKey={{GITHUB_ORG}}_{{REPO_NAME}}
sonar.organization={{GITHUB_ORG}}

# Quellen — Node/Python Standard:
sonar.sources=src
sonar.exclusions=node_modules/**,dist/**,build/**,coverage/**,.semgrep/**

# Optional — Coverage-Report einbinden (aus /implement Coverage-Gate BOO-15):
# Node (Vitest/Jest):
#   sonar.javascript.lcov.reportPaths=coverage/lcov.info
# Python (pytest-cov):
#   sonar.python.coverage.reportPaths=coverage.xml

# Optional — Test-Quellen:
# sonar.tests=tests
# sonar.test.exclusions=**/*.test.js,**/*.spec.js
```

**Platzhalter ersetzen:**
| Platzhalter | Wert |
|-------------|------|
| `{{GITHUB_ORG}}` | GitHub-Organisations- oder Nutzer-Name |
| `{{REPO_NAME}}` | Repository-Name |

**Hinweis:** Projekt-Key und Organisation muessen exakt mit dem SonarCloud-Projekt uebereinstimmen (angelegt unter https://sonarcloud.io).

---

### `.github/workflows/sonar.yml (BOO-5 — SonarQube Cloud CI Gate)`

Wird von `/bootstrap` Block D §D.5 generiert wenn SonarQube Cloud aktiviert.
Voraussetzung: `SONAR_TOKEN` als GitHub Repository Secret (via `gh secret set SONAR_TOKEN`).

```yaml
# SonarQube Cloud CI Gate — generiert von /bootstrap BOO-5
# Trigger: Push auf main + alle Pull Requests

name: SonarQube Cloud

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  sonarqube:
    name: SonarQube Scan
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Pflicht fuer SonarQube Blame-Analyse

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Erweiterung mit Coverage (empfohlen nach BOO-15 Coverage-Gate):**

Node.js (Vitest):
```yaml
      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npx vitest run --coverage

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
Zusatz in `sonar-project.properties`: `sonar.javascript.lcov.reportPaths=coverage/lcov.info`

Python (pytest):
```yaml
      - name: Install dependencies
        run: pip install -r requirements.txt pytest pytest-cov

      - name: Run tests with coverage
        run: pytest --cov=src --cov-report=xml

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
Zusatz in `sonar-project.properties`: `sonar.python.coverage.reportPaths=coverage.xml`

`type: fachliche-entscheidung` — fuer fachliche/regulatorische ADRs (z.B. "warum FIFO-Accounting", "warum strikte KYC-Regel X"). `/sprint-review` zaehlt beide Typen in der Decision-Rate.

---

### `.claude/sensitive-paths.json (BOO-18 — Mandatory Human Review)`

Wird von `/bootstrap` Phase 4.4i angelegt wenn der Operator sensible Pfade konfiguriert.
Platzierung: `.claude/sensitive-paths.json` (im `.gitignore` NICHT — explizit committen für Audit-Trail).

```json
{
  "patterns": [
    "auth/**",
    "authn/**",
    "authz/**",
    "payment/**",
    "billing/**",
    "**/*credential*",
    "**/*personal*",
    "**/*pii*",
    "**/*gdpr*"
  ],
  "review_required_by": ["{{OPERATOR_NAME}}"],
  "human_review_reminder": "Diese Story berührt sensitive Pfade — bitte Zeile-für-Zeile prüfen, nicht nur Plan freigeben."
}
```

**Platzhalter ersetzen:**
| Platzhalter | Wert |
|-------------|------|
| `{{OPERATOR_NAME}}` | GitHub-Handle oder Name des verantwortlichen Reviewers |

**Hinweis:** Die Pattern-Liste ist ein Minimal-Default. Operator ergänzt projektspezifische sensitive Pfade (z.B. `src/api/**` für kritische API-Endpunkte, `stripe/**` für Payment-Integration).
