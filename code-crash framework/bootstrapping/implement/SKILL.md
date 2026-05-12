---
name: implement
description: |
  Implementierungs-Protokoll fuer CLAW User Stories. 8-Schritte-Workflow von Issue-Identifikation
  bis Ergebnis-Tabelle inkl. Post-Implement Validation. Verwenden wenn der Operator "los" sagt,
  eine Story umsetzen will, oder "/implement" ausfuehrt. Wird auch vom Automation Daemon genutzt
  (ohne Human-in-the-Loop).
version: 2.7.0
metadata:
  hermes:
    category: coding
    tags: [code-generation, deklarativer-modus, quality-gates, token-pre-flight]
    requires_toolsets: [terminal, git, eslint, semgrep]
    related_skills: [ideation, sprint-review]
---

# Implement

User Story aus dem Linear-Backlog systematisch umsetzen. 8 Schritte + Governance-Validation, keiner darf uebersprungen werden.

## Workflow (9 Schritte)

### Schritt 0: Environment laden

1. Lese `.claude/environment.json` (falls vorhanden — sonst Defaults verwenden + Warnung loggen).
2. Bei Bedarf Pfade extrahieren aus `paths.*` (z.B. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Bei Tool-Aufruf pruefen: ist Tool in `tools_available.<tool>` aktiv (z.B. `tools_available.eslint`, `tools_available.semgrep`, `tools_available.tests`)? Bei `false` oder fehlendem Eintrag: Skill ueberspringt den Aufruf und gibt einen Hinweis im Output.
4. Fallback bei fehlender Datei: Standard-Pfade aus dem Schema annehmen (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

### Schritt 0b: Token-Window-Pre-Flight (BOO-40, weich)

Vor jeder Story pruefen, ob die geschaetzte Story-Last die Sprint-Box-Grenze knackt. **Soft-Trigger** — der Operator kann immer weitermachen, der Skill warnt nur. Konvention: HANDBUCH Anhang G (BOO-38).

**Logik:**

1. **Aktuelles Context-Window messen:**
   - Bevorzugt via `/context`-Befehl ODER `claude-code measure-context` (falls verfuegbar)
   - Fallback: Schaetzung aus Chat-Laenge (sehr ungenau — Hinweis im Output)

2. **Story-Token-Schaetzung aus Spec-Frontmatter `token_estimate` lesen** (gesetzt von `/ideation` Schritt 5b — BOO-39).
   - Fallback: aus `estimate` (SP) ableiten gemaess HANDBUCH Anhang G:
     - 1 SP → 5%, 2 → 12%, 3 → 25%, 5 → 50%, 8 → "Story zu gross, splitten"

3. **Projektion berechnen:**
   ```
   projektion_prozent = aktuell_prozent + story_geschaetzt_prozent
   ```

4. **Schwellen aus `.claude/environment.json` lesen** (BOO-38 hat sie als Pflicht-Feld etabliert):
   - `thresholds.token_warn_threshold` (Default 70)
   - `thresholds.token_hard_threshold` (Default 80)

5. **Wenn `projektion > token_hard_threshold`:**

   ```
   [!warning] Token-Pre-Flight:
   - Aktuell: 65% (130k / 200k)
   - Story-Schaetzung: 25% (50k)
   - Projektion: 90% — ueber Sprint-Box-Grenze (80%)

   Empfehlung: Sprint hier abschliessen.
   Naechste Schritte:
   1. /sprint-review starten (aktuellen Sprint-Stand persistieren)
   2. Diesen Chat schliessen
   3. Neuen Chat oeffnen, Story dort starten

   Trotzdem fortfahren? [ja/nein]
   ```

6. **Bei `nein`:** Skill stoppt, gibt /sprint-review-Hinweis und Sprint-Wechsel-Anleitung aus:

   ```
   1. /sprint-review starten (Sprint-File schreiben, L3 aktualisieren)
   2. Letzte Lesson committen
   3. Diesen Chat schliessen
   4. Neuen Chat oeffnen mit:
      "Setze Sprint X fort, naechste Story: BOO-YY"
      /implement BOO-YY
   ```

7. **Bei `ja`:** Risiko-Vermerk in `journal/reports/local/{date}_{story}/meta.json` schreiben (Feld wird in Schritt 6f-bis ergaenzt):

   ```json
   "pre_flight_warning": "projection 90%, user proceeded"
   ```

   ... weiter zu Schritt 1.

8. **Bei `projektion > token_warn_threshold` aber `<= token_hard_threshold`:** weicher Hinweis ohne Block:

   ```
   [!info] Token-Pre-Flight:
   - Projektion: 78% (knapp unter Sprint-Box-Grenze 80%)
   - Hinweis: noch eine kleine Story passt rein, danach Sprint-Ende empfohlen
   ```

   Weiter zu Schritt 1.

**Begruendung Soft-Trigger:** manche Stories sind kleiner als geschaetzt; manche Sprint-Wechsel sind teurer als ein Compact. Operator behaelt Kontrolle. Wenn `pre_flight_warning` in `meta.json` ist und die Session tatsaechlich gecompacted hat → Lesson fuer L3 ("Schaetzung war zu konservativ" oder "User-Entscheid war richtig") → Kalibrierung fuer `/ideation` Token-Heuristik (BOO-39).

### Schritt 1: Issue identifizieren

- `linear.getOpenIssues()` — gesamtes Backlog laden
- Issue mit Status "In Progress" identifizieren (das ist der Auftrag)
- Falls mehrere "In Progress": aeltestes zuerst, Operator fragen bei Unklarheit
- Issue-Description vollstaendig lesen

### Schritt 1b: Schrader-Bestandteile-Gate ⛔ HARD GATE — kein Implement ohne vollstaendigen Prompt

Prueft ob das Issue ein vollstaendiger Schrader-Prompt ist (Code Crash Kap. 5). Kein Soft-Warning — harter Block.

**Ablauf:**

1. Issue-Description auf Sektion `## Schrader-Prompt-Bestandteile` pruefen (alternativ: `## Schrader Prompt Components` fuer EN-Issues)
2. Alle 4 Sub-Sections pruefen — muss mind. 20 Zeichen nicht-leeren Inhalt enthalten (kein Template-Placeholder):
   - `### Insight (Perceive)`
   - `### Constraints`
   - `### Erfolgskriterien` (oder `### Success Criteria`)
   - `### Gewuenschtes Ergebnis` (oder `### Desired Outcome`)
3. Optional: `## Definition of Done` Sektion pruefen — Existenz pruefen (Inhalt nicht tief validiert)

**Bei fehlendem Bestandteil — STOPP:**
```
[STOP] Issue BOO-XX ist kein vollstaendiger Prompt — Schrader-Bestandteil fehlt:
  - [x] Insight: vorhanden
  - [ ] Constraints: leer oder fehlt
  - [x] Erfolgskriterien: vorhanden
  - [x] Gewuenschtes Ergebnis: vorhanden

Geh zurueck zu /ideation und ergaenze den fehlenden Bestandteil bevor du /implement startest.
```

**Bei vollstaendigem Issue:** Weiter zu Schritt 2.

> Pruefung regelbasiert (kein LLM noetig). Issues vor Code Crash Governance v2 (ohne `## Schrader-Prompt-Bestandteile`) koennen den Gate-Check nicht passieren — Operator muss die Sektion nachtraeglich ergaenzen (Migrations-Schritt in `migration-checklist-v1-to-v2.md`).

### Schritt 2: Abhaengigkeits-Check

- `## Abhaengigkeiten` Sektion im Issue pruefen
- Parent-Issue und Siblings pruefen (EPIC-Kontext)
- Gesamtes Backlog auf Referenzen zum Issue durchsuchen (CLAW-XX Mentions)
- **Falls Abhaengigkeit OFFEN:** Operator warnen — "CLAW-XX haengt von CLAW-YY ab (Status: Backlog). Trotzdem fortfahren?"
- **Falls Reihenfolge abweicht:** Impact-Analyse zeigen

### Schritt 3: Kontext aufbauen

- CLAUDE.md lesen (Systemkontext)
- **`ARCHITECTURE_DESIGN.md` lesen** — Lead-Dokument: ADRs, Quality Attributes, Leitprinzipien. Pruefen ob die Story gegen bestehende ADRs oder Quality Attributes verstoesst (z.B. ADR-6: Zero External Dependencies, ADR-5: Kill-Switch First). Verweist auf alle weiteren Architektur-Dokumente.
- Betroffene Code-Dateien identifizieren (aus Issue-Description + eigene Analyse)
- Verwandte abgeschlossene Issues pruefen (was wurde schon gebaut?)
- Architektur-Dimensionen pruefen die fuer diese Story relevant sind:
  Siehe [references/architecture-checklist.md](references/architecture-checklist.md)
- **Domain-Context (wenn vorhanden):** Falls `docs/domain/` im Projekt existiert, relevante `docs/domain/*.md`-Dateien laden (Schluessel-Begriffe die in der Story-Description oder den ACs vorkommen). Bei Sub-Agent-Delegation den Domain-Context als Teil des Mini-Briefings mitgeben: "Relevante Domain-Begriffe fuer diese Story: [Begriff → Pfad zur domain/*.md]"

### Schritt 3b: Governance-Validation (PFLICHT)

Vor der Plan-Erstellung die Governance-Artefakte aus dem Issue validieren.
Siehe [references/governance-validation.md](references/governance-validation.md)

1. **8-Dimensionen pruefen:** Ist die Tabelle im Issue vorhanden? Stimmt die Einschaetzung?
   Fehlt eine Dimension die durch die geplante Aenderung betroffen ist?
2. **Security-Checklist:** Security-by-Design Sektion im Issue lesen.
   SECURITY.md Checkliste fuer den Change-Type durchgehen (neue API? Webhook? externer Input?).
3. **ADD validieren (bei Features):** Architecture Design Document gegen aktuellen Code pruefen.
   Stimmen die genannten Dateien noch? Sind die Integrationspunkte korrekt?
4. **Fehlende Artefakte:** Falls 8-Dimensionen, Security-Sektion oder ACs im Issue fehlen:
   - **Operator warnen:** "Issue CLAW-XX fehlt [Sektion]. Soll ich die Sektion nachtraeglich ergaenzen?"
   - **NICHT stillschweigend weitermachen** — Governance-Luecken muessen sichtbar sein

### Schritt 3c: Spec-File Gate ⛔ HARD GATE — kein Plan ohne Spec

> **Diese Sperre wird zusaetzlich durch `.claude/hooks/spec-gate.sh` maschinell erzwungen.**
> Der Hook blockiert jeden `git commit CLAW-XXX` wenn `specs/CLAW-XXX.md` fehlt.

**Ablauf:**

1. Pruefen: Existiert `specs/CLAW-XXX.md`?

2. **Falls JA:** Spec lesen — stimmt der Inhalt mit dem aktuellen Issue ueberein?
   Falls veraltet: Spec aktualisieren, dann weiter zu Schritt 4.

3. **Falls NEIN → STOPP. Spec jetzt erstellen:**
   a. `specs/TEMPLATE.md` lesen
   b. `specs/CLAW-XXX.md` vollstaendig befuellen:
      - Why (aus Issue uebernehmen)
      - What (Deliverable + Done-Kriterien)
      - Constraints (Must / Must Not / Out of Scope)
      - Current State (betroffene Dateien + bestehende Patterns)
      - Tasks (T1, T2... — max 3 Files/Task, konkreter Verify-Step)
   c. Spec in Git committen: `git commit -m "docs: specs/CLAW-XXX.md erstellt"`
   d. **Operator explizit bestaetigen lassen:**
      Ausgabe: `"Spec-File erstellt: specs/CLAW-XXX.md — bitte prüfen und bestätigen, dann geht es weiter."`
   e. **Warten auf Operator-OK** — erst danach weiter zu Schritt 4
   f. Linear Issue Kommentar: Link zum Spec-File

4. **Keine Ausnahmen** — auch bei kleinen Fixes, Hotfixes, Config-Aenderungen.
   Einzige Ausnahme: reine Doku-Commits ohne Code-Aenderungen.

### Schritt 4: Plan erstellen + Operator-Freigabe

- Konkreten Implementierungsplan praesentieren
- Dateien, Aenderungen, Risiken, Test-Strategie
- **Warten auf Operator-Freigabe** (Human-in-the-Loop)
- Bei Daemon-Ausfuehrung (Auto-Execute): diesen Schritt ueberspringen

### Schritt 5: Implementation (nach Freigabe)

- Sub-Tasks: Vor Implementation → "In Progress", nach Abschluss → "Done"
- Plan vollstaendig umsetzen
- Alle neuen Funktionen, Methoden und Code-Pfade mit Kommentar `// AI-generated: {STORY_ID}` markieren (Rollback-Identifikation, BOO-17). Fuer Python: `# AI-generated: {STORY_ID}`.
- Alle Doku-Files aktualisieren (CLAUDE.md, SYSTEM_ARCHITECTURE.md, etc.)
- Git Commit + Push
- **Session-Referenz ins Spec-File schreiben (BOO-19):**
  ```bash
  # Commit-SHA holen
  COMMIT_SHA=$(git rev-parse HEAD)
  # Neueste Session-Datei fuer dieses Projekt (best-effort)
  SESSION_FILE=$(ls -t ~/.claude/projects/*/sessions/*.jsonl 2>/dev/null | head -1)
  SESSION_ID=$(basename "${SESSION_FILE}" .jsonl 2>/dev/null || echo "unbekannt")
  SESSION_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  ```
  In `specs/CLAW-XXX.md` unter `## Session-Referenz` eintragen:
  ```markdown
  ## Session-Referenz

  **Session-Timestamp:** {SESSION_TS}
  **Session-ID:** `{SESSION_ID}` (best-effort — neueste Session beim Commit)
  **Session-Log:** `~/.claude/projects/.../sessions/{SESSION_ID}.jsonl`
  **Commit-SHA:** `{COMMIT_SHA}`
  **Audit-Trace:** `bash .claude/scripts/audit-trace.sh {SPEC_ID}` (braucht jq)
  ```
  Danach Spec-File committen: `git commit -m "docs: specs/CLAW-XXX.md Session-Referenz (BOO-19)"`

  > Wenn SESSION_FILE leer bleibt (keine Session-Datei gefunden): Nur COMMIT_SHA + SESSION_TS eintragen, SESSION_ID als "unbekannt" markieren — kein STOPP.

- Rueckfragen NUR bei echten Blockern

### Schritt 5.5: Sensitive-Paths-Gate ⛔ STOP BEI SENSITIVEM PFAD (BOO-18)

> Dieser Schritt laeuft NUR wenn `.claude/sensitive-paths.json` im Projekt existiert.
> Ohne diese Datei: sofort weiter zu Schritt 6.

**Ablauf:**

1. `.claude/sensitive-paths.json` lesen — `patterns`-Array laden.
2. Geaenderte Dateien ermitteln:
   ```bash
   git diff --name-only HEAD
   ```
3. Jede geaenderte Datei gegen die Pattern-Liste pruefen (Glob-Matching, `**` = rekursiv):
   - `auth/**` trifft auf `auth/token.js`, `auth/middleware/jwt.js`, etc.
   - `**/*pii*` trifft auf `lib/pii-handler.js`, `src/models/pii.js`, etc.
4. **Kein Treffer → Gate bestanden**, weiter zu Schritt 6.
5. **Treffer vorhanden → PFLICHT-STOPP:**

```
[STOP — SENSITIVE PATH] Die folgenden geaenderten Dateien beruehren sensible Bereiche:
  - auth/token.js  (Pattern: auth/**)
  - lib/pii-handler.js  (Pattern: **/*pii*)

Mandatory Human Review erforderlich (BOO-18, Schrader Kap. 3 §Enterprise Governance).

VOLLSTAENDIGER DIFF ZUR REVIEW:
[diff output hier]

Bitte prüfe den Diff Zeile-für-Zeile und bestätige mit:
  review-ok: {dein-name} - {kurzer Kommentar was geprüft wurde}

Ohne explizite Bestätigung wird der Commit nicht durchgeführt.
```

6. **Auf Review-Bestätigung warten** — Operator antwortet mit `review-ok: ...`
7. **Nach Bestätigung:**
   a. Review-Kommentar ins Spec-File eintragen unter `## Human Review`:
      ```markdown
      ## Human Review
      - **Date:** {{TODAY}}
      - **Reviewer:** {{REVIEWER_NAME}}
      - **Comment:** {{REVIEW_COMMENT}}
      - **Sensitive Paths Touched:** {{LIST_OF_SENSITIVE_FILES}}
      ```
   b. Spec-File committen: `git commit -m "docs: specs/CLAW-XXX.md Human Review dokumentiert (BOO-18)"`
   c. Danach regulaerer Commit mit dem Code.

> **Ohne `review-ok`-Bestätigung:** Schritt 6 wird NICHT erreicht. Keine Ausnahme, kein Auto-Bypass.

### Schritt 6: Post-Implement Validation

Validierung BEVOR das Issue auf "Done" gesetzt wird. Siehe [references/validation-checklist.md](references/validation-checklist.md)

**6-Prelude) Iteration-Run-Setup — Persistenz-Verzeichnis fuer raw Tool-Outputs (BOO-36)**

Bevor die einzelnen Gates (6a/6a-bis/6a-quart/...) iterieren, wird **einmal pro Implement-Run** ein Persistenz-Verzeichnis fuer die raw Tool-Outputs angelegt. Alle Iterations-Outputs (ESLint, Semgrep, Tests, Coverage) landen parallel zur deklarativen Iteration auch dort — `/sprint-review` liest spaeter aus diesem Verzeichnis und aggregiert L2-Lessons. **`/implement` schreibt nur raw Outputs**, NICHT direkt in `journal/learnings.db` (L3). Die Trennung ist hart: Implement persistiert, Sprint-Review aggregiert.

```bash
# Default-Pfad (kann via paths.reports_local aus .claude/environment.json ueberschrieben werden)
REPORTS_BASE="journal/reports/local"
STAMP=$(date -u +%Y-%m-%d_%H%M)
STORY_ID="${ISSUE_KEY}"   # z.B. BOO-36
RUN_DIR="${REPORTS_BASE}/${STAMP}_${STORY_ID}"
mkdir -p "${RUN_DIR}"

# Start-Zeitstempel und Iterationen-Counter initialisieren (Shell-Variablen fuer meta.json)
RUN_STARTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ITER_ESLINT=0
ITER_TESTS=0
ITER_SEMGREP=0
ITER_COVERAGE=0
RUN_FINAL_STATUS="in_progress"
```

**Pfad-Konvention:**
- Default: `journal/reports/local/{YYYY-MM-DD_HHMM}_{STORY-ID}/` (lebend unter Projekt-Root)
- gitignored (Bootstrap legt den Eintrag in `.gitignore` an — siehe `references/file-templates.md` §.gitignore)
- Dateien pro Run:
  - `eslint-iter{N}.sarif` — pro ESLint-Iteration (`--format @microsoft/eslint-formatter-sarif --output-file ...` oder `--format json --output-file ...` als Fallback)
  - `tests-iter{N}.junit.xml` — pro Test-Iteration (`pytest --junit-xml=...` / `jest --reporters=default --reporters=jest-junit` mit `JEST_JUNIT_OUTPUT_FILE`)
  - `coverage-final.json` — Coverage-Endstand (c8 / pytest-cov, JSON-Reporter, einmaliger Lopy am Iterations-Ende)
  - `semgrep-final.sarif` — Semgrep-Endstand (`semgrep --sarif --output ...`, einmaliger Copy am Iterations-Ende)
  - `meta.json` — Run-Metadaten (Schema siehe Schritt 6-Closeout)

**Wichtig:** Schreib-Pfad ist eigenstaendig — wenn ein Gate uebersprungen wird (z.B. kein `eslint.config.mjs`), erscheint die entsprechende Datei nicht im Run-Verzeichnis. `meta.json.iterations.<gate>` bleibt dann auf `0`.

**Bei `tools_available.<tool> == false`** (aus `.claude/environment.json`): Persistenz fuer dieses Gate wird ebenfalls uebersprungen — das Verhalten passt zur regulaeren Gate-Logik, der raw Output entsteht ja gar nicht erst.

**6a) Code Quality Gate — ESLint + SonarLint + Error Lens (deklarative Iteration)**

