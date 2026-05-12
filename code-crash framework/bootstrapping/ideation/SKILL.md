---
name: ideation
description: |
  Deep Research, Architektur-Pruefung und User Story Erstellung. Liest vor Story-Erstellung
  den Learning-Loop (falls aktiv) und warnt bei Anti-Pattern-Match. Verwenden wenn der Nutzer
  eine neue Idee hat, ein Feature vorschlaegt, oder "ideation" / "neue Story" sagt.
  Ausloeser sind Anfragen wie "ich hab eine Idee", "neues Feature", "wir brauchen X", "/ideation".
version: 2.4.0
metadata:
  hermes:
    category: coding
    tags: [story-writing, spec-writing, intent-gate, token-heuristic]
    requires_toolsets: [terminal, git, linear, obsidian]
    related_skills: [intent, backlog, implement]
---

# Ideation

Neue Ideen systematisch recherchieren, gegen Architektur + Backlog + Learnings abgleichen und als qualitativ hochwertige User Story erstellen.

## Workflow (9 Schritte)

### Schritt 0: Environment laden

1. Lese `.claude/environment.json` (falls vorhanden — sonst Defaults verwenden + Warnung loggen).
2. Bei Bedarf Pfade extrahieren aus `paths.*` (z.B. `paths.reports_local`, `paths.lessons_l1`, `paths.lessons_l2_dir`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Bei Tool-Aufruf pruefen: ist Tool in `tools_available.<tool>` aktiv? Bei `false` oder fehlendem Eintrag: Skill ueberspringt den Aufruf und gibt einen Hinweis im Output.
4. Fallback bei fehlender Datei: Standard-Pfade aus dem Schema annehmen (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

### Schritt 0a: Architektur-Doku-Aktualitaet pruefen (Pre-Flight, weich)

> **Aktivierung:** Dieser Schritt laeuft immer wenn `ARCHITECTURE_DESIGN.md` im Projekt-Root existiert. Fehlt die Datei: ueberspringen ohne Warnung (Projekt ist noch nicht weit genug).

**Ziel:** Warnen bevor Stories gegen eine moeglicherweise veraltete Architektur-Doku angelegt werden. **Kein Hard-Gate** — der Operator kann jederzeit "ja" sagen und weiter.

1. Letzten Aenderungs-Zeitstempel der `ARCHITECTURE_DESIGN.md` lesen:
   ```bash
   git log -1 --format=%cd --date=iso ARCHITECTURE_DESIGN.md
   ```
   Bei nicht-versionierter Datei (kein Git-Log): `stat` als Fallback verwenden.
2. Threshold aus `.claude/environment.json` lesen: `thresholds.architecture_doc_freshness_days` (Default `30`, wenn Feld oder Datei fehlt).
3. Differenz in Tagen berechnen (heute minus letzter Aenderungstag).
4. Wenn Differenz `>` Threshold:
   ```
   Warnung: ARCHITECTURE_DESIGN.md wurde seit X Tagen nicht aktualisiert
   (Threshold: Y Tage).

   Empfehlung: /architecture-review ausfuehren, bevor neue Stories gegen
   eine evtl. veraltete Architektur angelegt werden.

   Trotzdem fortfahren? [ja/nein]
   ```
5. Bei `nein`: Skill stoppt mit Hinweis "Operator-Entscheidung: erst /architecture-review". Kein Issue wird angelegt.
6. Bei `ja`: weiter zu Schritt 0.5/0.6/1. Die Entscheidung wird in der Story unter `Current State` dokumentiert (`Architektur-Doku Z Tage alt — Operator-Override`).

**Warum weich, kein Hard-Block?** Ein Hard-Gate wuerde `/ideation` bei jedem laenger nicht angefassten Projekt blockieren. Realistisch ist die Doku haeufig „alt genug zum Warnen, aber noch valide" — der Operator entscheidet pro Story. Threshold ist konfigurierbar: ein schnell evolvierendes System setzt 14 Tage, ein stabiles System 90 Tage.

### Schritt 0.5: Learnings-Kontext (wenn Learning-Loop aktiv)

> **Aktivierung:** Dieser Schritt wird nur ausgefuehrt wenn `{PROJECT_PATH}/.learning-loop` existiert (Inhalt: `L1`, `L2` oder `L3`).

Vor der Story-Erstellung die letzten Lessons-Learned lesen und gegen die aktuelle Idee spiegeln.

**L1:** Letzte 3 Eintraege in `journal/learnings.md` lesen.

**L2/L3:** Letzte 2-3 Sprint-Retros lesen:
- `journal/sprint-{YYYY-MM-XX}.md` nach Datum sortiert
- Frontmatter-Tags `what_didnt` extrahieren

**Matching:** Wenn ein `what_didnt`-Tag (oder Inhalt) thematisch zur aktuellen Story-Idee passt:

```
Warnung: Im letzten Retro wurde X als "funktioniert nicht" markiert (Root-Cause: Y).
Beeinflusst das diese Story?

Moegliche Optionen:
  a) Story anpassen, um X zu vermeiden
  b) Aktuelles Problem ist anders gelagert — weiter
  c) Story verwerfen (das Pattern ist nicht tragfaehig)
```

Operator entscheidet. Antwort wird in der Story unter `Current State` als Kontext-Hinweis dokumentiert.

**Kein Match:** Schritt 0.5 wird in der Story erwaehnt als *"Learnings-Check: keine Anti-Pattern-Matches"* und weiter zu Schritt 1.

### Schritt 0.6: Intent-Check (wenn Intent aktiv)

> **Aktivierung:** Dieser Schritt wird nur ausgefuehrt wenn `{PROJECT_PATH}/intents/` Verzeichnis existiert und mindestens eine `INTENT-XX.md` Datei enthaelt.

1. Aktive `intents/INTENT-XX.md` laden (neueste Datei nach Datum oder via `status: aktiv` im Frontmatter)
2. Story-Idee gegen Intent-Metriken und Intent-Statement abgleichen
3. Klassifikation vergeben:

| Label | Kriterium | Konsequenz |
|-------|-----------|------------|
| **on-intent** | Story zahlt direkt auf eine Intent-Metrik ein | Story wird erstellt |
| **neutral** | Story ist indirekt noetig (Infrastruktur, tech-debt, Enabler) | Story wird erstellt MIT Begruendungspflicht im Story-Body |
| **off-intent** | Story zahlt gar nicht ein oder widerspricht dem Intent | Story wird NICHT erstellt — `/ideation` gibt Begruendung zurueck |

4. Label + Begruendung in Story-Body als Sektion `## Intent-Check` eintragen.

Bei `off-intent`: Operator informieren + Vorschlag machen wie die Story angepasst werden koennte um `neutral` oder `on-intent` zu erreichen. Operator kann Override erzwingen mit explizitem "override intent".

Binaeres on/off waere zu hart — Infrastruktur (Auth-Refactor, DB-Migration) ist nie direkt on-intent, muss aber moeglich sein (→ `neutral` mit Begruendung).

### Schritt 1: Research (wenn noetig)

Pruefen ob externe Recherche noetig ist (neue APIs, unbekannte Technologien, Best Practices).
- Falls ja: Den `/research`-Skill-Ansatz verwenden (2-Tier: QUICK fuer Fakten, DEEP fuer Analysen).
  Perplexity API Details: siehe `research/references/perplexity-api.md`
- Falls nein (internes Refactoring, bekannte Technologie): ueberspringen

### Schritt 2: Kontext laden

Parallel ausfuehren:
1. `linear.getOpenIssues()` — gesamtes Backlog laden
2. **`ARCHITECTURE_DESIGN.md` VOLLSTAENDIG lesen** — bis zur letzten Zeile — alle Sektionen §1–§8 und alle ADRs.
   **PFLICHT-Checkliste — alle folgenden Sektionen muessen gelesen sein:**
   - [ ] §1 Architectural Vision + Leitprinzipien
   - [ ] §2 Quality Attributes (Availability, Latency, Security-Targets)
   - [ ] §3 Alle vorhandenen ADRs vollstaendig (ADR-1 bis zum letzten im Dokument)
   - [ ] §4 Layer-to-Pipeline Mapping
   - [ ] §5 Failure Mode Analysis
   - [ ] §6 Component Relationships
   - [ ] §7 Scalability Roadmap
   - [ ] §8 Testing Architecture
   - [ ] Referenzen-Sektion (Querverweise auf weitere Architektur-Dokumente)
3. `SYSTEM_ARCHITECTURE.md` VOLLSTAENDIG lesen — Komponenten-Liste, Daten-Fluesse, bekannte Schwachstellen
4. `lib/config.js` relevante Sektionen pruefen
5. Pruefen: Gibt es schon ein aehnliches Issue? Existiert das Feature teilweise?

**DB-Schema-Check (PFLICHT wenn Story eine persistente Datenquelle beruehrt — nur wenn Projekt eine DB/Schema-Registry hat):**

1. Aktuelles Schema lesen (projekt-spezifisches DB-Modul, z.B. `lib/db.js` mit `SCHEMA_VERSION`-Konstante)
2. Alle offenen Issues nach `## DB Schema Impact` Sektion durchsuchen — welche Versionen sind bereits "vergeben"?
3. Naechste freie Ziel-Version ermitteln (Konflikt = zwei Stories mit gleicher `targetSchemaVersion`)
4. Im Story-Spec `## DB Schema Impact` ausfuellen: `currentSchemaVersion` + `targetSchemaVersion` + neue Tabellen/Spalten
5. Bei Versionskonflikt: Reihenfolge in `## Abhaengigkeiten` festhalten ("muss nach [STORY-XXX] implementiert werden")

Wenn das Projekt keine versionierte DB-Schema-Verwaltung hat: Schritt uebergehen.

**Domain-Context (wenn vorhanden):** Falls `docs/domain/` im Projekt existiert, alle `docs/domain/*.md`-Dateien lesen. Schluessel-Begriffe und Regulatorik-Anforderungen extrahieren. Relevante Domain-Begriffe in den Acceptance Criteria der Story verlinken (Beispiel: "Zahlungsabwicklung via [[docs/domain/chargeback.md]]"). Fehlt `docs/domain/`: Schritt ueberspringen.

> **Warum ARCHITECTURE_DESIGN.md vollstaendig?** Es ist das einzige Dokument das alle
> Architektur-Entscheidungen (ADRs), Quality Attributes und strategische Constraints
> zusammenfasst. Ohne alle ADRs gelesen zu haben fehlt der 360°-Blick: Das Kill-Switch Pattern
> ist Pflicht fuer jedes Feature, ADRs beeinflussen Signal-Routing-Entscheidungen.
> Jede neue Story muss gegen ALLE ADRs geprueft werden — sonst entstehen Features die mit
> bestehenden Entscheidungen kollidieren.

### Schritt 3: Architecture Design Document (fuer Features)

Bei Feature-Stories und komplexen Aenderungen ein ADD erstellen:
Siehe [references/architecture-design-document.md](references/architecture-design-document.md)

Das ADD beschreibt:
- Betroffene Layer und Komponenten-Zusammenspiel
- Datenarchitektur: Fluss, Formate, Konsistenz
- API- und Integrations-Design
- Infrastruktur-Impact (vom Cloud System Engineer, falls als Teammate verfuegbar)
- 8-Dimensionen-Bewertung mit Befund und konkreter Massnahme
- Architektur-Entscheidungen (ADRs) mit Begruendung
- Risiken und Mitigationen
- Implementierungs-Hinweise (betroffene Dateien, Reihenfolge, Config)

**Umfang skaliert mit Komplexitaet** — das ADD-Template definiert welche Sektionen
je nach Story-Typ Pflicht sind. Bug Fixes brauchen kein ADD.

**Bei Agent Teams:** Architekt-Teammate und Cloud System Engineer erstellen
das ADD kollaborativ und challengen sich gegenseitig.

### Enforcement-Check (PFLICHT bei jedem neuen ADR oder Architektur-Entscheid)

Nach jedem neuen ADR oder jeder neuen Architektur-Entscheidung IMMER diese Frage stellen:

> **"Ist dieser Entscheid nur dokumentiert — oder auch maschinell erzwungen?"**

| Antwort | Aktion |
|---------|--------|
| **Maschinell erzwungen** (Commit-Hook, Self-Healing Check, Config-Validation) | Hinweis in Story-Description eintragen wo der Guard liegt |
| **Nur dokumentiert** | Automatisch eine Guard-Story vorschlagen |

**Typische Guard-Mechanismen:**
- Commit-Hook in `.claude/hooks/` (wie Spec-Gate, Exchange-Guard)
- Self-Healing Check (Architecture Guard) — Erweiterung um neue Pruefung
- Config-Validation in Self-Healing

**Wichtig:** Der Operator muss nicht danach fragen — diese Pruefung laeuft automatisch
als Teil jeder Ideation-Session. Wenn ein ADR nur auf Papier existiert → Guard-Story
direkt in Schritt 5 (Abgleich) als separate 1-SP-Story vorschlagen.

### Schritt 4: Story entwerfen (Draft)

ADD + Story-Template kombinieren. Der Draft besteht aus:

**Story-Body** (je nach Typ):
- **Feature/Agent**: Siehe [references/story-template-feature.md](references/story-template-feature.md)
- **Fix/Refactoring**: Siehe [references/story-template-fix.md](references/story-template-fix.md)

**ADD als Anhang** (bei Features):
- Das ADD wird als Kommentar an die Linear-Story angehaengt
- Oder als eingeklappte Sektion (`<details>`) im Story-Body

Die 4 Perspektiven fliessen in Story + ADD ein:
- **Business:** Sektion 1 im ADD (Zusammenfassung)
- **Architektur:** Sektionen 2-7 im ADD
- **Umsetzung:** Sektion 9 im ADD + Story-Template
- **Qualitaet:** Acceptance Criteria in Story + Sektion 8 im ADD

### Schritt 5: Abgleich + Einordnung + Sprint-Fit

Den Draft dem Operator praesentieren, zusammen mit:
- Abhaengigkeiten zu bestehenden Issues (bidirektional)
- Prioritaetsempfehlung im Gesamtkontext
- Betroffene Issues die angepasst werden muessen
- Falls Vorarbeit noetig: "Dafuer brauchen wir erst [STORY-XX]" oder "Neue Story noetig fuer Y"

**Sprint-Fit-Bewertung** (PFLICHT):

| Kriterium | Bewertung |
|-----------|-----------|
| **Geschaetzte Story Points** | 1–5 SP (>5 → Splitting-Vorschlag machen) |
| **Sessions bis Done** | 1–2 Sessions (>2 → zu gross, splitten) |
| **Sprint-Passung** | Passt diese Story neben die aktuellen Sprint-Stories? (Max 3–4 total) |
| **WIP-Impact** | Wuerde die Aufnahme WIP > 2 erzeugen? |
| **Carry-Over-Risiko** | Niedrig / Mittel / Hoch — basierend auf Komplexitaet und Abhaengigkeiten |

Bei Carry-Over-Risiko "Hoch" einen Splitting-Vorschlag machen:
- Welche Teile koennen als eigene Stories herausgeloest werden?
- Was ist der minimale Scope fuer einen ersten Wurf?

**Auf Operator-Freigabe warten** bevor Linear-Issue erstellt wird.

### Schritt 5b: Token-Heuristik + Story-Points + Ausfuehrungsmodus (BOO-39)

Vor dem Linear-Push: Token-Verbrauch schaetzen und daraus SP + Modus ableiten. Konvention siehe HANDBUCH Anhang G (BOO-38), Heuristik-Signale siehe `references/token-heuristik.md`.

**Logik:**

1. **Story-Beschreibung parsen** und Signale extrahieren:
   - Anzahl betroffener Files (linear ~2k Token pro File)
   - Erwartete Diff-Groesse in Zeilen (~100 Token pro 50 Zeilen)
   - Test-Aufwand (neue Tests +20-50% Tool-Output)
   - Doku-Aufwand (HANDBUCH, README, Excalidraw +10-30%)
   - Cross-Skill-Beruehrungen (+1k pro betroffenen Skill)
   - Reference-Datei-Lese-Aufwand (+500-2000 pro Reference)

2. **Optional: L3-Kalibrierung** — wenn `journal/learnings.db` (Level L3) existiert: aehnliche Stories der letzten Sprints suchen (gleiche Skills, aehnliche Diff-Groesse), Multiplikator anpassen. Falls L3 nicht vorhanden oder weniger als 5 aehnliche Stories: ungewichtete Heuristik.

3. **Token-Estimate berechnen** als absolute Zahl in Tokens, plus prozentualer Anteil am Sprint-Budget (80% des Context-Windows).

4. **SP-Klasse aus HANDBUCH Anhang G ableiten:**

   | Token-Estimate | Anteil 80%-Budget | SP-Klasse | Ausfuehrungsmodus |
   |---|---|---|---|
   | < 8k | ~5% | 1 | linear |
   | 8-24k | ~10-15% | 2 | linear / sub-agents |
   | 24-48k | ~20-30% | 3 | sub-agents |
   | 48-96k | ~40-60% | 5 | agentic |
   | > 96k | ueber 60% | 8 | **Story aufteilen** |

5. **Operator-Hybrid-Frage:**

   ```
   "Token-Schaetzung: 38k (~24% Sprint-Budget) → 3 SP → Modus 'sub-agents'.
    Korrigieren? [y/n] (n = uebernehmen)"
   ```

   Bei `y`: neue SP-Eingabe, Modus automatisch nachgezogen aus Tabelle.

6. **Frontmatter der Story-Spec schreiben:**

   ```yaml
   ---
   story_id: BOO-XX
   estimate: 3
   token_estimate: 38000
   execution_mode: sub-agents
   estimation_basis: |
     4 Files (~8k), ~250 Zeilen Diff (~5k), Test-Erweiterung (+30%),
     HANDBUCH-Update (+20%), 2 aehnliche Stories in L3 (Faktor 0.9)
   ---
   ```

   `estimation_basis` als Prosa, damit Operator + spaeter `/implement` Schritt 0b die Schaetzung nachvollziehen koennen.

7. **Linear-Issue mit `estimate` setzen.** Den Ausfuehrungsmodus als Hinweis-Block in den Issue-Body packen (Hermes liest das ueber BOO-31 `metadata.hermes.related_skills`, andere Skills lesen es ueber die Spec).

**Bei SP = 8 (Story zu gross):** STOPP. Operator-Anweisung: Story in der bestehenden Logik aus Schritt 5 (Carry-Over-Risiko) splitten. Erst nach Split weiter zu Schritt 6.

### Schritt 6: Finalisieren (nach OK)

1. Linear-Issue erstellen mit vollstaendigem Template
2. Betroffene bestehende Issues updaten (Abhaengigkeiten, Gesamtplan)
3. Operator zusammenfassen: Was wurde erstellt, was wurde geaendert
