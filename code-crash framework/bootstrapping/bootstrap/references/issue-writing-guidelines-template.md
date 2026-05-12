# Issue Writing Guidelines — {{PROJECT_NAME}}

**Version:** 3.1
**Purpose:** Standardized issue creation for Claude + Operator collaboration
**Changes v3.1 (BOO-30):** §7 Definition of Done aligned to canonical 5-item checklist (1:1 from BOO-30), cross-reference to Linear workflow states (HANDBOOK §8g Linear setup per project) added

---

## Quick Reference

### Title Format
```
[Action] [Component] — [Detail/Benefit]
```

**Examples:**
- "Build Auth Service — JWT-based Session Management"
- "Add Rate Limiting to API Gateway"
- "Fix Memory Leak in Worker Process"
- "Epic: Data Pipeline Refactor (5 Components)"

### Description Structure
```
## Was
[What is being built/changed? Technical overview]

## Warum
[Why does this matter? Business value? Performance gain?]

## Kontext
[Related issues? Dependencies? Background?]

## Workflow-Type
`direct` (build immediately) or `epic` (multiple sub-tasks)

## Komplexität
`low`, `medium`, or `high`

## Abhängigkeiten
- Benötigt: [BOO-XX] (must be done first)
- Beeinflusst: [BOO-YY] (affected by this change)

## Akzeptanzkriterien
- [ ] Specific requirement 1
- [ ] Specific requirement 2
- [ ] Documentation updated (CLAUDE.md + SYSTEM_ARCHITECTURE.md)
- [ ] Git Push

## Schrader Prompt Components  ← Required (Code Crash Ch. 5)
### Insight / ### Constraints / ### Success Criteria / ### Desired Outcome

## Definition of Done  ← Required (gate checklist before "Done")

## Execution Mode  ← Required (agentic / sub-agents / linear + table)
```

---

## Detailed Format

### 1. Title

**Structure:**
```
[Action] [Component] — [Key Benefit/Detail]
```

**Action Types:**
- **Build:** "Build [Component]"
- **Add:** "Add [Feature] to [Component]"
- **Integrate:** "Integrate [Source] with [Target]"
- **Optimize:** "Optimize [Component]"
- **Fix:** "Fix [Issue] in [Component]"
- **Epic:** "Epic: [Large Architectural Theme]"

---

### 2. "Was" Section

**What to include:**
- Technical implementation details
- Architecture decisions
- Component breakdown
- Code references (files/functions)
- Data structures (if relevant)

**Template:**
```markdown
## Was

[Describe what is being built]

**Architecture:**
[Diagram or bullet points showing flow]

**Components:**
1. [Component 1]: [Purpose]
2. [Component 2]: [Purpose]
3. [Component 3]: [Purpose]

**Key Implementation Details:**
* [Detail 1]
* [Detail 2]
```

---

### 3. "Warum" Section

**What to include:**
- Business value / core benefit
- Performance improvements (quantified if possible)
- Risk reduction
- Comparison to current state

**Template:**
```markdown
## Warum

* [Benefit 1]: [Quantified if possible]
* [Benefit 2]: [Quantified if possible]

Compared to current solution:
| Aspect | Today | With this change |
|--------|-------|-----------------|
| [Metric 1] | [Current] | [Improved] |
```

---

### 4. "Kontext" Section

**What to include:**
- Related issues / epics
- Dependencies (what must happen first?)
- Risk considerations

**Template:**
```markdown
## Kontext

**Related Issues:**
* Depends on: [BOO-X], [BOO-Y]
* Blocks: [BOO-Z]
* Epic: [BOO-Epic]

**Trigger:**
Implement when [condition]. Currently [current state].

**Risks & Mitigation:**
* Risk 1 → Mitigation 1
* Risk 2 → Mitigation 2

**Workflow-Type:** `direct`
**Komplexität:** `high`
```

---

### 5. Acceptance Criteria

**Format:**
```markdown
## Akzeptanzkriterien

- [ ] Specific, testable requirement 1
- [ ] Specific, testable requirement 2
- [ ] Specific, testable requirement 3
- [ ] Documentation updated (CLAUDE.md + SYSTEM_ARCHITECTURE.md)
- [ ] Git Push
- [ ] [Optional: testing period, e.g., "48h parallel operation"]
```

**Rules:**
- Each checkbox must be testable/verifiable
- No ambiguous requirements
- Always include documentation updates
- Always include git push as final step

---

### 6. Schrader Prompt Components (Required — Code Crash Ch. 5)

From Schrader Code Crash Ch. 5 §"From Intent to Prompt". Every issue is a complete prompt — not a TODO list. All four sub-sections are mandatory.