> **Tool-Kette:** `eslint.config.mjs` definiert Regeln (Industriestandard seit BOO-2:
> ESLint Recommended + Airbnb Base + Security + SonarJS) → ESLint CLI prueft →
> SonarQube for IDE zeigt Tiefenanalyse → Error Lens zeigt beides inline in VS Code.

**Deklarativer Modus (Schrader Code Crash Z. 2105-2141, Compound Engineering Mechanik #1):**
Der Skill iteriert ueber den ESLint-Output bis 0 Errors — der Skill formuliert Code-Fixes
basierend auf den Findings, prueft erneut, und stoppt erst wenn das Gate gruen ist oder
das Iterations-Limit erreicht ist.

```bash
# Alle in diesem Commit geaenderten JS-Dateien pruefen — Pflicht-Run + SARIF-Persistenz pro Iteration
ITER_ESLINT=$((ITER_ESLINT + 1))
git diff --name-only HEAD | grep -E '\.(js|mjs)$' | \
  xargs npx eslint --max-warnings=0 \
    --format @microsoft/eslint-formatter-sarif \
    --output-file "${RUN_DIR}/eslint-iter${ITER_ESLINT}.sarif"
# Fallback ohne SARIF-Formatter: --format json --output-file "${RUN_DIR}/eslint-iter${ITER_ESLINT}.json"
```

> **SARIF vs JSON:** Wenn `@microsoft/eslint-formatter-sarif` als devDependency vorhanden ist, SARIF-Format nutzen (CI-tauglich, GitHub-Action-kompatibel). Sonst Built-in `--format json` als Fallback — dann heisst die Datei `eslint-iter{N}.json`. ESLint nativen SARIF-Support gibt es aktuell nicht; der `@microsoft/eslint-formatter-sarif`-Plugin ist der etablierte Weg.

**Iterations-Loop (Pflicht):**

1. ESLint auf geaenderten Dateien ausfuehren — Output landet IMMER auch in `${RUN_DIR}/eslint-iter${ITER_ESLINT}.sarif` (oder `.json` im Fallback).
2. Wenn `errors > 0`:
   a. Code-Fixes basierend auf Output formulieren (Skill liest Findings, schlaegt Patches vor)
   b. Patches anwenden (Edit-Tool)
   c. `ITER_ESLINT` erhoehen, erneut Schritt 1 pruefen (neuer Iterations-Output landet in `eslint-iter{N+1}.sarif`)
3. Wenn `errors == 0`: Gate bestanden — weiter zu Schritt 6b.
4. **Maximal 5 Iterationen.** Bei Iteration 5 ohne gruen: STOPP mit klarem Hinweis an
   den Operator: welche Findings persistieren, welche Fixes versucht wurden, warum sie
   nicht gegriffen haben. Operator entscheidet (manueller Fix, Regel-Ausnahme, oder Story
   als Carry-Over markieren).

**Gate-Verhalten:**
- **0 Errors + 0 Warnings:** Gate bestanden — weiter zu Schritt 6b.
- **Errors vorhanden + Iterationen verbleibend:** weiter iterieren.
- **Errors vorhanden + Iterations-Limit erreicht:** STOPP, Operator-Eingriff.
- **Nur Warnings:** Operator entscheidet ob akzeptabel (mit Begruendung im Linear-Kommentar).
- Kein `eslint.config.mjs` im Projekt: Gate ueberspringen + Operator hinweisen dass Regeldatei fehlt (BOO-2-Migration).

**Python-Aequivalent:** dasselbe Schema mit `npx eslint` -> `ruff check`, `eslint.config.mjs`
-> `pyproject.toml`. Ruff-Iteration laeuft mit demselben 5-Iterations-Limit. SARIF-Persistenz analog: `ruff check --output-format sarif --output-file "${RUN_DIR}/ruff-iter${ITER_ESLINT}.sarif"` (Ruff hat nativen SARIF-Support seit `ruff` 0.4.x). Counter-Variable bleibt `ITER_ESLINT`, der Datei-Name spiegelt den Linter (`ruff-iter{N}.sarif` statt `eslint-iter{N}.sarif`).

**6a-bis) Security Gate — Semgrep (deklarative Iteration, BOO-4)**

