---
name: bootstrap
version: 3.23.0
description: Setzt ein neues Projekt mit Governance-Framework auf — interaktiver Block-Interview-Flow in 4 Schritten, Doku-Architektur mit Hub-Auto-Verlinkung, optionaler Learning-Loop L1/L2/L3. Verwenden wenn der Operator ein neues Projekt aufsetzen will oder "/bootstrap" sagt.
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [setup, project-init, governance-config]
    requires_toolsets: [terminal, git, github, obsidian]
    related_skills: []
---

# Bootstrap — Neues Projekt aufsetzen (v3.0)

Setzt ein neues Projekt mit Governance-Framework auf. Der Flow ist in **4 Bloecke (A-D)** strukturiert — jeder Block mit klarem Fokus, keine Fragen-Batches.

Referenzen:
- `references/info-gathering.md` — Kern-Fragen (Block A)
- `references/existing-infra-check.md` — Bestehende Infrastruktur (Block B)
- `references/doc-architecture-proposal.md` — Doku-Architektur (Block C)
- `references/optional-components.md` — Self-Healing / DocSync / Daemon / Learning-Loop (Block D)
- `references/learning-loop.md` — L1/L2/L3 Design
- `references/file-templates.md` — Dateischablonen
- `references/skills-setup.md` — Skills aus GitHub ziehen
- `references/global-registry-update.md` — SecondBrain-Integration
- `references/hooks-setup.md` — Governance-Hooks

---

## Phase 0: Briefing (vor allen Fragen)

Den Operator zuerst informieren, dann starten:

```
Bootstrap v3.0 — ich fuehre dich durch 4 Bloecke:

  Block A — Projekt-Kern           (7 Fragen,  ~3 min)
  Block B — Bestehende Infra       (5 Fragen,  ~3 min)
  Block C — Doku-Architektur       (Vorschlag + Review)
  Block D — Optional-Komponenten   (4 Ja/Nein-Fragen am Ende)

Danach lege ich das Projekt an. Gesamt ~15 min.
Bereit? [ja / spaeter]
```

Warte auf `ja`.

---

## Phase 1: Block A — Projekt-Kern

Lies `references/info-gathering.md` fuer die vollstaendige Fragenliste. Stelle die Fragen **einzeln oder in kleinen Gruppen** (max 3 pro Rueckfrage), nicht als Batch.

### A.1 Stack-Frage (zuerst)

```
Was moechtest du entwickeln?
  a) Node.js / JavaScript Backend (API, CLI, Daemon)
  b) Frontend (React, Vue, Vanilla JS)
  c) Full-Stack (Backend + Frontend)
  d) Python (KI/ML, Scripts, FastAPI, Django)
  e) Anderes / Noch nicht klar
```

Antwort als `STACK_CHOICE` merken — bestimmt welche Linting-Tools angelegt werden:

| Wahl | Linter-Config | Formatter |
|------|--------------|-----------|
| a) Node.js | `eslint.config.mjs` | — |
| b) Frontend | `eslint.config.mjs` + `.prettierrc` | Prettier |
| c) Full-Stack | beide | Prettier |
| d) Python | `pyproject.toml` (Ruff + Black) | Black |
| e) Anderes | `eslint.config.mjs` (generisch) | — |

### A.1b Lighthouse-CI fuer Frontend-Performance (BOO-45, nur bei STACK_CHOICE = b oder c)

Wenn `STACK_CHOICE = b` (Frontend) oder `c` (Full-Stack mit Frontend-Anteil), Folge-Frage:

```
Lighthouse-CI fuer Web-Performance aktivieren?
  Pendant zu BOO-16 Performance-Gate fuer Backend-Services, aber gegen die Browser-URL.
  Misst LCP, FID, CLS + Bundle-Size + Accessibility und blockt Merge bei Budget-Verletzung.
  [ja / spaeter]
```

Bei `ja`:
- Render `lighthouserc.json` mit Performance-Budgets (LCP <2.5s, CLS <0.1, TBT <300ms, Mobile-Throttling 3G-slow) — Template in `references/file-templates.md` §`lighthouserc.json (BOO-45)`
- Render `.github/workflows/lighthouse.yml` (treosh/lighthouse-ci-action@v12, auf jeden Push + PR) — Template in `references/file-templates.md` §`.github/workflows/lighthouse.yml (BOO-45)`
- Beide Files schreiben Reports nach `journal/reports/ci/run-${{ github.run_id }}/lighthouse.json` (BOO-32-Konvention)
- HANDBUCH §Lighthouse-Integration (Anhang H) erklaert die manuellen Operator-Tasks: Frontend-URL pro Environment eintragen, Performance-Budgets justieren, Mobile-Throttling-Profil waehlen

Bei `spaeter`: kein Template angelegt. Operator kann via `migrate_boo_45()` nachholen.

`LIGHTHOUSE_CHOICE = yes | later` merken fuer Phase 4.

### A.2 Projekt-Identitaet (3 Fragen)

```
1. Projektname? (z.B. MyAnalytics)
2. Ein-Satz-Beschreibung: Was macht das System?
3. Start-Version? (default 0.1.0)
```

### A.3 Backlog (2 Fragen)

```
4. Issue-Prefix? (default aus Projektname abgeleitet, z.B. "MA-" fuer MyAnalytics)
5. Primaere Sprache fuer Doku? (de / en, default: de)
```

### A.4 Architektur-Dimensionen + Add-ons (1 Frage)

```
6. Standard-Dimensionen (immer aktiv): Reliability, Data Integrity, Security,
   Performance, Observability, Maintainability, Testability, Scalability, KI-Tauglichkeit.

   Zusaetzliche Add-ons aktivieren (Multi-Select)?
   [ ] Privacy / DSGVO — fuer Voice-Assistants, personenbezogene Daten, Tier-Modelle
   [ ] Cost Efficiency — bei LLM-lastigen / SaaS-Subscription-Projekten
   [ ] Signal Quality — bei ML / Analytics / Signal-Systemen
   [ ] Compliance — fuer regulierte Branchen (Gesundheit, Finanz, Legal)
```

Jedes aktivierte Add-on ergaenzt die Architektur-Dimensionen in `ARCHITECTURE_DESIGN.md` + entsprechende Sektion in `SECURITY.md` / `GOVERNANCE.md`.

**Merken:** `ADDONS = [...aktivierte]`

Phase-1-Checkpoint: Kurze Bestaetigung der Antworten ausgeben.

---

## Phase 2: Block B — Bestehende Infrastruktur

Lies `references/existing-infra-check.md` fuer den vollstaendigen Dialog-Flow.

Der Skill respektiert bereits vorhandene Infrastruktur — nicht alles neu anlegen.

```
Hast du bereits folgendes eingerichtet? (jede Frage einzeln beantworten)

1. Projekt-Verzeichnis?
   [a] Ja + absoluter Pfad
   [b] Nein, neu anlegen — wo? (absoluter Pfad)

2. GitHub-Repo?
   [a] Ja + URL
   [b] Nein, spaeter anlegen (keine Remote jetzt)
   [c] Kein GitHub gewuenscht

3. Obsidian-Vault fuer Doku?
   [a] Ja + absoluter Pfad
   [b] Nein, nur im Repo dokumentieren

4. Backlog-System?
   [a] Linear + Team-Slug
   [b] Microsoft 365 Planner
   [c] GitHub Issues
   [d] Keines

5. API-Keys fuer das Projekt?
   [a] Existieren bereits in .env
   [b] .env.example reicht, Keys spaeter
```

**Merge-Modus:** Wenn ein Ordner/Repo/Vault existiert und Dateien enthaelt, **vor dem Ueberschreiben** fragen:

```
Warnung: {PROJECT_PATH} enthaelt bereits Dateien.
  [a] Backup anlegen + Bootstrap fortsetzen
  [b] Nur fehlende Governance-Dateien ergaenzen (merge)
  [c] Abbruch
```

**Merken:** `EXISTING_INFRA = {...}` fuer weitere Phasen.

Phase-2-Checkpoint: Zusammenfassung ausgeben.

---

## Phase 3: Block C — Doku-Architektur-Vorschlag

Lies `references/doc-architecture-proposal.md` fuer die vollstaendige Begruendung.

Basierend auf Stack-Wahl (A.1) und Infra-Status (Block B) einen konkreten Doku-Struktur-Vorschlag praesentieren:

```
Vorschlag: 3-Schichten-Doku mit ARCHITECTURE_DESIGN.md als zentralem Hub

  Schicht 1 — Story-Specs (Repo)
    Pfad:     {PROJECT_PATH}/specs/<PREFIX>XXX.md
    Zweck:    Pro Story ein Spec, git-versioniert
    Trigger:  Pflicht vor jeder Code-Aenderung (spec-gate.sh)

  Schicht 2 — Component-Docs (Obsidian)
    Pfad:     {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/*.md
    Zweck:    Lebende Doku pro Komponente (Stack, Status, offene Fragen)
    Trigger:  Update bei jedem /implement (T_last-Pflicht)
    Komponenten-Vorschlag (basierend auf Stack): {STACK_SUGGESTION}

  Schicht 3 — Architektur-Vorgaben (Obsidian)
    Pfad:     {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Architektur-Vorgaben.md
    Zweck:    Konsolidierte Leitprinzipien, Stack-Entscheidungen, verworfene Alternativen
    Trigger:  Update bei ADR-Aenderungen

  Hub (Repo)
    Pfad:     {PROJECT_PATH}/ARCHITECTURE_DESIGN.md
    Zweck:    Einstiegspunkt fuer /ideation, /architecture-review, /implement
    §9 Referenzen verlinkt automatisch auf alle obigen Dateien

Passt das? [ja / anpassen / skip Obsidian-Schicht]
```

**Komponenten-Vorschlag (STACK_SUGGESTION) je nach A.1:**
- Node.js Backend → `api.md`, `db.md`, `background-jobs.md`, `auth.md`
- Frontend → `ui.md`, `state.md`, `routing.md`, `api-client.md`
- Full-Stack → `frontend.md`, `backend.md`, `api.md`, `db.md`
- Python → `cli.md`, `core.md`, `integrations.md`, `data.md`
- Anderes → fragt den Operator nach Komponenten-Namen

Operator kann Komponenten anpassen oder eigene eingeben.

**Bei `ja`:**
- Components-Skelette werden in Phase 4 angelegt
- `ARCHITECTURE_DESIGN.md §9 Referenzen` wird initial befuellt
- Optional `orphan-check.sh` Hook wird in Phase 4 installiert (fragt explizit: "Hook, der prueft ob jede neue `*.md` im Hub registriert ist? [ja, empfohlen / nein]")

**Bei `anpassen`:** Dialog fragt welche Schichten + Pfade gewuenscht sind.

**Bei `skip Obsidian-Schicht`:** Alle Docs im Repo (`docs/components/`), kein SecondBrain-Anteil.

Phase-3-Checkpoint: Doku-Struktur bestaetigen.

---

## Phase 4: Grundstruktur anlegen

### 4.1 Verzeichnisstruktur

```bash
mkdir -p {PROJECT_PATH}/{lib,agents,.claude/skills,.claude/hooks,specs,docs,journal,intents,pitch}
```

### 4.2 Git-Repo initialisieren (falls noch nicht vorhanden)

```bash
cd {PROJECT_PATH}
git init
# Remote nur setzen wenn B.2 == Ja + URL
git remote add origin {GITHUB_REPO}
```

`.gitignore` aus `references/file-templates.md` anlegen — enthaelt seit BOO-36 den Block `journal/reports/local/` (Iteration-Outputs aus `/implement` Schritt 6, lebend nur lokal — werden NICHT committed, weil sie pro Run einmalig und re-erzeugbar sind. `/sprint-review` aggregiert sie in `journal/sprint-{date}.md`, das wird committed). Pendant: `journal/reports/ci/` bleibt fuer CI-Runs aus GitHub Actions (separater Pfad, getrennt entscheidbar).

### 4.3 Kern-Dateien aus Templates rendern

Aus `references/file-templates.md` mit Block-A-Angaben befuellen:

| Datei | Template-Sektion |
|-------|-----------------|
| `lib/config.js` | config.js |
| `CLAUDE.md` | CLAUDE.md (mit Hub-Regel) |
| `SYSTEM_ARCHITECTURE.md` | SYSTEM_ARCHITECTURE.md |
| `ARCHITECTURE_DESIGN.md` | ARCHITECTURE_DESIGN.md (Hub mit §9 Referenzen) |
| `INDEX.md` | INDEX.md |
| `COMPONENT_INVENTORY.md` | COMPONENT_INVENTORY.md |
| `.env.example` | .env.example |
| `CHANGELOG.md` | CHANGELOG.md |
| `specs/TEMPLATE.md` | specs/TEMPLATE.md |

> **KI-Architektur-Block (BOO-24):** Das `ARCHITECTURE_DESIGN.md`-Template enthaelt bereits den Pflicht-Block "KI-Architektur-Prinzipien + Anti-Patterns" in §2 (Design-Rationale). Referenz: `bootstrapping/references/ki-architektur-prinzipien.md`. Der Block wird automatisch beim Template-Rendering befuellt — kein manueller Schritt noetig. `/architecture-review` (BOO-7) prueft alle 8 Checks reaktiv bei jeder Story.

Aus `references/governance-template.md`:
- `GOVERNANCE.md` mit Projektname + Prefix + aktivierten Add-ons

Aus `references/issue-writing-guidelines-template.md` (Version 3.1, BOO-30):
- `.claude/ISSUE_WRITING_GUIDELINES.md` mit ISSUE_PREFIX
- Enthaelt seit v3.1 die Pflicht-Sektion `## Definition of Done (Pflicht)` als 5er-Checkliste (lokale Gates, PR-Merge, Required Status Checks, kein "QA Failed", Spec-File-Update) — 1:1 aus BOO-30
- Operator-Hinweis: Linear-Workflow-States (Backlog → In Progress → In Review → QA Failed → Done → Cancelled) muessen pro Projekt einmalig manuell im Linear-Team angelegt werden — siehe Phase 4.4l

Zusaetzlich Skelette:
- `DEVELOPMENT_PROCESS.md` — Verweis auf GOVERNANCE.md
- `SECURITY.md` — Minimales Skelett (Add-on-Sektionen: Privacy/Compliance falls aktiviert)

> **KERN-REGEL in CLAUDE.md:** Jede neue Datei MUSS sofort in `ARCHITECTURE_DESIGN.md §9 Referenzen` UND `INDEX.md` eingetragen werden — vor dem git commit.

### 4.4 Linting-Konfiguration

Basierend auf `STACK_CHOICE` — siehe `references/file-templates.md`:
- Node.js / Full-Stack / Anderes → `eslint.config.mjs` (ESLint v9 Flat Config)
- Frontend / Full-Stack → zusaetzlich `.prettierrc`
- Python → `pyproject.toml` (Ruff + Black)

Zusaetzlich Stack-abhaengig **CI-Lint-Workflow (BOO-28)** — wird nur angelegt wenn `B.2 == ja` (GitHub-Repo angelegt). Pendant zur Semgrep-CI-Action (Phase 4.4c) — gleicher Layer-3-Mechanismus, andere Tool-Klasse (Lint statt SAST):

| STACK_CHOICE | CI-Workflow-Datei | Quelle |
|--------------|-------------------|--------|
| a) Node.js Backend | `.github/workflows/eslint.yml` | `references/file-templates.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` |
| b) Frontend | `.github/workflows/eslint.yml` | siehe oben |
| c) Full-Stack | `.github/workflows/eslint.yml` | siehe oben |
| d) Python | `.github/workflows/ruff.yml` | `references/file-templates.md` §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` |
| e) Anderes | keiner — Operator entscheidet manuell | — |

Beide Workflows schreiben SARIF nach `.ci-reports/` (Pflicht — wird in BOO-32 fuer Hermes-Konsumtion und in BOO-29 als Required Status Check `eslint` / `ruff` gelesen) und uploaden via `github/codeql-action/upload-sarif@v3` in den GitHub-Security-Tab.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): BOO-28-Schritt skippen, nur Layer 2 (Pre-Commit-Hook, Phase 4.6) deckt Linting lokal ab.

### 4.4b SAST-Konfiguration (Semgrep — alle Stacks)

Aus `references/file-templates.md` §.semgrep.yml + §.semgrepignore:

- `.semgrep.yml` — Drei-Layer-Default-Ruleset:
  - **Layer 1 (Pflicht, alle Stacks):** `p/security-audit`, `p/secrets`
  - **Layer 2 (sprach-spezifisch, auto-erkannt):** `p/javascript` wenn `package.json` vorhanden, `p/python` wenn `pyproject.toml` vorhanden
  - **Layer 3 (optional, auskommentiert):** `p/owasp-top-ten` — Operator entscheidet pro Web-Projekt
- `.semgrepignore` — Default-Excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`)

