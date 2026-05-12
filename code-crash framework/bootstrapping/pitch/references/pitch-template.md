# Kopiervorlage: `pitch/PITCH-XX.md`

Diese Datei wird vom `/pitch`-Skill am Ende der 6-Schritte-Session erzeugt und unter `pitch/PITCH-XX.md` im Projekt-Repo abgelegt (XX = naechste freie Nummer mit fuehrenden Nullen, z.B. `PITCH-12.md`). Die Datei wird committed, NICHT gitignored — Pitch-Briefings sind Teil der Projekt-Geschichte.

---

## Frontmatter-Schema

```yaml
---
pitch_id: PITCH-12
sprint: 12
created_at: 2026-04-28T14:00:00Z
related_intents: [INTENT-3, INTENT-5]
related_stories: [BOO-15, BOO-16, BOO-17]
metrics_snapshot:
  loc_delta: "+2,341 / -890"
  coverage_trend: "82% → 84% (+2pp)"
  p95_change: "180ms → 145ms (-19%)"
  iterations_avg: 2.3
  feature_flags_active: 3
  intent_fulfillment_score: 0.85
demo_path: "User-Onboarding → Search → Checkout"
status: prepared | delivered | post-mortem
---
```

## Feld-Erklaerung

| Feld | Erklaerung |
|---|---|
| `pitch_id` | Laufende ID, Format `PITCH-XX` mit fuehrenden Nullen. Hoechste Nummer in `pitch/PITCH-*.md` + 1. |
| `sprint` | Sprint-Nummer oder Sprint-Datei-Referenz, auf die sich der Pitch bezieht. |
| `created_at` | ISO-8601 UTC-Zeitstempel der Erstellung. Wird in Schritt 3 fuer den Architektur-Diff zurueckuebersetzt. |
| `related_intents` | Liste der Intent-IDs aus `intents/INTENT-XX.md`, die im Pitch-Fokus stehen. Mehrere moeglich. |
| `related_stories` | Liste der Linear-Story-IDs, die vorgestellt werden. |
| `metrics_snapshot.loc_delta` | Summe der `+/-`-Zeilen aus `git log --shortstat --since=<sprint-start>`. Format: `"+X / -Y"`. |
| `metrics_snapshot.coverage_trend` | Bewegung der Test-Coverage seit letztem Pitch. Quelle: Sprint-File oder neuester CI-Report. Format: `"vor% → nach% (+/-Xpp)"`. |
| `metrics_snapshot.p95_change` | Bewegung der p95-Latenz seit letztem Pitch. Quelle: Performance-Baseline (BOO-16). Format: `"vorMs → nachMs (+/-X%)"`. |
| `metrics_snapshot.iterations_avg` | Durchschnittliche Iterations-Anzahl pro Story im Scope. Quelle: `meta.json` der Local-Reports. |
| `metrics_snapshot.feature_flags_active` | Anzahl aktiver Feature-Flags. Quelle: `.claude/feature-flags.json` (BOO-17). |
| `metrics_snapshot.intent_fulfillment_score` | Aggregat-Score 0–1 ueber alle `related_intents`. Berechnet in Schritt 4. |
| `demo_path` | User-Journey als Pfeil-Notation (z.B. `"A → B → C"`). Vorschlag aus Demo-Pfad-Heuristik (Schritt 4); Operator kann uebersteuern. |
| `status` | `prepared` beim Erstellen, `delivered` nach Schritt 6, `post-mortem` wenn Pitch schief lief. |

## Body-Sektionen

Reihenfolge fix, alle Sektionen Pflicht — leere Sektion mit `_(keine)_` markieren statt zu loeschen.

### 1. Architektur-Diff seit letztem Pitch

Aus Schritt 3 des Skills. Bullet-Liste, pro Aenderung:

- §-Nummer aus `ARCHITECTURE_DESIGN.md`
- Was geaendert (1 Satz)
- Begruendung aus Commits (1 Satz, ggf. Commit-Hash)

Bei erstem Pitch: kompletter Stand von `ARCHITECTURE_DESIGN.md` zusammengefasst, 3–5 Bullets pro §-Sektion.

### 2. Quality-Gate-Status

Aus Sprint-File und SonarQube (wenn aktiv). Drei Unterpunkte:

- **Offene Findings** — Anzahl + Severity-Verteilung
- **Geschlossene Hotspots** — was im Sprint behoben wurde
- **Coverage-Bewegung** — vor/nach in Prozent-Punkten

### 3. Intent-Erfuellung

Pro `related_intent` ein Block:

```markdown
#### INTENT-X — <Kurz-Titel>

- **Erfolgskriterium:** <wortlaut aus intents/INTENT-X.md>
- **Aktueller Stand:** <Mess-Wert aus Sprint-Reports + Feature-Flag-Stand>
- **Score:** 0.X
```

Score-Berechnung aus Schritt 4 des Skills. Bei nicht messbarem Kriterium: `Score: null — manueller Operator-Score noetig`.

### 4. Demo-Pfad-Vorschlag

User-Journey aus Schritt 4 mit 3–5 Stationen. Pro Station:

- **Station** — Komponente/Endpunkt
- **Warum** — 1 Satz, warum sie sich fuer die Demo eignet (Aenderungsintensitaet ODER Intent-Relevanz)

Operator kann den Pfad waehrend Review (Schritt 5) frei editieren — siehe `demo-path-heuristic.md` §Operator-Override.

### 5. Open Questions

Was der Skill nicht weiss, was Stakeholder fragen koennten. Bullet-Liste, jeweils 1 Satz pro Frage. Skill darf hier Vermutungen formulieren, muss aber explizit als Vermutung markieren.

### 6. Outcome (post-pitch)

Leer beim Erstellen (Schritt 5). Wird vom Operator in Schritt 6 nach dem Stakeholder-Termin manuell befuellt — Freitext, 1–3 Saetze: Wer war da, welche Fragen kamen, welche Entscheidung wurde getroffen. KEINE Auto-Generierung.

---

## Beispiel-PITCH-12.md

```markdown
---
pitch_id: PITCH-12
sprint: 12
created_at: 2026-04-28T14:00:00Z
related_intents: [INTENT-3, INTENT-5]
related_stories: [BOO-15, BOO-16, BOO-17]
metrics_snapshot:
  loc_delta: "+2,341 / -890"
  coverage_trend: "82% → 84% (+2pp)"
  p95_change: "180ms → 145ms (-19%)"
  iterations_avg: 2.3
  feature_flags_active: 3
  intent_fulfillment_score: 0.85
demo_path: "User-Onboarding → Search → Checkout"
status: prepared
---

# PITCH-12 — Sprint 12 Stakeholder-Briefing

## 1. Architektur-Diff seit letztem Pitch

- §3.2 Search-Layer: Wechsel von In-Memory-Index auf Elasticsearch-Cluster. Begruendung: p95 unter 150ms bei >100k Dokumenten (Commit a1b2c3d).
- §4.1 Checkout-Flow: Stripe-Webhook-Retry-Logik ergaenzt. Begruendung: Idempotenz fuer Zahlungs-Bestaetigungen (Commit e4f5g6h).

## 2. Quality-Gate-Status

- **Offene Findings:** 4 (1 high, 3 medium)
- **Geschlossene Hotspots:** 2 SQL-Injection-Pfade im Search-Endpoint
- **Coverage-Bewegung:** 82% → 84% (+2pp), Schwerpunkt im Checkout-Modul

## 3. Intent-Erfuellung

#### INTENT-3 — Such-Latenz unter 150ms

- **Erfolgskriterium:** p95 fuer Suchanfragen sinkt von 180ms auf <150ms innerhalb von 2 Monaten.
- **Aktueller Stand:** p95 = 145ms (Messung 2026-04-27, CI-Report run-892)
- **Score:** 0.95

#### INTENT-5 — Onboarding-Abbruchquote halbieren

- **Erfolgskriterium:** Abbruchquote in Schritt 2 sinkt von 38% auf <19% bis Sprint 14.
- **Aktueller Stand:** Aktuell 27% (Telemetrie 2026-04-27), Feature-Flag `onboarding-v2` rollout 50%.
- **Score:** 0.62

## 4. Demo-Pfad-Vorschlag

- **User-Onboarding** — Konto-Setup mit neuem Schritt-2-Flow (groesster LOC-Delta im Sprint, deckt INTENT-5).
- **Search** — Suche nach Produkt-Liste (zeigt p95-Verbesserung live, deckt INTENT-3).
- **Checkout** — Bezahlung mit Stripe-Retry-Pfad (zeigt §4.1 Architektur-Diff).

## 5. Open Questions

- Wann wird `onboarding-v2` Feature-Flag auf 100% gestellt? (Vermutung: nach Sprint 13, abhaengig von Abbruchquote-Trend)
- Wie wird die ES-Cluster-Kapazitaet skaliert wenn Dokumenten-Anzahl >500k erreicht? (Vermutung: Sharding, aber nicht im Sprint 12 Scope)
- Stakeholder koennten nach Kosten der ES-Migration fragen — Zahlen nicht im Briefing.

## 6. Outcome (post-pitch)

_(Wird nach Termin vom Operator befuellt.)_
```