> **Tool-Kette:** `.semgrep.yml` (Manifest aus BOO-3) → Hook-Skript liest aktive Packs
> und konstruiert `--config p/...`-Flags → Semgrep CLI prueft → Findings im Output.
> Zweiter Quality-Gate nach ESLint, gleiche Iterations-Mechanik.

**Manifest-Reader (gleiche Logik wie im Pre-Commit-Hook und der GitHub Action):**

```bash
# Aktive Packs aus .semgrep.yml extrahieren
PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//')
ARGS=""
for pack in $PACKS; do
    ARGS="$ARGS --config $pack"
done

# Semgrep auf geanderten Dateien — SARIF-Persistenz fuer den Final-Lauf
ITER_SEMGREP=$((ITER_SEMGREP + 1))
git diff --name-only HEAD | xargs semgrep $ARGS --error --quiet \
    --sarif --output "${RUN_DIR}/semgrep-final.sarif"
```

> **Semgrep-Persistenz-Konvention:** Wir schreiben pro Iteration NACH `${RUN_DIR}/semgrep-final.sarif` — der File-Name `-final` reflektiert, dass nur der Endstand fuer Sprint-Review interessant ist (Semgrep iteriert seltener als ESLint und das letzte File gewinnt durch Ueberschreiben). Counter `ITER_SEMGREP` wird trotzdem hochgezaehlt fuer `meta.json.iterations.semgrep`.

