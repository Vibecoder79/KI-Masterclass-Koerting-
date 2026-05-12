---
title: Anti-Pattern-Katalog (Schrader Kap. 7)
version: 1.0.0
created: 2026-05-11
language: de
source: Schrader "Code Crash" (2026), Kapitel 7 "Risiken und Anti-Patterns"
---

# Anti-Pattern-Katalog — Sprint- und Programm-Ebene

Schraders 11 Anti-Patterns aus Kap. 7 als aktives Diagnose-Werkzeug. Wird vom `/sprint-review`-Skill in der Anti-Pattern-Selbstdiagnose (Schritt 7) konsumiert.

**Abgrenzung zu BOO-24 (Kap. 4 architektonische APs):**
- Kap. 4 APs (Monolith, implizites Wissen, keine Modul-Grenzen, Tests nachträglich) → Code-/Modul-Ebene → Hook in `/bootstrap` + `/architecture-review`
- **Kap. 7 APs (diese Datei)** → Sprint-/Programm-/Team-Ebene → Hook in `/sprint-review` + HANDBUCH.md

---

## Kategorie I: Prozess-Pathologien

### AP1: Tool-Chaos

**Symptom im Sprint-Alltag:**
- Mehr als 2 verschiedene KI-Coding-Tools im Einsatz — ohne zentrale Evaluation
- Keine standardisierten Prompts oder Workflows
- Jedes Team hat eigene Methoden; Onboarding wird komplexer statt einfacher

**Diagnose-Frage für /sprint-review:**
> "Mehr als 2 verschiedene KI-Coding-Tools im Einsatz — ohne zentrale Evaluation?"

**Gegenmittel:**
1. Ein offizielles Toolset definieren (1-2 Haupttools) — Einheitlichkeit schlägt Tool-Vielfalt
2. Experimente mit neuen Tools in Sandbox-Umgebungen kanalisieren
3. Erkenntnisse zentral teilen (Wiki, regelmäßige Meetings)
4. Neue Tools zentral evaluieren bevor sie ausgerollt werden — kein Individual-Rollout

**Skill-Abdeckung:** offen (kein BOO-Issue direkt)

---

### AP2: Review-Überlastung

**Symptom im Sprint-Alltag:**
- Code-Reviews dauern regelmäßig >24h
- Erfahrene Entwickler verbringen >50% ihrer Zeit mit Reviews
- Teams klagen über "Warten auf Freigabe" als Hauptblocker

**Diagnose-Frage für /sprint-review:**
> "Haben PR-Reviews im letzten Sprint regelmäßig >24h gedauert?"

**Gegenmittel:**
Reviews nach Risikostufe staffeln:

| Code-Typ | Review-Stufe |
|----------|-------------|
| Kritisch (Auth, Payment, PII) | Vollständige Prüfung + Security-Scan |
| Standard (Business-Logik, APIs) | Normales Code-Review |
| Geringes Risiko (Tests, Docs) | Automatisierter Check + Stichprobe |
| Generierter Standard-Code | Nur automatisierter Check |

Automatisierte Reviews ausbauen (Linting, SAST, Coverage). Junior-Entwickler trainieren, KI-Code zu prüfen.

**Skill-Abdeckung:** ✅ teilweise — BOO-18 (Mandatory Human Review für kritische Pfade — Auth/Payment/PII)

---

### AP3: Feature-Inflation

**Symptom im Sprint-Alltag:**
- "Wir können es schnell bauen" als häufigstes Argument für neue Features
- Niemand misst ob Features tatsächlich genutzt werden
- Nutzer klagen über "zu viel" statt "zu wenig"

**Diagnose-Frage für /sprint-review:**
> "Wurden Features ohne Intent-Anbindung gebaut — weil sie 'schnell gehen'?"

**Gegenmittel:**
1. **Outcome-Check:** Jedes Feature muss auf ein klares Ziel einzahlen. Wenn nicht erkennbar, nicht bauen.
2. **Opportunitätskosten sichtbar machen:** Jede Stunde in Feature A fehlt bei Feature B.
3. **Kill-Kriterien:** Wann wird ein Feature wieder entfernt? (z.B. <5% Nutzung nach 30 Tagen)
4. **Nutzervalidierung vor Entwicklung** — spart am meisten Zeit.

"Weil wir es können" ist kein Grund. "Weil Kunden es brauchen" schon.

**Skill-Abdeckung:** ✅ teilweise — BOO-1 (/intent-Skill), BOO-10 (Intent-Propagation durch Pipeline)

---

