<a name="english"></a>

# Grafana — Dashboards & PromQL from Claude Code

> Build Grafana Cloud dashboards, write PromQL queries and wire alert rules — directly from your Claude Code session via the official Grafana MCP server. No JSON export/import gymnastics.

**Version:** 1.0.0 · **Command:** `/grafana`

---

## What It Does

Classic Grafana workflow: edit panel in the UI → export JSON → paste into the repo → review → import elsewhere. Repeat. Error-prone, not versioned, not repeatable.

This skill makes Grafana a first-class teammate: Claude reads your dashboards, runs PromQL queries against Prometheus, builds new panels and commits the result. The MCP server handles the auth and API calls.

**What it handles:**

| Task | How |
|------|-----|
| Create a new dashboard | `update_dashboard(dashboard=..., overwrite=false)` |
| Add a panel to an existing dashboard | `get_dashboard(uid=...)` → append panel → `update_dashboard(..., overwrite=true)` |
| Debug a PromQL query | `query_prometheus(expr="...", datasourceUid="...")` |
| Search dashboards | `search_dashboards(query="...")` |
| Alert rules | Directly via MCP |

---

## Conventions (Project-Wide)

| Convention | Value |
|------------|-------|
| **Instance** | Grafana Cloud (primary) |
| **Folder** | One folder per project |
| **Panel naming** | `<Group>: <What>` — e.g. `Agents: Signal Age`, `Trading: P&L Today` |
| **Refresh** | 30s for live dashboards |
| **Time range default** | Last 1 hour |
| **Colors** | Green = OK, Yellow = Warning, Red = Critical |

---

## Metric Doesn't Exist Yet — What Now?

If `query_prometheus(expr="my_metric")` returns nothing:

1. Check if the metric is defined in `lib/metrics.js`
2. **If missing:** Do NOT build the panel. Instead:
   - Tell the operator: "Metric `my_metric` is missing in `lib/metrics.js`"
   - Describe what the metric should measure
   - Suggest `/ideation` to create a story or implement it directly
3. After implementation: Prometheus scrapes it automatically → available in Grafana Cloud

This rule exists because half-built dashboards with fake metrics create worse problems than no dashboard at all.

---

## Data Flow Reference

```
App Agents → lib/metrics.js → GET /metrics endpoint
    → Prometheus (scrape every 15s, Docker-internal)
        ├── Grafana local     — dev/debug
        └── remote_write → Grafana Cloud — PROD/mobile
                                ↑
                      /grafana skill + MCP intercepts here
```

---

## Trigger Phrases

- `/grafana`
- "Grafana"
- "dashboard"
- "panel"
- "query that metric"
- "alert rule"
- "build me a grafana dashboard"

---

## Interfaces with Other Skills

| Upstream | What's provided | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| `implement` | New metrics added to `lib/metrics.js` | `cloud-system-engineer` | Dashboards referencing infra metrics |
| `cloud-system-engineer` | Infra state: containers, ports, resources | `sprint-review` | Observability coverage snapshot |
| `architecture-review` | Observability dimension findings | Operator | Live dashboards for day-to-day monitoring |

---

## Artifacts / Outputs

- **Grafana Cloud dashboards** — live, via MCP, committed to the org's Grafana instance
- **Panels** — grouped by convention (Agents, Trading, Infra, etc.)
- **Alert rules** — PromQL-based, with thresholds
- **PromQL debug output** — structured JSON response for troubleshooting

---

## Requirements

- Grafana Cloud account
- Grafana MCP server configured: `grafana/mcp-grafana` (Docker)
- Prometheus as datasource
- API token stored in `.env` (never in code)

---

## Installation

```bash
cp -r grafana ~/.claude/skills/grafana
```

Then set up the Grafana MCP server:

```bash
docker run -d --name mcp-grafana \
  -e GRAFANA_URL=https://<your-instance>.grafana.net \
  -e GRAFANA_API_KEY=$GRAFANA_API_KEY \
  grafana/mcp-grafana
```

---

## File Structure

```
grafana/
└── SKILL.md     ← Skill definition (read by Claude Code)
```

---

---