**Iterations-Loop (gleiche Mechanik wie 6a):**

1. Manifest-Reader laedt aktive Packs aus `.semgrep.yml`.
2. Semgrep auf geanderten Dateien ausfuehren mit konstruierten Flags — Output ueberschreibt `${RUN_DIR}/semgrep-final.sarif`.
3. Wenn Findings vorhanden:
   a. Code-Fixes basierend auf Output formulieren
   b. Patches anwenden (Edit-Tool)
   c. `ITER_SEMGREP` erhoehen, erneut Schritt 2 pruefen
4. Wenn 0 Findings: Gate bestanden — weiter zu 6b.
5. **Maximal 5 Iterationen.** Bei Iteration 5 ohne gruen: STOPP, Operator-Eingriff.

**Gate-Verhalten:**
- 0 Findings: Gate bestanden — weiter zu 6b.
- High/Critical Findings + Iterationen verbleibend: weiter iterieren.
- High/Critical Findings + Iterations-Limit erreicht: STOPP, Operator-Eingriff.
- Nur Medium/Low: Operator entscheidet (mit Begruendung im Linear-Kommentar).
- Kein `.semgrep.yml`: Gate ueberspringen + Operator hinweisen "Regeldatei fehlt — /bootstrap erneut" (BOO-3-Migration).
- Keine aktiven Packs in `.semgrep.yml` (alle auskommentiert): Gate ueberspringen + Hinweis.

