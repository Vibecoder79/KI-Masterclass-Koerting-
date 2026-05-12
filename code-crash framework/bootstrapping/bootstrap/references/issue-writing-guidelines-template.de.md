# Issue-Schreibrichtlinien — {{PROJECT_NAME}}

**Version:** 3.1
**Zweck:** Standardisierte Issue-Erstellung fuer die Zusammenarbeit Claude + Operator
**Aenderungen v3.1 (BOO-30):** §7 Definition of Done auf 5er-Checkliste alignt (1:1 aus BOO-30), Querverweis auf Linear-Workflow-States (HANDBUCH §8g) ergaenzt
**Aenderungen v3.0:** §6 Schrader-Prompt-Bestandteile (neu), §7 Definition of Done (neu), §8 Ausfuehrungsmodus (ersetzt alt §6 Agent Team Setup), §9 Metadaten (vorher §7)

---

## Kurzreferenz

### Titel-Format
```
[Aktion] [Komponente] — [Detail/Nutzen]
```

**Beispiele:**
- "Build Auth Service — JWT-basiertes Session Management"
- "Add Rate Limiting to API Gateway"
- "Fix Memory Leak in Worker Process"
- "Epic: Data Pipeline Refactor (5 Komponenten)"

### Description-Struktur (Pflicht-Reihenfolge)
```
## Was
[Was wird gebaut/geaendert? Technischer Ueberblick]

## Warum
[Warum ist das wichtig? Business Value? Performance-Gewinn?]

## Kontext
[Verwandte Issues? Abhaengigkeiten? Hintergrund?]

## Workflow-Type
`direct` (direkt bauen) oder `epic` (mehrere Sub-Tasks)

## Komplexitaet
`low`, `medium`, oder `high`

## Abhaengigkeiten
- Benoetigt: [BOO-XX] (muss vorher fertig sein)
- Beeinflusst: [BOO-YY] (wird durch diese Aenderung beeinflusst)

## Akzeptanzkriterien
- [ ] Konkrete Anforderung 1
- [ ] Konkrete Anforderung 2
- [ ] Dokumentation aktualisiert (CLAUDE.md + SYSTEM_ARCHITECTURE.md)
- [ ] Git Push

## Schrader-Prompt-Bestandteile (Pflicht — Code Crash Kap. 5)
### Insight (Perceive)   — Erkenntnis + Intent-Referenz
### Constraints          — Tech, Zeit, Fachlich, Regulatorisch
### Erfolgskriterien     — Metriken + quantifizierte Zielwerte
### Gewuenschtes Ergebnis — konkrete Artefakte am Ende

## Definition of Done (Pflicht)
- [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)
- [ ] PR ist gemerged auf main
- [ ] Alle Required Status Checks gruen (siehe BOO-29)
- [ ] Kein offener "QA Failed"-Status
- [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)

## Ausfuehrungsmodus
**Modus:** `linear` | `sub-agents` | `agentic`
**Story Points:** [Zahl]
```

---

## Detailliertes Format

### 1. Titel

**Struktur:**
```
[Aktion] [Komponente] — [Hauptnutzen/Detail]
```

**Aktionstypen:**
- **Build:** "Build [Komponente]"
- **Add:** "Add [Feature] to [Komponente]"
- **Integrate:** "Integrate [Quelle] with [Ziel]"
- **Optimize:** "Optimize [Komponente]"
- **Fix:** "Fix [Problem] in [Komponente]"
- **Epic:** "Epic: [grosses Architektur-Thema]"

---

### 2. "Was"-Sektion

**Was einschliessen:**
- Technische Implementierungs-Details
- Architektur-Entscheidungen
- Komponenten-Breakdown
- Code-Referenzen (Dateien/Funktionen)
- Datenstrukturen (wenn relevant)

**Template:**
```markdown
## Was

[Was wird gebaut]

**Architektur:**
[Diagramm oder Bullet-Points die den Fluss zeigen]

**Komponenten:**
1. [Komponente 1]: [Zweck]
2. [Komponente 2]: [Zweck]
3. [Komponente 3]: [Zweck]

**Wichtige Implementierungs-Details:**
* [Detail 1]
* [Detail 2]
```

---

### 3. "Warum"-Sektion

**Was einschliessen:**
- Business Value / Kernnutzen
- Performance-Verbesserungen (wenn moeglich quantifiziert)
- Risiko-Reduktion
- Vergleich zum aktuellen Zustand