```markdown
## Schrader Prompt Components (Required — Code Crash Ch. 5)

### Insight (Perceive)
What insight drives this story? What have we recognized that others don't see?
*Inherited from the associated Intent (BOO-1, BOO-10). If no Intent link → Soulkiller check triggered.*

### Constraints
What limits us? Technical, time, domain, regulatory.
Examples:
* Tech: existing DB schema, external API with rate limit
* Time: before next Release X
* Domain: GDPR-compliant, no PII in logs
* Regulatory: EU-region only

### Success Criteria
How do we measure it works? Acceptance criteria + metrics with target values.
* Functional: API endpoint /xyz returns 200 for valid input X
* Quantitative: P95 latency <200ms, coverage >= 80%
* User-oriented: operator completes task Y in <30s

### Desired Outcome
What concretely exists at the end? As specific as possible.
* Which files were changed?
* Which API endpoint / UI element / CLI command is new?
* Which ADR was written?
* Which migration step?
```

**Example fill:**
```markdown
## Schrader Prompt Components

### Insight (Perceive)
Current issue templates have no structural prompt framework. Claude cannot verify whether an issue is truly a complete prompt. Inherited from INTENT-003: "Issues must be PRDs, not TODO lists."

### Constraints
* Existing Linear issues must not be retroactively invalidated
* Template file is bilingual (DE+EN), both versions must be equivalent

### Success Criteria
* /implement skill aborts with clear message on missing Schrader component
* New issues have all 4 sub-sections with non-empty content (min. 20 chars)

### Desired Outcome
* issue-writing-guidelines-template.de.md + .md updated to Version 3.0
* /implement SKILL.md has new Step 1b (Pre-Flight Check Schrader Components)
* HANDBUCH.md §Daily Usage mentions the required section
```

**Rules:**
- All four sub-sections must be present and non-empty
- Insight should reference a parent Intent if one exists (missing link triggers Soulkiller check)
- Success Criteria must be quantifiable where possible — avoid vague language like "works well"
- Desired Outcome names concrete artifacts, not abstract goals

---

### 7. Definition of Done (Required)

Story may only move to Linear status "Done" when all items are checked. This section is non-negotiable — it is 1:1 from BOO-30 and drives the Linear workflow state `Done` directly (see HANDBOOK §8g Linear setup per project).

```markdown
## Definition of Done (Required)

Story may only move to Linear status "Done" when:
* [ ] All local gates green (ESLint, Semgrep, tests, coverage)
* [ ] PR merged to main
* [ ] All required status checks green (see BOO-29)
* [ ] No open "QA Failed" status
* [ ] Spec file `specs/BOO-XX.md` updated with result summary (Implement Skill Step 8)
```

**Rules:**
- Do not customize or remove checklist items per story
- If a gate does not apply (e.g. no tests for a doc-only story), note it explicitly: `* [N/A] tests — doc-only story`
- The spec file update is mandatory regardless of story size

---

### 8. Execution Mode (Required)

Replaces the former binary "Agent Team Setup" section. Three modes derived from Story Points and complexity.

```markdown
## Execution Mode

**Mode:** `agentic` | `sub-agents` | `linear`
**Story Points:** [number] (determines mode)
```

**Decision table:**

| Signal | Mode |
|--------|------|
| Story Points high, multiple components/layers, parallel work possible | → `agentic` |
| Story Points medium, clear sequential sub-tasks | → `sub-agents` |
| Story Points low, single file or config, <50 lines change | → `linear` |
| Blocks other issues (needs architecture groundwork) | → `agentic` (+ Architect role) |
| Security/infrastructure relevant | → `agentic` (+ Security/Cloud role) |
| Pure documentation, single file | → `linear` |

**Note on "Skill":** Two types are valid:
1. Existing bootstrapping skills (e.g. `grafana`, `security-architect`) — referenced and invoked by name
2. Ad-hoc context briefing — when no skill fits: "You are [Role]", "Your context: [...]", "Your task: [...]"

---

#### When `agentic` (Lead + parallel sub-agents):

Claude is lead orchestrator. Multiple sub-agents work coordinated toward a shared goal.

```markdown
## Execution Mode

**Mode:** `agentic`
**Story Points:** [number]

| Role | Context (what the agent needs to know) | Task | Skill (existing or ad-hoc) |
|------|----------------------------------------|------|---------------------------|
| Lead (Claude) | — (receives synthesis from all sub-agents) | Orchestrate, merge results, decisions | — |
| Sub-Agent 1 | [project info, files, prior knowledge this agent needs] | [concrete sub-task] | [e.g. `grafana` / or ad-hoc briefing "You are X, you do Y"] |
| Sub-Agent 2 | [...] | [...] | [...] |
```