**Laufzeit-Budget:** muss unter 10 Sekunden bleiben. Bei groesseren Repos Optimierung via `--baseline-ref HEAD~1` statt voller Scan.

**6a-tris) Dependency Gate — Slopsquatting-Schutz (BOO-12)**

> **Tool-Kette:** `git diff --cached` -> `hooks/dependency-check.sh` -> Registry-Lookup
> (npm view / pip / curl-Fallback) -> Existenz + Age + CVE-Check.
> Schrader Code Crash Kap. 3-4: KI-Halluzinationen sind eigener Angriffsvektor.

**Trigger:** Lauft NUR wenn `package.json`, `requirements.txt`, `pyproject.toml` oder
`Cargo.toml` im Diff sind. Sonst sofort Exit 0 (Performance).

**Drei Checks pro neu hinzugefuegter Dependency:**

1. **Existenz-Check** — Registry-Lookup (npmjs/pypi). 404 → BLOCKIERT (Halluzination?).
2. **Age-Check** — Package <30 Tage alt? Warnung (Typosquatter-Risiko, manuelle Verifikation).
3. **CVE-Check** — `npm audit --audit-level=high` / `pip-audit`. High/Critical → BLOCKIERT.

**Gate-Verhalten:**
- 0 Findings: Gate bestanden — weiter zu 6b.
- Existenz-404 / High/Critical CVE: Gate BLOCKIERT, Operator muss verifizieren oder Paket entfernen.
- Age-Warning: Gate bestanden, aber Hinweis im Output. Operator entscheidet ob das ein Risiko ist.
- Cargo-Diff: Hinweis "Cargo-Vollunterstuetzung in zukuenftiger Iteration", Operator laeuft `cargo audit` manuell.
- Tool-Fallback: Bei fehlendem `npm` / `pip-audit` wird auf curl gegen Registry zurueckgefallen.