Die Sprach-Erkennung passiert beim Bestandsprojekt-Migrationspfad in `migrate_boo_3()` — fuer ein neues Projekt (Bootstrap-Flow) wird die jeweilige Layer-2-Zeile basierend auf `STACK_CHOICE` direkt aktiv eingefuegt:

| STACK_CHOICE | Layer-2-Aktivierung |
|--------------|--------------------|
| a) Node.js Backend | `p/javascript` aktiv |
| b) Frontend | `p/javascript` aktiv |
| c) Full-Stack | `p/javascript` aktiv |
| d) Python | `p/python` aktiv |
| e) Anderes | beide auskommentiert (Operator entscheidet manuell) |

Bei Frontend-/Full-Stack-Projekten zusaetzlich beim Anlegen Hinweis ausgeben:

```
Empfehlung: bei Web-App auch Layer 3 (p/owasp-top-ten) in .semgrep.yml aktivieren.
Einkommentieren ueber: sed -i '' 's/^  # - p\/owasp/  - p\/owasp/' .semgrep.yml
```

Konsumiert vom Pre-Commit-Hook (Layer 2, siehe Phase 4.6) und der GitHub Action (Layer 3, siehe Phase 4.4c).

### 4.4c CI-Layer (Semgrep, BOO-4)

Wenn `B.2 == ja` (GitHub-Repo angelegt), wird zusaetzlich `.github/workflows/semgrep.yml` aus `references/file-templates.md` §`.github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)` angelegt.

Die Action liest dasselbe `.semgrep.yml`-Manifest wie der Pre-Commit-Hook (Layer 2, Phase 4.6) — identische Manifest-Reader-Logik, identische Pack-Auswahl. Blockiert Merge in `main` via Required Status Check `Semgrep` (Branch-Protection wird in BOO-29 aktiviert).

| Layer | Wo | Wann | Was |
|-------|-----|------|-----|
| Layer 2 | `.git/hooks/pre-commit` | bei `git commit` | lokal blockierend, ESLint + Semgrep |
| Layer 3 | `.github/workflows/semgrep.yml` | bei `push`/`pull_request` auf `main` | CI-blockierend, Semgrep mit SARIF-Output nach `.ci-reports/` |

**Wichtig:** Beide Layer lesen `.semgrep.yml`. Wer den Hook lokal via `--no-verify` umgeht, wird in Layer 3 gefangen — Belt-and-Suspenders.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): Phase 4.4c skippen, nur Layer 2 (Hook) wird in Phase 4.6 installiert.

### 4.4d Test-Setup (BOO-15)

Voraussetzung fuer das Coverage-Gate (BOO-15) im `/implement`-Skill (Schritt 6a-quart). Ohne JSON-Coverage-Output wird das Gate uebersprungen mit Hinweis. Stack-abhaengig:

- **Node (a/b/c):** `c8` als devDependency installieren — `npm install --save-dev c8` — und in `package.json` ein Coverage-Test-Skript ergaenzen:
  ```json
  "scripts": {
    "test:coverage": "c8 --reporter=json --reporter=text-summary npm test"
  }
  ```
  Coverage-Output landet in `coverage/coverage-final.json`.

- **Python (d):** `pytest-cov` in `pyproject.toml` als Test-Dependency aufnehmen, Test-Lauf mit `pytest --cov --cov-report=json --cov-report=term-missing`. Coverage-Output landet in `coverage.json`.

- **Anderes (e):** Operator entscheidet manuell, Stack-passendes Coverage-Tool mit JSON-Export aktivieren.

Test-Verzeichnis-Konvention: `tests/` (Python), `__tests__/` oder `test/` (Node) — die Filter-Logik im Hook erkennt diese Pfade automatisch und schliesst Test-Dateien selbst aus der Diff-Coverage-Berechnung aus.

Coverage-Output-Pfade (Hook erwartet):
| Stack | Pfad |
|-------|------|
| Node (c8) | `coverage/coverage-final.json` |
| Python (pytest-cov) | `coverage.json` |

Hinweis: das Coverage-Gate selbst wird in Phase 4.6 installiert (`coverage-check.sh`), aber NICHT im Pre-Commit-Hook aufgerufen.

### 4.4e Environment-Awareness (BOO-34)

Voraussetzung dafuer, dass alle nachgelagerten Skills (implement, sprint-review, breakfix, ...) ihre Mac-/VPS-/CI-Awareness aus einer **Single Source of Truth** lesen, statt selbst Detection zu fahren. Single Source of Truth ist `.claude/environment.json` (Manifest), erzeugt vom mitgelieferten Bash-Generator.

Aus `references/file-templates.md` §`.claude/environment.json (BOO-34 — Skill-Umgebungs-Awareness)` und §`.claude/generate-environment-json.sh (BOO-34)`:

- `.claude/generate-environment-json.sh` — Bash-Generator (~120 Zeilen, BSD- und Linux-kompatibel, idempotent: schreibt nur wenn File fehlt oder `--force`-Flag). Keine Dependencies ausser `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`.
- Direkter erster Lauf nach dem Anlegen: `bash .claude/generate-environment-json.sh`
- Ergebnis: `.claude/environment.json` mit `environment` (mac/vps/ci, CI-Check zuerst), `tools_available` (eslint, semgrep, Test-Framework, SonarQube), `paths` (journal/reports/lessons/specs), `metadata` (created_at, bootstrap_version=3.3.0, stack).

> **Wichtig zur Detection-Reihenfolge:** CI-Check (env-var `$CI`) VOR Mac/VPS — ein CI-Runner kann Linux ODER Mac sein. Sonst wird ein Mac-CI-Job faelschlich als `mac` markiert.

`metadata.stack` wird analog zur BOO-3-Stack-Erkennung gesetzt:

| Indikator | stack-Wert |
|-----------|-----------|
| `package.json` + (`tsconfig.json` ODER `"typescript"` in deps) | `node-typescript` |
| `package.json` ohne TypeScript | `node-javascript` |
| `pyproject.toml` | `python` |
| Beide (`package.json` + `pyproject.toml`) | `mixed` |
| Keiner | `unknown` |

