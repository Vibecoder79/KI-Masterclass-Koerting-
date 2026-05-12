# Migrations-Checkliste Governance v1 → v2

Diese Checkliste fuehrt Bestands-Projekte mit Governance v1 systematisch auf v2 nach. Sie wird angewendet, sobald ein Projekt v2-Konformitaet anstrebt. Lesart: pro BOO-Issue ein Block mit Schritten, Test, Rollback und Abhaengigkeiten — Phasen wie im PMO-Hub gegliedert.

**Wachstumshinweis:** Diese Datei waechst parallel zur Umsetzung. Jeder BOO-Issue mit Skill- oder Config-Aenderung ergaenzt nach Done seinen eigenen Block bzw. ersetzt die Platzhalter durch die finalen Schritte.

**Status-Legende:** ☐ offen | ✓ erledigt | ✗ nicht-zutreffend | ⏸ blockiert
**Aufwand-Legende:** klein (<30 Min) | mittel (<2h) | gross (<1 Tag)

**Schwesterdatei (Englisch):** [`migration-checklist-v1-to-v2.en.md`](./migration-checklist-v1-to-v2.en.md)
**Begleit-Skript fuer deterministische Auto-Schritte:** [`../scripts/migrate-to-v2.sh`](../scripts/migrate-to-v2.sh)

---

## Pro-Projekt-Tracking

Jedes Bestands-Projekt bekommt eine eigene `migration-status.md` im Repo-Root, die diese Master-Checkliste mit Status pro Projekt spiegelt. Die Master-Checkliste ist der **Plan**, die `migration-status.md` ist der **Ist-Stand pro Projekt**. So bleibt nachvollziehbar, welcher BOO-Issue in welchem Projekt schon gelandet ist.

Vorgehen:

1. Master-Checkliste durchgehen, Phasen abarbeiten.
2. Pro Schritt im Projekt: ausfuehren, testen, in `migration-status.md` Status auf ✓ setzen, Datum + Notiz eintragen.
3. Bei `<wird beim Done von BOO-N nachgetragen>`-Platzhaltern: warten bis BOO-N implementiert ist, dann Master-Checkliste neu ziehen.

Kopiervorlage siehe naechster Abschnitt.

## Kopiervorlage migration-status.md

```markdown
---
projekt: <name>
gestartet: 2026-MM-TT
governance-baseline: v1
governance-ziel: v2
operator: <handle>
---

# Migrations-Status <Projekt>

Spiegel der Master-Checkliste aus `bootstrapping/bootstrap/references/migration-checklist-v1-to-v2.md`. Status hier pflegen, nicht in der Master.

| BOO  | Titel                                               | Status | Datum      | Notizen                  |
| ---- | --------------------------------------------------- | ------ | ---------- | ------------------------ |
| BOO-1  | /intent-Skill bauen                               | ☐      |            |                          |
| BOO-2  | ESLint-Regelsatz haerten                          | ☐      |            |                          |
| BOO-3  | .semgrep.yml Auto-Setup                           | ☐      |            |                          |
| BOO-4  | Semgrep als Pre-Commit-Gate                       | ☐      |            |                          |
| BOO-5  | SonarQube Cloud Auto-Setup                        | ☐      |            |                          |
| BOO-6  | SonarQube API in /architecture-review + /sprint-review | ✓      | git pull   | siehe §BOO-6 |
| BOO-7  | KI-Tauglichkeit-Checkliste                        | ☐      |            |                          |
| BOO-8  | Testability als 7. Standard-Dimension             | ☐      |            |                          |
| BOO-10 | Intent-Propagation                                | ☐      |            |                          |
| BOO-11 | Issue-Writing-Guidelines                          | ☐      |            |                          |
| BOO-12 | Slopsquatting-Check Pre-Commit                    | ☐      |            |                          |
| BOO-13 | Scalability mit 4 Invarianten                     | ☐      |            |                          |
| BOO-14 | Observability-Skelett                             | ☐      |            |                          |
| BOO-15 | Coverage-Gate >=80% neuer Code                    | ☐      |            |                          |
| BOO-16 | Performance-Baseline-Gate                         | ☐      |            |                          |
| BOO-17 | Feature-Flag-Konvention                           | ☐      |            |                          |
| BOO-18 | Sensitive-Paths Human Review                      | ☐      |            |                          |
| BOO-19 | Prompt-Audit-Trail                                | ☐      |            |                          |
| BOO-20 | HANDBUCH Schrader-Appendix                        | ✗      | n/a        | nur Skill, keine Migration |
| BOO-21 | Domainwissen ins Projekt                          | ☐      |            |                          |
| BOO-24 | 4 KI-Architektur-Prinzipien Pflichtblock          | ☐      |            |                          |
| BOO-25 | Reliability als Architektur-Dimension             | ☐      |            |                          |
| BOO-26 | Anti-Pattern-Katalog                              | ☐      |            |                          |
| BOO-27 | Issue-Template Pflichtfelder                      | ☐      |            |                          |
| BOO-28 | ESLint als GitHub Action                          | ☐      |            |                          |
| BOO-29 | Branch-Protection Required Status Checks          | ☐      |            |                          |
| BOO-31 | Hermes-Frontmatter-Block                          | ✓      | git pull   | siehe §BOO-31 + HANDBUCH Anhang D |
| BOO-32 | CI-Output-Standardisierung Hermes                 | ✓      | partial    | siehe §BOO-32 + HANDBUCH Anhang E |
| BOO-33 | Hermes-Setup-Anleitung                            | ✗      | n/a        | nur Skill, keine Migration |
| BOO-34 | .claude/environment.json                          | ☐      |            |                          |
| BOO-35 | ARCHITECTURE_DESIGN-Aktualitaets-Pre-Flight       | ☐      |            |                          |
| BOO-36 | journal/reports/local/ Persistenz                 | ☐      |            |                          |
| BOO-37 | /pitch-Skill                                      | ✓      | partial    | siehe §BOO-37 + HANDBUCH Anhang L |
| BOO-45 | Lighthouse-CI Frontend-Performance                | ✓      | migrate_boo_45 | siehe §BOO-45 + HANDBUCH Anhang H |
| BOO-46 | Self-Hosted-Runner + 10%-Threshold                | ✓      | partial    | siehe §BOO-46 + HANDBUCH Anhang I |
| BOO-49 | Framework-Tool-Unabhaengigkeit (Doku)             | ✓      | git pull   | siehe §BOO-49 + CONVENTIONS.md + HANDBUCH Anhang K |
| BOO-38 | Sprint-Sizing-Konvention                          | ✓      | manuell    | siehe §BOO-38 + HANDBUCH Anhang G |
| BOO-39 | Token-Heuristik /ideation                         | ✓      | git pull   | siehe §BOO-39 + token-heuristik.md |
| BOO-40 | Token-Window-Pre-Flight /implement                | ✓      | git pull   | siehe §BOO-40 + HANDBUCH Anhang G |
```

---

## Phase 1 — Fundament

### BOO-1 — /intent-Skill bauen (Schrader Kap. 4)

**Status:** ☐ offen
**Aufwand:** klein-mittel (Skill selbst ist seit 2026-05-01 in `bootstrapping/intent/` verfuegbar — pro Bestands-Projekt nur `intents/`-Verzeichnis nachziehen)
**Linear:** https://linear.app/owlist/issue/BOO-1
**Auto-Schritt:** ja (Schritte 1-3 idempotent automatisiert)
**Schritte:**
0. Aus dem Bestands-Projekt-Root: `bash <pfad-zum-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-1` ausfuehren — legt Schritte 1-3 automatisch an.
1. Verzeichnis `intents/` im Repo-Root (Speicherort fuer Intent-Dateien pro Initiative).
2. `intents/.gitkeep` anlegen, damit das Verzeichnis im Repo bleibt.
3. `intents/README.md` mit Hinweis auf den `/intent`-Skill und Datei-Konvention `intents/INTENT-XX.md` + paralleler `INTENT-XX.validation.md`.
4. **Manuell:** Pruefen, ob bestehende `docs/intent.md` oder vergleichbare Notizen existieren — falls ja, nach `intents/legacy.md` migrieren mit Hinweis auf neue Konvention.
5. **Manuell:** Skill verfuegbar machen — entweder via `/bootstrap`-Update (Phase 5 zieht alle Sub-Skills) oder durch Kopieren von `bootstrapping/intent/` nach `~/.claude/skills/intent/` bzw. `<projekt>/.claude/skills/intent/`.
6. **Test:** `ls intents/ && cat intents/README.md` → Verzeichnis und README vorhanden. Skill-Trigger `/intent` im Projekt funktioniert.

**Rollback:** `rm -rf intents/`, ggf. `docs/intent.md` aus Git-History wiederherstellen.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `~/Documents/GitHub/claudecodeskills/bootstrapping/intent/` (Erstveroeffentlichung 2026-05-01, v1.0.0)

### BOO-2 — ESLint-Regelsatz haerten (Airbnb + security + sonarjs)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-2
**Auto-Schritt:** teilweise (npm install + Konfig-Anzeige automatisierbar, Datei-Replacement bewusst manuell wegen moeglicher Hausregel-Anpassungen)
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad-zum-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-2` ausfuehren — installiert die npm-Pakete (Node-Projekte) bzw. zeigt den Operator-Hinweis fuer Python.
2. **Node.js / Full-Stack:** `npm install --save-dev eslint @eslint/js eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat` (mit React: `eslint-config-airbnb` statt `-base`).
3. **Node.js:** `eslint.config.mjs` aus aktualisiertem `bootstrap/references/file-templates.md` §eslint.config.mjs uebernehmen (4-Layer-Stack: Recommended + Airbnb + Security + SonarJS + Hausregeln).
4. **Python:** in `pyproject.toml` den Block `[tool.ruff.lint]` aus `file-templates.md` §pyproject.toml uebernehmen — `select` enthaelt `S` (flake8-bandit), `B` (bugbear), `C4` (comprehensions). Plus `[tool.ruff.lint.per-file-ignores]` fuer Tests/Migrations.
5. **Manuell:** Erstlauf `npx eslint . --max-warnings 0` bzw. `ruff check .` — Findings sind erwartbar (Legacy-Code wird nicht plotzlich Industriestandard-konform). Operator entscheidet: (a) `/implement` deklarativ iterieren lassen bis gruen, (b) als separate Story "Lint-Cleanup" einplanen, oder (c) gezielt Regeln per `// eslint-disable-next-line` mit Begruendung lokal abfangen.
6. **Test:** `npx eslint --version && npx eslint -c eslint.config.mjs --print-config <eine-test-datei>.js | head` zeigt geladene Configs (Recommended, Airbnb, Security, SonarJS sichtbar). Python: `ruff check --show-settings | grep -E "select|S|B|C4"`.

**Rollback:** Pakete deinstallieren (`npm uninstall eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat`), `eslint.config.mjs` und `pyproject.toml` aus Git-History wiederherstellen.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §eslint.config.mjs + §pyproject.toml (BOO-2 v3.2.2, 2026-05-01) — und `bootstrapping/implement/SKILL.md` §Schritt 6a fuer den deklarativen Iterations-Loop.

---

## Phase 2 — Production-Readiness (Security + Coverage)