**Laufzeit-Budget:** mit Registry-Lookup ueblicherweise 2-5 Sekunden. Bei vielen neuen
Dependencies parallelisierbar — heute serielle Implementation, optimierbar bei Bedarf.

**6a-quart) Coverage Gate — Diff-Coverage >=80% fuer neuen Code (BOO-15)**

> **Tool-Kette:** Test-Lauf (c8 / pytest-cov) -> coverage.json -> hooks/coverage-check.sh
> -> korreliert git diff --added mit Coverage-Daten -> Gate-Entscheidung.
> Schrader Code Crash Kap. 3: Gesamt-Coverage auf Legacy-Repos ist unfair —
> nur Diff-Coverage auf neu hinzugefuegten Zeilen.

**Wichtig:** Dieser Schritt laeuft im Skill, NICHT im Pre-Commit-Hook (Tests
dauern zu lange — wuerde 10s-Budget des Hooks sprengen).

**Iterations-Loop:**

1. Test-Lauf mit Coverage-Output und JUnit-XML pro Iteration:
   - Node: `npx c8 --reporter=json --reporter=text-summary npx jest --reporters=default --reporters=jest-junit` mit `JEST_JUNIT_OUTPUT_FILE="${RUN_DIR}/tests-iter${ITER_TESTS}.junit.xml"`. Coverage-Output landet in `coverage/coverage-final.json`.
   - Python: `pytest --cov --cov-report=json --junit-xml="${RUN_DIR}/tests-iter${ITER_TESTS}.junit.xml"`. Coverage-Output landet in `coverage.json`.
   - Iterations-Counter zuvor hochzaehlen: `ITER_TESTS=$((ITER_TESTS + 1))`.
   - Bei Iteration: `ITER_COVERAGE=$((ITER_COVERAGE + 1))` synchron.
2. `bash .claude/hooks/coverage-check.sh` aufrufen — vergleicht Added-Lines
   aus `git diff --cached -U0` mit Coverage-Daten.
3. Coverage-Endstand nach Run-Verzeichnis kopieren (einmaliger Copy am Iterations-Ende):
   - Node: `cp coverage/coverage-final.json "${RUN_DIR}/coverage-final.json"`
   - Python: `cp coverage.json "${RUN_DIR}/coverage-final.json"`
4. Gate-Verhalten:
   - **>=80% (Pass):** Gate bestanden — weiter zu 6b.
   - **60-80% (Warn):** Operator entscheidet, Begruendung im Linear-Kommentar.
   - **<60% (Block):** Tests hinzufuegen + Iterations-Schritt 1 wiederholen.
5. **Maximal 5 Iterationen.** Bei Iteration 5 ohne gruen: STOPP, Operator-Eingriff
   (manueller Test-Reichweiten-Plan oder Story splitten).

