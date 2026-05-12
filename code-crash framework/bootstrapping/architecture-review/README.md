<a name="deutsch"></a>

# Architecture Review — 8 Dimensionen gegen eine Story oder das Gesamtsystem

> Prueft jede Story — oder das gesamte System — gegen 8 Architektur-Dimensionen. Findet Risiken, Tech Debt und Skalierungs-Probleme **bevor** sie im Produktivsystem landen.

**Version:** 1.3.0 · **Befehl:** `/architecture-review`

---

## Was der Skill tut

Die meisten Teams machen Architektur-Review erst wenn etwas kaputt geht. Dieser Skill macht Review zu einem Routine-Checkpoint — fuer einzelne Stories (Story-Review) oder das Gesamtsystem (System-Review).

Der Skill zwingt Claude, `ARCHITECTURE_DESIGN.md` komplett zu lesen (§1–§8 plus alle ADRs) bevor irgendeine Bewertung erfolgt. Kein Ueberfliegen, kein "ich habe genug gelesen". Diese Regel allein verhindert die meisten Fehleinschaetzungen.

**Zwei Modi:**

| Modus | Ausloeser | Was rauskommt |
|-------|-----------|---------------|
| **A — Story-Review** | Bevor eine Story in `/implement` geht | Status pro Dimension (OK / Warnung / Kritisch), konkrete Empfehlungen, optional Story-Aenderungen |
| **B — System-Review** | Quartalsweise oder vor Refactor | Voll-Audit: Staerken, Risiken, Tech Debt, neue Backlog-Issues |

---

## Die 8 Architektur-Dimensionen

| # | Dimension | Was geprueft wird |
|---|-----------|-------------------|
| 1 | **Reliability** | Failure Modes, Retries, Backoff, Circuit Breaker |
| 2 | **Data Integrity** | Schema-Vertraege, Migrations, referentielle Integritaet |
| 3 | **Security** | Auth-Grenzen, Secret-Handling, Angriffsflaeche |
| 4 | **Performance** | Latenz-Budgets, Hot Paths, Bottlenecks |
| 5 | **Observability** | Metrik-Coverage, Logs, Traces, Alert Rules |
| 6 | **Maintainability** | Kopplung, Klarheit, toter Code, Duplikate |
| 7 | **Cost Efficiency** | Cloud-Ausgaben, redundanter Compute, Leerlauf |
| 8 | **Signal Quality** | Fuer ML/AI-Systeme: Rauschen vs. Signal, Drift |

Dimensionen 7 und 8 werden beim Bootstrap domain-spezifisch angepasst — ersetz sie durch das, was dein Projekt wirklich interessiert.

---

## Wie er funktioniert

```
Story / System im Review
        │
        ▼
ARCHITECTURE_DESIGN.md §1–§8 + alle ADRs lesen (Pflicht-Checkliste)
        │
        ▼
Aenderung auf betroffene Komponenten mappen
        │
        ▼
Relevante Dimensionen bewerten (nicht immer alle 8)
        │
        ▼
Output:  Status · Befund · Empfehlung  (pro Dimension)
```

Die Pflicht-Regel zum Doku-Lesen bricht das Anti-Pattern. Ohne sie wird das Review zum Bauchgefuehl. Mit ihr ist jede Bewertung an ein konkretes ADR oder eine Design-Entscheidung gebunden.

---

## Trigger-Phrasen

- `/architecture-review`
- "Architektur pruefen"
- "passt das architektonisch?"
- "Review"
- "Architektur-Audit"

---

## Schnittstellen zu anderen Skills

| Upstream (liefert Input) | Was geliefert wird | Downstream (nutzt das Review) | Was wir liefern |
|--------------------------|--------------------|--------------------------------|------------------|
| `ideation` | Story mit ACs + vorgeschlagene Komponenten | `implement` | Go/No-Go Signal bevor Code geschrieben wird |
| `backlog` | Prio-Liste offener Stories | `sprint-review` | Dimension-Befunde fliessen ins Quartals-Audit |
| `security-architect` (DESIGN-Mode) | Threat Model fuer die Aenderung | `research` | Markiert offene Fragen fuer Deep Research |

---

## Artefakte / Outputs

Pro geprueefter Dimension:

```
### Dimension: Reliability
Status:       WARNUNG
Befund:       Retry-Logik auf Kafka-Consumer ohne exponential Backoff.
              First-Retry-Storm in Staging bei 4× Normallast beobachtet.
Empfehlung:   Jittered Exponential Backoff hinzufuegen (ADR-12 Praezedenzfall).
              Neue Story: "RELI-43 — Add backoff to consumer retries"
```

System-Review zusaetzlich:
- **Staerken** — was laeuft gut
- **Top-3-Risiken** — was zuerst angehen
- **Tech-Debt-Score** — Niedrig / Mittel / Hoch
- **Empfohlene Issues** — neue Linear-Tickets fuer Backlog

---

## Installation

```bash
cp -r architecture-review ~/.claude/skills/architecture-review
```

Aktiviert sich automatisch in der naechsten Claude-Code-Session.

---

## Dateistruktur

```
architecture-review/
├── README.md                        ← Diese Datei
├── SKILL.md                         ← Skill-Definition (wird von Claude Code gelesen)
└── references/
    └── dimensions-detail.md         ← Erweiterte Kriterien pro Dimension
```

---

## Changelog

### v1.3.0 (BOO-14)

Observability-Invarianten als Pflicht-Pruefpunkte in §5 Qualitaets-Dimensionen verankert. Pflicht-Checkliste in `SKILL.md` erweitert um expliziten Sub-Block "Observability — drei Invarianten": Logging-Schema (6 Pflicht-Felder + Logger-ADR), Metrics-Endpoint (4 Pflicht-Metriken + Port 9090+N), Alert-Rules (3 Pflicht-Alerts `{service}_down` / `{service}_error_rate_high` / `{service}_p95_slow` + Routing + promtool-Validierung). `references/dimensions-detail.md` §5 in drei Sub-Sektionen 5.1/5.2/5.3 mit jeweils 5 Pruef-Fragen strukturiert; bestehende BOO-8-Inhalte als "Allgemeine Hygiene"-Block beibehalten. Schrader Code Crash Kap. 3 + Kap. 4 als Quelle verlinkt.

### v1.2.1 (BOO-43)

Drift-Fix: `architecture-design-template.md` zurueckgezogen auf §-Nummerierung, sodass die §1–§N-Referenzen im Skill aufloesbar sind. Skill-Pflicht-Checkliste auf das tatsaechliche Template-Layout (§1 Big Picture, §2 Design-Rationale, §3 ADR, §4 Komponenten-Uebersicht, §5 Qualitaets-Dimensionen, §6 Referenzen, §7+ optionale Add-ons) angeglichen.