**Template:**
```markdown
## Warum

* [Nutzen 1]: [wenn moeglich quantifiziert]
* [Nutzen 2]: [wenn moeglich quantifiziert]

Vergleich zur aktuellen Loesung:
| Aspekt | Heute | Mit dieser Aenderung |
|--------|-------|----------------------|
| [Metrik 1] | [aktuell] | [verbessert] |
```

---

### 4. "Kontext"-Sektion

**Was einschliessen:**
- Verwandte Issues / Epics
- Abhaengigkeiten (was muss vorher passieren?)
- Risiko-Betrachtungen

**Template:**
```markdown
## Kontext

**Verwandte Issues:**
* Haengt ab von: [BOO-X], [BOO-Y]
* Blockiert: [BOO-Z]
* Epic: [BOO-Epic]

**Trigger:**
Umsetzen wenn [Bedingung]. Aktuell [Ist-Zustand].

**Risiken & Mitigation:**
* Risiko 1 → Mitigation 1
* Risiko 2 → Mitigation 2

**Workflow-Type:** `direct`
**Komplexitaet:** `high`
```

---

### 5. Akzeptanzkriterien

**Format:**
```markdown
## Akzeptanzkriterien

- [ ] Konkrete, testbare Anforderung 1
- [ ] Konkrete, testbare Anforderung 2
- [ ] Konkrete, testbare Anforderung 3
- [ ] Dokumentation aktualisiert (CLAUDE.md + SYSTEM_ARCHITECTURE.md)
- [ ] Git Push
- [ ] [Optional: Testperiode, z.B. "48h Parallelbetrieb"]
```

**Regeln:**
- Jede Checkbox muss testbar/verifizierbar sein
- Keine mehrdeutigen Anforderungen
- Immer Doku-Updates einschliessen
- Immer git push als letzten Schritt einschliessen

---

### 6. Schrader-Prompt-Bestandteile (Pflicht — Code Crash Kap. 5)

Aus Schrader Code Crash Kap. 5 §"From Intent to Prompt": Jedes Issue ist ein vollstaendiger Prompt. Alle vier Bestandteile sind Pflicht — ein fehlendes Feld loest den Soulkiller-Check aus.

```markdown
## Schrader-Prompt-Bestandteile (Pflicht — Code Crash Kap. 5)

### Insight (Perceive)
Welche Erkenntnis treibt diese Story? Was haben wir erkannt, das andere nicht sehen?
*Vererbt aus dem zugehoerigen Intent (BOO-1, BOO-10). Wenn kein Intent-Bezug → Soulkiller-Check ausgeloest.*

### Constraints
Was schraenkt uns ein? Technisch, zeitlich, fachlich, regulatorisch.
Beispiele:
* Tech: bestehende DB-Schema, externes API mit Rate Limit
* Zeitlich: vor naechstem Release X
* Fachlich: DSGVO-konform, kein PII im Log
* Regulatorisch: nur in EU-Region

### Erfolgskriterien
Wie messen wir, dass es funktioniert? Akzeptanzkriterien + Metriken mit Zielwerten.
* Funktional: API-Endpunkt /xyz liefert 200 fuer gueltige Eingabe X
* Quantitativ: P95-Latenz <200ms, Coverage >= 80%
* Nutzer-orientiert: Operator kann Aufgabe Y in <30s erledigen

### Gewuenschtes Ergebnis
Was steht am Ende konkret da? Moeglichst spezifisch.
* Welche Dateien wurden veraendert?
* Welcher API-Endpunkt / UI-Element / CLI-Befehl ist neu?
* Welche ADR wurde geschrieben?
* Welcher Migrations-Schritt?
```

**Beispiel-Ausfuellung:**
```markdown
## Schrader-Prompt-Bestandteile

### Insight (Perceive)
Heutige Issue-Templates haben keinen strukturellen Prompt-Rahmen. Claude kann nicht pruefen ob ein Issue wirklich ein vollstaendiger Prompt ist. Vererbt aus INTENT-003: "Issues muessen PRDs sein, keine TODO-Listen."

### Constraints
* Bestehende Linear-Issues duerfen nicht rueckwirkend invalidiert werden
* Template-Datei ist bilingual (DE+EN), beide Versionen muessen aequivalent sein

### Erfolgskriterien
* /implement-Skill bricht bei fehlendem Schrader-Bestandteil mit klarem Hinweis ab
* Neue Issues haben alle 4 Sub-Sections mit nicht-leerem Inhalt (mind. 20 Zeichen)

### Gewuenschtes Ergebnis
* issue-writing-guidelines-template.de.md + .md auf Version 3.0
* /implement SKILL.md hat neuen Schritt 1b (Pre-Flight-Check Schrader-Bestandteile)
* HANDBUCH.md §Daily Usage erwaehnt die Pflichtsektion
```