> **JUnit-XML-Konvention:** Sowohl pytest (`--junit-xml=...`) als auch jest-junit (env-var `JEST_JUNIT_OUTPUT_FILE`) schreiben JUnit-XML — Standardformat fuer Test-Reports, von `/sprint-review` parsbar. Wenn der Test-Runner kein JUnit-XML kann (z.B. Mocha ohne Reporter): Persistenz fuer Tests uebersprungen, `ITER_TESTS` wird nicht erhoeht, `meta.json.iterations.tests` bleibt 0 — der Coverage-Lauf selbst laeuft weiter.

**Gate-Verhalten Sonderfaelle:**
- Keine Coverage-Daten (kein `coverage-final.json` / `coverage.json`): Gate
  uebersprungen mit Hinweis "/bootstrap nachziehen fuer Test-Setup".
- Diff hat nur Test-Files / Configs / Docs: Gate uebersprungen.
- Diff hat 0 added lines: Gate uebersprungen.

**Konfiguration:** Schwellwerte sind als Konstanten im Skript (`COVERAGE_PASS=80`,
`COVERAGE_WARN=60`). Operator kann via env-vars override:
`COVERAGE_PASS=90 bash .claude/hooks/coverage-check.sh`.

**Laufzeit-Budget:** Skript-Lauf <2 Sekunden. Test-Lauf selbst kann mehrere
Minuten dauern — daher NICHT im Pre-Commit-Hook.

Schritt 2 — Syntax & Laufzeit:
- `node --check` auf alle geaenderten .js Files (Syntax-Fehler?)
- Falls Agent: 1x ausfuehren im DRY_RUN/TEST_MODE — laeuft er durch ohne Crash?
- Falls Library/Modul: Wird es korrekt importiert von allen Consumern?

**Hintergrund der 6 Tools:**
| Tool | Rolle | Wann aktiv |
|------|-------|-----------|
| **ESLint** (`.eslintrc.js`) | Definiert + prueft Coding-Regeln (Syntax, Security, Style) | CLI in Schritt 6a + passiv in VS Code |
| **Semgrep** (`.semgrep.yml`) | Pre-Commit-SAST mit Pack-basiertem Regelset | CLI in Schritt 6a-bis + Pre-Commit-Hook + CI-Layer |
| **Slopsquatting-Hook** (`.claude/hooks/dependency-check.sh`) | Supply-Chain-Pruefung (Existenz + Age + CVE) | Pre-Commit-Hook nach Semgrep, nur bei Manifest-Diff |
| **Coverage-Hook** (`.claude/hooks/coverage-check.sh`) | Diff-Coverage-Gate (>=80% added lines) | Wann aktiv: /implement Schritt 6a-quart, NICHT Pre-Commit-Hook |
| **SonarQube for IDE** (SonarLint) | Tiefere Security-Analyse, Code Smells, Bug-Patterns | Passiv im Editor waehrend Coding |
| **Error Lens** | Zeigt ESLint + SonarLint Findings inline in der Zeile | Passiv im Editor — kein Verstecken von Fehlern |

**6b) Akzeptanzkriterien + Linear-Kommentar** (PFLICHT)
- Jedes Akzeptanzkriterium aus der Issue-Description einzeln durchgehen
- Checkbox-fuer-Checkbox: Ist das Kriterium erfuellt? Evidenz notieren
- Falls ein Kriterium NICHT erfuellt: Fix implementieren oder Operator informieren
- **Linear-Kommentar schreiben** mit AC-Verification:
  ```
  ## AC-Verification
  - [x] AC 1: [Beschreibung] — ✅ [Evidenz]
  - [x] AC 2: [Beschreibung] — ✅ [Evidenz]
  - [ ] AC 3: [Beschreibung] — ❌ [Grund / was fehlt]
  ```

**6c) Architektur-Quick-Check**
- Nur die relevanten Dimensionen pruefen (siehe architecture-checklist.md)
- Fokus: Wurde etwas eingefuehrt das gegen bestehende Patterns verstoesst?
- Config-SSoT verletzt? Hardcoded Values statt config.js?
- Error Handling vorhanden wo noetig? (API-Calls, File I/O)

**6d) Smoke Test**
- Agent/Feature 1x real ausfuehren (nicht nur Syntax-Check)
- Output plausibel? Signal-File korrekt geschrieben?
- Keine unerwarteten Seiteneffekte auf andere Agents/Signals?

**6e) Security-Findings dokumentieren**
- Was wurde geprueft? (aus Schritt 3b Security-Checklist)
- Was ist sicher? Was wurde mitigiert?
- Offene Risiken die akzeptiert wurden?
- Bei LOW-Risk Stories genuegt: "Security: Keine neuen Angriffsvektoren"

**6f) Ergebnis**
- **PASS:** Weiter zu Schritt 7 (Linear → Done, Change-Log, Push)
- **FAIL:** Zurueck zu Schritt 5, Fix implementieren, erneut validieren
- Validation-Ergebnis als Kommentar im Linear Issue dokumentieren

Nach erfolgreicher Validation:
- Linear → Done + Kommentar (inkl. Validation-Ergebnis)
- Obsidian Change-Log via `linear.writeChangeLog()`

**6f-bis) meta.json schreiben (BOO-36)**

