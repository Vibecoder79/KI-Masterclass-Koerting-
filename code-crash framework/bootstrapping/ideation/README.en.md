<a name="english"></a>

# Ideation — From Raw Idea to Well-Written Linear Story

> 6-step workflow that turns a raw idea into a production-ready Linear issue — with research, architecture design document (ADD), dependency mapping, and a sprint-fit check. No more "what did we actually agree on?" three weeks later.

**Version:** 1.3.0 · **Command:** `/ideation`

---

## What It Does

Most teams write issues like chat messages: a headline, a paragraph, maybe acceptance criteria if you're lucky. Three weeks later, nobody remembers what "it" actually meant.

This skill runs a rigorous 6-step process: it researches (when needed), reads the full architecture (all ADRs, not just the first few), checks the DB schema chain, creates an Architecture Design Document (ADD) for real features, flags when a decision needs a machine-enforced guard, drafts the story with sprint-fit scoring, and only then — after operator approval — creates the Linear issue.

The output is a story that a teammate can pick up in six months and still understand the full context.

---

## The 6 Steps

| # | Step | What it enforces |
|---|------|------------------|
| 1 | **Research (when needed)** | External facts get verified via `/research` before they become ACs. No "I think the API supports this." |
| 2 | **Context load (parallel)** | Backlog, `ARCHITECTURE_DESIGN.md` (full), `SYSTEM_ARCHITECTURE.md`, schema check, similar-issue check |
| 3 | **Architecture Design Document** | Features get an ADD: components, data flow, infra impact, 8-dimension eval, ADRs, risks |
| 4 | **Story draft** | Combines ADD + story template (feature or fix/refactor) |
| 5 | **Alignment + sprint-fit** | Dependencies (bidirectional), priority in context, SP estimate, WIP check, carry-over risk |
| 6 | **Finalize (after OK)** | Linear issue created + affected issues updated |

---

## The Enforcement Check (Mandatory on Every New ADR)

Every new architectural decision triggers this question: **Is this enforced, or just documented?**

| Answer | Action |
|--------|--------|
| Machine-enforced (commit hook, self-healing check, config validation) | Note the guard's location in the story |
| Only documented | Automatically suggest a "Guard Story" as a separate 1-SP ticket |

Typical guard mechanisms:
- Commit hooks in `.claude/hooks/` (like spec-gate, exchange-guard)
- Self-healing architecture guard — extend with a new check
- Config validation in self-healing

This check runs automatically. You don't ask for it. Paper-only ADRs become guard stories.

---

## Sprint-Fit Scoring (Mandatory)

| Criterion | Rating |
|-----------|--------|
| Estimated story points | 1–5 SP (>5 → suggest splitting) |
| Sessions to Done | 1–2 sessions (>2 → too big, split) |
| Sprint fit | Does it fit alongside current sprint stories? (max 3–4 total) |
| WIP impact | Would taking it on push WIP > 2? |
| Carry-over risk | Low / Medium / High |

High carry-over risk → splitting suggestion attached.

---

## Trigger Phrases

- `/ideation`
- "I have an idea"
- "new feature"
- "we need X"
- "new story"

---

## Interfaces with Other Skills

| Upstream | What's provided | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| User idea | Raw description | `backlog` | New priority-ranked story |
| `research` | Facts, comparisons, API details | `implement` | Story + Spec with clear ACs and scope |
| `security-architect` (DESIGN) | Threat model for the change | `architecture-review` | Story ready for pre-check |
| `cloud-system-engineer` (Teammate) | Infrastructure impact assessment | | |

---

## Artifacts / Outputs

- **Linear issue** — fully filled template (feature or fix/refactor)
- **Architecture Design Document (ADD)** — attached as comment or `<details>` block for features
- **`specs/ISSUE-XX.md` placeholder** — sketched for implement to complete
- **Dependency updates** — bidirectional in affected issues
- **Guard Story** — whenever a new ADR needs machine enforcement

---

## Installation

```bash
cp -r ideation ~/.claude/skills/ideation
```

---

## File Structure

```
ideation/
├── SKILL.md                                      ← Skill definition
└── references/
    ├── architecture-design-document.md           ← ADD template
    ├── architecture-dimensions.md                ← 8 dimensions deep dive
    ├── story-template-feature.md                 ← Feature/agent template
    ├── story-template-fix.md                     ← Fix/refactor template
    └── perplexity-api.md                         ← Deep-research integration
```

---

---