---

### 7. Definition of Done (Pflicht)

Story darf erst auf Linear-Status "Done" wenn alle Punkte abgehakt sind. Diese Sektion ist nicht verhandelbar — sie ist 1:1 aus BOO-30 uebernommen und steuert direkt den Linear-Workflow-State `Done` (vgl. HANDBUCH §8g Linear-Setup pro Projekt).

```markdown
## Definition of Done (Pflicht)

Story darf erst auf Linear-Status "Done" wenn:
* [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)
* [ ] PR ist gemerged auf main
* [ ] Alle Required Status Checks gruen (siehe BOO-29)
* [ ] Kein offener "QA Failed"-Status
* [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)
```

**Regeln:**
- Checklisten-Punkte nicht pro Story anpassen oder weglassen.
- Wenn ein Gate nicht zutrifft (z.B. keine Tests bei einer reinen Doku-Story), explizit kennzeichnen: `* [N/A] Tests — reine Doku-Story`.
- Spec-File-Update ist unabhaengig von der Story-Groesse Pflicht.

---

### 8. Ausfuehrungsmodus

Bestimmt wie Claude die Story ausfuehrt. Story Points sind der primaere Indikator, Kontext kann den Modus nach oben korrigieren.

```markdown
## Ausfuehrungsmodus

**Modus:** `agentic` | `sub-agents` | `linear`
**Story Points:** [Zahl] (bestimmt den Modus mit)
```

#### Wenn `agentic` (Lead + parallele Sub-Agents):
Claude ist Lead-Orchestrator, mehrere Sub-Agents arbeiten koordiniert gegen ein gemeinsames Ziel.

```markdown
| Rolle | Kontext (was der Agent wissen muss) | Aufgabe | Skill (existierend oder ad-hoc) |
|-------|-------------------------------------|---------|----------------------------------|
| Lead (Claude) | — (bekommt Synthese von allen Sub-Agents) | Orchestrieren, Ergebnisse mergen, Entscheidungen | — |
| Sub-Agent 1 | [Projekt-Infos, Dateien, Vorwissen das dieser Agent braucht] | [konkrete Teilaufgabe] | [z.B. `grafana` / oder Ad-hoc-Briefing "Du bist X, tust Y"] |
| Sub-Agent 2 | [...] | [...] | [...] |
```

#### Wenn `sub-agents` (sequenziell, kein paralleles Team):
Claude ruft pro Teilaufgabe einzelne fokussierte Sub-Agents, ohne sie parallel zu orchestrieren.

```markdown
| Rolle | Kontext | Aufgabe | Skill |
|-------|---------|---------|-------|
| Sub-Agent | [...] | [...] | [...] |
```

#### Wenn `linear` (direkt, kein Unterbau):
Claude arbeitet die Aufgabe direkt ab, ohne Sub-Agents zu spawnen.

```markdown
**Begruendung:** [z.B. "einzelne Datei, <20 Zeilen, Sub-Agent-Overhead groesser als Nutzen"]
```

**Entscheidungs-Hilfe:**

| Signal | Modus |
|--------|-------|
| Story Points high, mehrere Komponenten/Layer betroffen, parallele Arbeit moeglich | → agentic |
| Story Points medium, klare Teilaufgaben die nacheinander gehen | → sub-agents |
| Story Points low, einzelne Datei oder Config, <50 Zeilen Aenderung | → linear |
| Blockiert andere Issues (braucht Architecture-Vorlauf) | → agentic (+ Architect-Rolle) |
| Sicherheits-/Infrastruktur-relevant | → agentic (+ Security-/Cloud-Rolle) |
| Reine Dokumentation, einzelne Datei | → linear |

**Hinweis zu Skill vs. Ad-hoc:**
Unter "Skill" sind zwei Arten gemeint:
1. Existierende Bootstrapping-Skills (z.B. `grafana`, `security-architect`) — referenziert + aufgerufen
2. Ad-hoc Kontext-Briefing — wenn keiner passt: "Du bist [Rolle]", "Dein Kontext: [...]", "Deine Aufgabe: [...]"