Am Ende des Runs — egal ob PASS, FAIL oder STOP — wird `meta.json` ins Run-Verzeichnis geschrieben. Audit-Spur fuer `/sprint-review`.

```bash
RUN_COMPLETED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
# RUN_FINAL_STATUS aus Schritt 6f setzen: "passed" | "failed" | "stopped_iteration_limit"
# ENVIRONMENT aus .claude/environment.json laden (mac/vps/ci) — Default "unknown" wenn Datei fehlt
ENVIRONMENT=$(jq -r .environment .claude/environment.json 2>/dev/null || echo "unknown")

cat > "${RUN_DIR}/meta.json" <<EOF
{
  "story_id": "${STORY_ID}",
  "started_at": "${RUN_STARTED_AT}",
  "completed_at": "${RUN_COMPLETED_AT}",
  "iterations": {
    "eslint": ${ITER_ESLINT},
    "tests": ${ITER_TESTS},
    "semgrep": ${ITER_SEMGREP},
    "coverage": ${ITER_COVERAGE}
  },
  "final_status": "${RUN_FINAL_STATUS}",
  "environment": "${ENVIRONMENT}"
}
EOF
```

**Schema (Fixwert, nicht erweiterbar in dieser Iteration):**

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
  "environment": "mac"
}
```

**Feld-Konvention:**
- `story_id`: Issue-Key aus Linear (z.B. `BOO-36`)
- `started_at` / `completed_at`: ISO-8601 UTC (`date -u +%Y-%m-%dT%H:%M:%SZ`)
- `iterations.<gate>`: Anzahl Iterationen pro Gate, 0 wenn Gate uebersprungen
- `final_status`: `passed` (Gate alle gruen) | `failed` (Gate-Block ohne Iterations-Limit) | `stopped_iteration_limit` (Iteration 5 erreicht ohne gruen)
- `environment`: `mac` | `vps` | `ci` | `unknown` (aus `.claude/environment.json`)

**Wichtig — Verantwortlichkeits-Trennung:**
- `/implement` schreibt NUR raw Outputs nach `journal/reports/local/` — inkl. `meta.json`.
- `/sprint-review` LIEST `journal/reports/local/` + `ci/` und aggregiert zu `journal/sprint-{date}.md` (L2). In einer zweiten Phase parsed `/sprint-review` die aggregierten Daten in `journal/learnings.db` (L3).
- **`/implement` schreibt NICHT direkt in `learnings.db`.** Diese Trennung haelt Implement schnell (kein DB-Lock, kein Schema-Wissen) und macht Sprint-Review zum Single Writer der Learnings-DB.

**6g) Intent-Verifikation**

> Dieser Schritt wird nur ausgefuehrt wenn `intents/INTENT-XX.md` im Projekt existiert.

1. Aktive `intents/INTENT-XX.md` laden
2. Pro Metrik im Intent:
   - Aktuellen Wert messen (Monitoring, Tests, Logs — je nach Metrik-Typ)
   - Ins Spec-File eintragen (unter `## Intent-Verifikation`):
     ```
     - Metrik: [Name]. Ziel: [Zielwert]. Messung: [Ist-Wert] [✅/⚠/❌]
     ```
3. Wenn alle Metriken ✅ → im Linear-Kommentar als "Intent: alle Metriken erreicht" notieren
4. Wenn Metriken ⚠ oder ❌ → Hinweis: "Intent-Metrik [X] nicht erreicht — neue Story zur Nacharbeit empfohlen?"

**Blockt nicht.** Selbst wenn eine Metrik schlechter geworden ist, geht der Commit durch. Der Measure-Loop dokumentiert nur, damit die naechste Story gezielt gegensteuern kann. (Schrader: "Nach jedem KI-Output fragt sich das Team: Erfuellt das unseren Intent?")

### Schritt 7: Backlog-Update

- Pruefen ob durch die Umsetzung andere Issues im Backlog betroffen sind
- Falls ja: Descriptions aktualisieren (neue Abhaengigkeiten, geaenderte Voraussetzungen)
- Falls Issues obsolet geworden sind: Operator informieren

### Schritt 8: Ergebnis-Tabelle (PFLICHT)

Nach Abschluss IMMER eine Zusammenfassungs-Tabelle ausgeben:

```markdown
| Was | Status |
|-----|--------|
| Config-Aenderung | ✅ Detail |
| Code-Aenderung | ✅ Detail |
| Tests/Verifikation | ✅ Detail |
| Dokumentation | ✅ Detail |
| Git Push | ✅ Commit-Hash |
| Linear → Done | ✅ |
| Obsidian Change-Log | ✅ |
```

Zeilen je nach Umsetzung anpassen. Jede Zeile mit Checkmark und kurzem Detail.
Der Operator soll auf einen Blick sehen was gemacht wurde, ohne nachfragen zu muessen.

Danach: **`## Zusammenfassung` im Spec-File befuellen** (`specs/CLAW-XXX.md`).
Kein Fachjargon — so erklaert als wuerde man es einem Laien erzaehlen der das System nicht kennt.
3 Absaetze: (1) Was war das Problem? (2) Was wurde gebaut / wie funktioniert es? (3) Was aendert sich dadurch?
Dann committen: `git commit -m "docs: specs/CLAW-XXX.md Zusammenfassung ergaenzt"`

## Aenderungs-Checkliste (PFLICHT nach jeder Code-Aenderung)

Siehe [references/change-checklist.md](references/change-checklist.md)
