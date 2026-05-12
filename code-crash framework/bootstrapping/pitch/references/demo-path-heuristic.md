# Demo-Pfad-Heuristik

Diese Heuristik implementiert Schritt 4 des `/pitch`-Skills — den Demo-Pfad-Vorschlag. Sie wird vom Skill gelesen, nicht vom Operator manuell ausgefuehrt.

## Zweck

Der Skill schlaegt einen User-Journey-Pfad vor (z.B. `"User-Onboarding → Search → Checkout"`), der die Intent-Erfuellung im Live-System am besten zeigt. Der Vorschlag landet im Frontmatter (`demo_path`) und in der Body-Sektion `## 4. Demo-Pfad-Vorschlag` der `PITCH-XX.md`. Der Operator kann den Vorschlag waehrend Review uebersteuern.

## Zwei Faktoren

Die Heuristik kombiniert zwei Signale:

1. **Aenderungsintensitaet seit letztem Pitch** — welche Komponenten haben die meisten Commits/LOC-Delta im Sprint-Zeitraum? Pointe: was sich stark veraendert hat, lohnt sich zu zeigen.
2. **Intent-Relevanz** — welche Komponenten sind in den Erfolgskriterien der `related_intents` genannt? Pointe: die Demo soll Intent-Erfuellung visualisieren, nicht zufaellige Aenderungen.

Beide Faktoren werden zu gleichen Teilen gewichtet (siehe Score-Berechnung).

## Score-Berechnung

Pro Komponente:

```
change_score = (anzahl_commits_im_scope * 0.4) + (loc_delta_normiert * 0.6)
intent_score = anzahl_intents_die_komponente_nennen / anzahl_related_intents
total        = change_score * 0.5 + intent_score * 0.5
```

Definitionen:

- `anzahl_commits_im_scope` — Commits, die mindestens eine Datei der Komponente beruehren, im Sprint-Zeitraum (`git log --since=<sprint-start>`).
- `loc_delta_normiert` — LOC-Delta (added + removed) der Komponente geteilt durch das groesste LOC-Delta einer Komponente im Sprint. Ergibt Wert zwischen 0 und 1.
- `intent_score` — Anteil der `related_intents`, deren Erfolgskriterien-Text den Komponenten-Namen enthaelt (einfache Keyword-Suche). Wert zwischen 0 und 1.

Komponenten-Ranking absteigend nach `total`. Top 3–5 werden in eine User-Journey-Reihenfolge angeordnet — der Skill versucht einen logischen Pfad zu finden (Eingangs-Komponente → Kern-Logik → Output). Bei mehreren moeglichen Pfaden wird der gewaehlt, der den hoechsten kumulativen Score hat.

## Datenquellen

| Signal | Quelle |
|---|---|
| Commits + LOC-Delta pro File | `git log --shortstat --since=<sprint-start>` |
| File → Komponente Mapping | `COMPONENT_INVENTORY.md` (BOO-21 — Domainwissen, Operator-gepflegt) |
| Erfolgskriterien-Text | `intents/INTENT-XX.md` — Abschnitt `## 5. Erfolgsmetrik` und `## Intent-Statement (final)` |
| Komponenten-Namen fuer Keyword-Suche | Aus `COMPONENT_INVENTORY.md` (Komponente-Spalte) |

## Edge Cases

- **Erster Pitch** (keine vorherige `PITCH-XX.md`): Es gibt keinen "Diff seit letztem Pitch". Skill faellt auf reine Intent-Relevanz zurueck und schlaegt den Pfad vor, der alle `related_intents` erstmalig demonstriert.
- **Keine `related_intents` angegeben**: Skill nimmt rein die Aenderungsintensitaet und schlaegt einen "Highlights"-Pfad vor (Top-3 Komponenten nach `change_score`).
- **Keine `COMPONENT_INVENTORY.md`**: Skill arbeitet auf File-Ebene statt Komponenten-Ebene und gibt Hinweis im Output: "Empfehlung: `COMPONENT_INVENTORY.md` pflegen fuer bessere Pfad-Vorschlaege (siehe BOO-21)."
- **Keine Commits im Sprint-Zeitraum** (z.B. Doku-Sprint): `change_score = 0` fuer alle Komponenten. `intent_score` allein entscheidet. Wenn auch der 0 ist: Skill schlaegt keinen Pfad vor, setzt `demo_path: null` und Hinweis "kein automatischer Vorschlag — Operator-Auswahl noetig".

## Operator-Override

Der Skill-Vorschlag erscheint im `PITCH-XX.md` unter `## 4. Demo-Pfad-Vorschlag` und als Frontmatter-Feld `demo_path`. Der Operator kann den Pfad waehrend Review (Schritt 5 des Skills) frei editieren. Das `demo_path`-Frontmatter-Feld wird vom Skill nicht ueberschrieben, wenn der Operator es manuell angepasst hat — der Skill respektiert den vorhandenen Wert bei einem zweiten Lauf auf derselben Datei.