**agentic example** (new architecture dimension with 4 files):
```markdown
**Mode:** `agentic`
**Story Points:** 8

| Role | Context | Task | Skill |
|------|---------|------|-------|
| Lead | ARCHITECTURE_DESIGN.md, specs/BOO-13.md | Orchestrate, merge, update spec | — |
| Writer A | ki-architektur-prinzipien.md as reference | New dimension chapter in architecture-checklist.md | Ad-hoc: "You are Technical Writer..." |
| Writer B | Existing dimensions §1-§8 | Section §9 Scalability in implement/references/architecture-checklist.md | Ad-hoc |
```

---

#### When `sub-agents` (sequential, no parallel team):

Claude calls individual focused sub-agents per sub-task, without orchestrating them in parallel.

```markdown
## Execution Mode

**Mode:** `sub-agents`
**Story Points:** [number]

| Role | Context | Task | Skill |
|------|---------|------|-------|
| Sub-Agent | [...] | [...] | [...] |
```

---

#### When `linear` (direct, no sub-agents):

Claude completes the task directly, without spawning sub-agents.

```markdown
## Execution Mode

**Mode:** `linear`
**Story Points:** [number]

**Rationale:** [e.g. "single file, <20 lines, sub-agent overhead outweighs benefit"]
```

**linear example** (config change in one file):
```markdown
**Mode:** `linear`
**Story Points:** 1

**Rationale:** Single file (semgrep.yml), adding 3 new rules, no cross-layer effect.
```

---

### 9. Metadata (Before Creating in Linear)

```
Priority: [1=Urgent, 2=High, 3=Medium, 4=Low]
Labels: [relevant tags, e.g., feature, bug, architecture, infra]
Estimate: [hours, or leave empty if uncertain]
State: [Backlog, Current Sprint, etc.]
```

---

## When Claude Creates an Issue

Always add at the top of the description:

```markdown
> 🤖 **Ideation Source:** Claude AI Agent
> Created during [context]
> Recommendation: [priority suggestion]
```

---

## Anti-Patterns

| Bad | Good |
|-----|------|
| "Improve the system" | "Optimize Worker Loop — Add Delta-Based Change Detection" |
| "Build something cool" | "- [ ] Feature X implemented and tested" |
| "Add new component" | "Depends on BOO-50. Blocked until database deployed." |
| "Make it faster" | "Reduce latency from 150ms to <100ms" |
| "This will be great!" | "Risk: Single point of failure. Mitigation: Graceful degradation." |
| Missing Schrader section | All 4 sub-sections filled with non-empty, specific content |
| "Done when it works" | Definition of Done checklist fully checked |
| "Whoever builds it" | Execution Mode declared with mode + Story Points + table |

---

## Full Template for Claude-Generated Issues

```markdown
> 🤖 **Ideation Source:** Claude AI Agent
> Proposed during [context]
> Recommendation: [e.g. "After BOO-42"]

## Was
[Technical implementation]

## Warum
[Business value + quantified benefits]

## Kontext
[Dependencies, triggers, risks]
**Workflow-Type:** `direct`
**Komplexität:** `medium`

## Abhängigkeiten
- Benötigt: [BOO-XX, if any]
- Beeinflusst: [BOO-YY, if any]

## Akzeptanzkriterien
- [ ] Specific requirement 1
- [ ] Documentation updated
- [ ] Git Push

## Schrader Prompt Components (Required)

### Insight (Perceive)
[Insight + intent reference if available]

### Constraints
[Technical, time, domain, regulatory]

### Success Criteria
[Quantifiable metrics + acceptance criteria]

### Desired Outcome
[Concrete artifacts at the end]

## Definition of Done (Required)
Story may only move to Linear status "Done" when:
* [ ] All local gates green (ESLint, Semgrep, tests, coverage)
* [ ] PR merged to main
* [ ] All required status checks green (see BOO-29)
* [ ] No open "QA Failed" status
* [ ] Spec file `specs/BOO-XX.md` updated with result summary (Implement Skill Step 8)

## Execution Mode

**Mode:** `linear` | `sub-agents` | `agentic`
**Story Points:** [number]

[Table and rationale depending on mode]

**Priority:** [1-4]
**Labels:** [relevant tags]
**Estimate:** [hours or TBD]
**Depends on:** [BOO-X, if any]
```

---

*Issue Writing Guidelines — {{PROJECT_NAME}} | Code Crash Governance v2 | Version 3.1*
