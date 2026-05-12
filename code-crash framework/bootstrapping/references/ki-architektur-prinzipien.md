# KI-Architektur-Prinzipien (Schrader Kap. 4)

> Single Source of Truth fuer `/bootstrap` (proaktive Verankerung) und `/architecture-review` (reaktive Pruefung).
> Schrader Code Crash Kap. 4 §SYSTEM (Z. 1806-1808) + §"Woran scheitert KI-gestuetzte Entwicklung" (Z. 1485-1510).

## §1 Die 4 Prinzipien (Was tun?)

Die 4 Prinzipien sind **Voraussetzung, keine Option** (Schrader Z. 1806) — sie muessen vor dem Code existieren, nicht nach ihm.

| # | Prinzip | Kriterium | Pruef-Tool |
|---|---------|-----------|------------|
| P1 | **Kleine, unabhaengige Module** | Max. 500 LOC, ein Zweck pro Modul | `cloc`, `wc -l` |
| P2 | **Explizite Interfaces** | Starke Typen, API-Doc zu jeder public Funktion, ADR fuer jede Architekturentscheidung | TypeScript / JSDoc / OpenAPI |
| P3 | **Testbarkeit als Grundvoraussetzung** | Unit + Contract + Integration-Tests, separat ausfuehrbar, Coverage >=80% auf neuem Code (BOO-15) | `c8`, `pytest-cov` |
| P4 | **Von Anfang an observable** | Strukturiertes JSON-Logging, Distributed Tracing, Metriken + Alerts ab Tag 0 (BOO-14) | `pino`, `structlog`, Prometheus |

### Detail: P1 — Kleine, unabhaengige Module

- Jedes Modul hat genau **einen klar benannten Zweck** — wenn der Modulname zwei Verben enthaelt ("fetch and parse"), ist das ein Split-Signal.
- Harte Grenze: **500 LOC** ohne Tests und Kommentare. Ausnahmen nur mit explizitem ADR.
- Abhaengigkeiten laufen immer **nach aussen** (Hub-and-Spoke, nicht zirkulaer). Zirkulaere Imports sind ein Modul-Design-Fehler, kein Build-Problem.
- KI-Kontext: Module >500 LOC uebersteigen typischerweise das Kontextfenster eines KI-Assistenten — er verliert den Ueberblick, halluziniert Abhaengigkeiten.

### Detail: P2 — Explizite Interfaces

- Starke Typen an **allen** Modulgrenzen (TypeScript-Interfaces, Python-Dataclasses, OpenAPI-Schemas).
- Jede public Funktion hat eine kurze Doc-Zeile (JSDoc `@param`/`@returns` oder Python-Docstring).
- Jede Architekturentscheidung erhaelt ein ADR in `ARCHITECTURE_DESIGN.md §3` — "das war halt so" ist kein Interface.
- KI-Kontext: Ohne explizite Typen und Docs inferiert der KI-Assistent Vertraege aus dem Kontext — das fuehrt zu stillen Inkompatibilitaeten bei Aenderungen.

### Detail: P3 — Testbarkeit als Grundvoraussetzung

- Tests kommen **vor oder parallel** zum Code — niemals als nachtraeglicher Schritt.
- Test-Pyramide: Unit-Tests (viele, schnell) > Contract-Tests (Modul-Schnittstellen) > Integration-Tests (wenige, langsam).
- Jeder neue Code-Pfad hat mindestens einen Unit-Test fuer den Happy Path und einen fuer den wichtigsten Failure-Mode.
- Coverage-Gate (BOO-15): >=80% auf dem staged Diff — nicht Gesamt-Coverage.

### Detail: P4 — Von Anfang an observable

- Strukturiertes JSON-Logging mit 6 Pflicht-Feldern ab dem ersten Commit: `timestamp`, `level`, `service`, `trace_id`, `message`, `context`.
- Kein `console.log` / `print` im Production-Code.
- `/metrics`-Endpoint im Prometheus-Format pro Service (BOO-14).
- 3 Pflicht-Alerts pro Service: `_down`, `_error_rate_high`, `_p95_slow`.
- KI-Kontext: Stumme Systeme sind nicht debugbar — KI-generierter Code schlaegt haeufiger leise fehl als manueller Code, weil Randfaelle schwerer vorherzusehen sind.

---

## §2 Die 4 Anti-Patterns (Was vermeiden?)