### BOO-3 — /bootstrap: .semgrep.yml Auto-Setup

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-3
**Auto-Schritt:** ja (sprach-aware)
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad-zum-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-3` ausfuehren — legt `.semgrep.yml` und `.semgrepignore` mit sprach-erkanntem Default-Ruleset an. Idempotent — vorhandene Dateien werden nicht ueberschrieben.
2. **Auto:** `.semgrep.yml` enthaelt drei Layer:
   - **Layer 1 (Pflicht, alle Stacks):** `p/security-audit`, `p/secrets`
   - **Layer 2 (sprach-spezifisch, auto-erkannt):** `p/javascript` aktiv wenn `package.json` vorhanden, `p/python` aktiv wenn `pyproject.toml` vorhanden
   - **Layer 3 (auskommentiert):** `p/owasp-top-ten` — Operator entscheidet pro Web-Projekt manuell
3. **Auto:** `.semgrepignore` mit Standard-Excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`).
4. **Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` oder `pip install semgrep`). Bei aktivem `pyproject.toml` ggf. via venv: `pip install semgrep`.
5. **Test (Validierung):** `semgrep --config=.semgrep.yml --validate` — Exit 0, Manifest ist YAML-konform.
6. **Hinweis (Manifest, nicht Native-Config):** `.semgrep.yml` ist ein Manifest-File — der direkte Lauf `semgrep --config=.semgrep.yml --error` liefert "No config given" und ist erwartet. Pack-Loading kommt in BOO-4 (Pre-Commit-Hook liest Manifest und konstruiert `--config p/...`-Flags). Bis dahin manuell: `semgrep --config p/security-audit --config p/secrets [...]`.
7. **Manuell (Web-Projekt):** Bei Web-Frontend / REST-API / GraphQL `p/owasp-top-ten` in `.semgrep.yml` einkommentieren (Layer 3).

**Rollback:** `.semgrep.yml` und `.semgrepignore` loeschen.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §.semgrep.yml + §.semgrepignore (BOO-3 v3.2.3, 2026-05-06) — und `bootstrapping/bootstrap/SKILL.md` §4.4b fuer den Bootstrap-Flow neuer Projekte.

### BOO-4 — /implement Schritt 6a-bis: Semgrep als zweiter Gate (Pre-Commit + CI)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-4
**Auto-Schritt:** ja
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-4` ausfuehren — installiert Pre-Commit-Hook in `.git/hooks/pre-commit` (mit Manifest-Reader fuer ESLint und Semgrep) und legt GitHub Action `.github/workflows/semgrep.yml` an. Idempotent — bestehende Hooks/Workflows werden nicht ueberschrieben.
2. **Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` Mac, `pip install semgrep` Linux). Bei VPS folgt Auto-Install in BOO-44.
3. **Voraussetzung:** `.semgrep.yml` aus BOO-3 vorhanden mit mindestens Layer 1 (`p/security-audit`, `p/secrets`).
4. **Test 1 (Hook-Syntax):** `bash -n .git/hooks/pre-commit` — Exit 0.
5. **Test 2 (Manifest-Reader):** `grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//'` — listet aktive Packs.
6. **Test 3 (Hook lauffaehig):** `git commit --allow-empty -m "test pre-commit"` — Hook laeuft ohne Crash. Bei vorhandener `eslint.config.mjs`/`pyproject.toml` werden die Gates aktiviert.
7. **Test 4 (Workflow-Syntax):** `cat .github/workflows/semgrep.yml | head -5` — YAML-konform, `name:` und `on:` vorhanden.
8. **Manuell (optional):** Branch-Protection in GitHub aktivieren — Required Status Check "Semgrep" (siehe BOO-29).

**Rollback:** `.git/hooks/pre-commit` und `.github/workflows/semgrep.yml` loeschen.
**Abhaengigkeiten:** BOO-3 (Semgrep-Manifest muss existieren)
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §.git/hooks/pre-commit + §.github/workflows/semgrep.yml (BOO-4 v3.2.4, 2026-05-06) — und `bootstrapping/implement/SKILL.md` §Schritt 6a-bis fuer den Iterations-Loop.

### BOO-5 — /bootstrap: SonarQube Cloud Auto-Setup

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-5
**Auto-Schritt:** teilweise
**Schritte:**
1. **[MANUAL]** Operator: SonarCloud-Account verifizieren, Org auf `owlist` pruefen.
2. **[MANUAL]** Operator: Projekt in SonarCloud anlegen, `SONAR_TOKEN` in GitHub-Secrets eintragen.
3. `sonar-project.properties` im Repo-Root anlegen (Auto, Inhalt aus `bootstrap/references/file-templates.md`).
4. `.github/workflows/sonarcloud.yml` anlegen (Auto, Inhalt aus `file-templates.md`).
5. **Test:** Push auf Branch → Action laeuft gruen, SonarCloud-Dashboard zeigt erste Analyse.

**Rollback:** Workflow-Datei und `sonar-project.properties` loeschen, Secret entfernen.
**Abhaengigkeiten:** keine

### BOO-6 — /architecture-review + /sprint-review: SonarQube Cloud API lesen

**Status:** ✓ in v2-Skill-Source enthalten (Skill-Code mit Graceful-Fallback)
**Aufwand:** klein (operator-side: git pull, SONAR_TOKEN ggf. bereits aus BOO-5 vorhanden)
**Linear:** https://linear.app/owlist/issue/BOO-6
**Auto-Schritt:** ja (im Skill-Update enthalten)
**Schritte:**
1. **`[AUTO]`** Skills neu ziehen: `cd ~/.claude/skills && git pull origin main`. `/architecture-review` v1.10.0 hat den neuen "SonarQube-Cloud-API-Lese-Block" (Security Hotspots, Tech-Debt-Ratio, Reliability/Maintainability-Rating). `/sprint-review` v2.3.0 hat den neuen Schritt 2b "Reports-Aggregation + Metriken" (SonarQube API + Local-Reports + CI-Reports + L3-DB).
2. **`[AUTO/Voraussetzung]`** `SONAR_TOKEN` muss als GitHub-Secret oder in `.env` verfuegbar sein — wurde bereits durch BOO-5-Migration eingerichtet. Wenn fehlt: Skills laufen mit Graceful-Skip-Hinweis "SonarQube Cloud nicht konfiguriert — Metriken nicht verfuegbar", kein Fehler.
3. **`[MANUAL]`** Optional: `sonar-project.properties` `sonar.projectKey` + `sonar.organization` verifizieren (`grep -E "sonar.(projectKey|organization)" sonar-project.properties`) — Skill liest diese Felder fuer den API-Call.

**Test:**
- `/architecture-review` auf einem Projekt mit aktivem SonarQube laufen lassen → Review-Tabelle hat neue "SonarQube"-Spalte mit Hotspots-Count + Debt-Ratio + Rel/Sec-Rating.
- `/sprint-review` laufen lassen → Sprint-File-Frontmatter enthaelt `metrics.sonarqube_hotspots_new` + `metrics.sonarqube_hotspots_resolved` + `metrics.coverage_trend`.
- Ohne SONAR_TOKEN: beide Skills laufen ohne SonarQube-Block weiter, geben `[!info] SonarQube-Block uebersprungen` aus.

**Rollback:** Skills auf v1.9.0 / v2.2.0 zuruecksetzen (`git checkout <pre-boo6-commit> -- architecture-review/ sprint-review/`). Effekt: kein SonarQube-Lese-Block, Reviews laufen ohne diese Metriken.
**Abhaengigkeiten:** BOO-5 (SonarQube-Cloud-Setup + sonar-project.properties + SONAR_TOKEN). Nutzt auch BOO-32 (`journal/reports/ci/`-Konvention) und BOO-36 (`journal/reports/local/`-Konvention) fuer die erweiterte Sprint-Review-Aggregation.
**Skill-Quelle:** `bootstrapping/architecture-review/SKILL.md` §SonarQube-Cloud-API-Lese-Block + `bootstrapping/sprint-review/SKILL.md` §Schritt 2b.

### BOO-12 — Dependency + Halluzinations-Check Pre-Commit (Slopsquatting-Schutz)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-12
**Auto-Schritt:** ja
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-12` ausfuehren — legt `.claude/hooks/dependency-check.sh` an, macht es ausfuehrbar, und ergaenzt den Pre-Commit-Hook (BOO-4) um den Aufruf nach Semgrep. Idempotent.
2. **Voraussetzung:** `curl` ist Standard. Optional: `npm` (Node-Projekt — fuer Existenz/Age/CVE), `pip-audit` (Python — fuer CVE).
3. **Voraussetzung:** Pre-Commit-Hook aus BOO-4 vorhanden — sonst Exit mit Hinweis.
4. **Test 1 (Skript-Syntax):** `bash -n .claude/hooks/dependency-check.sh` — Exit 0.
5. **Test 2 (Trigger-Logik):** Hook ohne Manifest-Diff aufrufen — sofort Exit 0 (Performance).
6. **Test 3 (Halluzinations-Block):** Test-Commit mit `react-totally-not-malware-3000` in `package.json` einbauen — Gate muss blocken mit "Paket existiert nicht — Halluzination?".
7. **Test 4 (Age-Warning):** Optional, bei einem frischen Paket (<30 Tage) — Output zeigt Warnung.
8. **Test 5 (CVE-Block):** Optional, mit absichtlicher veralteter Dependency-Version mit High/Critical-CVE.

**Rollback:** `.claude/hooks/dependency-check.sh` loeschen, Pre-Commit-Hook (`.git/hooks/pre-commit`) Aufruf-Zeile entfernen.
**Abhaengigkeiten:** BOO-4 (Pre-Commit-Hook-Infrastruktur)
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §hooks/dependency-check.sh (BOO-12 v3.2.5, 2026-05-06) — und `bootstrapping/implement/SKILL.md` §Schritt 6a-tris fuer den Workflow-Anschluss.

### BOO-15 — /implement Coverage-Gate (>=80% fuer neuen Code)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-15
**Auto-Schritt:** ja
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-15` ausfuehren — legt `.claude/hooks/coverage-check.sh` an, macht es ausfuehrbar.
2. **Voraussetzung:** Test-Tooling installiert.
   - **Node:** `npm install --save-dev c8` (falls nicht vorhanden), Test-Skript laeuft mit `npx c8 --reporter=json npm test`.
   - **Python:** `pytest-cov` als Test-Dependency, Lauf mit `pytest --cov --cov-report=json`.
3. **Voraussetzung:** `python3` verfuegbar (fuer JSON-Parsing). Standard auf Mac/Linux.
4. **Test 1 (Skript-Syntax):** `bash -n .claude/hooks/coverage-check.sh` — Exit 0.
5. **Test 2 (Skip ohne Coverage-Daten):** Hook ohne `coverage.json` aufrufen — Exit 0 mit Hinweis "Keine Coverage-Daten".
6. **Test 3 (Skip ohne Diff):** Mit `coverage.json` aber ohne staged Diff — Exit 0 mit Hinweis "Keine neu hinzugefuegten Zeilen".
7. **Test 4 (Echter Lauf):** Test-Suite mit Coverage laufen, neue Funktion ohne Tests stagen, dann Hook → BLOCK bei <60% Coverage.
8. **Manuell:** `/implement` Schritt 6a-quart wird automatisch durch den Skill aufgerufen. Operator kann manuell laufen lassen mit `bash .claude/hooks/coverage-check.sh`.

**Rollback:** `.claude/hooks/coverage-check.sh` loeschen.
**Abhaengigkeiten:** keine (laeuft unabhaengig von BOO-4-Hook)
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §hooks/coverage-check.sh (BOO-15 v3.2.6, 2026-05-06) — und `bootstrapping/implement/SKILL.md` §Schritt 6a-quart fuer den Workflow-Anschluss.

### BOO-27 — Issue-Template: 4 Schrader-Prompt-Bestandteile als Pflichtfelder + Pre-Flight-Check

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-27
**Auto-Schritt:** ja (GitHub Issue Template)
**Schritte:**
1. `[AUTO]` `.github/ISSUE_TEMPLATE/story.yml` wird angelegt mit 4 Pflichtfeldern (Insight / Constraints / Erfolgskriterien / Gewuenschtes Ergebnis) + Ausfuehrungsmodus-Dropdown + DoD-Checkliste. Idempotent — vorhandene Datei wird uebersprungen.
2. `[MANUAL]` `/implement` hat seit BOO-27 einen HARD GATE in Schritt 1b: bestehende Linear-Issues muessen alle 4 Schrader-Prompt-Bestandteile enthalten (je min. 20 Zeichen), bevor `/implement` aufgerufen werden kann. Offene Backlog-Issues pruefen und fehlende Bestandteile nachpflegen.
3. `[MANUAL]` Optional: `CLAUDE.md` des Projekts um folgende Regel ergaenzen:
   ```
   Jedes Linear-Issue muss die 4 Schrader-Prompt-Bestandteile enthalten
   (Insight / Constraints / Erfolgskriterien / Gewuenschtes Ergebnis).
   /implement blockt sonst in Schritt 1b.
   ```