## Kategorie II: Qualitäts-Pathologien

### AP4: Sicherheit als Endstation

**Symptom im Sprint-Alltag:**
- Sicherheitsprüfung erfolgt nur am Ende der Pipeline, kurz vor Produktion
- Regelmäßige Konflikte mit dem Sicherheitsteam wegen zu spätem Feedback
- Hohe Rate von "akzeptierten Risiken" wegen Deadline-Druck

**Diagnose-Frage für /sprint-review:**
> "Werden Sicherheitschecks als letzter Schritt vor Deployment gemacht statt in der Pipeline?"

**Gegenmittel:**
Sicherheit nach vorne verlagern (Shift-Left):
1. Sicherheitschecks in der IDE — schon beim Schreiben
2. Automatische Scans bei jedem Commit (Pre-Commit + CI)
3. Dependency-Checks vor dem Mergen
4. Security-Training für alle Entwickler (nicht nur Spezialisten)

KI-generierter Code muss besonders früh geprüft werden. KI strebt nach "funktioniert", nicht nach "ist sicher".

**Skill-Abdeckung:** ✅ BOO-3 (Semgrep Auto-Setup), BOO-4 (Semgrep Gate in /implement), BOO-5 (SonarQube Cloud), BOO-18 (Human Review für kritische Pfade)

---

### AP5: Technische Schulden im Turbo-Modus

**Symptom im Sprint-Alltag:**
- Steigende Duplikationsraten im Code (SonarQube zeigt es)
- Widersprüchliche Architektur-Patterns zwischen Modulen ("Warum ist das anders aufgebaut?")
- Coding-Tools können das Projekt nicht mehr vollständig im Kontextfenster erfassen
- DORA Report 2024: 25% mehr KI-Nutzung → 7,2% weniger Lieferstabilität

**Diagnose-Frage für /sprint-review:**
> "Steigen Duplikationsraten oder widersprüchliche Patterns im Code?"

**Gegenmittel:**
1. **Architektur-Reviews** regelmäßig führen — nicht nur Code reviewen
2. **Duplikationsmetriken gleichrangig** behandeln wie Coverage
3. **15%-Regel:** 15% des Entwicklungsbudgets für Schuldenabbau freihalten
4. **KI für Debt-Analyse** nutzen — Ironie: KI findet die Schulden, die KI verursacht hat
5. **Schuldenobergrenzen** als harte Grenzen: "Kein neues Feature wenn Duplikation X% übersteigt"
6. **Strikt modularisieren** — jedes Modul vollständig im Kontextfenster abbildbar

**Skill-Abdeckung:** ✅ teilweise — BOO-7 (/architecture-review KI-Tauglichkeit-Checkliste), BOO-15 (Coverage-Gate ≥80%)

---

### AP6: Erfahrungsschulden

**Symptom im Sprint-Alltag:**
- Der "Wie macht man das nochmal?"-Effekt bei Stammnutzern
- Steigendes Support-Volumen für Fragen, die ein intuitives Produkt gar nicht aufwirft
- Funktionen existieren, werden aber nicht genutzt weil niemand sie findet
- Widersprüchliche Interaktionsmuster zwischen Features

**Diagnose-Frage für /sprint-review:**
> "Wurden Features ohne UX/Design-Review geliefert — 'Design kommt später'?"

**Gegenmittel:**
1. **Erfahrungsschulden sichtbar machen:** Widersprüche in der Bedienung zählen
2. **Design-Check als Gate** am lauffähigen Kandidaten (nicht am Mockup)
3. **15%-Budget für UX-Vereinheitlichung** — analog zur technischen Schulden-Regel
4. **Feedback-Schleifen mit Nutzern:** Messen WIE Funktionen genutzt werden

Ein technisch sauberes Produkt mit schlechter Experience verliert gegen eines, das sich gut anfühlt. Experience ist kein Add-on — sie ist das Produkt.

**Skill-Abdeckung:** → HANDBUCH.md (organisatorisch, nicht skill-detektierbar durch Gates)

---

### AP10: Slopware statt Software

**Symptom im Sprint-Alltag:**
- Features erscheinen schneller, aber niemand misst ihren Wert
- Offene Bugs wachsen trotz mehr Fixes
- "47 Features diese Woche!" — aber welche nutzt jemand?
- Dokumentation hinkt systematisch hinterher

**Diagnose-Frage für /sprint-review:**
> "Mehr Features als in vorherigen Sprints — aber sinkende Outcome-Messung?"

