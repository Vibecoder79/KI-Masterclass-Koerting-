---
name: visualize
description: |
  Auto-generate architecture diagrams in Miro from documentation files.
  Reads architecture docs from the project and creates a complete set of flowcharts/diagrams
  in Miro — overview + detail diagrams per layer.
  Use when the operator says "visualize", "create diagram", "visualize architecture",
  "Miro diagram" or "/visualize".
version: 2.2.0
language: en
author: Tobias Schmidt
metadata:
  hermes:
    category: doku
    tags: [diagrams, system-architecture]
    requires_toolsets: [terminal, mermaid]
    related_skills: [architecture-review]
---

# Visualize — Architecture Diagrams in Miro

Create a complete layer-diagram set in Miro from architecture documentation.

## Prerequisites

1. **Miro MCP server** must be configured in Claude Code (see README.en.md)
2. **Miro board** must exist (board URL as argument)
3. **Architecture documentation** must be present in the project (see step 2)

## Invocation

```
/visualize <board-url> [diagram-type]
```

**Arguments:**
- `board-url` (required): Miro board URL
- `diagram-type` (optional): `overview`, `detail`, `all` (default)
  - `overview` = 3 overview diagrams (layer, dataflow, deployment)
  - `detail` = 3 detail diagrams (layer 1, layer 2–4, layer 5–7)
  - `all` = all 6 diagrams

## Workflow

### Step 0: Load environment

1. Read `.claude/environment.json` (if present — otherwise fall back to defaults and log a warning).
2. Extract paths from `paths.*` as needed (e.g. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Before any tool invocation, check `tools_available.<tool>`. If `false` or missing, the skill skips the call and notes it in the output.
4. Missing-file fallback: assume the schema defaults (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) and add a note to the output: "Note: `.claude/environment.json` is missing — defaults active. Recommendation: re-run `/bootstrap` or create the file manually."

### Step 1: Parse parameters

- Extract board URL from arguments
- Determine diagram type (default: `all`)

### Step 2: Read architecture documentation

> **ADJUST:** replace the paths below with your actual documentation paths.
> At minimum `LAYER_ARCHITECTURE.md` is required. All others are optional but recommended.

Read the following files (adjust paths per project):

| Document | Content | Required |
|----------|---------|----------|
| `LAYER_ARCHITECTURE.md` | Layered architecture: layer names, files per layer, input/output | **Yes** |
| `COMPONENT_INVENTORY.md` | All modules/classes/services with layer assignment | Recommended |
| `API_INVENTORY.md` | External API connections with dataflow direction (IN/OUT/BI) | Recommended |
| `DATA_FLOW.md` | Pipelines, data formats, error paths | Recommended |
| `DEPLOYMENT_ARCHITECTURE.md` | Processes, servers, daemons, cron jobs | Recommended |
| `CROSS_CUTTING.md` | Logging, error handling, monitoring | Optional |

If these files don't exist or have different names:
- Search existing architecture docs with similar content and use them
- Fill gaps from CLAUDE.md or other project files
- Inform the operator which docs were found and what's missing

### Step 3: Load the DSL format

Call `diagram_get_dsl` with `diagram_type: "flowchart"` — once per session is enough.

### Step 4: Generate diagrams

#### Row 1: Overview (y=0)

**Diagram 1 (x=0): Layer Architecture overview**
- All architecture layers as boxes (BT direction) with color coding
- External systems (APIs, databases, operator) as external nodes
- Connections between layers
- Cluster by functional groups

**Diagram 2 (x=2500): Data Flow**
- LR direction
- Main data pipelines as clusters
- Decision nodes for branches
- All important data formats and stores

**Diagram 3 (x=5000): Deployment**
- TB direction
- Server/container structure
- All running processes and daemons
- External services

#### Row 2: Detail per layer (y=2500 through y=7500)

**Diagram 4 (x=0, y=2500): Ingress-layer detail**
From API_INVENTORY.md + COMPONENT_INVENTORY.md:
- LR direction
- All external data sources (APIs, webhooks, etc.)
- All ingestion components with type and frequency
- Output data formats

**Diagram 5 (x=0, y=5000): Core-layer detail**
From DATA_FLOW.md:
- LR direction
- Aggregation and processing logic
- Decision gates with conditions
- Execution layer with safety checks

**Diagram 6 (x=0, y=7500): Operations-layer detail**
From CROSS_CUTTING.md + DEPLOYMENT_ARCHITECTURE.md:
- LR direction
- Monitoring and self-healing
- Feedback loops and learning mechanisms
- Presentation and output channels

### Step 5: Present the result

Show the operator:
- Table of all diagrams created with deep links to Miro
- Board URL for overview
- Note: diagrams in Miro are freely movable and editable

## Color coding (recommendation)

| Layer type | Color | Hex |
|------------|-------|-----|
| Ingress layer (data ingestion) | Light blue | #ccf4ff |
| Aggregation layer | Light green | #adf0c7 |
| Decision layer | Light yellow | #fff6b6 |
| Execution layer | Light red | #ffc6c6 |
| Monitoring layer | Light purple | #dedaff |
| Feedback layer | Light orange | #f8d3af |
| Presentation layer | Light gray | #e7e7e7 |
| External systems | Blue | #c6dcff |

## Board layout

```
y=0      [Overview: Layer]    [Overview: Dataflow]    [Overview: Deployment]
          x=0                   x=2500                   x=5000

y=2500   [Ingress-layer detail: all data sources + components]

y=5000   [Core-layer detail: aggregation + decision + execution]

y=7500   [Operations-layer detail: monitoring + feedback + presentation]
```