**Test:** `test -f .github/ISSUE_TEMPLATE/story.yml && echo 'OK' || echo 'FEHLT'`
**Rollback:** `.github/ISSUE_TEMPLATE/story.yml` loeschen.
**Abhaengigkeiten:** keine

**Skill-Quelle:** `bootstrapping/bootstrap/references/issue-writing-guidelines-template.de.md` v3.0 (BOO-27) + `bootstrapping/implement/SKILL.md` v2.1.0 §Schritt 1b fuer den HARD GATE.

### BOO-28 — /bootstrap: ESLint als GitHub Action konfigurieren (CI-Gate)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-28
**Auto-Schritt:** ja (Files anlegen via `migrate_boo_28()`, Stack-Detection automatisch)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-28` ausfuehren — legt Stack-abhaengig Workflow-File(s) an:
   - **Node-Stack** (`package.json` vorhanden) → `.github/workflows/eslint.yml`. Workflow ruft `npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif` auf und uploaded das SARIF via `github/codeql-action/upload-sarif@v3` in den GitHub-Security-Tab. SARIF-Output ist Pflicht — wird in BOO-32 (CI-Output-Standardisierung) fuer Hermes-Konsumtion gelesen.
   - **Python-Stack** (`pyproject.toml` ODER `requirements.txt` vorhanden) → `.github/workflows/ruff.yml`. Workflow ruft `ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif` auf und uploaded analog.
   - **Mixed-Stack** (beide Manifest-Files vorhanden) → beide Workflows parallel.
   - **Unknown-Stack** (kein Manifest-File) → `log_warn` + Hinweis, kein Workflow angelegt.

   Bestehende Workflow-Files werden ge`[SKIP]`ped — `--force` ueberschreibt. `.ci-reports/` wird idempotent in `.gitignore` ergaenzt.
2. **`[AUTO]`** (nur Node-Stack) — Falls `jq` vorhanden: `migrate_boo_28()` ergaenzt `package.json` devDependencies um `"@microsoft/eslint-formatter-sarif": "^3.1.0"` (Voraussetzung fuer den `--format=@microsoft/eslint-formatter-sarif`-Flag).
3. **`[MANUAL]`** (nur Node-Stack, wenn jq fehlt oder Operator-Verifikation): `npm install --save-dev @microsoft/eslint-formatter-sarif` ausfuehren — verifiziert dass der SARIF-Formatter unter `node_modules/` ankommt.
4. **`[MANUAL]`** Operator: ersten CI-Lauf abwarten (Push auf main oder PR-Open) — gruener Check `ESLint` (bzw. `Ruff` fuer Python) sollte erscheinen.
5. **`[MANUAL]`** Operator: SARIF-Upload im GitHub-Security-Tab pruefen (`Settings -> Security -> Code scanning alerts`) — Findings landen dort und erscheinen inline im PR.
6. **`[MANUAL]`** Nach BOO-28-Done in BOO-29 Branch-Protection aktivieren mit Required Status Check `ESLint` (bzw. `Ruff` fuer Python).

**Test:**
- `ls .github/workflows/eslint.yml` (Node) bzw. `ls .github/workflows/ruff.yml` (Python) → vorhanden.
- `grep -F '.ci-reports/' .gitignore` → Eintrag vorhanden.
- (Node) `jq '.devDependencies."@microsoft/eslint-formatter-sarif"' package.json` → `"^3.1.0"` (oder hoeher).
- PR oeffnen → Workflow laeuft, SARIF-Upload erscheint im Security-Tab.

**Rollback:**
1. `rm .github/workflows/eslint.yml` (und/oder `.github/workflows/ruff.yml`).
2. (Node) `jq 'del(.devDependencies."@microsoft/eslint-formatter-sarif")' package.json > package.json.tmp && mv package.json.tmp package.json` + `npm install`.
3. `.gitignore`-Eintrag `.ci-reports/` entfernen (manueller Edit).

**Abhaengigkeiten:** BOO-2 (ESLint-Config muss bereits gehaertet sein), BOO-32 (SARIF-Konsumtion durch Hermes — Pflicht-Output-Format jetzt schon vorbereitet).
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` + §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` (v3.17.0, 2026-05-12) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4 fuer den Bootstrap-Flow neuer Projekte.

### BOO-29 — /bootstrap: Branch-Protection mit Required Status Checks

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-29
**Auto-Schritt:** ja (via `migrate_boo_29()` und `scripts/setup-branch-protection.sh`)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-29` ausfuehren — die Funktion `migrate_boo_29()` prueft die Voraussetzungen (`gh` installiert, `gh auth status`, `git remote get-url origin`) und ruft dann `scripts/setup-branch-protection.sh` auf. Bei `DRY_RUN=true` wird nur der geplante Aufruf geloggt.

2. **`[AUTO]`** `setup-branch-protection.sh` liest dynamisch alle Workflow-Files unter `.github/workflows/*.yml` und `.github/workflows/*.yaml`. Pro Datei wird die erste Top-Level-`name:`-Zeile gelesen — das ist der GitHub-Actions-Context-Name. Diese Liste wird zu `required_status_checks[contexts][]`. Workflows, die nicht existieren (z.B. wenn `BOO-16` Perf noch nicht aktiviert ist), werden ausgelassen.

   Standard-Set bei allen aktivierten Workflows: `ESLint`, `Ruff`, `Semgrep`, `Tests`, `Coverage`, `Perf`, `SonarQube` (oder `SonarCloud`).

3. **`[AUTO]`** Der `gh api`-Aufruf erfolgt 1:1 aus dem BOO-29-Issue-Body:
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

   Idempotent — der PUT-Call ist Replace, mehrfaches Ausfuehren ist sicher.

4. **`[MANUAL]`** Voraussetzungen, falls einer der Auto-Checks fehlschlaegt (Skript bricht mit klarer Operator-Meldung ab):
   - `brew install gh` (Mac) / https://cli.github.com/ (sonst), wenn `gh CLI nicht gefunden`.
   - `gh auth login` mit Token im `repo`-Scope, wenn `gh CLI nicht eingeloggt`.
   - `git remote add origin git@github.com:<owner>/<repo>.git`, wenn kein `origin` gesetzt ist.
   - `git push -u origin main` einmal laufen lassen, wenn der `main`-Branch remote noch nicht existiert.

5. **`[MANUAL]`** Operator: in GitHub-UI verifizieren — `https://github.com/<owner>/<repo>/settings/branches` zeigt die aktive Protection-Rule fuer `main`.

6. **`[MANUAL]`** Operator: Test-PR ohne gruene Checks oeffnen — Merge muss blockiert sein.

**Test:**
- `bash <pfad>/migrate-to-v2.sh --issue BOO-29 --dry-run` → `[DRY] bash ... setup-branch-protection.sh --dry-run` erscheint.
- `gh api repos/<owner>/<repo>/branches/main/protection` → 200 mit `required_status_checks.contexts` befuellt.
- PR ohne gruene Checks kann nicht gemergt werden (GitHub blockiert via UI + API).

**Rollback:** `gh api -X DELETE repos/<owner>/<repo>/branches/main/protection` (loescht die Protection vollstaendig).

**Abhaengigkeiten:** BOO-28 (ESLint-Workflow), BOO-4 (Semgrep-Workflow), BOO-5 (SonarQube-Workflow), BOO-15 (Coverage), BOO-16 (Perf) — mindestens einer der Workflows muss existieren, sonst wird die Protection ohne Required Status Checks gesetzt (Skript-Warnung).

**Skill-Quelle:** `bootstrapping/bootstrap/scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12), `bootstrapping/bootstrap/scripts/migrate-to-v2.sh` §`migrate_boo_29` (v3.18.0) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4k fuer den Bootstrap-Flow neuer Projekte.

### BOO-30 — Linear-Workflow-States + Definition-of-Done konfigurieren

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-30
**Auto-Schritt:** teilweise — Issue-Template-Erweiterung ist automatisiert (`migrate_boo_30()`); Linear-Setup (6 Workflow-States + GitHub-Integration) ist bewusst manuell pro Projekt (Aufwand-/Nutzen-Verhaeltnis schlecht fuer API-Automatisierung)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-30` ausfuehren. `migrate_boo_30()` macht idempotent:
   - **Teil 1:** `.github/ISSUE_TEMPLATE/story.yml` patchen — der `dod`-Textarea-Block wird durch die kanonische 5er-Checkliste aus BOO-30 ersetzt (alte 5-Punkte-Liste aus BOO-27 ohne Linear-Workflow-Bezug wird ueberschrieben). Marker fuer Idempotenz: `Story darf erst auf Linear-Status "Done" wenn:` — vorhanden → `[SKIP]`. Implementierung via inline-Python (re-basiert, BSD/GNU-kompatibel). Falls `python3` fehlt: `[WARN]` + Hinweis auf manuelle Vorlage in HANDBUCH §8g.
   - **Teil 2:** `.claude/ISSUE_WRITING_GUIDELINES.md` ergaenzen — wenn die Datei existiert (gerendet vom Bootstrap-Skill) und der DoD-Marker fehlt, wird die DoD-Pflicht-Sektion (BOO-30, 5er-Checkliste + Regeln) am Ende angehaengt. Idempotent ueber denselben Marker.
   - **Teil 3:** 6 `[MANUAL]`-Log-Zeilen fuer den Linear-Setup (siehe Schritt 2-5 unten).
2. **`[MANUAL]`** Operator: Linear → Settings → <Team> → Workflow. Sechs States in genau dieser Reihenfolge anlegen (Namen exakt — sie steuern Auto-Transitions):

   | State | Bedeutung | Auto-Transition |
   |---|---|---|
   | Backlog | Triage | initial |
   | In Progress | Skill arbeitet, lokale Gates iterativ | manuell |
   | In Review | PR offen, CI laeuft | auto bei PR-Open |
   | QA Failed | CI rot, Story re-opened | manuell oder Webhook |
   | Done | PR gemerged, alle Checks gruen | auto bei PR-Merge |
   | Cancelled | verworfen | manuell |

3. **`[MANUAL]`** Operator: Linear → Settings → Integrations → GitHub → Connect Repository → Projekt-Repo auswaehlen. Nach dem OAuth-Handshake greift Auto-Recognition fuer:
   - Branch-Names mit `{ISSUE_PREFIX}-XX`-Prefix (z.B. `BOO-30-feature-foo`)
   - PR-Titel mit `{ISSUE_PREFIX}-XX`
   - Commit-Messages mit `{ISSUE_PREFIX}-XX`
   - PR-Body mit `Closes {ISSUE_PREFIX}-XX`
4. **`[MANUAL]`** Operator: Test-Story mit Branch `{ISSUE_PREFIX}-XX-test` anlegen — PR-Open transitioniert Issue automatisch auf `In Review`.
5. **`[MANUAL]`** Operator: vollstaendige Anleitung in HANDBUCH §8g "Linear-Setup pro Projekt" lesen — enthaelt Begruendung der Workflow-Paarung (Backlog↔Cancelled, In Progress↔In Review, QA Failed↔Done) und das exakte DoD-Snippet.

**Test:**
- `grep -F 'Story darf erst auf Linear-Status "Done" wenn:' .github/ISSUE_TEMPLATE/story.yml` → Treffer (vorhanden).
- `grep -F 'Story darf erst auf Linear-Status "Done" wenn:' .claude/ISSUE_WRITING_GUIDELINES.md` → Treffer (wenn Datei existiert).
- Zweiter Lauf `--issue BOO-30` → `[SKIP]`-Zeilen fuer beide Files (Idempotenz).
- Linear-UI: 6 States vorhanden, Reihenfolge stimmt.
- Test-PR → Issue-State springt automatisch auf `In Review`.

**Rollback:**
1. Issue-Template: `dod`-Block in `.github/ISSUE_TEMPLATE/story.yml` zurueck auf BOO-27-Stand setzen (manueller Edit).
2. Guidelines: BOO-30-Sektion am Ende von `.claude/ISSUE_WRITING_GUIDELINES.md` loeschen.
3. Linear-States: in Linear-UI loeschen oder umbenennen (zerstoert dann allerdings die Historie aller Bestands-Issues).