Direkte Spiegelbilder der 4 Prinzipien — aus Schrader Kap. 4 §"Woran scheitert KI-gestuetzte Entwicklung" (Z. 1485-1510).

| Anti-Pattern | Verletzt Prinzip | Symptom | Schwellwert (BLOCK) |
|-------------|-----------------|---------|-------------------|
| **AP1: Der gewachsene Monolith** | P1 (kleine Module) | Module >500 LOC, mehrere Zwecke vermischt, zirkulaere Imports | >500 LOC oder >1 Zweck |
| **AP2: Implizites Wissen als Architekturprinzip** | P2 (explizite Interfaces) + P4 (Observability) | Entscheidungen nur im Kopf, fehlende ADRs, unstrukturierte Logs | Fehlende ADR fuer Architekturentscheidung, `console.log` im Production-Code |
| **AP3: Keine echten Grenzen zwischen Modulen** | P2 (explizite Interfaces) | Direkter DB-Zugriff aus mehreren Modulen, keine Typen, zirkulaere Imports, Shared State | Zirkulaerer Import, ungetypte Modulgrenzen |
| **AP4: Tests als nachtraegliches Nice-to-have** | P3 (Testbarkeit) | Tests nach Code geschrieben (oder gar nicht), Coverage <50%, keine Contract-Tests | Coverage <60% auf neuem Code (Warn bei 60-80%, Block bei <60%) |

### Detail: AP1 — Der gewachsene Monolith

- **Erkennung:** Modulgroesse > 500 LOC (ohne Tests), mehr als ein Verb im Modulnamen, Funktionen die nichts miteinander zu tun haben aber im selben File leben.
- **Ursache:** Schnelle Feature-Iteration ohne Modul-Disziplin. KI-Assistenten folgen oft dem vorhandenen Muster — wenn das Muster "alles in eine Datei" ist, setzt er das fort.
- **Gegenmittel:** Split-Refactoring via ADR, Modulgrenzen explizit zeichnen bevor Code geschrieben wird.

### Detail: AP2 — Implizites Wissen als Architekturprinzip

- **Erkennung:** "Frag Peter, der weiss das." Kein ADR fuer Entscheidungen. `console.log("hier bin ich")` statt strukturiertem Logging. Magic Strings ohne Erklaerung.
- **Ursache:** Zeitdruck + "war doch klar". KI-Assistenten koennen implizites Wissen nicht lesen — sie raten, was zu Drift fuehrt.
- **Gegenmittel:** ADR bei jeder nicht-offensichtlichen Entscheidung, strukturiertes Logging von Tag 0.

### Detail: AP3 — Keine echten Grenzen zwischen Modulen

- **Erkennung:** Modul A greift direkt auf die DB zu, obwohl Modul B dafuer zustaendig ist. Zirkulaere Imports. Shared global state. Keine TypeScript-Interfaces oder Python-Dataclasses an Modulgrenzen.
- **Ursache:** "Geht doch schneller so." KI-Assistenten greifen auf den naechstgelegenen Accessor zu — ohne explizite Grenze ist das oft das falsche Modul.
- **Gegenmittel:** Interface-First-Design, alle Modulgrenzen typisieren, zirkulaere Imports im ESLint als Error markieren.

### Detail: AP4 — Tests als nachtraegliches Nice-to-have

- **Erkennung:** Tests werden "spaeter" geschrieben. Coverage <50%. Nur manuelles Testen. Kein CI-Gate der roten Code blockt.
- **Ursache:** "KI generiert den Code schon richtig." Statistisch falsch — KI-Code hat Edge Cases, die ohne Tests unsichtbar bleiben.
- **Gegenmittel:** Coverage-Gate (BOO-15) im `/implement`-Skill, Test-Pyramide als Pflicht-Check im Architecture-Review (BOO-7).

---

## Verwendung

| Skill | Rolle | Wie |
|-------|-------|-----|
| `/bootstrap` | Proaktiv | Schreibt Prinzipien + Anti-Patterns in `ARCHITECTURE_DESIGN.md §2` bei Projekt-Setup |
| `/architecture-review` | Reaktiv | Prueft alle 8 Checks (4 Pro + 4 Anti) gegen das laufende Projekt |

Schrader: "Wer die Prinzipien nur im Review prueft, hat sie zu spaet verankert." (Code Crash Kap. 4 Z. 1806)