Konsumiert von **allen** Sub-Skills via Schritt-0-Read (Rollout in BOO-34 Sub-Agent #2). Beispiel-Pattern:

```bash
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
fi
```

Bei Tooling-Aenderung (z.B. Semgrep nachinstalliert) Datei mit `bash .claude/generate-environment-json.sh --force` neu generieren. Die Datei wird committed — `metadata.created_at` ist Audit-Spur.

### 4.4f Observability-Skelett (BOO-14)

Voraussetzung dafuer, dass jedes Projekt ab Tag 0 eine **strukturierte Logging-, Metrics- und Alert-Konvention** hat — nicht erst spaeter retrofittet wird. Schrader Code Crash Kap. 3 §Production Readiness §Observability + Kap. 4 §Run the System (Saeule 3 Observability): "Wer ohne Observability deployed, fliegt blind."

Aus `references/file-templates.md` §`observability.md (BOO-14 — Observability-Skelett)`, §`observability/alerts/<service>.yml (BOO-14)` und §`observability/.env.observability (BOO-14)`:

- `observability.md` (Projekt-Root) — zentrales Skelett mit drei Pflicht-Sektionen:
  - **Logging-Schema** — strukturierte JSON-Logs mit Pflicht-Feldern (`timestamp`, `level`, `service`, `trace_id`, `message`, `context`)
  - **Metrics-Endpoint** — `/metrics` im Prometheus-Format pro Service, Port-Konvention `9090+N` (auth=9091, api=9092, ...)
  - **Alert-Rules** — drei Pflicht-Alerts pro Service: `{service}_down` (`up == 0` fuer >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% fuer 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s fuer 5 min, severity warning)
- `observability/alerts/<service>.yml` — Pro Service aus Block C eine Prometheus-Alert-Rules-Datei.
- `observability/.env.observability` — Routing-Konfiguration (Telegram/Slack/Email-Webhooks). **Wird ge-gitignored**, nur `.env.observability.example` committed.
- `.gitignore`-Eintrag: `observability/.env.observability`.

**Block-C-Kopplung:** Pro Service aus Block C (`STACK_SUGGESTION` — z.B. `api.md`, `db.md`, `auth.md` bei Node.js) wird in `observability.md` eine Sektion `### Service: <name>` angelegt + eine Datei `observability/alerts/<name>.yml` mit den drei Pflicht-Alerts.

**Stack-Defaults** (Vorschlag, Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Logger-Lib | Metrics-Lib |
|-------|-----------|-------------|
| Node.js (a/b/c) | `pino` | `prom-client` |
| Python (d) | `structlog` | `prometheus_client` |
| Frontend (b) | Hinweis: Browser-Logs gehen an Backend-Service, nicht direkt an Prometheus |
| Anderes (e) | Operator entscheidet — als ADR in `docs/domain/adrs/` dokumentieren |

**Validierung (optional, falls `promtool` lokal installiert):**

```bash
promtool check rules observability/alerts/*.yml
```

Wenn `promtool` nicht installiert: Skip mit Hinweis. Empfehlung: `brew install prometheus` (Mac) bzw. `apt install prometheus` (VPS) beim ersten Service mit echten Alert-Rules.

> **Issue-Referenz:** BOO-14, Schrader Code Crash Kap. 3 §Production Readiness §Observability sowie Kap. 4 §Run the System (Saeule 3 Observability).

### 4.4g Performance-Baseline (BOO-16)

Voraussetzung dafuer, dass Performance-Regressionen **vor** dem Merge auffallen — nicht erst in Production. BOO-14 hat bereits den Production-Alarm `{service}_p95_slow` etabliert; BOO-16 ergaenzt den Pre-Production-Gate: CI-Bench gegen lebende Baseline, blockiert Merge bei p95 > Baseline +20 %. Schrader Code Crash Kap. 3 §Production Readiness (Gate 3: Performance Baseline) — ohne Baseline keine sichtbare Regression.

Aus `references/file-templates.md` §`Performance-Baseline-Gate (BOO-16 — P95 + 20%-Rueckfall-Alarm)` mit den vier Sub-Sektionen:

- `journal/perf-baseline.json` (Projekt-Root, committed) — lebende Baseline mit `p50_ms`, `p95_ms`, `p99_ms`, `req_per_sec`, `recorded_at`, `commit_sha`, `bench_tool` pro Service. Beim Bootstrap initial mit `services: []` angelegt; Operator befuellt nach erstem gruenen CI-Lauf.
- `bench/<service>.bench.js` (Node-Stack) ODER `bench/<service>_bench.py` (Python-Stack) — Service-Benchmark mit autocannon (Node, 30s Lauf, 10 Connections, Warmup 5s) bzw. pytest-benchmark + httpx (Python, Approximation `p95 ≈ mean + 1.645*stddev`).
- `.github/workflows/perf.yml` — CI-Gate (`pull_request` gegen `main` + `workflow_dispatch`), Schwellen `<=1.05` PASS / `1.05-1.20` WARNING (PR-Comment) / `>1.20` FAIL. Override via PR-Label `perf-override` ODER Commit-Trailer `Perf-Override: <begruendung>`, append-only nach `journal/reports/perf/overrides.log`.
- `journal/reports/perf/overrides.log` — entsteht beim ersten Override; append-only Audit-Spur.

**Block-C-Kopplung:** Pro Service aus Block C (`STACK_SUGGESTION`) wird ein Bench-File angelegt + ein Eintrag in der Workflow-Matrix `service: [...]`. Service-Namen identisch zu `observability.md` (Kebab-Case).

**Stack-Defaults** (Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Bench-Tool | Bench-File | bench_tool-Wert in Baseline |
|-------|-----------|-----------|----------------------------|
| Node.js (a/c) | autocannon (devDep) | `bench/<service>.bench.js` | `autocannon` |
| Python (d) | pytest-benchmark + httpx (test-Dep) | `bench/<service>_bench.py` | `pytest-benchmark` |
| Frontend (b) | Lighthouse CI (separater Issue) | — | aus BOO-16-Scope ausgeschlossen |
| Anderes (e) | Operator-Choice mit JSON-Output (p50/p95/p99) | — | `other` |

> [!important] autocannon hat kein natives p95
> autocannon's `result.latency` exponiert `p2_5, p50, p75, p90, p97_5, p99, ...` — kein `p95`. Wir nutzen `p97_5` als konservative Approximation (worst-case Bias nach oben — eine echte Regression wird erkannt, harmlose Schwankungen ggf. groesser dargestellt). Das ist explizit dokumentiert in der Baseline ueber `bench_tool: "autocannon"`. Details siehe Template-Sektion.

> [!important] GitHub-Hosted-Runner-Varianz
> Standard-Runner sind shared Hardware mit +/- 30 % Varianz zwischen identischen Laeufen. Der 20%-FAIL-Threshold ist absichtlich generoes — er faengt echte Regressionen, nicht Noise. Folge-Issue (nach BOO-16): Self-Hosted-Runner mit reservierter CPU/Memory, dort kann der Threshold auf 10 % geschaerft werden.

> [!note] Erstbefuellung der Baseline
> Frischer Repo-State: `services: []`. Erster CI-Lauf failt mit "Baseline fehlt". Operator laed das Bench-Artefakt herunter, kopiert die Werte manuell in `perf-baseline.json` und committed mit Begruendung — danach laeuft das Gate. Auto-Befuellung waere ein Anti-Pattern, weil dann jede Regression automatisch zur neuen Baseline wird.

> **Issue-Referenz:** BOO-16, Schrader Code Crash Kap. 3 §Production Readiness (Gate 3: Performance Baseline). Pendant zum Production-Alarm `{service}_p95_slow` aus BOO-14.

### 4.4h Reliability-Skelett (BOO-25)

Sechste Saeule des Schrader-Modells: Reliability als Architektur-Eigenschaft. Wer nur deployed und hofft, baut einen Demo. BOO-25 setzt fuenf Invarianten als konkrete Skelett-Dateien an: Idempotenz, Retry+Backoff, Circuit Breaker, Graceful Degradation und SLO+Error-Budget. Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability) — die Differenz zwischen "es lief beim Start" und "es laeuft Monat zwei".

Aus `references/file-templates.md` §`Reliability-Skelett (BOO-25 — 5 Invarianten Idempotenz/Retry/Circuit-Breaker/Graceful-Degradation/SLO)` mit den vier Sub-Sektionen:

- `docs/SLO.md` (Projekt-Root, committed) — Service Level Objective Manifest mit drei SLIs (Availability / Latency P95 / Error Rate), PromQL-Mess-Methode (liest aus dem `/metrics`-Endpoint von BOO-14), Error-Budget-Tabelle pro Quartal mit Verbrauch-Tracker, Review-Cadence in `/sprint-review` (monatlich).
- `lib/idempotency.{js,py}` — Idempotency-Key-Middleware (Express-Middleware bzw. FastAPI-Dependency). Liest Header `Idempotency-Key` (UUID v4), persistiert Request-Hash + Response in Redis fuer 24h TTL. Bei Wiederholung mit gleichem Key: cached Response. Bei gleichem Key + abweichendem Body: HTTP 422.
- `lib/retry.{js,py}` — Retry-Wrapper mit exponential Backoff + Jitter. Default: 3 Versuche, Faktor 2, Jitter aktiv. **Hard Constraint:** nur transiente Fehler (5xx, Timeout, Connection-Reset) werden retried — KEIN Retry bei 4xx oder 422.
- `lib/circuit-breaker.{js,py}` — Circuit-Breaker-Wrapper, **eine Instanz pro externe Abhaengigkeit** (DB, externe API, Message Bus). Drei States (Closed/Open/Half-Open), Logging via Pino/structlog (BOO-14), Fallback als Operator-Choice (Cache / Default / 503 + `Retry-After`).

**Phase 4.4h ist OPTIONAL** — nicht jeder Service braucht alle vier Skelette ab Tag 0. Operator-Frage am Anfang der Phase:

```
Reliability-Skelett aus BOO-25 anlegen? (Schrader Saeule 6)
  a) ja, alle vier (SLO + Idempotency + Retry + Circuit Breaker)  — empfohlen fuer Backend mit externer Abhaengigkeit
  b) nur Idempotency + SLO  — minimaler schreibender Service ohne externe Abhaengigkeiten
  c) nur SLO  — reine Lese-Services, Reliability-Mess-Manifest reicht
  d) nein  — uebersrpingen (Default fuer reines Frontend / Skript / experimentelles Setup)
```

**Default-Empfehlung pro Stack:**

| Stack | Default-Antwort | Begruendung |
|-------|-----------------|-------------|
| Node.js (a/c) | a) alle vier | Backend mit Side-Effects, externe Calls erwartet |
| Python (d) | a) alle vier | dito |
| Frontend (b) | d) nein | kein Server-Endpoint, Backend macht das |
| Anderes (e) | c) nur SLO | Tool-unabhaengig, Mess-Manifest immer sinnvoll |

