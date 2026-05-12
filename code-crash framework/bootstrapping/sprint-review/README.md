<a name="deutsch"></a>

# Sprint Review — Quartals-Audit fuer Architektur, Tech Debt und Backlog

> Periodischer System-Check: 8 Architektur-Dimensionen · Tech-Debt-Inventur · Backlog-Hygiene · Prozess-Compliance. Ein Durchlauf, ein Report, eine Action-Liste.

**Version:** 1.2.0 · **Befehl:** `/sprint-review`

---

## Was der Skill tut

Die meisten Teams reviewen "wie lief der Sprint" anhand der Velocity. Das ist ein Symptom. Dieser Skill auditiert das System selbst: Ist die Architektur noch gesund? Waechst Tech Debt? Haben Issues Abhaengigkeiten? Ist die Doku synchron?

Der Output ist handlungsfaehig: Top-3-Risiken, Tech-Debt-Score (Niedrig / Mittel / Hoch), empfohlene neue Issues, Backlog-Bereinigungs-Vorschlaege.

---

## Wie er funktioniert

```
Schritt 1: System-Snapshot (parallel)
   · Linear-Backlog (alle Stati)
   · ARCHITECTURE_DESIGN.md (komplett, §1–§8 + alle ADRs)
   · SYSTEM_ARCHITECTURE.md
   · config.js aktueller Stand
   · Git-Log der Periode
   · Self-Healing Logs (haeufige Warnings)

Schritt 2: Architektur-Review (8 Dimensionen)
   Reliability · Data Integrity · Security · Performance
   Observability · Maintainability · Cost Efficiency · Signal Quality

Schritt 3: Tech-Debt-Inventur
   · Code-Duplikation · hardcoded Werte · Deprecated Features
   · Offene Code-Marker · stale Dependencies

Schritt 4: Backlog-Hygiene
   · Orphans · fehlende Abhaengigkeiten · obsolete Issues · veraltete Prios

Schritt 5: Prozess-Compliance
   · Pflicht-Template bei neuen Issues?
   · Abhaengigkeiten bidirektional dokumentiert?
   · Doku-Versionen synchron?
   · Obsidian-Change-Logs geschrieben?

Schritt 6: Report + Massnahmen
   · 3–5 Saetze Gesamtbewertung
   · Top-3-Risiken
   · Tech-Debt-Score
   · Empfohlene neue Issues
   · Backlog-Bereinigungsvorschlaege
```

---

## Trigger-Phrasen

- `/sprint-review`
- "Sprint Review"
- "Architektur-Audit"
- "Tech Debt"
- "Aufraeumen"
- "Quartals-Check"

---

## Schnittstellen zu anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| `architecture-review` (System-Mode) | 8-Dimensionen-Befunde pro Story | `backlog` | Neue Issues + obsolete Issues zum Schliessen |
| `backlog` | Aktueller Backlog-Stand | `ideation` | Tech-Debt-Stories zum Ausfuellen |
| `security-architect` (AUDIT) | Security-Posture | `research` | Offene Fragen fuer Deep Research |
| `grafana` | Observability-Coverage | Operator | Quartals-Action-Plan |

---

## Artefakte / Outputs

- **Zusammenfassung** — 3–5 Saetze Top-Bewertung
- **Top-3-Risiken** — was zuerst, mit Begruendung
- **Tech-Debt-Score** — Niedrig / Mittel / Hoch, plus Grund
- **Empfohlene Issues** — neue Linear-Tickets, bereit fuer `/ideation`
- **Backlog-Bereinigung** — Issues zum Schliessen, Re-Priorisieren, Mergen

---

## Installation

```bash
cp -r sprint-review ~/.claude/skills/sprint-review
```

---

## Dateistruktur

```
sprint-review/
└── SKILL.md     ← Skill-Definition
```