**Abhaengigkeiten:** BOO-27 (Issue-Template muss vorhanden sein, sonst `[WARN]` + Abbruch des Patch-Schritts), BOO-29 (Required Status Checks werden in der DoD-Checkliste referenziert).
**Skill-Quelle:** `bootstrapping/bootstrap/references/issue-writing-guidelines-template.de.md` v3.1 (BOO-30), `bootstrapping/bootstrap/scripts/migrate-to-v2.sh` §`migrate_boo_30` (v3.19.0, 2026-05-12), `bootstrapping/bootstrap/SKILL.md` Phase 4.4l, `bootstrapping/HANDBUCH.md` §8g Linear-Setup pro Projekt.

### BOO-34 — /bootstrap: .claude/environment.json — Skill-Umgebungs-Awareness

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-34
**Auto-Schritt:** ja
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-34` ausfuehren — legt `.claude/generate-environment-json.sh` ausfuehrbar an, ruft den Generator auf und schreibt `.claude/environment.json` mit Detection von `environment` (mac/vps/ci), `tools_available` (eslint, semgrep, tests, sonarqube_*), `paths` und `metadata` (created_at, bootstrap_version, stack). Idempotent — bestehende Dateien werden geSKIPped.
2. **Pre-Check:** Wenn `.claude/`-Ordner fehlt, wird er vom Skript angelegt — kein Operator-Eingriff noetig.
3. **Schema-Quelle:** Vor dem Lauf optional `bootstrap/references/file-templates.md` §`.claude/environment.json` lesen, um die Felder zu verstehen. Generator-Script-Quelle: §`.claude/generate-environment-json.sh` (selbe Datei).
4. **Test 1 (Skript-Syntax):** `bash -n .claude/generate-environment-json.sh` — Exit 0.
5. **Test 2 (JSON-Validitaet):** `cat .claude/environment.json` — Pflichtfelder `environment`, `tools_available`, `paths`, `metadata` vorhanden. Optional: `python3 -m json.tool .claude/environment.json` — Exit 0.
6. **Test 3 (Idempotenz):** Skript zweimal mit `--issue BOO-34` aufrufen — beim zweiten Lauf erscheinen `[SKIP]`-Zeilen fuer Generator und JSON-File.
7. **Test 4 (Re-Generierung):** Nach Tool-Installation (z.B. `brew install semgrep`) `bash .claude/generate-environment-json.sh --force` ausfuehren — `tools_available.semgrep` flippt von `false` auf `true`.
8. **`.gitignore`-Frage — bewusst NICHT ignorieren:** `.claude/environment.json` **soll committed** werden. Begruendung: gleiche Tooling-Annahmen im Team, Audit-Spur via `metadata.created_at`, und Projekt-Migrationen wollen wissen "mit welcher Bootstrap-Version wurde generiert". Maschinenspezifische Drift (Mac-Operator vs. Linux-VPS) wird ueber `--force` und Re-Commit aufgeloest, nicht ueber Ignorieren. Kein Eintrag in `.gitignore` noetig.
9. **Manuell:** Falls SonarLint VS-Code-Plugin auf Mac aktiv: `tools_available.sonarqube_ide_plugin` in `.claude/environment.json` von `false` auf `true` setzen — CLI-Detection ist nicht moeglich. Falls Projekt SonarCloud NICHT nutzt, `tools_available.sonarqube_cloud` von `true` auf `false` setzen.
10. **Re-Run nach Bootstrap-Update (optional):** Bei naechster `/bootstrap`-Skill-Version, die Phase 4.4e neu fasst, einfach `bash .claude/generate-environment-json.sh --force` — alte Datei wird ueberschrieben mit aktualisierter `metadata.bootstrap_version`.

**Rollback:** `.claude/environment.json` und `.claude/generate-environment-json.sh` loeschen.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §`.claude/environment.json` + §`.claude/generate-environment-json.sh` (BOO-34 v3.3.0, 2026-05-06) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4e fuer den Bootstrap-Flow neuer Projekte.

### BOO-36 — /implement: Local-Iteration-Outputs in journal/reports/local/ persistieren

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-36
**Auto-Schritt:** ja
**Schritte:**
1. `journal/reports/local/` anlegen mit `.gitkeep`.
2. In `.gitignore` einen Eintrag `journal/reports/local/*` plus `!journal/reports/local/.gitkeep` ergaenzen — lokale Iteration bleibt lokal.
3. **Test:** `ls journal/reports/local/` und `git check-ignore journal/reports/local/foo.json` — Foo wird ignoriert.

**Rollback:** Verzeichnis und .gitignore-Eintrag entfernen.
**Abhaengigkeiten:** keine

### BOO-38 — Sprint-Sizing-Konvention auf Token-Window-Basis dokumentieren

**Status:** ✓ Doku im Bundle (HANDBUCH Anhang G), Projekt-Governance-Template ergaenzt
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-38
**Auto-Schritt:** nein
**Schritte:**
1. **`[MANUAL]`** Lokale `Projekt-Governance.md` um §9 Sprint-Sizing ergaenzen (Vorlage: `bootstrap/references/governance-template.md` §9). Enthaelt: 80%-Regel, SP-Tabelle, Velocity-Verbot, SP→Modus-Mapping, Pre-Flight-Verweis.
2. **`[MANUAL]`** `.claude/environment.json` um `thresholds.token_warn_threshold: 70` und `thresholds.token_hard_threshold: 80` ergaenzen (falls noch nicht aus BOO-35-Migration vorhanden).
3. **`[MANUAL]`** Team-Briefing: Velocity-Tracking abschalten (kein Burndown-Chart, keine SP-Statistik). Outcome-Tracking ueber Intent-Erfuellung (BOO-1 + BOO-10).

**Test:** `Projekt-Governance.md` hat §9 mit der SP-Tabelle (5 Zeilen 1/2/3/5/8 Punkte). `environment.json` enthaelt beide threshold-Felder.

**Rollback:** §9 aus `Projekt-Governance.md` entfernen, threshold-Felder aus environment.json zuruecknehmen. Effekt: Skill warnt nicht mehr vor Window-Erschoepfung (BOO-40 wird wirkungslos).
**Abhaengigkeiten:** keine. Voraussetzung fuer BOO-39 (Token-Heuristik referenziert die SP-Tabelle) und BOO-40 (Pre-Flight nutzt die thresholds).
**Skill-Quelle:** `bootstrapping/HANDBUCH.md` Anhang G + `bootstrap/references/governance-template.md` §9.

### BOO-39 — /ideation: Token-Heuristik + Ausfuehrungsmodus-Empfehlung

**Status:** ✓ in v2-Skill-Source enthalten (keine Per-Projekt-Migration noetig)
**Aufwand:** klein (operator-side: nur git pull der Skills)
**Linear:** https://linear.app/owlist/issue/BOO-39
**Auto-Schritt:** ja (im Skill-Update enthalten)
**Schritte:**
1. **`[AUTO]`** Skills neu ziehen: `cd ~/.claude/skills && git pull origin main`. `/ideation` v2.4.0 hat den neuen Schritt 5b (Token-Heuristik + SP + Modus + Operator-Hybrid-Frage). Reference-Datei `ideation/references/token-heuristik.md` (DE+EN) liegt automatisch dabei.
2. **`[MANUAL]`** Bestehende `specs/`-Files brauchen das neue Frontmatter nicht zwingend. Neue Stories die ab jetzt via `/ideation` angelegt werden, bekommen `token_estimate` + `execution_mode` + `estimation_basis` automatisch.
3. **`[MANUAL]`** Optional: `specs/TEMPLATE.md` im Projekt aktualisieren, damit manuell angelegte Specs auch das Frontmatter haben (Vorlage: `bootstrap/references/file-templates.md` §`specs/TEMPLATE.md`).

**Test:** Nach `git pull`: `/ideation` neue Dummy-Story durchlaufen lassen → erwartet Schritt 5b Operator-Hybrid-Frage "Token-Schaetzung: Xk → Y SP → Modus Z. Korrigieren? [y/n]". Spec-File enthaelt Frontmatter mit den 4 neuen Feldern.

**Rollback:** Skill auf v2.3.0 zuruecksetzen (`git checkout <pre-boo39-commit> -- ideation/`). Effekt: Schritt 5b entfaellt, SP wird wieder manuell gesetzt.
**Abhaengigkeiten:** BOO-38 (HANDBUCH Anhang G mit SP-Tabelle muss bekannt sein, weil Schritt 5b darauf verweist).
**Skill-Quelle:** `bootstrapping/ideation/SKILL.md` Schritt 5b + `ideation/references/token-heuristik.md`.

### BOO-40 — /implement: Token-Window-Pre-Flight (Schritt 0b)

**Status:** ✓ in v2-Skill-Source enthalten (Skill + environment.json-Defaults)
**Aufwand:** klein (operator-side: git pull + optional environment.json patchen)
**Linear:** https://linear.app/owlist/issue/BOO-40
**Auto-Schritt:** ja (im Skill-Update enthalten)
**Schritte:**
1. **`[AUTO]`** Skills neu ziehen: `cd ~/.claude/skills && git pull origin main`. `/implement` v2.7.0 hat den neuen Schritt 0b (Token-Window-Pre-Flight zwischen Schritt 0 und 1).
2. **`[MANUAL]`** `.claude/environment.json` um die beiden neuen thresholds ergaenzen (falls noch nicht via BOO-38-Migration vorhanden):
   ```json
   "thresholds": {
     "architecture_doc_freshness_days": 30,
     "token_warn_threshold": 70,
     "token_hard_threshold": 80
   }
   ```
   Defaults (70/80) sind sinnvoll fuer Anfang — schaerfere Werte (60/75) wenn das Projekt viele grosse Stories hat.
3. **`[MANUAL]`** Token-Counter-Voraussetzung pruefen: `claude-code measure-context` muss verfuegbar sein. Falls nicht: Skill faellt auf Chat-Laengen-Schaetzung zurueck (im Output markiert als "ungenau").

**Test:** Story mit kuenstlich hohem Context-Stand triggern (z.B. einen grossen Test-File reading lassen, dann Story starten). Schritt 0b zeigt `[!warning]` mit Projektion + Sprint-Wechsel-Anweisung bei `nein`.

**Rollback:** Skill auf v2.6.0 zuruecksetzen (`git checkout <pre-boo40-commit> -- implement/`). Effekt: Schritt 0b entfaellt, kein Warnsystem mehr — Compaction-Notfaelle moeglich.
**Abhaengigkeiten:** BOO-38 (HANDBUCH Anhang G + thresholds-Felder), BOO-39 (`token_estimate` im Spec-Frontmatter), BOO-36 (meta.json um `pre_flight_warning`-Feld erweitert).
**Skill-Quelle:** `bootstrapping/implement/SKILL.md` Schritt 0b + HANDBUCH Anhang G §Schwellen-Konfiguration.

---

## Phase 3 — Observability + Performance

### BOO-8 — Testability als 7. Standard-Dimension einfuehren

**Hinweis zur Issue-Historie:** Das Issue war 2026-04-23 als "Operations -> Testability + Observability" formuliert. Beim BOO-8-Re-Scope (2026-05-06) wurde festgestellt, dass weder "Operations" als Sammel-Dimension existiert noch "Observability" neu angelegt werden muss — Observability ist bereits Standard-Dimension #5. BOO-8 wird dadurch zu einem reinen **additiven** Schritt: Testability wird als 7. Standard-Dimension eingefuehrt.

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-8
**Auto-Schritt:** nein (Operator-getrieben — Auto-Edit waere zu projekt-spezifisch riskant)
**Schritte:**
1. **Auto-Vorbereitung:** Aus dem Projekt-Root `bash <pfad-zum-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-8` ausfuehren — gibt den `[MANUAL]`-Hinweis mit den Operator-Schritten aus. Das Skript schreibt **keine** Datei (zu projekt-spezifisch).
2. **Manuell:** `ARCHITECTURE_DESIGN.md` (oder das aequivalente Hub-File des Projekts) oeffnen, §3 "Quality Attributes" / "Qualitaets-Dimensionen" suchen.
3. **Manuell:** Neue Zeile **Testability** zwischen Maintainability (#6) und den optional-Spalten (Cost Efficiency / Domain Quality) einfuegen. Vorlage:
   - Dimension: **Testability**
   - Pruef-Frage fuer dieses Projekt: Coverage auf neuem Code (Change Value)? Test-Pyramide (Unit/Contract/Integration)? Pass-Rate stabil?
   - Detail-Inhalt aus `bootstrapping/architecture-review/references/dimensions-detail.md §7 Testability` uebernehmen.
4. **Manuell (Bewertung):** Pruefen, ob heute Test-Aspekte unter Maintainability oder Reliability vermischt sind — z.B. "Tests fuer kritische Pfade?" als Sub-Punkt unter Maintainability. Falls ja: Operator entscheidet pro Projekt, ob diese Punkte nach Testability migriert werden oder beide Dimensionen sich darauf beziehen.
5. **Test (Sanity):** `grep -E "Testability" ARCHITECTURE_DESIGN.md` → mindestens ein Treffer in der Quality-Attributes-Tabelle.
6. **Test (End-to-End, optional):** `architecture-review` Skill auf einem Bestands-Projekt durchlaufen lassen — verifizieren, dass die neue Dimension korrekt erkannt und gepruefft wird. Das ist der DoD-Punkt aus dem urspruenglichen Linear-Issue.

**Rollback:** Testability-Zeile aus `ARCHITECTURE_DESIGN.md` entfernen. Add-on-Dimensionen rutschen wieder eine Position nach oben.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `bootstrapping/bootstrap/references/architecture-design-template.md` + `bootstrapping/architecture-review/references/dimensions-detail.md §7 Testability` (BOO-8 v3.4.0, 2026-05-06).

### BOO-13 — Scalability als 8. Standard-Architektur-Dimension einfuehren

**Hinweis zur Issue-Historie:** Das Issue war urspruenglich als reine Sektions-Erweiterung in `ARCHITECTURE_DESIGN.md` mit 4 Scalability-Invarianten formuliert. Beim BOO-13-Re-Scope (2026-05-08) wurde der Zuschnitt mit BOO-8 (Testability als 7. Standard-Dimension) harmonisiert: Scalability wird als **8. Standard-Architektur-Dimension** im Skill-Set verankert (analog Reliability/Testability), inklusive 4 Pro-Invarianten und 4 Anti-Patterns. Der ursprueng­liche Stub-Inhalt (4 Invarianten in der Quality-Attributes-Tabelle des Bestands-Projekts) bleibt als Operator-Schritt erhalten — kommt aber jetzt aus `architecture-review/references/dimensions-detail.md §8 Scalability`.

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-13
**Auto-Schritt:** nein (Operator-getrieben — Scalability gilt fuer alle Stacks gleichermassen, kein Skelett-File noetig)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad-zum-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-13` ausfuehren — gibt den `[MANUAL]`-Hinweis mit den Operator-Schritten aus. Das Skript schreibt **keine** Datei (Scalability ist eine Architektur-Dimension, kein Code-Skelett).
2. **`[MANUAL]`** `docs/ARCHITECTURE_DESIGN.md` (oder das aequivalente Hub-File des Projekts) oeffnen, §3 "Quality Attributes" / "Qualitaets-Dimensionen" suchen. Zeile **Scalability** zwischen Testability (#7) und den optional-Spalten (Cost Efficiency / Domain Quality) einfuegen. Die 4 Pro-Invarianten (Stateless, Horizontal-Scaling-Faehigkeit, 12-Factor, Async-Entkopplung) und 4 Anti-Patterns als Sub-Bullets oder als Verweis auf `architecture-review/references/dimensions-detail.md §8 Scalability` aufnehmen.
3. **`[MANUAL]`** Architektur des Bestands-Projekts gegen die 4 Pro-Invarianten haltbar machen — pro Invariante: Status (erfuellt / nicht erfuellt / n/a) + Begruendung. Pruefen, was nicht erfuellt ist (Stateless: keine In-Process-Sessions / kein Modul-Globaler State; Horizontal-Scaling: Service kann ohne Koordination N-mal laufen; 12-Factor: Config in ENV, nicht im Code; Async-Entkopplung: Long-Running-Jobs ueber Queue/Bus, nicht inline).
4. **`[MANUAL]`** Anti-Pattern-Sweep: `grep -RIn "globalThis\.sessions\|\.lock\b\|setInterval\|node-cron\|node-schedule" src/ lib/ services/` und manueller Scan auf Modul-globale Mutables / Singleton-State / In-Process-Cron. Funde dokumentieren — entweder als ADR unter `docs/domain/adrs/NNN-scalability-debt.md` oder als Backlog-Issue. Bewusste Schulden sind akzeptabel, dokumentiert.
5. **`[MANUAL]`** `architecture-design-template.md`-Wahl klaeren: wird Scalability bewusst als Default aktiv gefahren (Empfehlung fuer alle Projekte mit Multi-Instance-Ambition oder Backpressure-Anforderung) oder fuer dieses Bestands-Projekt deaktiviert (z.B. Single-User-CLI, Local-Tool ohne Skalierungs-Pfad)? ADR begruenden, falls deaktiviert: `docs/domain/adrs/NNN-scalability-disabled.md`.
6. **`[MANUAL]`** `/architecture-review --system` laufen lassen — der Skill prueft jetzt 8 Standard-Dimensionen. Ergebnis-Report archivieren in `journal/reports/architecture-review-<datum>.md`. Risiko-Eintraege fuer Scalability-Anti-Patterns priorisieren.
7. **`[MANUAL]`** Falls eine der 4 Pro-Invarianten nicht erfuellt ist und nicht bewusst als Schuld akzeptiert wird: Backlog-Issue anlegen (Linear / GitHub-Issues / journal je nach Backlog-Tool des Projekts) und priorisieren. Nicht alles muss sofort gefixt werden — Reihenfolge nach Risiko (Stateless vor 12-Factor vor Async-Entkopplung, weil Stateless die Voraussetzung fuer Horizontal-Scaling ist).
8. **`[AUTO]`** Pruefen, dass im `architecture-review/references/dimensions-detail.md` der Bestands-Skill-Installation §8 Scalability vorhanden ist: `grep -E "^## §?8\.? Scalability" .claude/skills/architecture-review/references/dimensions-detail.md`. Falls nicht: Skill-Update via `git pull` im `.claude/skills/architecture-review`-Klon oder Neu-Install via Phase 5 von `/bootstrap` (`a/b/c/d`-Auswahl).

**Test:**
- `grep -E "Scalability" docs/ARCHITECTURE_DESIGN.md` → mindestens ein Treffer in der Quality-Attributes-Tabelle.
- Sektion enthaelt 4 Pro-Invarianten mit Status (erfuellt/nicht erfuellt/n/a) und 4 Anti-Patterns.
- `grep -E "^## §?8\.? Scalability" .claude/skills/architecture-review/references/dimensions-detail.md` → Skill-Referenz vorhanden.
- Optional (DoD): `/architecture-review --system` durchlauf zeigt Scalability als gepruefte Dimension im Output-Report.

**Rollback:** Scalability-Zeile aus `docs/ARCHITECTURE_DESIGN.md` entfernen; ADR `NNN-scalability-disabled.md` (falls angelegt) als `superseded` markieren statt loeschen. Add-on-Dimensionen rutschen wieder eine Position nach oben.
**Abhaengigkeiten:** keine harten — additiv zu BOO-8 (Testability als 7. Standard-Dimension) und BOO-25 (Reliability-Saeulen). Inhaltliche Ueberlappung mit BOO-25 Backpressure-Strategie ist beabsichtigt — Scalability prueft die Strukturfrage (kann der Service skaliert werden?), Reliability prueft die Robustheits-Frage (haelt er bei Druck stand?).
**Skill-Quelle:** `bootstrapping/architecture-review/references/dimensions-detail.md §8 Scalability` (4 Pro-Invarianten + 4 Anti-Patterns) seit Skill-Version v1.6.0 (BOO-13, 2026-05-08) — und `bootstrapping/bootstrap/references/architecture-design-template.md` fuer den Bootstrap-Flow neuer Projekte.

### BOO-14 — /bootstrap Observability-Skelett (strukturiertes Logging + Metrics-Endpoint + Alert-Rules)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-14
**Auto-Schritt:** teilweise (Files anlegen via `migrate_boo_14()`, Service-spezifische Befuellung manuell)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-14` ausfuehren — legt `observability.md` (Skelett mit drei Pflicht-Sektionen), `observability/alerts/.gitkeep` (Verzeichnis-Marker) und `observability/.env.observability` (Routing-Stub mit Telegram-Placeholder) an. `.gitignore` wird idempotent um `observability/.env.observability` ergaenzt. Bestehende Files werden ge`[SKIP]`ped — `--force` ueberschreibt.
2. **`[MANUAL]`** Operator listet Services aus `ARCHITECTURE_DESIGN.md §4 Komponenten-Uebersicht` (oder dem Komponenten-Inventar des Projekts) in `observability.md` als `### Service: <name>` Sektionen (eine pro Service).
3. **`[MANUAL]`** Operator setzt **Port-Konvention 9090+N** pro Service (auth=9091, api=9092, db=9093, ...) und traegt den Port in der jeweiligen Service-Sektion ein.
4. **`[MANUAL]`** Operator entscheidet **Logger-Bibliothek pro Stack** — Defaults: Node.js → `pino`, Python → `structlog`. Abweichungen als ADR unter `docs/domain/adrs/NNN-logger-choice.md` dokumentieren.
5. **`[MANUAL]`** Operator legt pro Service ein File `observability/alerts/<service>.yml` mit den drei Pflicht-Alerts an: `{service}_down` (`up == 0` fuer >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% fuer 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s fuer 5 min, severity warning). Vorlage: `bootstrap/references/file-templates.md` §`observability/alerts/<service>.yml (BOO-14)`. Schwellwerte sind Defaults — Operator passt sie projekt-spezifisch an.
6. **`[MANUAL]`** Operator konfiguriert Routing in `observability/.env.observability` (Telegram-Bot-Token, Slack-Webhook, Email-Smtp). Echte Secrets gehen NICHT ins Repo — die Datei ist gitignored. Eine `.env.observability.example` (ohne Secrets) wird committed.
7. **`[AUTO]`** `.gitignore`-Eintrag `observability/.env.observability` (legt der Migrate-Schritt 1 idempotent an — falls schon vorhanden, `[SKIP]`).
8. **`[MANUAL]`** `promtool check rules observability/alerts/*.yml` lokal validieren — DoD-Punkt. Wenn `promtool` nicht installiert: `brew install prometheus` (Mac) bzw. `apt install prometheus` (VPS).

**Test:**
- `ls observability.md observability/alerts/ observability/.env.observability` → alle drei vorhanden.
- `grep -E "^### Service:" observability.md` → mindestens ein Service-Eintrag.
- `grep -F "observability/.env.observability" .gitignore` → Eintrag vorhanden.
- Optional (DoD): `promtool check rules observability/alerts/*.yml` → `SUCCESS`.

**Rollback:**
1. `rm observability.md`
2. `rm -rf observability/`
3. `.gitignore`-Eintrag `observability/.env.observability` entfernen (manueller Edit).

**Abhaengigkeiten:** BOO-8 (Observability ist bereits Standard-Dimension #5; BOO-14 baut nur das physische Skelett).
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §`observability.md` + §`observability/alerts/<service>.yml` + §`observability/.env.observability` (BOO-14 v3.5.0, 2026-05-07) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4f fuer den Bootstrap-Flow neuer Projekte.

### BOO-16 — Performance-Baseline-Gate (P95 + Alarm bei 20% Rueckfall)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-16
**Auto-Schritt:** teilweise (Files anlegen via `migrate_boo_16()`, Baseline-Werte und Service-Start-Command manuell)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-16` ausfuehren — legt `journal/perf-baseline.json` initial mit `services: []` an (lebende Baseline, im Repo committed). Bestehende Datei wird ge`[SKIP]`ped — `--force` ueberschreibt.
2. **`[MANUAL]`** Operator leitet die **Service-Liste** ab. Quellen in dieser Reihenfolge: ENV `BOO16_SERVICES="auth-service api-gateway"` hat Vorrang, sonst Parse aus `observability.md` (Heading `### Service: <name>` — BOO-14), sonst aus den `Block-C`-Komponenten in `ARCHITECTURE_DESIGN.md §4`. Wenn aus `observability.md` geparst: Liste in der Log-Ausgabe verifizieren.
3. **`[AUTO]`** Pro Service ein Bench-Stub: `bench/<service>.bench.js` (Node) oder `bench/<service>_bench.py` (Python). Stack-Auto-Detect via `package.json` (Node), `pyproject.toml` ODER `requirements.txt` (Python); Mixed-Stack legt beide Varianten parallel an. Vorlagen: `bootstrap/references/file-templates.md` §`bench/<service>.bench.js` (autocannon-basiert) und §`bench/<service>_bench.py` (pytest-benchmark + httpx). Service-Namens-Substitution erfolgt automatisch (`{{SERVICE_NAME_KEBAB}}` / `{{SERVICE_NAME_SNAKE}}`).
4. **`[AUTO]`** Stack-spezifische devDeps idempotent ergaenzen: Node → `package.json` devDeps `autocannon` via `jq`-Merge (Skip wenn vorhanden, Operator-Hinweis falls `jq` fehlt); Python → `pyproject.toml` `[project.optional-dependencies].test` `pytest-benchmark` + `httpx` (Skip wenn vorhanden, `log_manual`-Hinweis falls `pyproject.toml` ergaenzt werden muss).
5. **`[AUTO]`** `.github/workflows/perf.yml` aus Template-Heredoc rendern, Service-Matrix automatisch aus der Service-Liste (`{{SERVICE_MATRIX}}` substituiert via `sed`). Vorlage: `bootstrap/references/file-templates.md` §`.github/workflows/perf.yml`. Schwellen: `<=5%` PASS, `5-20%` WARNING (PR-Comment), `>20%` FAIL (ausser Override). Override-Mechanik: PR-Label `perf-override` ODER Commit-Message-Trailer `Perf-Override: <begruendung>`.
6. **`[MANUAL]`** Erster Bench-Lauf in CI failt absichtlich mit "Baseline fehlt" (Comparator-Output): Operator laedt das Artefakt `perf-bench-<service>` herunter, kopiert `p50_ms` / `p95_ms` / `p99_ms` / `req_per_sec` / `commit_sha` / `recorded_at` / `bench_tool` in `journal/perf-baseline.json` unter `services[]` und committed als `BOO-16: initial baseline for <service>`. Zusaetzlich Operator: Service-Start-Command in `.github/workflows/perf.yml` Step `Start service (background)` eintragen (Platzhalter `exit 1` ersetzen).
7. **`[MANUAL]`** Branch-Protection aktivieren: `Perf` als Required Status Check eintragen (`Settings → Branches → Branch protection rules → Require status checks to pass → Perf`). Wer das Gate bewusst deaktiviert (z.B. Single-User-CLI ohne Server-Endpoint), legt einen ADR `docs/domain/adrs/NNN-perf-gate-disabled.md` mit Begruendung an.
8. **`[AUTO]`** `journal/reports/perf/.gitkeep` + leeres `journal/reports/perf/overrides.log` (append-only Audit-Spur) anlegen. `.gitignore` idempotent um `coverage/` und `journal/reports/perf/*.json` ergaenzen (Reports sind Artefakt-Output, nicht commit-Material — der Comparator-Step uebernimmt nur ausgewaehlte Werte in die Baseline).

**Test:**
- `ls journal/perf-baseline.json .github/workflows/perf.yml journal/reports/perf/overrides.log` → alle drei vorhanden.
- `jq '.services | length' journal/perf-baseline.json` → `0` initial, nach Operator-Befuellung `>= 1`.
- `ls bench/` → mindestens ein `<service>.bench.js` oder `<service>_bench.py` pro Service.
- `grep -F "journal/reports/perf/*.json" .gitignore` → Eintrag vorhanden.
- Optional (DoD): erster PR mit dummy-Change triggert `Perf` Workflow → FAIL mit "Baseline fehlt" (erwartet).

**Rollback:**
1. `rm -rf bench/`
2. `rm journal/perf-baseline.json`
3. `rm -rf journal/reports/perf/`
4. `rm .github/workflows/perf.yml`
5. `.gitignore`-Eintraege `coverage/` und `journal/reports/perf/*.json` entfernen (manueller Edit).
6. `package.json` devDeps `autocannon` bzw. `pyproject.toml` `test`-Block manuell zuruecknehmen (`npm uninstall autocannon` / Edit).
7. Branch-Protection: `Perf` Required Status Check deaktivieren.

**Abhaengigkeiten:** BOO-14 (Service-Liste wird optional aus `observability.md` geparst — wenn BOO-14 noch nicht migriert ist, wird die Liste ueber ENV `BOO16_SERVICES` oder den Default-Service-Eintrag erzeugt).
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §`journal/perf-baseline.json` + §`bench/<service>.bench.js` + §`bench/<service>_bench.py` + §`.github/workflows/perf.yml` (BOO-16 v3.8.0, 2026-05-11) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4g fuer den Bootstrap-Flow neuer Projekte.

### BOO-25 — Reliability als eigene Architektur-Dimension einfuehren (Schraders 6. Saeule)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-25
**Auto-Schritt:** teilweise (Skelett-Files via `migrate_boo_25()`, Service-spezifische Aktivierung manuell)
**Schritte:**
1. **`[AUTO]`** Aus dem Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-25` ausfuehren — legt die vier Skelett-Files an: `lib/idempotency.{js,py}`, `lib/retry.{js,py}`, `lib/circuit-breaker.{js,py}`, `docs/SLO.md`. Stack-Detection erfolgt via `package.json` (Node), `pyproject.toml` / `requirements.txt` (Python) bzw. legt beide Varianten parallel an, falls beide Manifest-Files existieren (Mixed-Stack). Bestehende Files werden ge`[SKIP]`ped — `--force` ueberschreibt mit Backup `.bak`.
2. **`[MANUAL]`** Operator entscheidet pro Service welche der vier Saeulen aktiviert werden — nicht jeder Service braucht Idempotency (z.B. read-only-Services brauchen sie nicht), nicht jeder Downstream-Call braucht einen eigenen Circuit-Breaker. Inhalte fuer die Skelette: `bootstrap/references/file-templates.md` §`lib/idempotency` / §`lib/retry` / §`lib/circuit-breaker` / §`docs/SLO.md`.
3. **`[MANUAL]`** Idempotency-Middleware in den Service-Entry-Point einhaengen — Express via `app.use()` fuer eine Pflicht-Route-Gruppe oder pro schreibendem Endpoint, FastAPI via `Depends()`. **NICHT global** ueber alle Endpoints, sondern explizit pro POST/PUT/PATCH/DELETE. Redis-Connection als `REDIS_URL` in `.env` ergaenzen (Beispielwert in `.env.example` committed).
4. **`[MANUAL]`** Pro externer Abhaengigkeit (DB, Auth-Service, externe API, Message Bus) einen eigenen Circuit-Breaker konfigurieren. Default-Config: `errorThresholdPercentage: 50`, `resetTimeout: 30000`, `volumeThreshold: 10`. Schwellen pro Abhaengigkeit anpassen (DB darf langsamer sein als Auth-Service; externe APIs duerfen restriktiver sein).
5. **`[MANUAL]`** Retry-Helper auf alle Downstream-Calls anwenden (HTTP-Client, DB-Adapter, Message-Bus-Publisher). Status-Code-Filter pruefen — **KEIN Retry bei 4xx** (Client-Fehler sind nicht transient). Idempotency-Konflikte (HTTP 422 mit Idempotency-Key-Mismatch) ebenfalls nicht retryen.
6. **`[MANUAL]`** `docs/SLO.md` befuellen: Availability-Ziel definieren (99.9 / 99.95 / 99.99), Error-Budget-Tabelle pro Quartal, mindestens 3 SLIs mit Mess-Methode (Verweis auf BOO-14-Metrics-Endpoint als Quelle: `error_rate`, `p95_latency`, `up`-Probe). Review-Cadence in `/sprint-review` einplanen — Error-Budget-Status pro Sprint-Review-Run pruefen.
7. **`[MANUAL]`** Tests fuer Idempotenz und Retry-Pfad ergaenzen: (a) Doppel-Submit mit gleichem `Idempotency-Key` → cached Response, (b) gleicher Key + abweichender Body → HTTP 422, (c) transienter 503 → 3 Retries → Erfolg, (d) 4xx → kein Retry. Coverage-Gate (BOO-15) verlangt eh >=80% auf neuem Code — die Tests fallen unter dieses Gate.
8. **`[MANUAL]`** `docs/ARCHITECTURE_DESIGN.md` §3 Quality Attributes pruefen — Reliability-Invarianten als bewusste Entscheidung dokumentieren: Welche der fuenf Saeulen (Idempotenz, Retry+Backoff, Circuit Breaker, Graceful Degradation, SLO+Error-Budget) sind aktiv? Welche bewusst ausgelassen? Warum? Fuer Bestands-Projekte ohne Quality-Attributes-Sektion: Operator-Entscheidung als ADR unter `docs/domain/adrs/NNN-reliability-pillars.md` dokumentieren. (Dieser Schritt integriert den urspruenglichen Stub-Inhalt — die Sektion "Reliability" in `ARCHITECTURE_DESIGN.md` enthaelt damit die vier Themen Retry-Strategie, Circuit-Breaker, Idempotenz, SLO/SLI plus Graceful Degradation als 5. Saeule.)

**Test:**
- `ls lib/idempotency.* lib/retry.* lib/circuit-breaker.* docs/SLO.md` → alle vier Skelette vorhanden (mindestens eine Stack-Variante pro Saeule).
- `grep -E "^## (Reliability|Quality Attributes)" docs/ARCHITECTURE_DESIGN.md` → Sektion vorhanden mit Reliability-Eintrag.
- Tests fuer Idempotenz + Retry laufen gruen (siehe Schritt 7).
- Optional (DoD): Error-Budget-Tabelle in `docs/SLO.md` enthaelt aktuelles Quartal mit konkretem Wert.

**Rollback:**
1. `rm -f lib/idempotency.{js,py} lib/retry.{js,py} lib/circuit-breaker.{js,py} docs/SLO.md`
2. Idempotency-Middleware in Entry-Points zuruecknehmen, `REDIS_URL` aus `.env` entfernen.
3. Retry-Wrapper aus Downstream-Calls entfernen, Circuit-Breaker-Instanzen abbauen.
4. ADR `docs/domain/adrs/NNN-reliability-pillars.md` als `superseded` markieren statt loeschen.

**Abhaengigkeiten:** BOO-8 (Reliability als 6. Standard-Dimension; BOO-25 baut das physische Skelett), BOO-13 (Scalability-Invarianten ueberlappen mit Backpressure-Strategie). Keine harte Abhaengigkeit zu BOO-14 — kann auch ohne Observability gefahren werden, aber `docs/SLO.md` referenziert BOO-14-Metrics-Endpoint als SLI-Quelle.
**Skill-Quelle:** `bootstrapping/bootstrap/references/file-templates.md` §`lib/idempotency` + §`lib/retry` + §`lib/circuit-breaker` + §`docs/SLO.md` (BOO-25 v3.7.0, 2026-05-07) — und `bootstrapping/bootstrap/SKILL.md` Phase 4.4h fuer den Bootstrap-Flow neuer Projekte. Cross-Link Architektur-Dimensionen: `architecture-review/references/dimensions-detail.md` §1.1-§1.5 (die fuenf Reliability-Saeulen).

---

## Phase 4 — Intent-Propagation + KI-taugliche Architektur

### BOO-7 — /architecture-review: KI-Tauglichkeit-Checkliste (4 Prinzipien + 4 Anti-Patterns)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-7
**Auto-Schritt:** nein
**Schritte:**
1. <wird beim Done von BOO-7 nachgetragen — geplant: Skill-Update, in Bestands-Projekt nur Verweis im README/HANDBUCH>
2. **Test:** <wird beim Done von BOO-7 nachgetragen>

**Rollback:** Doku-Verweis entfernen.
**Abhaengigkeiten:** BOO-24, BOO-26

### BOO-10 — Intent-Propagation durch die Pipeline (ideation + backlog + implement)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-10
**Auto-Schritt:** teilweise
**Schritte:**
1. Issue-Template um Feld "Intent-Referenz" erweitern (Pfad zu `intents/<key>.md`).
2. PR-Template um Block "Intent erfuellt? (Belegen via Test/ADR)" erweitern.
3. **Test:** Neuer Issue / PR zeigt Pflichtfelder.

**Rollback:** Template-Aenderungen aus Git-History wiederherstellen.
**Abhaengigkeiten:** BOO-1

### BOO-21 — Domainwissen ins Projekt (Research + Domain-Context + Domain-ADRs)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-21
**Auto-Schritt:** ja
**Schritte:**
1. Verzeichnis `docs/domain/` anlegen.
2. `docs/domain/README.md` mit Inhaltsuebersicht und Konvention.
3. `docs/domain/research/` und `docs/domain/adrs/` als Unterordner anlegen.
4. Domain-ADR-Template aus `bootstrap/references/file-templates.md` nach `docs/domain/adrs/000-template.md` kopieren.
5. **Test:** `tree docs/domain` zeigt Struktur.

**Rollback:** `rm -rf docs/domain`.
**Abhaengigkeiten:** keine

### BOO-24 — /bootstrap: 4 KI-Architektur-Prinzipien + 4 Anti-Patterns als Pflicht-Block in ARCHITECTURE_DESIGN.md §2

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-24
**Auto-Schritt:** nein (Operator-getrieben — ARCHITECTURE_DESIGN.md-Struktur ist zu projekt-spezifisch fuer Auto-Edit)
**Schritte:**
1. `ARCHITECTURE_DESIGN.md` oeffnen und in §2 Design-Rationale den KI-Block einfuegen:
   - Vorlage: `bootstrapping/references/ki-architektur-prinzipien.md` §1 + §2
   - Kompakt-Block (wie im Template) einfuegen — nicht die volle Detail-Datei kopieren
2. In `ARCHITECTURE_DESIGN.md §5` Tabelle Zeile 9 fuer KI-Tauglichkeit ergaenzen:
   - `| 9 | **KI-Tauglichkeit** | 4 Prinzipien eingehalten (Module <500 LOC, explizite Interfaces, Testbarkeit, Observability)? 4 Anti-Patterns abwesend? |`
3. Ersten ehrlichen Status pro Prinzip eintragen (P1-P4 + AP1-AP4) — ohne zu schoenfarben
4. Offene Findings als Issues anlegen (z.B. "AP1: Modul X hat 800 LOC — Split-Refactoring")
5. Commit: `chore: BOO-24 KI-Architektur-Block in ARCHITECTURE_DESIGN.md verankert`

**Test:**
- `grep "KI-Architektur-Prinzipien" ARCHITECTURE_DESIGN.md` → Treffer in §2.
- `grep "KI-Tauglichkeit" ARCHITECTURE_DESIGN.md` → Treffer in §5 Qualitaets-Dimensionen.
- Alle 4 Prinzipien (P1-P4) und 4 Anti-Patterns (AP1-AP4) mit initialem Status vorhanden.

**Rollback:** Block und Zeile 9 entfernen.
**Abhaengigkeiten:** keine
**Skill-Quelle:** `bootstrapping/references/ki-architektur-prinzipien.md` + `bootstrapping/bootstrap/references/architecture-design-template.md` §2 + §5 (BOO-24, 2026-05-10).

**Erwarteter Zeitaufwand:** 30-60 min je nach Zustand des Projekts.

### BOO-26 — Anti-Pattern-Katalog (Schrader Kap. 7, 11 APs) als Reference-Datei + /sprint-review-Hook

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-26
**Auto-Schritt:** nein
**Schritte:**
1. <wird beim Done von BOO-26 nachgetragen — geplant: Reference-Datei im Skill, im Bestands-Projekt nur Verweis>
2. **Test:** <wird beim Done von BOO-26 nachgetragen>

**Rollback:** Doku-Verweis entfernen.
**Abhaengigkeiten:** keine

### BOO-35 — /ideation: Pre-Flight-Check ARCHITECTURE_DESIGN.md-Aktualitaet

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-35
**Auto-Schritt:** nein
**Schritte:**
1. <wird beim Done von BOO-35 nachgetragen — geplant: Skill-Update, keine Projekt-Migration>
2. **Test:** <wird beim Done von BOO-35 nachgetragen>

**Rollback:** n/a
**Abhaengigkeiten:** BOO-24

---

## Phase 5 — Enterprise Governance

### BOO-11 — Issue-Writing-Guidelines: dreistufiger Ausfuehrungsmodus + Sub-Agent-Kontext pro Rolle

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-11
**Auto-Schritt:** teilweise
**Schritte:**
1. `docs/issue-writing-guidelines.md` aus `bootstrap/references/issue-writing-guidelines-template.de.md` kopieren.
2. Bei Linear-Setup: Issue-Template um Felder "Ausfuehrungsmodus" (linear/sub-agents/agentic) und "Sub-Agent-Kontext" erweitern.
3. **Test:** Datei vorhanden, Template-Felder erscheinen im neuen Issue.

**Rollback:** Datei loeschen, Template-Felder entfernen.
**Abhaengigkeiten:** keine

### BOO-17 — Feature-Flag-Konvention fuer AI-Code (gestufter Rollout in Spec)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-17
**Auto-Schritt:** nein
**Schritte:**
1. <wird beim Done von BOO-17 nachgetragen — geplant: Spec-Template um Block "Rollout-Stufen" erweitern, ggf. Feature-Flag-Library im Projekt einbinden>
2. **Test:** <wird beim Done von BOO-17 nachgetragen>

**Rollback:** Spec-Block entfernen.
**Abhaengigkeiten:** keine

### BOO-18 — Mandatory Human Review fuer sensible Pfade (.claude/sensitive-paths.json anlegen)

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-18
**Auto-Schritt:** ja
**Schritte:**
1. `.claude/sensitive-paths.json` anlegen mit Default-Pfaden (`.env`, `secrets/`, `infra/terraform/`, `migrations/`).
2. Pre-Commit-Hook erweitern: bei Aenderung in einem dieser Pfade → Hard-Stop, manuelle Freigabe verlangen.
3. **Test:** `cat .claude/sensitive-paths.json | jq .paths` listet Default-Pfade.

**Rollback:** Datei loeschen, Hook-Block entfernen.
**Abhaengigkeiten:** BOO-4

### BOO-19 — Prompt-Audit-Trail (Session-Logs + Spec-Referenz)

**Status:** ☐ offen
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-19
**Auto-Schritt:** teilweise
**Schritte:**
1. <wird beim Done von BOO-19 nachgetragen — geplant: `journal/sessions/`-Verzeichnis mit Session-Log-Konvention, PR-Template um Feld "Session-Log-Referenz" erweitern>
2. **Test:** <wird beim Done von BOO-19 nachgetragen>

**Rollback:** Verzeichnis und PR-Template-Aenderung zuruecknehmen.
**Abhaengigkeiten:** keine

---

## Phase 6 — Dokumentation + Rollout

### BOO-20 — HANDBUCH.md Schrader-Appendix

**Status:** ✗ nicht-zutreffend
**Aufwand:** mittel
**Linear:** https://linear.app/owlist/issue/BOO-20
**Auto-Schritt:** nein
**Schritte:** Skill-interne Doku — keine Projekt-Migration.

**Rollback:** n/a
**Abhaengigkeiten:** keine

### BOO-37 — /pitch-Skill bauen — Daten sammeln, Mensch baut Story (Schrader Kap. 5)

**Status:** ✓ in v2-Skill-Source enthalten (Skill-Code via git pull, Projekt-Setup via diesen Schritt)
**Aufwand:** klein (Operator: ein migrate-Aufruf + ein Generator-Refresh)
**Linear:** https://linear.app/owlist/issue/BOO-37
**Auto-Schritt:** ja (`migrate_boo_37`)
**Schritte:**
1. **`[AUTO]`** Bundle-Skills aus dem Repo neu ziehen: `cd ~/.claude/skills && git pull origin main` — `pitch/` ist seit Bundle v3.23.0 enthalten.
2. **`[AUTO]`** Im Projekt-Root `bash <pfad>/migrate-to-v2.sh --issue BOO-37` ausfuehren — legt `pitch/.gitkeep` und `intents/.gitkeep` an (idempotent), prueft `paths.pitches` in `.claude/environment.json`.
3. **`[MANUAL]`** Wenn `.claude/environment.json` existiert, aber `paths.pitches` noch fehlt: `bash .claude/generate-environment-json.sh --force` ausfuehren — die v3.23.0-Variante des Generators schreibt `paths.intents` und `paths.pitches` mit. Falls die Datei noch gar nicht existiert: erst `migrate_boo_34` ausfuehren, dann diesen Schritt wiederholen.
4. **`[OPTIONAL]`** Erstes Pitch-Briefing erzeugen: in Claude Code `/pitch` aufrufen — Skill fragt nach Sprint + Intents + Stories und legt `pitch/PITCH-1.md` an.

**Verifikation:**
- `ls pitch/` zeigt mindestens `.gitkeep`
- `grep '"pitches"' .claude/environment.json` liefert `"pitches": "pitch/"`
- `ls intents/` zeigt mindestens `.gitkeep` (Voraussetzung fuer das Lesen von `INTENT-XX.md`)

**Rollback:** `git checkout .` auf die beiden `.gitkeep`-Dateien sowie `rm -rf pitch/ intents/` (nur wenn keine Briefings/Intents drinliegen — sonst verlierst du Arbeit).
**Abhaengigkeiten:** BOO-34 (environment.json muss da sein, damit `paths.pitches` regeneriert werden kann), BOO-1 (Intent-Skill liefert die `INTENT-XX.md`-Quelle), BOO-17 (Feature-Flag-Konvention liefert `.claude/feature-flags.json`-Quelle)

---

## Phase 7 — Hermes-Integration (post-2026-04-27)

### BOO-31 — metadata.hermes-Block in alle Skill-Frontmatter

**Status:** ✓ in v2-Skill-Source enthalten (keine Per-Projekt-Migration noetig)
**Aufwand:** klein (operator-side: nur git pull der Skills)
**Linear:** https://linear.app/owlist/issue/BOO-31
**Auto-Schritt:** ja (im Skill-Update enthalten)
**Schritte:**
1. **`[AUTO]`** Skills aus dem Repo neu ziehen: `cd ~/.claude/skills && git pull origin main` (oder Projekt-spezifischer Skills-Klon). Der `metadata.hermes`-Block ist seit BOO-31 in jedem Bundle-Skill-Frontmatter enthalten.
2. **`[MANUAL]`** Verifikation: `grep -l "metadata:" ~/.claude/skills/<skill>/SKILL.md` — sollte fuer alle 10 Bundle-Skills (bootstrap, intent, ideation, backlog, implement, architecture-review, sprint-review, cloud-system-engineer, grafana, visualize) einen Treffer geben.
3. **`[MANUAL]`** Optional (nur wenn Hermes lokal installiert ist): `hermes catalog refresh` — laesst Hermes den Skill-Katalog neu scannen.

**Test:** `grep -A 5 "metadata:" ~/.claude/skills/bootstrap/SKILL.md` zeigt den `hermes:`-Subblock mit `category`, `tags`, `requires_toolsets`, `related_skills`.

**Rollback:** Skill auf v1-Frontmatter zuruecksetzen (`git checkout <pre-boo31-commit> -- SKILL.md`). Hermes-Routing degraded auf Inferenz, andere Skill-Funktionen unveraendert.

**Abhaengigkeiten:** keine. Voraussetzung fuer BOO-32 (CI-Output-Konsumtion) und BOO-33 (Setup-Anleitung).
**Skill-Quelle:** `bootstrapping/HANDBUCH.md` Anhang D (Schema + Mapping-Tabelle).

### BOO-32 — CI-Output-Standardisierung fuer Hermes-Konsumtion

**Status:** ☐ offen
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-32
**Auto-Schritt:** teilweise (Verzeichnis + .gitignore-Eintrag automatisch; CI-Workflow-Patches Operator-side)
**Schritte:**
1. **`[AUTO]`** `journal/reports/ci/` und `journal/reports/local/` als gitignored Verzeichnisse anlegen. `.gitignore` idempotent ergaenzen: `journal/reports/`. (`migrate_boo_32()` in `migrate-to-v2.sh` macht das.)
2. **`[MANUAL]`** Pro existierendem CI-Workflow (`eslint.yml`, `ruff.yml`, `semgrep.yml`, `perf.yml`, `sonar.yml`) zwei Steps am Ende des Jobs ergaenzen:
   - **`Collect reports`** mit `if: always()` und `mkdir -p journal/reports/ci/run-${{ github.run_id }}` plus `cp -f`-Befehle, die den tool-spezifischen Output dorthin verschieben.
   - **`Upload reports as artifact`** mit `actions/upload-artifact@v4`, `name: ci-reports-${{ github.run_id }}`, `path: journal/reports/ci/run-${{ github.run_id }}/`, `retention-days: 30`.
   Template-Snippet: siehe HANDBUCH Anhang E §Aggregator-Step.
3. **`[MANUAL]`** Pro Tool das Output-Flag in einen konsistenten Pfad lenken (innerhalb des Workflow-Steps, nicht am Ende):
   - ESLint: `--output-file=.ci-reports/eslint.sarif` (existing) → bleibt; Collect-Step kopiert weiter.
   - Semgrep: `--sarif --output semgrep.sarif` → ggf. ergaenzen falls nur stdout.
   - pytest: `--junit-xml=tests.junit.xml`.
   - Coverage: Vitest/Jest standard `coverage/coverage-final.json` + `coverage.lcov` (nichts zu aendern, nur kopieren).
   - SonarQube: nach `SonarSource/sonarqube-scan-action` einen Post-Step ergaenzen, der `https://sonarcloud.io/api/measures/component?...` zieht und als `sonarqube.json` ablegt (Token aus `SONAR_TOKEN`-Secret).
4. **`[MANUAL]`** Branch-Protection-Konfiguration unveraendert lassen — Artifacts sind kein Required-Status-Check, nur Beobachtungs-Signal.

**Test:**
- `bash -n` aller geaenderten Workflows → exit 0
- PR auftriggern (z.B. ESLint-bewusster Error), CI laufen lassen, im Actions-Tab den Artifact `ci-reports-{id}` herunterladen → sollte `eslint.sarif` enthalten.
- Wiederholung mit gruenem CI-Lauf — Artifact existiert ebenfalls (`if: always()`).

**Rollback:** Collect + Upload-artifact-Steps aus Workflows entfernen, `.gitignore`-Eintrag entfernen, Verzeichnis loeschen. CI-Output-Verhalten zurueck auf Pre-BOO-32 (kein Signal-Sammeln, Hermes nicht andockfaehig).
**Abhaengigkeiten:** BOO-2 (ESLint-Haertung), BOO-3/4 (Semgrep), BOO-5 (SonarCloud), BOO-15 (Coverage), BOO-16 (Performance), BOO-28 (ESLint-CI), BOO-31 (Frontmatter).
**Skill-Quelle:** `bootstrapping/HANDBUCH.md` Anhang E (Layout + Tool-Mapping + Aggregator-Snippet).

### BOO-33 — Hermes-Setup-Anleitung im HANDBUCH

**Status:** ✗ nicht-zutreffend
**Aufwand:** klein
**Linear:** https://linear.app/owlist/issue/BOO-33
**Auto-Schritt:** nein
**Schritte:** Skill-interne Doku — keine Projekt-Migration.

**Rollback:** n/a
**Abhaengigkeiten:** keine

---

### BOO-45 — Lighthouse-CI Setup-Integration (Frontend-Performance-Gate)

**Status:** ✓ in v2-Skill-Source enthalten (Bootstrap-Frage in Block A.1b + Templates + migrate_boo_45())
**Aufwand:** klein (Bestands-Projekte mit Frontend-Anteil) / nicht relevant (Backend-only)
**Linear:** https://linear.app/owlist/issue/BOO-45
**Auto-Schritt:** ja, mit Frontend-Erkennung
**Schritte:**
1. **`[AUTO]`** `bash migrate-to-v2.sh --issue BOO-45` ausfuehren. Funktion prueft `package.json` auf Frontend-Frameworks (React/Vue/Svelte/Astro/Next/Nuxt/Vite/Webpack). Bei Treffer: `lighthouserc.json` + `.github/workflows/lighthouse.yml` aus Template rendern. Bei Backend-only-Stack: Skip mit Hinweis. Override fuer Non-Standard-Frontend: `FRONTEND_OVERRIDE=true bash migrate-to-v2.sh --issue BOO-45`.
2. **`[MANUAL]`** `lighthouserc.json` anpassen: `ci.collect.url` auf echte Preview-Deploy / Staging / Prod-URL setzen (default `http://localhost:3000/` ist nur Smoke-Test). Performance-Budgets justieren (LCP/CLS/TBT/minScore). Mobile-Throttling-Profil waehlen (`desktop` vs. `mobile`).
3. **`[MANUAL]`** `.github/workflows/lighthouse.yml` an Stack anpassen: Build-Command (`npm run build` vs. `next build` vs. `vite build`) und Preview-Server-Command (`npx serve` vs. `npm run start` vs. `npm run preview`).
4. **`[MANUAL]`** Optional: `LHCI_GITHUB_APP_TOKEN` als GitHub-Secret setzen fuer Lighthouse-CI-Server-Status-Checks. Ohne den Token: Filesystem-Reports (default).

**Test:** PR mit absichtlich grossem Bundle-Import auftriggern → Lighthouse-Gate sollte FAIL melden. Artifact `ci-reports-{id}` im Actions-Tab pruefen — sollte `lighthouse.json` + `lighthouse-out/*.json` enthalten.

**Rollback:** `lighthouserc.json` und `.github/workflows/lighthouse.yml` loeschen, ggf. `journal/reports/ci/lighthouse-out/` zu `.gitignore` zuruecknehmen. Effekt: kein Frontend-Performance-Gate mehr, Stack laeuft wie vor BOO-45.
**Abhaengigkeiten:** BOO-2 (ESLint-Haertung), BOO-32 (Reports-Konvention `journal/reports/ci/`). Pendant zu BOO-16.
**Skill-Quelle:** `bootstrap/SKILL.md` Block A.1b + `bootstrap/references/file-templates.md` §`lighthouserc.json` + §`lighthouse.yml`.

### BOO-46 — Self-Hosted-Runner + 10%-Threshold-Schaerfung

**Status:** ✓ partial (perf.yml-Patch automatisch via migrate_boo_46; VPS-Setup operator-side)
**Aufwand:** mittel (Operator-Setup VPS + Runner-Installation) — bundle-seitig klein
**Linear:** https://linear.app/owlist/issue/BOO-46
**Auto-Schritt:** partial
**Schritte:**
1. **`[MANUAL]`** Hardware/VPS waehlen (siehe HANDBUCH Anhang I §1): Hostinger-Beifahrer / dedizierter VPS / Mac-Mini. Entscheidung haengt von Performance-Gate-Frequenz und Cost-Sensitivity ab.
2. **`[MANUAL]`** GitHub-Actions-Runner-Software installieren: Settings -> Actions -> Runners -> New self-hosted runner, dann `./config.sh --url ... --token ...` auf VPS ausfuehren (siehe HANDBUCH Anhang I §2).
3. **`[MANUAL]`** systemd-Service-Unit anlegen: `sudo ./svc.sh install && sudo ./svc.sh start` (HANDBUCH Anhang I §3).
4. **`[AUTO]`** `bash migrate-to-v2.sh --issue BOO-46` im Projekt ausfuehren. Funktion patcht `perf.yml`: `runs-on: ubuntu-latest` -> `runs-on: self-hosted` (mit `.boo46-backup`-Backup), Threshold `1.20` -> `1.10` (20% -> 10%), Kommentare aktualisiert.
5. **`[MANUAL]`** Runner-Health-Check via Cron alle 6h (HANDBUCH Anhang I §5). Alert bei `status != online > 10min`.

**Test:** Bench-Lauf via PR auftriggern → sollte auf self-hosted Runner laufen (im Actions-Tab am Runner-Namen erkennbar). Nach mehreren Laeufen Threshold-Verhalten beobachten — bei zuviel False-Positives Threshold auf 15% justieren.

**Rollback:** `cp .github/workflows/perf.yml.boo46-backup .github/workflows/perf.yml` (Backup wurde von migrate_boo_46 angelegt). Runner-Software auf VPS deaktivieren: `sudo ./svc.sh stop && sudo ./svc.sh uninstall && ./config.sh remove --token {RUNNER_TOKEN}`. Effekt: zurueck zu GitHub-Hosted-Runner mit 20%-Threshold.
**Abhaengigkeiten:** BOO-16 (Performance-Gate aktiv — sonst nichts zu patchen).
**Skill-Quelle:** `bootstrap/SKILL.md` Block D.6 + `bootstrap/scripts/migrate-to-v2.sh` §migrate_boo_46.

### BOO-49 — Framework-Tool-Unabhaengigkeit dokumentieren (CONVENTIONS.md + Tool-Adapter)

**Status:** ✓ in v2-Bundle enthalten (Doku-Initiative, keine Skill-Code-Aenderung)
**Aufwand:** klein (operator-side: nur git pull, neue Doku lesen)
**Linear:** https://linear.app/owlist/issue/BOO-49
**Auto-Schritt:** ja (Doku ist Teil des Bundles)
**Schritte:**
1. **`[AUTO]`** `cd ~/Documents/GitHub/claudecodeskills && git pull origin main` — neue `bootstrapping/CONVENTIONS.md` + HANDBUCH Anhang K liegen jetzt im Bundle.
2. **`[MANUAL]`** Operator: `CONVENTIONS.md` einmal durchlesen — beschreibt das Framework tool-neutral. Erlaubt spaeter Tool-Wechsel (Claude Code → Codex → Cursor → lokales LLM) ohne Framework-Verlust.
3. **`[MANUAL]`** Optional: HANDBUCH Anhang K "Tool-Adapter" lesen, falls du planst ein zweites KI-Tool zu nutzen (z.B. Codex fuer Background-Tasks, siehe BOO-50).

**Test:** `CONVENTIONS.md` ist auf `bootstrapping/`-Top-Level vorhanden. HANDBUCH hat Anhang K. README.md verweist auf CONVENTIONS.md.

**Rollback:** n/a — reine Doku-Erweiterung, kein Risiko fuer existierende Projekte.
**Abhaengigkeiten:** keine. Konzeptionelle Voraussetzung fuer BOO-50 (Codex-Integration).
**Skill-Quelle:** `bootstrapping/CONVENTIONS.md` + `HANDBUCH.md` Anhang K.

---

## Nicht-Skill-Issues (uebersprungen)

Diese Issues betreffen Operator-Tooling, Meta-Arbeit oder Doppelungen und brauchen **keine** Migration in Bestands-Projekten. Sie erscheinen in `migration-status.md` mit Status ✗.

- **BOO-9** — Rollout auf drei Hostinger-VPS. Das Rollout selbst ist keine Migration eines Skills, sondern Anwendung der Migrations-Checkliste auf VPS-Projekte.
- **BOO-22** — Duplicate (canceled).
- **BOO-23** — Diese Migrations-Checkliste (Meta-Issue, Selbstreferenz).
- **BOO-30** — Linear-Workflow-States + DoD konfigurieren. Reine Operator-Tool-Konfiguration, keine Repository-Aenderung.
