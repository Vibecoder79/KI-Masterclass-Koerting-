# webflow-design-build

Ein Claude-Code-Skill, der Webflow-Sektionen und -Seiten ueber den Webflow-MCP **diszipliniert und
slop-frei** baut. Er verhindert den generischen KI-Look nicht durch "guten Geschmack", sondern
durch drei Zwaenge: ein hartes Design-System-Gate, einen Abnahme-Gate ueber klickbaren
Artifact-Prototyp vor dem Live-Bau, und ein Verify-vor-Publish. Fuer wiederkehrende Website-Arbeit
an eigenen Marken und Kundenprojekten.

## Problem, das er loest

KI baut Websites standardmaessig im generischen Default-Look (Creme + Serif + Terracotta, Inter,
alles zentriert, `rounded-lg`). Dieser Skill zwingt stattdessen: erst ein fixiertes Design-System
pinnen, dann bauen, dann pruefen. Ausserdem buendelt er das teuer erlernte Webflow-MCP-Handwerk
(Collection-List-Bindung, CMS-Locales, HtmlEmbed-Code, selbst-enthaltene Visualisierungen), damit
es nicht bei jedem Projekt neu erarbeitet werden muss.

## Installation & Nutzung

Der Skill liegt unter `~/.claude/skills/webflow-design-build/` und wird automatisch erkannt.
Aufruf ueber Trigger-Saetze oder `/webflow-design-build`:

- "baue die Sektion in Webflow" / "ueberarbeite die Partner-Kachel auf owlist.ch"
- "Webflow-Redesign" / "an die Collection binden" / "verhindere den KI-Look"

Voraussetzung: aktiver Webflow-MCP-Server. Bei CMS-Arbeit Schreibrechte auf die Collections.

## Ablauf (Phasen)

- **Phase 0 — Design-System-Gate (hart):** kein Bau ohne fixierte Tokens/Formensprache. Fehlt das
  System, verweist der Skill auf `design-md-generator` (extrahieren) bzw. `ci-extraktor`
  (Kunden-CI) oder erzwingt eine explizite Festlegung.
- **Phase 1 — Inspizieren:** Struktur, Styles (wo lebt das CSS?), Freeform-Scripts, CMS-Felder
  lesen — nie blind bauen.
- **Phase 2 — Prototyp + Abnahme:** klickbarer Artifact-Prototyp, Freigabe abwarten.
- **Phase 3 — Live bauen:** nach dem Webflow-MCP-Playbook (CMS → Struktur → Bindung → Styles),
  abhaengige Scripts erhalten.
- **Phase 4 — Verify + Publish:** strukturell + Render/E2E pruefen, dann mit Freigabe publishen.
- **Phase 5 — Anti-Slop-Pass:** Pflicht-Checkliste gegen die visuellen Slop-Cluster.

## Dateistruktur

```
webflow-design-build/
├── SKILL.md                          # Anleitung (DE)
├── SKILL.en.md                       # Anleitung (EN)
├── README.md / README.en.md          # diese Datei (DE/EN)
├── references/
│   ├── webflow-mcp-playbook.md       # Bau-/CMS-/Embed-Muster + Stolpersteine
│   ├── anti-slop-gate.md             # visuelle Slop-Cluster + Checkliste
│   └── prototyp-gate.md              # Abnahme-Prototyp bauen/kommunizieren
├── webflow-design-build-overview.excalidraw / .png        # Diagramm (DE)
└── webflow-design-build-overview.en.excalidraw / .en.png  # Diagramm (EN)
```

## Zusammenspiel mit anderen Skills

Orchestriert bestehende Skills statt sie nachzubauen: `design-md-generator`/`ci-extraktor`
(System), `anti-slop` (Text), `design-motion-principles` (Motion), `nanobanana2` (Bilder),
`journal` (Doku). Marken-/CI-Kontext liegt im SecondBrain (`00 Kontext/Branding.md`,
`00 Kontext/Anti-Slop.md`), nicht im Skill.

## Hintergrund / Motivation

Aus realer Bauarbeit an owlist.ch/team destilliert (Core-Team-Kacheln "Richtung C", Standortkarte,
Partner-Slider). Ziel: mehrere Websites mit gleichbleibender Qualitaet bauen, ohne bei jedem
Projekt in den KI-Default zurueckzufallen oder die Webflow-Stolpersteine neu zu lernen.

## Quellen

- Anthropic `artifact-design` (Anti-Slop-Cluster, Design-Fundamentals).
- SecondBrain `00 Kontext/Anti-Slop.md`, `00 Kontext/Branding.md`, `00 Kontext/Schreibstil.md`.
- Webflow-MCP `webflow_guide_tool` (Tool-Playbook).