**Beispiel `agentic`** (neue Architektur-Dimension mit 4 Dateien):
```markdown
**Modus:** `agentic`
**Story Points:** 8

| Rolle | Kontext | Aufgabe | Skill |
|-------|---------|---------|-------|
| Lead | ARCHITECTURE_DESIGN.md, specs/BOO-13.md | Orchestrieren, Merge, Spec aktualisieren | — |
| Writer A | ki-architektur-prinzipien.md als Referenz | Neues Dimensions-Chapter in architecture-checklist.md | Ad-hoc: "Du bist Technical Writer..." |
| Writer B | Bestehende Dimensionen §1-§8 | Section §9 Scalability in implement/references/architecture-checklist.md | Ad-hoc |
```

**Beispiel `linear`** (Config-Aenderung in einer Datei):
```markdown
**Modus:** `linear`
**Story Points:** 1

**Begruendung:** Einzelne Datei (semgrep.yml), 3 neue Regeln hinzufuegen, kein Layer-uebergreifender Effekt.
```

---

### 9. Metadaten (vor Erstellung in Linear)

```
Priority: [1=Urgent, 2=High, 3=Medium, 4=Low]
Labels: [relevante Tags, z.B. feature, bug, architecture, infra]
Estimate: [Stunden, oder leer lassen wenn unsicher]
State: [Backlog, Current Sprint, etc.]
```

---

## Wenn Claude ein Issue erstellt

Am Anfang der Description immer einfuegen:

```markdown
> 🤖 **Ideation Source:** Claude AI Agent
> Erstellt waehrend [Kontext]
> Empfehlung: [Prioritaets-Vorschlag]
```

---

## Anti-Patterns

| Schlecht | Gut |
|----------|-----|
| "Verbessere das System" | "Optimize Worker Loop — Add Delta-Based Change Detection" |
| "Bau was Cooles" | "- [ ] Feature X implementiert und getestet" |
| "Neue Komponente hinzufuegen" | "Haengt von BOO-50 ab. Blockiert bis Datenbank deployed." |
| "Mach es schneller" | "Reduziere Latenz von 150ms auf <100ms" |
| "Das wird super!" | "Risiko: Single Point of Failure. Mitigation: Graceful Degradation." |
| Schrader-Bestandteile leer lassen | Alle 4 Sub-Sections mit konkretem Inhalt (mind. 20 Zeichen) |
| Definition of Done weglassen | Jedes Issue hat DoD-Checklist, Status "Done" erst wenn alles abgehakt |
| Ausfuehrungsmodus fehlt | Modus + Story Points pflicht, Tabelle bei agentic/sub-agents |

---

## Vollstaendiges Template fuer Claude-generierte Issues

```markdown
> 🤖 **Ideation Source:** Claude AI Agent
> Vorgeschlagen waehrend [Kontext]
> Empfehlung: [z.B. "Nach BOO-42"]

## Was
[Technische Implementierung]

## Warum
[Business Value + quantifizierte Nutzen]

## Kontext
[Abhaengigkeiten, Trigger, Risiken]
**Workflow-Type:** `direct`
**Komplexitaet:** `medium`

## Abhaengigkeiten
- Benoetigt: [BOO-XX, falls vorhanden]
- Beeinflusst: [BOO-YY, falls vorhanden]

## Akzeptanzkriterien
- [ ] Konkrete Anforderung 1
- [ ] Dokumentation aktualisiert
- [ ] Git Push

## Schrader-Prompt-Bestandteile (Pflicht — Code Crash Kap. 5)

### Insight (Perceive)
[Erkenntnis + Intent-Referenz wenn vorhanden]

### Constraints
[Technisch, zeitlich, fachlich, regulatorisch]

### Erfolgskriterien
[Quantifizierbare Metriken + Akzeptanzkriterien]

### Gewuenschtes Ergebnis
[Konkrete Artefakte am Ende]

## Definition of Done (Pflicht)
Story darf erst auf Linear-Status "Done" wenn:
* [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)
* [ ] PR ist gemerged auf main
* [ ] Alle Required Status Checks gruen (siehe BOO-29)
* [ ] Kein offener "QA Failed"-Status
* [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)

## Ausfuehrungsmodus

**Modus:** `linear` | `sub-agents` | `agentic`
**Story Points:** [Zahl]

[Bei `agentic` oder `sub-agents`: Tabelle mit Rolle / Kontext / Aufgabe / Skill]
[Bei `linear`: Begruendung warum kein Sub-Agent-Overhead noetig]

**Priority:** [1-4]
**Labels:** [relevante Tags]
**Estimate:** [Stunden oder TBD]
**Depends on:** [BOO-X, falls vorhanden]
```

---

*Issue-Schreibrichtlinien — {{PROJECT_NAME}} | Code Crash Governance v2 | Version 3.1*