**Stack-Defaults pro Skelett** (Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Idempotency | Retry | Circuit Breaker | SLO |
|-------|-------------|-------|-----------------|-----|
| Node.js (a/c) | `lib/idempotency.js` + `redis@5.x` | `lib/retry.js` + `p-retry@8.x` | `lib/circuit-breaker.js` + `opossum@9.x` | `docs/SLO.md` |
| Python (d) | `lib/idempotency.py` + `redis>=5.0` | `lib/retry.py` + `tenacity>=9.0` | `lib/circuit-breaker.py` + `pybreaker>=1.0` | `docs/SLO.md` |
| Frontend (b) | nicht aktiv (Backend macht das) | nicht aktiv | nicht aktiv | nicht aktiv |
| Anderes (e) | Operator-Choice | Operator-Choice | Operator-Choice | `docs/SLO.md` |

> [!important] SLO ist Architektur-Artefakt, kein Marketing-Versprechen
> Wer 99,99 % schreibt ohne Multi-Region oder Active-Passive-Failover, ist unehrlich. Default-Empfehlung: 99,9 % fuer Single-Region (43,8 min Downtime/Monat), 99,95 % mit Failover, 99,99 % nur mit Multi-Region + Chaos-Tests. Hoeher ist eine Luege bis zum Beweis des Gegenteils.

> [!important] Idempotency NUR fuer schreibende Endpunkte
> Anwenden auf POST / PUT / PATCH / DELETE — nicht auf GET (per HTTP-Spec idempotent, der Layer ist Overhead). Auch nicht global fuer alle Routes — nur dort, wo Side-Effects passieren (DB-Writes, externe API-Calls, Geld-Bewegung).

> [!important] Circuit Breaker pro externe Abhaengigkeit, nicht global
> Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate Instanzen mit eigenen Schwellen. Wenn die DB langsam ist, soll Auth nicht mit-failen. Schwellen pro Abhaengigkeit anpassen, dokumentiert im Code.

> [!note] Kopplung zu Reliability-Dimension in `architecture-review`
> Die Reliability-Dimension in `architecture-review/references/dimensions-detail.md` §1 listet diese fuenf Invarianten als Pflicht-Checks. Die hier erstellten Skelette sind die operationalisierte Form derselben Invarianten — bei `/architecture-review` werden die `lib/`-Dateien und `docs/SLO.md` gegen die Pflicht-Checks gehalten.

> **Issue-Referenz:** BOO-25, Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability). Pendant zur Reliability-Dimension in `architecture-review/references/dimensions-detail.md` §1.

### 4.4i Sensitive-Paths-Konfiguration (BOO-18)

Stellt sicher, dass Code-Aenderungen an sensiblen Pfaden (Auth, Payment, PII) einen **Mandatory Human Review** ausloesen — Schritt 5.5 im `/implement`-Skill blockiert den Commit bis der Operator explizit freigegeben hat. Schrader Code Crash Kap. 3 §Enterprise Governance.

Operator-Frage:

```
Sensitive Pfade fuer Mandatory Human Review konfigurieren? (BOO-18)
  a) ja — `.claude/sensitive-paths.json` mit Default-Patterns anlegen (empfohlen fuer jedes Projekt mit Auth/Payment/PII)
  b) nein — überspringen (Default fuer rein experimentelle Projekte ohne sensible Daten)
```

Bei `a) ja`:
- `.claude/sensitive-paths.json` aus `references/file-templates.md` §`.claude/sensitive-paths.json (BOO-18)` rendern
- `{{OPERATOR_NAME}}` mit dem Projektnamen oder GitHub-Handle des Operators befuellen
- Operator darauf hinweisen: Pattern-Liste ergaenzen fuer projektspezifische sensible Pfade (z.B. `src/api/**`, `stripe/**`)
- Datei committen: `git commit -m "chore: .claude/sensitive-paths.json — Mandatory Human Review Patterns (BOO-18)"`

Bei `b) nein`: Skip mit Log-Eintrag "BOO-18 Human Review: deaktiviert".

> **Wichtig:** `.claude/sensitive-paths.json` wird NICHT in `.gitignore` eingetragen — Audit-Trail-Pflicht. Wer sensible Pfade definiert, muss das committen.

> **Issue-Referenz:** BOO-18, Schrader Code Crash Kap. 3 §Enterprise Governance — "Mandatory Human Review fuer sensible Bereiche (Authentication, Payment, PII)".

### 4.5 Component-Skelette (wenn Block C = ja)

Fuer jede Komponente aus dem Doku-Architektur-Vorschlag:
- **Wenn Obsidian-Schicht:** `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/{component}.md`
- **Wenn Obsidian geskipped:** `{PROJECT_PATH}/docs/components/{component}.md`

Skelett-Struktur siehe `references/doc-architecture-proposal.md` (Frontmatter + Zweck + Stack + Architektur + Konfiguration + Phase-Status + Verbundene Stories + Offene Fragen + Referenzen).

Alle Component-Docs werden in `ARCHITECTURE_DESIGN.md §9 Referenzen` eingetragen.

### 4.6 Governance-Hooks installieren

Siehe `references/hooks-setup.md` fuer Details.

Hooks:
- `spec-gate.sh` — blockiert `git commit` mit `<PREFIX>XXX` wenn Spec-File fehlt
- `doc-version-sync.sh` — blockiert wenn `lib/config.js` VERSION erhoeht aber DOC_FILES nicht synchron
- Optional (bei Block C = ja, orphan-check = ja): `orphan-check.sh` — blockiert wenn neue `*.md` nicht im Hub §9 registriert
- `pre-commit` (BOO-4) — Quality-Gate Layer 2: ESLint + Semgrep mit Manifest-Reader. Liest `.semgrep.yml` (BOO-3), extrahiert aktive Packs via `grep` + `sed`, baut `--config p/...`-Flags und ruft Semgrep CLI auf. Inhalt aus `references/file-templates.md` §`.git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)`. Pendant-CI-Layer 3 (`semgrep.yml`-Workflow) wird in Phase 4.4c angelegt — beide Layer lesen dasselbe Manifest.
- `dependency-check.sh` (BOO-12) — Slopsquatting-Schutz: drittes Gate im Pre-Commit-Hook nach ESLint und Semgrep. Eigenstaendiges Bash-Skript unter `.claude/hooks/dependency-check.sh`, das nur lauft wenn `package.json`/`requirements.txt`/`pyproject.toml`/`Cargo.toml` im Diff der gestagten Files ist. Drei Stufen: Existenz-Check (404 -> BLOCK, Halluzination?), Age-Check (Paket <30 Tage alt -> Warnung, Typosquatter-Risiko), CVE-Check (`npm audit` / `pip-audit`, High/Critical -> BLOCK). Mit BOO-12 bekommt der `.git/hooks/pre-commit`-Hook aus BOO-4 einen vierten Aufruf am Ende: `bash .claude/hooks/dependency-check.sh`. Inhalt aus `references/file-templates.md` §`hooks/dependency-check.sh (BOO-12 — Slopsquatting-Schutz)`. Schrader Code Crash Kap. 3-4: 19,7 % der KI-empfohlenen Pakete existieren nicht.
- `coverage-check.sh` (BOO-15) — Diff-Coverage-Gate: misst Coverage nur auf NEU hinzugefuegten Zeilen (`git diff --cached -U0`) gegen `coverage/coverage-final.json` (c8) bzw. `coverage.json` (pytest-cov). Drei Schwellwerte: `>=80%` Pass, `60-80%` Warnung mit Operator-Freigabe, `<60%` BLOCK. Eigenstaendiges Bash-Skript unter `.claude/hooks/coverage-check.sh`. Wird **NICHT** im Pre-Commit-Hook aufgerufen — Tests dauern zu lange und wuerden das 10s-Budget des Hooks sprengen. Stattdessen ruft der `/implement`-Skill den Hook in Schritt 6a-quart auf, nachdem die Test-Suite mit Coverage-Output gelaufen ist. Inhalt aus `references/file-templates.md` §`hooks/coverage-check.sh (BOO-15 — Coverage-Gate >=80% fuer neuen Code)`. Schrader Code Crash Kap. 3 §Production Readiness — Gate 2: Testabdeckung >=80 % auf neuem Code, nicht Gesamt-Coverage.

