<a name="english"></a>

# Sprint Review — Quarterly Audit of Architecture, Tech Debt, and Backlog

> Periodic check of system health: 8 architecture dimensions · tech debt inventory · backlog hygiene · process compliance. One run, one report, one action list.

**Version:** 1.2.0 · **Command:** `/sprint-review`

---

## What It Does

Most teams review "how did the sprint go" by looking at velocity. That's a symptom. This skill audits the system itself: Is the architecture still healthy? Is tech debt growing? Are issues being written with dependencies? Are docs in sync?

The output is actionable: Top-3 risks, a tech debt score (Low / Medium / High), recommended new issues for the backlog, and suggestions for backlog cleanup.

---

## How It Works

```
Step 1: System snapshot (parallel)
   · Linear backlog (all statuses)
   · ARCHITECTURE_DESIGN.md (full read, §1–§8 + all ADRs)
   · SYSTEM_ARCHITECTURE.md
   · config.js current state
   · Git log of the period
   · Self-healing logs (frequent warnings)

Step 2: Architecture review (8 dimensions)
   Reliability · Data Integrity · Security · Performance
   Observability · Maintainability · Cost Efficiency · Signal Quality

Step 3: Tech debt inventory
   · Code duplication · hardcoded values · deprecated features
   · Open code markers · stale dependencies

Step 4: Backlog hygiene
   · Orphans · missing dependencies · obsolete issues · stale priorities

Step 5: Process compliance
   · Mandatory template on recent issues?
   · Bidirectional dependency docs?
   · Doc file versions in sync?
   · Obsidian change-logs written?

Step 6: Report + actions
   · 3–5 sentence summary
   · Top 3 risks
   · Tech debt score
   · Recommended new issues
   · Backlog cleanup suggestions
```

---

## Trigger Phrases

- `/sprint-review`
- "sprint review"
- "architecture audit"
- "tech debt"
- "cleanup"
- "quarterly health check"

---

## Interfaces with Other Skills

| Upstream | What's provided | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| `architecture-review` (System mode) | 8-dimension findings per story | `backlog` | Suggested new issues + obsolete issues to close |
| `backlog` | Current backlog state | `ideation` | Tech debt stories to flesh out |
| `security-architect` (AUDIT) | Security posture | `research` | Open questions flagged for deep research |
| `grafana` | Observability coverage | Operator | Quarterly action plan |

---

## Artifacts / Outputs

- **Summary** — 3–5 sentence top-level assessment
- **Top 3 Risks** — what to fix first, with rationale
- **Tech Debt Score** — Low / Medium / High, plus reason
- **Recommended Issues** — new Linear tickets, ready to create via `/ideation`
- **Backlog Cleanup** — issues to close, re-prioritize, or merge

---

## Installation

```bash
cp -r sprint-review ~/.claude/skills/sprint-review
```

---

## File Structure

```
sprint-review/
└── SKILL.md     ← Skill definition (read by Claude Code)
```

---

---