**Gegenmittel:**
1. **Outcome vor Output:** Nicht was geliefert wird zählen — was es bewirkt messen
2. **Qualitätsgates automatisieren:** Kein Code ohne Tests, kein Deployment ohne Security-Scan. Keine Ausnahmen.
3. **Bewusst klein:** Weniger Features, aber bessere. Erfordert Mut wenn der Wettbewerb überschwemmt.
4. **Slopware als Chance:** Wer Qualität hält während andere fluten, schwimmt oben.

**Skill-Abdeckung:** ✅ teilweise — BOO-12 (Dependency + Slopsquatting-Schutz)

---

## Kategorie III: Kultur-Pathologien

> Die folgenden APs (AP7, AP8, AP9, AP11) sind nicht durch automatische Gates detektierbar. Sie sind Reflexionspunkte für Sprint-Retros und Führungskräfte. Details und Handlungsempfehlungen im HANDBUCH.md §Anti-Patterns auf Programm-Ebene.

### AP7: Verantwortungsdiffusion

**Symptom im Sprint-Alltag:**
- Bei Problemen wird nach Schuldigen gesucht statt nach Ursachen
- "Die KI hat es so gemacht" als Entschuldigung
- Retrospektiven führen zu keinen klaren Verantwortlichkeiten

**Diagnose-Frage für /sprint-review:**
> "Hat jemand 'Die KI hat es so gemacht' gesagt wenn etwas schiefgelaufen ist?"

**Skill-Abdeckung:** → HANDBUCH.md §Anti-Patterns auf Programm-Ebene

---

### AP8: Geschwindigkeit ohne System

**Symptom im Sprint-Alltag:**
- Keine Zeit für Tests ("wir müssen liefern")
- Rollbacks häufiger als stabile Deployments
- Team feiert Deployment-Frequenz, nicht Deployment-Qualität

**Diagnose-Frage für /sprint-review:**
> "Mehr als 1 Rollback im letzten Sprint wegen fehlender Tests oder fehlender Observability?"

**Gegenmittel (Kurzform):** System zuerst — Tests, Security-Checks, Rollback <5min, Alerts. Erst dann Geschwindigkeit.

**Skill-Abdeckung:** ✅ teilweise — BOO-14 (Observability), BOO-15 (Coverage), BOO-16 (Performance-Baseline)

---

### AP9: Individual-First als Isolation

**Symptom im Sprint-Alltag:**
- "Das habe ich schon gebaut" — "Ich auch, aber besser!"
- Keine gemeinsamen Architekturentscheidungen
- Dokumentation ist persönlich, nicht teamweit

**Diagnose-Frage für /sprint-review:**
> "Gibt es Doppelarbeit im Sprint weil Architekturentscheidungen nicht geteilt wurden?"

**Skill-Abdeckung:** → HANDBUCH.md §Anti-Patterns auf Programm-Ebene

---

### AP11: Die politischen Saboteure

**Symptom im Sprint-Alltag (3 Typen):**
- *Neid-Saboteur:* Code-Reviews die zu lange dauern, Standards plötzlich nicht verhandelbar, Skepsis verpackt als konstruktive Kritik
- *Power Player:* Strategische Bedenken in Steuerungskomitees, Pilotprojekte werden ausgehungert
- *Angst-Blocker:* "Wir brauchen dreiwöchige Analyse" für jede Vereinfachung

**Diagnose-Frage für /sprint-review:**
> "Gibt es ein Muster von systematischen Blockaden bei denselben Personen?"

**Gegenmittel:** Das Muster erkennen, nicht einzelne Aktionen isoliert bewerten. Budget und Einfluss verfolgen. Konstruktiv ansprechen bevor es destruktiv wird.

**Skill-Abdeckung:** → HANDBUCH.md §Anti-Patterns auf Programm-Ebene

---

## Referenz

Schrader "Code Crash" (2026), Kapitel 7 "Risiken und Anti-Patterns":
- AP1 Tool-Chaos — Z. 3646
- AP2 Review-Überlastung — Z. 3677
- AP3 Feature-Inflation — Z. 3716
- AP4 Sicherheit als Endstation — Z. 3752
- AP5 Technische Schulden im Turbo-Modus — Z. 3788
- AP6 Erfahrungsschulden — Z. 3853
- AP7 Verantwortungsdiffusion — Z. 3908
- AP8 Geschwindigkeit ohne System — Z. 3942
- AP9 Individual-First als Isolation — Z. 3975
- AP10 Slopware statt Software — Z. 4011
- AP11 Die politischen Saboteure — Z. 4082