Registrierung:
```json
// {PROJECT_PATH}/.claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [
        { "type": "command", "command": "bash {PROJECT_PATH}/.claude/hooks/spec-gate.sh" },
        { "type": "command", "command": "bash {PROJECT_PATH}/.claude/hooks/doc-version-sync.sh" }
      ]
    }]
  }
}
```

> **Hinweis:** Der Claude-Code-Harness kann `.claude/settings.json` bei Permission-Grants auto-regenerieren und Hook-Sektionen stripppen. Als robusten Fallback: Hooks zusaetzlich in `.claude/settings.local.json` (gitignored) registrieren.

Hook-Test (probeweise):
```bash
cd {PROJECT_PATH}
echo "test" > test.txt && git add test.txt
git commit -m "test: {ISSUE_PREFIX}1 — should be blocked"
# Erwartet: Governance-Sperre
git restore --staged test.txt && rm test.txt
```

### 4.7 .env anlegen

Wenn `B.5 == Ja (existiert)`: Operator setzt `.env` selbst — Skill referenziert nur.

Wenn `B.5 == Nein`:
```
Ich habe .env.example angelegt. Bitte trage deine Keys in {PROJECT_PATH}/.env ein.
Variablen-Namen stehen in .env.example.
NIEMALS echte Keys im Chat nennen.
```

Warte auf Bestaetigung `done` bevor weiter.

### 4.8 Backlog-Labels einrichten

Wenn `B.4 == Linear`: Skill bietet an, Standard-Labels via Linear-MCP anzulegen:
- `architecture`, `bug`, `feature`, `refactor`, `docs`, `infra`
- Plus Add-on-Labels: `privacy` (wenn Privacy aktiviert), `compliance` (wenn Compliance aktiviert)

Wenn `B.4 == M365 Planner` / `GitHub Issues`: Operator bekommt Label-Liste zum manuellen Anlegen.

Wenn `B.4 == Keines`: Skip.

### 4.9 Erster Git-Commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Initial Governance Setup"
# Push nur wenn B.2 == Ja
git push -u origin main
```

### 4.4j Audit-Trail-Konfiguration (BOO-19)

Session-Logging ist in Claude Code per Default aktiv (`~/.claude/settings.json`). Dieser Schritt stellt sicher dass der Audit-Trail-Mechanismus im Projekt verankert ist.

**Schritte:**

1. `scripts/audit-trace.sh` aus `bootstrapping/bootstrap/scripts/audit-trace.sh` in das Projekt-Verzeichnis kopieren:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/audit-trace.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/audit-trace.sh
   ```
2. Ins Spec-Template (`specs/TEMPLATE.md`) ist der `## Session-Referenz`-Block bereits enthalten — kein manueller Schritt nötig.
3. **GOVERNANCE.md** um Sektion `## Audit-Trail` ergänzen:
   ```markdown
   ## Audit-Trail

   Alle `/implement`-Sessions schreiben automatisch eine Session-Referenz ins Spec-File (BOO-19).
   Rekonstruktion: `bash .claude/scripts/audit-trace.sh {SPEC_ID}`

   **Retention-Policy (ADR anlegen unter `docs/domain/adrs/`):**
   - Session-Logs 90 Tage aufbewahren
   - Lesezugriff: nur Operator (lokales `~/.claude/`)
   - Sensitive Prompts mit Produktionsdaten: Projekt-Scope meiden — nicht in `/implement` eingeben
   ```

> **Issue-Referenz:** BOO-19, Schrader "Code Crash" Kap. 3 §Enterprise Governance — "Audit Trails: Jeder Prompt und jede Änderung werden für eine spätere Rekonstruktion protokolliert."

### 4.4k Branch-Protection-Setup (BOO-29)

Voraussetzung dafuer, dass kein Merge in `main` ohne gruene CI-Checks moeglich ist. Wird **nur ausgefuehrt wenn `B.2 == ja`** (GitHub-Repo angelegt) **und** Phase 4.9 (Erster Git-Commit + `git push -u origin main`) bereits gelaufen ist — die Branch-Protection braucht den remote `main`-Branch.

**Schritte:**

