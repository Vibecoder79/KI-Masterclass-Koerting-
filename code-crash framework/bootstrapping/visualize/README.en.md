<a name="english"></a>

# Visualize — Auto-Generated Architecture Diagrams in Miro

> One command (`/visualize <miro-board-url>`) reads all your architecture docs and produces **6 diagrams** directly in Miro — automatically placed, color-coded, and deep-linked.

**Version:** 2.1.0 · **Command:** `/visualize`

---

## What It Does

Every team has an architecture doc nobody reads. And a Miro board nobody updates. The gap is a translation problem: `.md` to visuals.

This skill closes the gap. It reads your architecture markdown files, builds a layer graph in memory, and renders six diagrams straight into a Miro board via the Miro MCP connector. No manual drawing, no out-of-date boxes.

**The 6 diagrams:**

| Diagram | What it shows |
|---------|---------------|
| **Overview** | All architecture layers at a glance |
| **Data Flow** | How data moves through the system |
| **Deployment** | Servers, processes, daemons |
| **Detail 1: Ingress** | Deep dive into input-layer components |
| **Detail 2: Core** | Core processing components |
| **Detail 3: Operations** | Output/observability/ops components |

---

## Prerequisites

### 1. Claude Code installed
```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Miro MCP connector configured

Uses the **Miro MCP connector** via Claude.ai:

1. **Claude Pro or Team account** on [claude.ai](https://claude.ai)
2. In Claude.ai → Settings → Integrations → **Connect Miro**
3. Activate the Miro MCP connector in your Claude Code project:

```bash
claude mcp add --scope user claude_ai_Miro <connection-details>
```

> **Note:** The Miro MCP connector is available via Claude.ai OAuth. More info: [docs.anthropic.com/mcp](https://docs.anthropic.com/mcp)

### 3. Miro board created

1. Create a new empty board on [miro.com](https://miro.com)
2. Note the board URL (format: `https://miro.com/app/board/uXXXXXXX=`)

### 4. Architecture documentation

The skill reads markdown files. **Minimum:** one file describing your architecture layers.

**Recommended structure** (filenames adjustable):

```
your-project/
├── LAYER_ARCHITECTURE.md      # Required: layer structure
├── COMPONENT_INVENTORY.md     # Recommended: all components
├── API_INVENTORY.md           # Recommended: external connections
├── DATA_FLOW.md               # Recommended: data pipelines
├── DEPLOYMENT_ARCHITECTURE.md # Recommended: servers/processes
└── CROSS_CUTTING.md           # Optional: logging, monitoring
```

**Minimal example `LAYER_ARCHITECTURE.md`:**

```markdown
# Layer Architecture

## L1: Data Ingestion
- Files: src/collectors/*, src/scrapers/*
- Input: external APIs, webhooks
- Output: data/raw/*.json

## L2: Processing
- Files: src/processors/*
- Input: data/raw/*.json
- Output: data/processed/*.json

## L3: Output
- Files: src/api/*, dashboard/*
- Input: data/processed/*.json
- Output: HTTP API, dashboard
```

---

## Installation

```bash
mkdir -p ~/.claude/skills/visualize
cp SKILL.md ~/.claude/skills/visualize/SKILL.md
```

Register the skill:

```markdown
## Skills
- `/visualize` — Generate architecture diagrams in Miro
```

Or:

```bash
claude config set skills.visualize.path ~/.claude/skills/visualize
```

---

## Usage

### Basic call

```
/visualize https://miro.com/app/board/uXXXXXXX=
```

### With diagram type

```
# Overview diagrams only (faster)
/visualize https://miro.com/app/board/uXXXXXXX= overview

# Detail diagrams only
/visualize https://miro.com/app/board/uXXXXXXX= detail

# All 6 diagrams (default)
/visualize https://miro.com/app/board/uXXXXXXX= all
```

---

## Customization

### Custom doc paths

The skill looks in the project root by default. For different locations, edit `SKILL.md`:

```markdown
### Step 2: Read architecture documentation
Read files from `docs/architecture/`:
- `docs/architecture/layers.md`
- `docs/architecture/components.md`
- etc.
```

### Custom colors

In `SKILL.md` under `## Color Coding`, adjust hex values:

```markdown
| My Layer | Color | Hex |
|----------|-------|-----|
| Frontend | Light blue  | #ccf4ff |
| Backend  | Light green | #adf0c7 |
| Database | Yellow      | #fff6b6 |
```

### More or fewer layers

Works with any number of layers. Describe them in `LAYER_ARCHITECTURE.md` — Claude adapts the diagrams automatically.

---

## Result Example

After `/visualize` you get:

| Diagram | Miro Deep-Link |
|---------|----------------|
| Layer Architecture Overview | [Open in Miro](https://miro.com/...) |
| Data Flow | [Open in Miro](https://miro.com/...) |
| Deployment | [Open in Miro](https://miro.com/...) |
| L1 Detail: Data Ingestion | [Open in Miro](https://miro.com/...) |
| L2-L4 Detail: Core Processing | [Open in Miro](https://miro.com/...) |
| L5-L7 Detail: Operations | [Open in Miro](https://miro.com/...) |

---

## Trigger Phrases

- `/visualize`
- "generate architecture diagrams"
- "draw the architecture"
- "Miro diagram"
- "visualize the system"

---

## Interfaces with Other Skills

| Upstream | What's provided | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| `architecture-review` | Layer mapping, component inventory | Operator / stakeholders | Ready-to-share Miro board |
| `sprint-review` | System snapshot with docs | `design-md-generator` | Visual reference for the style guide |
| `bootstrap` | Initial architecture docs + `.md` structure | | |

---

## Artifacts / Outputs

- **Miro board** with 6 auto-placed, color-coded diagrams
- **Deep links** per diagram for sharing
- **Color convention** shared across all diagrams (consistent layer → color mapping)

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Miro MCP not available" | Re-connect the Miro MCP connector in Claude.ai settings |
| "Board not found" | Verify URL format: `https://miro.com/app/board/uXXXXXXX=` |
| "No architecture docs found" | Create at least `LAYER_ARCHITECTURE.md` in project root |
| Diagrams overlap | Clear the board and re-run `/visualize` |

---

## File Structure

```
visualize/
├── README.md     ← This file
└── SKILL.md      ← Skill definition (read by Claude Code)
```

---

*Skill Version 2.1.0 | Claude Code Skills*

---

---

