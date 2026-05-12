<a name="english"></a>

# Implement — 8-Step Protocol from Issue to Shipped Code

> Turns a Linear issue into shipped code through a non-skippable 8-step protocol: identify → dependencies → context → governance validation → spec-gate → plan → implement → post-validation. No step optional, no shortcuts. Also usable by the automation daemon without human in the loop.

**Version:** 1.5.0 · **Command:** `/implement`

---

## What It Does

Most "AI pair programmer" tools jump from "here's the ticket" to "here's the code". In between, they skip: reading the architecture, validating dependencies, checking for an existing spec, verifying governance artifacts, and running acceptance criteria against the real output.

This skill runs the full 8-step protocol. Every step has an explicit purpose and a gate to the next. Skipping is not an option — the governance hooks (spec-gate, doc-version-sync) enforce it machine-level on `git commit` and `git push`.

---

## The 8 Steps

| # | Step | Gate |
|---|------|------|
| 1 | **Identify issue** | Linear: "In Progress" issue exists and is unambiguous |
| 2 | **Dependency check** | Blockers resolved? Siblings aligned? |
| 3 | **Context build** | `CLAUDE.md`, `ARCHITECTURE_DESIGN.md` (full), affected files, related completed issues |
| 3b | **Governance validation** | 8-dimension table present? Security-by-Design section? ADD valid? |
| 3c | **Spec-file gate** ⛔ HARD GATE | `specs/ISSUE-XX.md` exists? Enforced by `.claude/hooks/spec-gate.sh` |
| 4 | **Plan + operator approval** | Human-in-the-loop (auto-execute skips) |
| 5 | **Implementation** | Plan executed, docs updated, git commit + push |
| 6 | **Post-implement validation** | See sub-steps below |
| 7 | **Backlog update** | Other issues affected by the change updated |
| 8 | **Result table** (mandatory) | Summary + `specs/ISSUE-XX.md` "Summary" section filled |

### Post-Implement Validation (Step 6)

| Sub | Check | Tool |
|-----|-------|------|
| 6a | **Code Quality Gate** | ESLint (0 errors + 0 warnings) · SonarLint (IDE) · Error Lens (inline) |
| 6b | **Acceptance Criteria + Linear comment** | Check every AC, evidence logged |
| 6c | **Architecture Quick-Check** | Relevant dimensions — config SSoT? Hardcoded values? Error handling? |
| 6d | **Smoke Test** | Real execution — not just syntax check |
| 6e | **Security Findings** | Documented — what was checked, what's safe, what was mitigated |
| 6f | **Result: PASS / FAIL** | PASS → Linear Done + changelog + Obsidian sync |

---

## The Spec-File Gate (Hard Gate)

This is the governance firewall. Every code change requires a spec file at `specs/ISSUE-XX.md` **before** the plan step begins.

- If the spec exists → read it, verify it matches the current issue, proceed
- If missing → **STOP**. Create the spec from `specs/TEMPLATE.md`, commit it, wait for operator confirmation
- No exceptions — not for hotfixes, not for config changes. Only pure doc-only commits are exempt.

Machine-enforced by `.claude/hooks/spec-gate.sh`, which blocks any `git commit ISSUE-XXX` if `specs/ISSUE-XXX.md` is missing.

---

## Trigger Phrases

- `/implement`
- "los" (German "go")
- "implement the story"
- "build it"

Also runs automatically under the Linear Automation Daemon when a webhook fires.

---

## Interfaces with Other Skills

| Upstream | What's provided | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| `backlog` | Top-ranked story | `security-architect` (REVIEW) | Code changes reviewed before commit |
| `ideation` | Story + ADD + spec placeholder | `architecture-review` | Impact on affected dimensions |
| `architecture-review` (Pre-check) | Go/No-Go signal | `grafana` | New metrics → dashboards |
| `research` (on-demand) | Fact checks during implementation | `sprint-review` | Cumulative change history |
| `cloud-system-engineer` | Deployment guidance | | |

---

## Artifacts / Outputs

- **Code changes** — committed with proper ISSUE-XX message format
- **Updated documentation** — `CLAUDE.md`, `SYSTEM_ARCHITECTURE.md`, etc., version-bumped together
- **Linear comments** — AC verification, validation result
- **`specs/ISSUE-XX.md`** — completed with summary (3 paragraphs, plain language)
- **Changelog entry** — CHANGELOG.md + Obsidian sync
- **Result table** — mandatory summary

---

## Installation

```bash
cp -r implement ~/.claude/skills/implement
```

Also ensure the governance hooks are installed (done by `/bootstrap`):
```bash
ls .claude/hooks/spec-gate.sh .claude/hooks/doc-version-sync.sh
```

---

## File Structure

```
implement/
├── SKILL.md                                    ← Skill definition
└── references/
    ├── architecture-checklist.md               ← Relevant-dimensions checklist
    ├── change-checklist.md                     ← Per-change validation
    ├── governance-validation.md                ← Governance artifact check
    └── validation-checklist.md                 ← Post-implement sub-steps
```

---

---

