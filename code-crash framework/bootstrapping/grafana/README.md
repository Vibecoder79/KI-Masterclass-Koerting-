<a name="deutsch"></a>

# Grafana — Dashboards & PromQL direkt aus Claude Code

> Baue Grafana-Cloud-Dashboards, schreibe PromQL-Queries und verdrahte Alert Rules — direkt aus Claude Code via offiziellem Grafana MCP Server. Kein JSON-Export/Import-Zirkus.

**Version:** 1.0.0 · **Befehl:** `/grafana`

---

## Was der Skill tut

Klassischer Grafana-Workflow: Panel in UI bearbeiten → JSON exportieren → ins Repo pasten → Review → woanders importieren. Wiederholen. Fehleranfaellig, nicht versioniert, nicht reproduzierbar.

Der Skill macht Grafana zum vollwertigen Teammate: Claude liest deine Dashboards, setzt PromQL gegen Prometheus ab, baut neue Panels und committet. Der MCP-Server uebernimmt Auth und API.

**Was er kann:**

| Aufgabe | Wie |
|---------|-----|
| Neues Dashboard erstellen | `update_dashboard(dashboard=..., overwrite=false)` |
| Panel zu bestehendem Dashboard | `get_dashboard(uid=...)` → Panel anhaengen → `update_dashboard(..., overwrite=true)` |
| PromQL-Query debuggen | `query_prometheus(expr="...", datasourceUid="...")` |
| Dashboards suchen | `search_dashboards(query="...")` |
| Alert Rules | Direkt via MCP |

---

## Konventionen (projektweit)

| Konvention | Wert |
|------------|------|
| **Instanz** | Grafana Cloud (Primaer) |
| **Folder** | Ein Folder pro Projekt |
| **Panel-Naming** | `<Gruppe>: <Was>` — z.B. `Agents: Signal Age`, `Trading: P&L Today` |
| **Refresh** | 30s fuer Live-Dashboards |
| **Zeitraum-Default** | Letzte 1h |
| **Farben** | Gruen = OK, Gelb = Warning, Rot = Kritisch |

---

## Metrik existiert nicht — was nun?

Wenn `query_prometheus(expr="my_metric")` nichts zurueckgibt:

1. Pruefen ob die Metrik in `lib/metrics.js` definiert ist
2. **Fehlt sie:** Panel NICHT bauen. Stattdessen:
   - Operator informieren: "Metrik `my_metric` fehlt in `lib/metrics.js`"
   - Beschreiben was die Metrik messen soll
   - Vorschlag: `/ideation` fuer neue Story oder direkt implementieren
3. Nach Implementierung: Prometheus scrapt automatisch → in Grafana Cloud verfuegbar

Regel existiert weil halb-gebaute Dashboards mit Fake-Metriken schlimmer sind als gar kein Dashboard.

---

## Datenfluss-Referenz

```
App Agents → lib/metrics.js → GET /metrics Endpoint
    → Prometheus (Scrape alle 15s, Docker-intern)
        ├── Grafana lokal — Dev/Debug
        └── remote_write → Grafana Cloud — PROD/Mobile
                                ↑
                       /grafana Skill + MCP greift hier ein
```

---

## Trigger-Phrasen

- `/grafana`
- "Grafana"
- "Dashboard"
- "Panel"
- "Metrik abfragen"
- "Alert Rule"
- "bau mir ein Grafana-Dashboard"

---

## Schnittstellen zu anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| `implement` | Neue Metriken in `lib/metrics.js` | `cloud-system-engineer` | Dashboards mit Infra-Metriken |
| `cloud-system-engineer` | Infra-State: Container, Ports, Ressourcen | `sprint-review` | Observability-Snapshot |
| `architecture-review` | Observability-Befunde | Operator | Live-Dashboards fuer Day-to-Day-Monitoring |

---

## Artefakte / Outputs

- **Grafana-Cloud-Dashboards** — live via MCP, committed in die Org-Grafana
- **Panels** — nach Konvention gruppiert (Agents, Trading, Infra, etc.)
- **Alert Rules** — PromQL-basiert, mit Thresholds
- **PromQL-Debug-Output** — strukturierte JSON-Antwort fuer Troubleshooting

---

## Voraussetzungen

- Grafana Cloud Account
- Grafana MCP Server konfiguriert: `grafana/mcp-grafana` (Docker)
- Prometheus als Datasource
- API-Token in `.env` (nie im Code)

---

## Installation

```bash
cp -r grafana ~/.claude/skills/grafana
```

MCP Server aufsetzen:

```bash
docker run -d --name mcp-grafana \
  -e GRAFANA_URL=https://<deine-instanz>.grafana.net \
  -e GRAFANA_API_KEY=$GRAFANA_API_KEY \
  grafana/mcp-grafana
```

---

## Dateistruktur

```
grafana/
└── SKILL.md     ← Skill-Definition
```
