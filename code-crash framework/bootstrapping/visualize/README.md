<a name="deutsch"></a>

# Visualize — Automatische Architektur-Diagramme in Miro

> Ein Befehl (`/visualize <miro-board-url>`) liest alle deine Architekturdokumente und erstellt **6 Diagramme** direkt in Miro — automatisch platziert, farbcodiert, mit Deep-Links.

**Version:** 2.1.0 · **Befehl:** `/visualize`

---

## Was der Skill tut

Jedes Team hat eine Architektur-Doku, die niemand liest. Und ein Miro-Board, das niemand aktualisiert. Die Luecke ist ein Uebersetzungsproblem: `.md` zu Visuellem.

Der Skill schliesst die Luecke. Er liest Markdown-Architekturdateien, baut einen Layer-Graph im Speicher auf und rendert sechs Diagramme direkt in ein Miro-Board via Miro MCP Connector. Kein manuelles Zeichnen, keine veralteten Boxen.

**Die 6 Diagramme:**

| Diagramm | Was es zeigt |
|----------|--------------|
| **Übersicht** | Alle Architektur-Layer auf einen Blick |
| **Datenfluss** | Wie Daten durch dein System fließen |
| **Deployment** | Server, Prozesse, Daemons |
| **Detail 1: Eingang** | Eingangs-Layer-Komponenten |
| **Detail 2: Core** | Core-Processing-Komponenten |
| **Detail 3: Operations** | Output/Observability/Ops-Komponenten |

---

## Voraussetzungen

### 1. Claude Code installiert

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Miro MCP Server konfigurieren

Der Skill nutzt den **Miro MCP Connector** via Claude.ai:

1. **Claude Pro oder Team Account** auf [claude.ai](https://claude.ai)
2. In Claude.ai → Settings → Integrations → **Miro verbinden**
3. Miro MCP Connector im Claude Code Projekt aktivieren:

```bash
claude mcp add --scope user claude_ai_Miro <connection-details>
```

> **Hinweis:** Der Miro MCP Connector ist über Claude.ai OAuth verfügbar. Weitere Infos: [docs.anthropic.com/mcp](https://docs.anthropic.com/mcp)

### 3. Miro Board erstellen

1. Auf [miro.com](https://miro.com) ein neues leeres Board erstellen
2. Board-URL notieren (Format: `https://miro.com/app/board/uXXXXXXX=`)

### 4. Architekturdokumentation

Der Skill liest Markdown-Dateien. **Mindestanforderung:** Eine Datei die Architektur-Layer beschreibt.

**Empfohlene Struktur** (Dateinamen anpassbar):

```
dein-projekt/
├── LAYER_ARCHITECTURE.md      # Pflicht: Layer-Struktur
├── COMPONENT_INVENTORY.md     # Empfohlen: alle Komponenten
├── API_INVENTORY.md           # Empfohlen: externe Verbindungen
├── DATA_FLOW.md               # Empfohlen: Datenpipelines
├── DEPLOYMENT_ARCHITECTURE.md # Empfohlen: Server/Prozesse
└── CROSS_CUTTING.md           # Optional: Logging, Monitoring
```

**Minimalbeispiel `LAYER_ARCHITECTURE.md`:**

```markdown
# Layer Architecture

## L1: Data Ingestion
- Dateien: src/collectors/*, src/scrapers/*
- Input: externe APIs, Webhooks
- Output: data/raw/*.json

## L2: Processing
- Dateien: src/processors/*
- Input: data/raw/*.json
- Output: data/processed/*.json

## L3: Output
- Dateien: src/api/*, dashboard/*
- Input: data/processed/*.json
- Output: HTTP API, Dashboard
```

---

## Installation

```bash
mkdir -p ~/.claude/skills/visualize
cp SKILL.md ~/.claude/skills/visualize/SKILL.md
```

Skill in Claude Code registrieren — in `CLAUDE.md` oder `~/.claude/CLAUDE.md`:

```markdown
## Skills

- `/visualize` — Architektur-Diagramme in Miro generieren
```

Oder via Claude Code Settings:

```bash
claude config set skills.visualize.path ~/.claude/skills/visualize
```

---

## Verwendung

### Grundaufruf

```
/visualize https://miro.com/app/board/uXXXXXXX=
```

### Mit Diagramm-Typ

```
# Nur Übersichtsdiagramme (schneller)
/visualize https://miro.com/app/board/uXXXXXXX= overview

# Nur Detaildiagramme
/visualize https://miro.com/app/board/uXXXXXXX= detail

# Alle 6 Diagramme (default)
/visualize https://miro.com/app/board/uXXXXXXX= all
```

---

## Anpassungen

### Eigene Dokumentationspfade

Der Skill sucht standardmäßig im Projektroot. Für andere Pfade `SKILL.md` anpassen:

```markdown
### Schritt 2: Architekturdokumentation lesen
Dateien lesen aus `docs/architecture/`:
- `docs/architecture/layers.md`
- `docs/architecture/components.md`
- etc.
```

### Eigene Farben

In `SKILL.md` unter `## Farb-Kodierung` die Hex-Werte anpassen:

```markdown
| Mein Layer | Farbe | Hex |
|------------|-------|-----|
| Frontend   | Hellblau | #ccf4ff |
| Backend    | Hellgrün | #adf0c7 |
| Datenbank  | Gelb     | #fff6b6 |
```

### Andere Layer-Anzahl

Funktioniert mit beliebig vielen Layern. Beschreibe sie in `LAYER_ARCHITECTURE.md` — Claude passt die Diagramme automatisch an.

---

## Ergebnis-Beispiel

Nach `/visualize` erhältst du eine Tabelle wie:

| Diagramm | Miro Deep-Link |
|----------|----------------|
| Layer Architecture Übersicht | [Öffnen in Miro](https://miro.com/...) |
| Data Flow | [Öffnen in Miro](https://miro.com/...) |
| Deployment | [Öffnen in Miro](https://miro.com/...) |
| L1 Detail: Data Ingestion | [Öffnen in Miro](https://miro.com/...) |
| L2-L4 Detail: Core Processing | [Öffnen in Miro](https://miro.com/...) |
| L5-L7 Detail: Operations | [Öffnen in Miro](https://miro.com/...) |

---

## Trigger-Phrasen

- `/visualize`
- "generiere Architektur-Diagramme"
- "zeichne die Architektur"
- "Miro-Diagramm"
- "visualisiere das System"

---

## Schnittstellen zu anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| `architecture-review` | Layer-Mapping, Komponenten-Inventur | Operator / Stakeholder | Share-bereites Miro-Board |
| `sprint-review` | System-Snapshot mit Doku | `design-md-generator` | Visuelle Referenz fuer Style Guide |
| `bootstrap` | Initiale Architektur-Doku + `.md`-Struktur | | |

---

## Artefakte / Outputs

- **Miro-Board** mit 6 auto-platzierten, farbcodierten Diagrammen
- **Deep-Links** pro Diagramm zum Teilen
- **Farb-Konvention** diagramm-uebergreifend konsistent (Layer → Farbe)

---

## Troubleshooting

| Problem | Loesung |
|---------|---------|
| "Miro MCP not available" | Miro MCP Connector in Claude.ai Settings neu verbinden |
| "Board not found" | URL-Format pruefen: `https://miro.com/app/board/uXXXXXXX=` |
| "No architecture docs found" | Mindestens `LAYER_ARCHITECTURE.md` im Projektroot anlegen |
| Diagramme überlappen | Board leeren und `/visualize` erneut aufrufen |

---

## Dateistruktur

```
visualize/
├── README.md     ← Diese Datei
└── SKILL.md      ← Skill-Definition
```

---

*Skill Version 2.1.0 | Claude Code Skills*
