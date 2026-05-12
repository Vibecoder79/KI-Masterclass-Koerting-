<a name="english"></a>

# Architecture Review — 8 Dimensions Against One Story or the Whole System

> Review any story — or the entire system — against 8 architectural dimensions. Catches risks, tech debt, and scaling issues **before** they land in production.

**Version:** 1.3.0 · **Command:** `/architecture-review`

---

## What It Does

Most teams only review architecture when something breaks. This skill turns architecture review into a routine checkpoint — for individual stories (Story Review) or the full system (System Review).

The skill forces Claude to read `ARCHITECTURE_DESIGN.md` end-to-end (§1–§8 plus every ADR) before making any judgment. No skimming, no "I've read enough." That rule alone prevents most bad calls.

**Two modes:**

| Mode | Trigger | What it produces |
|------|---------|------------------|
| **A — Story Review** | Before a story goes into `/implement` | Per-dimension status (OK / Warning / Critical), concrete recommendations, optional story changes |
| **B — System Review** | Quarterly or when planning a refactor | Full audit: strengths, risks, concrete tech debt, new issues for the backlog |

---

## The 8 Architecture Dimensions

| # | Dimension | What gets checked |
|---|-----------|-------------------|
| 1 | **Reliability** | Failure modes, retries, backoff, circuit breakers |
| 2 | **Data Integrity** | Schema contracts, migrations, referential integrity |
| 3 | **Security** | Auth boundaries, secret handling, attack surface |
| 4 | **Performance** | Latency budgets, hot paths, bottlenecks |
| 5 | **Observability** | Metrics coverage, logs, traces, alert rules |
| 6 | **Maintainability** | Coupling, clarity, dead code, duplication |
| 7 | **Cost Efficiency** | Cloud spend, redundant compute, idle resources |
| 8 | **Signal Quality** | For ML/AI systems: noise vs. signal, drift |

Dimensions 7 and 8 are domain-customized at bootstrap time — swap them out for anything your project actually cares about.

---

## How It Works

```
Story / System under review
        │
        ▼
Read ARCHITECTURE_DESIGN.md §1–§8 + all ADRs (enforced checklist)
        │
        ▼
Map the change to affected components
        │
        ▼
Evaluate relevant dimensions (not always all 8)
        │
        ▼
Output:  Status · Finding · Recommendation  (per dimension)
```

The enforced read-the-docs-first rule is the anti-pattern-breaker. Without it, reviews turn into gut checks. With it, every judgment ties back to a concrete ADR or design decision.

---

## Trigger Phrases

- `/architecture-review`
- "review the architecture"
- "does this fit architecturally?"
- "architectural check"
- "architecture audit"

---

## Interfaces with Other Skills

| Upstream (feeds into it) | What's provided | Downstream (consumes the review) | What we deliver |
|--------------------------|-----------------|----------------------------------|------------------|
| `ideation` | Story with ACs + proposed components | `implement` | Pass/Fail signal before code is written |
| `backlog` | Priority list of pending stories | `sprint-review` | Dimension-level findings feed the quarterly audit |
| `security-architect` (DESIGN mode) | Threat model for the change | `research` | Flags open questions that need deep research |

---

## Artifacts / Outputs

Per dimension reviewed:

```
### Dimension: Reliability
Status:        WARNING
Finding:       Retry logic on the Kafka consumer lacks exponential backoff.
               First-retry storm observed in staging at 4× normal load.
Recommendation: Add jittered exponential backoff (ADR-12 precedent).
                Create story: "RELI-43 — Add backoff to consumer retries"
```

A System Review additionally produces:
- **Strengths** — what is working well
- **Top 3 risks** — what to fix first
- **Tech debt score** — Low / Medium / High
- **Recommended issues** — new Linear tickets for the backlog

---

## Installation

```bash
cp -r architecture-review ~/.claude/skills/architecture-review
```

The skill activates automatically on the next Claude Code session.

---

## File Structure

```
architecture-review/
├── README.md                        ← This file
├── SKILL.md                         ← Skill definition (read by Claude Code)
└── references/
    └── dimensions-detail.md         ← Expanded criteria per dimension
```

---

## Changelog

### v1.3.0 (BOO-14)

Observability invariants pinned as mandatory check points under §5 Quality dimensions. `SKILL.md` mandatory checklist extended with an explicit "Observability — three invariants" sub-block: logging schema (6 mandatory fields + logger ADR), metrics endpoint (4 mandatory metrics + port 9090+N), alert rules (3 mandatory alerts `{service}_down` / `{service}_error_rate_high` / `{service}_p95_slow` + routing + promtool validation). `references/dimensions-detail.en.md` §5 restructured into three sub-sections 5.1/5.2/5.3, each with 5 review questions; existing BOO-8 content kept as a "General hygiene" block. Schrader Code Crash chap. 3 + chap. 4 linked as source.

### v1.2.1 (BOO-43)

Drift fix: `architecture-design-template.md` rolled back to §-numbering so the §1–§N references in the skill resolve. Skill mandatory checklist re-aligned to the real template layout (§1 Big Picture, §2 Design rationale, §3 ADR, §4 Component overview, §5 Quality dimensions, §6 References, §7+ optional add-ons).