1. `scripts/setup-branch-protection.sh` aus `bootstrapping/bootstrap/scripts/setup-branch-protection.sh` in das Projekt-Verzeichnis kopieren:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/setup-branch-protection.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/setup-branch-protection.sh
   ```

2. Skript ausfuehren — liest dynamisch alle `.github/workflows/*.yml` und baut die `required_status_checks[contexts][]`-Liste aus dem ersten `name:`-Feld jedes Workflows:
   ```bash
   cd {PROJECT_PATH}
   bash .claude/scripts/setup-branch-protection.sh
   ```

   Erwartete Detection-Set abhaengig von aktivierten Workflows (Phase 4.4 + 4.4c + 4.4d + 4.4g + Phase 6 D.5):

   | Workflow-Datei (BOO) | Detected Context |
   |----------------------|------------------|
   | `eslint.yml` (BOO-28) | `ESLint` |
   | `ruff.yml` (BOO-28) | `Ruff` |
   | `semgrep.yml` (BOO-4) | `Semgrep` |
   | `tests.yml` / `coverage.yml` (BOO-15) | `Tests` / `Coverage` |
   | `perf.yml` (BOO-16) | `Perf` |
   | `sonar.yml` (BOO-5/D.5) | `SonarQube` (oder `SonarCloud` je Workflow) |

   Workflows, die nicht existieren, werden aus `contexts[]` ausgelassen — das Skript wird nicht hart fehlschlagen, sondern protokolliert in `[INFO]`-Zeilen die tatsaechlich gefundenen Workflows.

3. Skript ruft intern (1:1 aus BOO-29):
   ```bash
   gh api -X PUT "repos/${OWNER}/${REPO}/branches/main/protection" \
     -F required_status_checks[strict]=true \
     -F required_status_checks[contexts][]=<dynamisch> \
     -F enforce_admins=false \
     -F required_pull_request_reviews[dismiss_stale_reviews]=true \
     -F required_pull_request_reviews[required_approving_review_count]=1 \
     -F restrictions=null \
     -F allow_force_pushes=false
   ```

   Idempotent — der PUT-Call ist Replace, also re-run-safe. Mehrfaches Ausfuehren ueberschreibt die Protection identisch.

4. **Voraussetzungen, die das Skript selbst prueft (mit Operator-Meldung bei Fehler):**
   - `gh --version` (CLI installiert?)
   - `gh auth status` (eingeloggt mit `repo`-Scope?)
   - `git remote get-url origin` (Remote vorhanden?)
   - Remote `main`-Branch existiert (`gh api repos/<owner>/<repo>/branches/main`)

   Bei Fehlschlag wird klar geloggt, was als naechstes zu tun ist (z.B. `gh auth login`, `git push -u origin main`) — kein stiller Fail.

5. Verifikation in GitHub-UI: `https://github.com/<owner>/<repo>/settings/branches` — Protection-Rule sollte aktiv sein mit den detected Checks.

6. Test-PR ohne gruene Checks oeffnen — Merge muss blockiert sein.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): Phase 4.4k komplett skippen — Branch-Protection ist GitHub-spezifisch, hat kein Pendant auf lokalen oder Self-Hosted-Setups ohne GitHub.

> **Issue-Referenz:** BOO-29. Quelle: `scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12). Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-29.

### 4.4l Linear-Workflow-States + GitHub-Integration (BOO-30, manueller Operator-Schritt)

**Nur ausfuehren wenn `B.4 == Linear`** (Backlog-Tool ist Linear). Bei `M365 Planner` / `GitHub Issues` / `Keines` ueberspringen.

**Klare Trennung:**
- **Automatisiert (durch /bootstrap):** Issue-Template wird in Phase 4.3 mit DoD-Pflichtsektion gerendert (siehe oben). DoD-Checkliste ist in `.claude/ISSUE_WRITING_GUIDELINES.md` v3.1 enthalten und im Issue-Template `.github/ISSUE_TEMPLATE/story.yml` ueber `migrate_boo_27()` verankert.
- **Manuell pro Projekt (Operator-Aufgabe):** Linear-Workflow-States anlegen + GitHub-Integration in Linear aktivieren. Die Linear-API koennte das automatisieren, aber Aufwand-/Nutzen-Verhaeltnis ist schlecht (Einmal-Setup pro Projekt, Linear-UI ist klar gefuehrt) — bewusste Entscheidung.

**Operator-Anleitung:** Vollstaendige Schritt-fuer-Schritt-Anleitung im HANDBUCH §8g Linear-Setup pro Projekt. Skill listet hier nur den Checkpoint.

**Workflow-States (1:1 aus BOO-30):**

| State | Bedeutung | Auto-Transition |
|---|---|---|
| Backlog | Triage | initial |
| In Progress | Skill arbeitet, lokale Gates iterativ | manuell |
| In Review | PR offen, CI laeuft | auto bei PR-Open |
| QA Failed | CI rot, Story re-opened | manuell oder Webhook |
| Done | PR gemerged, alle Checks gruen | auto bei PR-Merge |
| Cancelled | verworfen | manuell |

**GitHub-Integration (manuell im Linear-Team):**
1. Linear → Settings → Integrations → GitHub → Connect Repository → Repo des Projekts auswaehlen.
2. Auto-Recognition wirkt sofort fuer:
   - Branch-Names mit `{ISSUE_PREFIX}-XX`-Prefix (z.B. `BOO-30-feature-foo`)
   - PR-Titel mit `{ISSUE_PREFIX}-XX`
   - Commit-Messages mit `{ISSUE_PREFIX}-XX`
   - PR-Body mit `Closes {ISSUE_PREFIX}-XX`
3. PR-Open setzt Issue → `In Review`, Merge setzt Issue → `Done`.

**Checkpoint Operator:**
- [ ] 6 Workflow-States im Linear-Team angelegt (Namen exakt: `Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`)
- [ ] GitHub-Integration mit Projekt-Repo verbunden
- [ ] Test-Story mit Branch `{ISSUE_PREFIX}-XX-test` erstellt — PR-Open transitioniert Issue auf `In Review`

> **Issue-Referenz:** BOO-30. Quelle: `references/issue-writing-guidelines-template.de.md` v3.1 + HANDBUCH §8g. Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-30 (Issue-Template-Erweiterung wird automatisch nachgezogen, Linear-Setup bleibt manuell).

### Phase 4.10: Domain Deep Research (PFLICHT)

**Zweck:** Domainwissen persistieren bevor Stories geschrieben werden. KI-Operator-Teams haben kein verteiltes Fach-Team-Wissen — dieser Schritt kompensiert das systematisch (Schrader Kap. 2 §Differenzierungskrise).

**Schritte:**

1. Operator fragen: "Welche Branche / welcher fachliche Domain-Kontext gilt fuer dieses Projekt?"
2. `/research` mit dem Projektthema aufrufen — DEEP-Modus:
   - Fachbegriffe + Glossar
   - Regulatorik (DSGVO/BDSG/nDSG, PSD2, MiFID, HIPAA — je nach Branche)
   - User-Personas + Stakeholder
   - Branchenmetriken + KPIs
   - Wettbewerber + Marktstandards
3. Output nach `Research/Domain-Overview.md` schreiben (Frontmatter: `source: claude`, `type: domain-research`)
4. `docs/domain/` Ordner anlegen mit `README.md`-Skelett:

```markdown
# Domain Context

Kuratierte Schluessel-Begriffe fuer [Projektname]. Ein Begriff pro Datei unter `docs/domain/`.
Format: 1 Datei pro Schluessel-Begriff, <30 Zeilen, Beispiele + Gegenbeispiele.

## Bekannte Begriffe
<!-- Wird bei /ideation und /implement erweitert -->

| Begriff | Datei | Beschreibung |
|---------|-------|-------------|
```

5. Fuer jeden Schluessel-Begriff aus der Research eine eigene Datei anlegen: `docs/domain/{begriff}.md`
   Template pro Begriff-Datei:
   ```markdown
   # {Begriff}
   
   **Definition:** [1-2 Saetze]
   
   **Beispiel:** [konkretes Praxis-Beispiel]
   
   **Gegenbeispiel / Abgrenzung:** [was es NICHT ist]
   
   **Regulatorik:** [falls relevant — Norm/Gesetz + Kernpflicht]
   ```

**Nicht optional.** Auch wenn Operator sagt "ich kenn die Branche": Research-Schritt kostet 5–10 Min und spart spaeter Stunden an Story-Nacharbeit durch fehlendes Fachvokabular.

Phase-4-Checkpoint: Zusammenfassung der angelegten Dateien.

---

## Phase 5: Skills installieren

Lies `references/skills-setup.md` fuer Details.

Skills werden aus dem offiziellen GitHub-Repo via `git clone` in einen Temp-Ordner geholt und in `{PROJECT_PATH}/.claude/skills/` kopiert.

```bash
# Temp-Ordner fuer Skill-Quelle
SKILL_SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vibercoder79/claudecodeskills "$SKILL_SRC"
```

### Repo-Struktur

Das `claudecodeskills`-Repo gruppiert Skills in zwei Bereiche:

- **`$SKILL_SRC/bootstrapping/<skill>/`** — Governance-Sub-Skills (architecture-review, backlog, cloud-system-engineer, grafana, ideation, implement, sprint-review, visualize)
- **`$SKILL_SRC/<skill>/`** — Eigenstaendige Top-Level-Skills (design-md-generator, research, security-architect, setup-checklist, skill-creator, u.a.)

### Skill-Auswahl

```
Welche Skills installieren?
  a) Minimum (ideation, implement, backlog)
  b) Standard (+ architecture-review, sprint-review, research, security-architect, skill-creator, setup-checklist)
  c) Voll (alle verfuegbaren: + grafana, cloud-system-engineer, visualize, design-md-generator)
  d) Manuell auswaehlen
```

### Kopieren

Die Kopier-Logik muss wissen, ob ein Skill unter `bootstrapping/` oder Top-Level liegt:

```bash
# Skills unter bootstrapping/ im claudecodeskills-Repo
BOOTSTRAPPING_SUBSKILLS="architecture-review backlog cloud-system-engineer grafana ideation implement sprint-review visualize"

for skill in $SELECTED_SKILLS; do
  if echo "$BOOTSTRAPPING_SUBSKILLS" | grep -qw "$skill"; then
    SRC_PATH="$SKILL_SRC/bootstrapping/$skill"
  else
    SRC_PATH="$SKILL_SRC/$skill"
  fi
  cp -R "$SRC_PATH" "{PROJECT_PATH}/.claude/skills/$skill"
done
```

Ergebnis: Alle Skills landen **flach** in `.claude/skills/<skill>/` — die Verschachtelung `bootstrapping/` existiert nur im Repo, nicht in der Installation.

### Projekt-spezifische Anpassung (generisch, nicht trading-spezifisch)

- `.claude/ISSUE_WRITING_GUIDELINES.md` wird aus `references/issue-writing-guidelines-template.md` gerendert (Issue-Prefix eingesetzt)
- `implement/references/change-checklist.md` enthaelt generische Change-Typen — keine projekt-spezifische Anpassung noetig. Projekt-spezifische Spezial-Checklisten koennen spaeter via `/skill-creator` ergaenzt werden.

### Aufraeumen

```bash
rm -rf "$SKILL_SRC"
```

Phase-5-Checkpoint: Installierte Skills auflisten.

---

## Phase 6: Block D — Optional-Komponenten

Lies `references/optional-components.md` fuer die Implementation-Details.

> **Operator-Hinweis (BOO-30):** Block D ist die richtige Stelle, um den manuellen Linear-Setup aus Phase 4.4l zu finalisieren — Workflow-States anlegen + GitHub-Integration aktivieren — bevor die ersten Stories ueber `/ideation` produziert werden. Issue-Template-Rendering selbst ist bereits in Phase 4.3 automatisiert (DoD-Pflichtsektion). Vollstaendige Operator-Anleitung: HANDBUCH §8g Linear-Setup pro Projekt.

Jede Frage einzeln mit klarer Empfehlung und Default:

### D.1 Self-Healing-Agent

```
Self-Healing-Agent einrichten?
(Cron alle 15 min: prueft Dok-Versionen, Datei-Integritaet, sendet Alerts)

Empfohlen: ab mehreren Mitwirkenden oder wenn Doku-Drift kritisch ist.
[ja / nein (default)]
```

Wenn `ja`: `agents/self-healing.js` aus `references/self-healing-template.js` rendern + Cron-Eintrag generieren.

### D.2 DocSync zum Obsidian-Vault

```
DocSync zum Obsidian-Vault?
(Bei jedem /implement werden Component-Docs im Vault mit-aktualisiert)

Kein Cron — laeuft als Manuelle-Aufforderung via implement-Skill T_last.
Empfohlen wenn Obsidian-Vault angegeben.
[ja (default wenn Vault) / nein]
```

Wenn `ja`: `lib/doc-sync.js` aus `references/doc-sync-template.js` rendern + Mapping Repo → Vault.

### D.3 Automation-Daemon (Linear-Webhook-Listener)

```
Automation-Daemon?
(Vollautomatische Story-Umsetzung ohne Operator-Freigabe — Linear Webhook triggert /implement)

Nur fuer fortgeschrittene Setups mit Linear. Sicherheits-Implikationen beachten.
[ja / nein (default)]
```

Wenn `ja`: Setup-Schritte fuer Linear-Webhook + Daemon.

### D.4 Learning-Loop-Level

Lies `references/learning-loop.md` fuer das vollstaendige Design.

```
Learning-Loop aktivieren?
Der Loop erfasst systematisch: was funktioniert hat, was nicht, naechste Experimente.
Trigger: /sprint-review. Speicherort: journal/ + optional Obsidian.

  L1 — Einfach     (learnings.md, Bullet-Points — empfohlen fuer Solo-Projekte)
  L2 — Strukturiert (Sprint-Journal mit Frontmatter — empfohlen ab 10+ Sprints)
  L3 — SQLite      (quantitative Metriken — empfohlen ab 50+ Sprints)
  nein             (keine Lessons-Learned dokumentieren)

Default: L1. Welches Level?
```

Wenn `L1/L2/L3` gewaehlt:
- `journal/`-Struktur entsprechend anlegen
- `.learning-loop`-Config im Repo (Level speichern)
- Wenn Obsidian aktiv: `04 Ressourcen/{PROJECT_NAME}/learnings.md` als Cross-Link vom PMO-Hub

Learning-Loop wird von `sprint-review` gefuettert (Pflicht-Schritt am Ende des Reviews) und von `ideation` bei Story-Erstellung gelesen (Anti-Pattern-Warnung).

### D.5 SonarQube Cloud

```
SonarQube Cloud aktivieren?
(Code-Qualitaets-Dashboard: Bugs, Smells, Security-Hotspots, Coverage-Trends nach jedem Push)

Kosten: Public Repos gratis. Private Repos ab ~10 EUR/Monat.
[Mac] Lokal: SonarLint VS-Code Connected Mode.
[VPS] Nur CI-Gate — kein IDE-Plugin.

[ja] Skill generiert sonar-project.properties + .github/workflows/sonar.yml
[nein] (default) — kann spaeter nachgezogen werden
```

Wenn `ja`: Lies `references/optional-components.md §D.5` fuer Implementation-Details inkl. Verify-Schritt.
Wenn `nein`: `tools_available.sonarqube_cloud = false` in `.claude/environment.json`.

### D.6 Self-Hosted-Runner (BOO-46, nur wenn Performance-Gate aktiv)

Wenn `STACK_CHOICE` Backend-Anteil hat (`a`, `c`, `d`) UND Performance-Gate aus BOO-16 aktiv ist:

```
Self-Hosted-Runner fuer Performance-Tests aktivieren?
  (Folgeschnitt zu BOO-16. GitHub-Hosted-Runner haben +/-30%% Varianz, daher
   BOO-16-Default-Threshold 20%%. Self-Hosted-Runner mit reservierten Ressourcen
   reduzieren Varianz auf ~5%% — dann kann der Threshold auf 10%% geschaerft werden.)

  Kosten: ein Hostinger-VPS-Beifahrer oder dedizierter Mac-Mini.
  Aufwand: Runner-Software installieren (Step-by-Step in HANDBUCH Anhang I).

  [ja] HANDBUCH §Self-Hosted-Runner-Setup mit Step-by-Step + migrate_boo_46() schaerft perf.yml
  [nein] (default) — GitHub-Hosted bleibt aktiv, Threshold bleibt 20%%
```

Wenn `ja`: Reine HANDBUCH-Verweise (kein Auto-Setup, weil VPS-Installation Operator-Hoheit ist). `migrate_boo_46()` patcht spaeter `perf.yml` (`runs-on: ubuntu-latest` -> `self-hosted`, Threshold 1.20 -> 1.10) wenn Operator den Runner installiert hat.
Wenn `nein`: kein Eintrag in `environment.json`, kein perf.yml-Patch.

Phase-6-Checkpoint: Optional-Komponenten-Status (D.1–D.6).

---

## Phase 7: Finalisierung

Lies `references/global-registry-update.md` fuer die genaue Pfad-Liste.

### 7.1 SecondBrain-Integration (wenn B.3 == Obsidian aktiv)

- `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/` anlegen
- `{PROJECT_NAME} - PMO HUB.md` mit Projekt-Frontmatter, Phase-Tabelle, Backlog-Link, Referenzen-Block
- `Components/`, `Decisions/`, `Meetings/`, `Research/` Ordner anlegen
- `Architektur-Vorgaben.md` Skelett (wird bei /ideation mit Research-Konsolidierung gefuellt)
- Eintrag in `{OBSIDIAN_VAULT}/00 Kontext/Projekte.md` (Projekt-Index)

### 7.2 Globale Registry (~/.claude/)

Wenn der Operator in `~/.claude/CLAUDE.md` eine Projekt-Tabelle hat:
- Projekt-Zeile ergaenzen (Name, Pfad, GitHub, Obsidian-Pfad, Sprint-Review-Frequenz)
- Skill listet Operator die Zeile vor, der bestaetigt den Einfuegepunkt

### 7.3 Finaler Commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Complete Governance Bootstrap"
git push  # nur wenn B.2 == Ja
```

### 7.4 Abschluss-Tabelle

| Phase | Was | Status |
|-------|-----|--------|
| Block A | Projekt-Kern + Stack + Add-ons | done |
| Block B | Bestehende Infrastruktur | done |
| Block C | Doku-Architektur (3 Schichten + Hub) | done |
| Phase 4 | Grundstruktur (Dateien, Git, Linting, Hooks, Labels) | done |
| Phase 5 | Skills installiert ({skill_count}) | done |
| Block D | Optional-Komponenten | {D-Status} |
| Phase 7 | SecondBrain + Registry + Final-Commit | done |

### 7.5 VS Code Extensions (optional, basierend auf STACK_CHOICE)

**Fuer alle Stacks:**
- ESLint `dbaeumer.vscode-eslint`
- SonarLint `SonarSource.sonarlint-vscode`
- Error Lens `usernamehw.errorlens`
- Claude Code `anthropic.claude-code`

**Node.js:** REST Client `humao.rest-client`

**Frontend / Full-Stack:** Prettier `esbenp.prettier-vscode`, Auto Rename Tag `formulahendry.auto-rename-tag`, CSS Peek `pranaygp.vscode-css-peek`

**Python:** Python `ms-python.python`, Black Formatter `ms-python.black-formatter`, Ruff `charliermarsh.ruff`

### 7.6 Naechste Schritte

```
Bootstrap fertig. Weiter mit:

  1. VS Code Extensions installieren (Liste oben)
  2. cd {PROJECT_PATH} && claude
  3. /ideation — erste Story erstellen
  4. Wenn Learning-Loop aktiv: nach 1-2 Sprints /sprint-review laufen lassen
```

---

## Fehlerbehandlung

| Problem | Loesung |
|---------|---------|
| git push schlaegt fehl | SSH Key pruefen: `ssh -T git@github.com` |
| Linear API Fehler | Linear-API-Key in .env pruefen, Team-Slug validieren |
| Obsidian-Pfad nicht erreichbar | Pfad mit `ls` verifizieren, ggf. iCloud-Sync aktiv |
| Hook blockiert Commit | Spec-File anlegen aus `specs/TEMPLATE.md`, Agent-Pattern ausfuellen |
| doc-version-sync blockiert | Alle DOC_FILES auf neue VERSION setzen, dann `git add` |
| Harness strippt Hooks aus settings.json | Hook-Registrierung in `.claude/settings.local.json` (gitignored) als Fallback |
| Component-Doc fehlt nach /implement | T_last-Task im specs/TEMPLATE.md pruefen — muss Component-Update enthalten |
| Learning-Loop-Eintrag vergessen | /sprint-review erneut aufrufen, Schritt 7 ausfuehren |
