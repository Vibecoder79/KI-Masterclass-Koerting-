<a name="deutsch"></a>

# Ideation — Vom rohen Einfall zur gut geschriebenen Linear-Story

> 6-Schritte-Workflow der aus einer rohen Idee ein produktionsreifes Linear-Issue macht — mit Research, Architecture Design Document (ADD), Dependency-Mapping und Sprint-Fit-Check. Schluss mit "was haben wir eigentlich beschlossen?" drei Wochen spaeter.

**Version:** 1.3.0 · **Befehl:** `/ideation`

---

## Was der Skill tut

Die meisten Teams schreiben Issues wie Chat-Nachrichten: ein Titel, ein Absatz, vielleicht ACs wenn man Glueck hat. Drei Wochen spaeter weiss niemand mehr was "es" eigentlich hiess.

Der Skill fuehrt einen strengen 6-Schritte-Prozess: Research (wenn noetig), Lesen der vollstaendigen Architektur (alle ADRs, nicht nur die ersten paar), DB-Schema-Chain-Check, Erstellung eines Architecture Design Documents (ADD) bei echten Features, Enforcement-Check bei jedem neuen ADR, Story-Draft mit Sprint-Fit-Scoring, und erst dann — nach Operator-Freigabe — Linear-Issue erstellen.

Output: Eine Story die jemand in sechs Monaten aufschlagen kann und weiss worum es ging.

---

## Die 6 Schritte

| # | Schritt | Was er erzwingt |
|---|---------|-----------------|
| 1 | **Research (wenn noetig)** | Externe Fakten werden via `/research` verifiziert bevor sie ACs werden. Kein "Ich glaube die API kann das." |
| 2 | **Kontext laden (parallel)** | Backlog, `ARCHITECTURE_DESIGN.md` (komplett), `SYSTEM_ARCHITECTURE.md`, Schema-Check, Similar-Issue-Check |
| 3 | **Architecture Design Document** | Features bekommen ein ADD: Komponenten, Datenfluss, Infra-Impact, 8-Dim-Eval, ADRs, Risiken |
| 4 | **Story-Draft** | Kombiniert ADD + Story-Template (Feature oder Fix/Refactor) |
| 5 | **Abgleich + Sprint-Fit** | Abhaengigkeiten (bidirektional), Prio im Kontext, SP-Estimate, WIP-Check, Carry-Over-Risiko |
| 6 | **Finalisieren (nach OK)** | Linear-Issue erstellt + betroffene Issues upgedatet |

---

## Der Enforcement-Check (Pflicht bei jedem neuen ADR)

Jede neue Architektur-Entscheidung triggert diese Frage: **Ist sie maschinell erzwungen oder nur dokumentiert?**

| Antwort | Aktion |
|---------|--------|
| Maschinell erzwungen (Commit-Hook, Self-Healing-Check, Config-Validation) | Guard-Location in Story eintragen |
| Nur dokumentiert | Automatisch Guard-Story als separates 1-SP-Ticket vorschlagen |

Typische Guard-Mechanismen:
- Commit-Hooks in `.claude/hooks/` (wie Spec-Gate, Exchange-Guard)
- Self-Healing Architecture-Guard — um neue Pruefung erweitern
- Config-Validation in Self-Healing

Check laeuft automatisch. Du fragst nicht danach. Papier-ADRs werden zu Guard-Stories.

---

## Sprint-Fit-Scoring (Pflicht)

| Kriterium | Bewertung |
|-----------|-----------|
| Geschaetzte Story Points | 1–5 SP (>5 → Splitting-Vorschlag) |
| Sessions bis Done | 1–2 Sessions (>2 → zu gross, splitten) |
| Sprint-Passung | Passt neben aktuellen Sprint-Stories? (max 3–4 total) |
| WIP-Impact | Wuerde Aufnahme WIP > 2 erzeugen? |
| Carry-Over-Risiko | Niedrig / Mittel / Hoch |

Carry-Over "Hoch" → Splitting-Vorschlag wird mitgeliefert.

---

## Trigger-Phrasen

- `/ideation`
- "ich hab eine Idee"
- "neues Feature"
- "wir brauchen X"
- "neue Story"

---

## Schnittstellen zu anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| User-Idee | Roh-Beschreibung | `backlog` | Neue priorisierte Story |
| `research` | Fakten, Vergleiche, API-Details | `implement` | Story + Spec mit klaren ACs und Scope |
| `security-architect` (DESIGN) | Threat Model fuer die Aenderung | `architecture-review` | Story bereit fuer Pre-Check |
| `cloud-system-engineer` (Teammate) | Infrastruktur-Impact | | |

---

## Artefakte / Outputs

- **Linear-Issue** — komplett befuelltes Template (Feature oder Fix/Refactor)
- **Architecture Design Document (ADD)** — als Kommentar oder `<details>`-Block bei Features
- **`specs/ISSUE-XX.md` Placeholder** — vorgezeichnet fuer implement zum Vervollstaendigen
- **Abhaengigkeits-Updates** — bidirektional in betroffenen Issues
- **Guard-Story** — wenn ein neues ADR maschinelle Erzwingung braucht

---

## Installation

```bash
cp -r ideation ~/.claude/skills/ideation
```

---

## Dateistruktur

```
ideation/
├── SKILL.md                                      ← Skill-Definition
└── references/
    ├── architecture-design-document.md           ← ADD-Template
    ├── architecture-dimensions.md                ← 8 Dimensionen Deep Dive
    ├── story-template-feature.md                 ← Feature/Agent-Template
    ├── story-template-fix.md                     ← Fix/Refactor-Template
    └── perplexity-api.md                         ← Deep-Research-Integration
```
