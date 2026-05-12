---
name: implement
description: |
  Implementation protocol for user stories. 8-step workflow from issue identification
  to closing table including post-implement validation. Use when the operator says "go",
  wants to implement a story, or runs "/implement". Also used by the automation daemon
  (no human in the loop).
version: 2.7.0
language: en
metadata:
  hermes:
    category: coding
    tags: [code-generation, deklarativer-modus, quality-gates, token-pre-flight]
    requires_toolsets: [terminal, git, eslint, semgrep]
    related_skills: [ideation, sprint-review]
---

# Implement

Systematically implement a user story from the Linear backlog. 8 steps + governance validation — none may be skipped.

## Workflow (9 steps)

### Step 0: Load environment

1. Read `.claude/environment.json` (if present — otherwise fall back to defaults and log a warning).
2. Extract paths from `paths.*` as needed (e.g. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Before any tool invocation, check `tools_available.<tool>` (e.g. `tools_available.eslint`, `tools_available.semgrep`, `tools_available.tests`). If `false` or missing, the skill skips the call and notes it in the output.
4. Missing-file fallback: assume the schema defaults (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) and add a note to the output: "Note: `.claude/environment.json` is missing — defaults active. Recommendation: re-run `/bootstrap` or create the file manually."

### Step 0b: Token-window pre-flight (BOO-40, soft)

Before each story, check whether the estimated story load crosses the sprint-box limit. **Soft trigger** — the operator can always proceed; the skill only warns. Convention: HANDBUCH Appendix G (BOO-38).

**Logic:**

1. **Measure current context window:**
   - Preferred via `/context` command OR `claude-code measure-context` (if available)
   - Fallback: estimate from chat length (very rough — flag in output)

2. **Read story token estimate from spec frontmatter `token_estimate`** (set by `/ideation` step 5b — BOO-39).
   - Fallback: derive from `estimate` (SP) per HANDBUCH Appendix G:
     - 1 SP → 5%, 2 → 12%, 3 → 25%, 5 → 50%, 8 → "story too large, split"

3. **Compute projection:**
   ```
   projection_percent = current_percent + story_estimated_percent
   ```

4. **Read thresholds from `.claude/environment.json`** (BOO-38 established them as mandatory fields):
   - `thresholds.token_warn_threshold` (default 70)
   - `thresholds.token_hard_threshold` (default 80)

5. **If `projection > token_hard_threshold`:**

   ```
   [!warning] Token pre-flight:
   - Current: 65% (130k / 200k)
   - Story estimate: 25% (50k)
   - Projection: 90% — over sprint-box limit (80%)

   Recommendation: close the sprint here.
   Next steps:
   1. Start /sprint-review (persist current sprint state)
   2. Close this chat
   3. Open a new chat and start the story there

   Proceed anyway? [yes/no]
   ```

6. **On `no`:** the skill stops and emits the /sprint-review hint plus sprint-switch instructions:

   ```
   1. Start /sprint-review (write the sprint file, update L3)
   2. Commit the last lesson
   3. Close this chat
   4. Open a new chat with:
      "Continue sprint X, next story: BOO-YY"
      /implement BOO-YY
   ```

7. **On `yes`:** write a risk note into `journal/reports/local/{date}_{story}/meta.json` (field added in step 6f-bis):

   ```json
   "pre_flight_warning": "projection 90%, user proceeded"
   ```

   ... continue to step 1.

8. **If `projection > token_warn_threshold` but `<= token_hard_threshold`:** soft hint without block:

   ```
   [!info] Token pre-flight:
   - Projection: 78% (just below the sprint-box limit of 80%)
   - Hint: one small story may still fit, then sprint close is recommended
   ```

   Continue to step 1.

**Soft-trigger rationale:** some stories are smaller than estimated; some sprint switches are costlier than a compact. The operator stays in control. When `pre_flight_warning` ends up in `meta.json` and the session actually compacted → lesson for L3 ("estimate was too conservative" or "operator decision was right") → calibration for `/ideation` token heuristic (BOO-39).

### Step 1: Identify the issue

- `linear.getOpenIssues()` — load the full backlog
- Identify the issue with status "In Progress" (that's the assignment)
- If several are "In Progress": oldest first, ask operator when unclear
- Read the issue description in full

### Step 2: Dependency check

- Check the `## Dependencies` section of the issue
- Check parent issue and siblings (EPIC context)
- Scan the entire backlog for references to the issue (PREFIX-XX mentions)
- **If a dependency is OPEN:** warn the operator — "PREFIX-XX depends on PREFIX-YY (status: backlog). Continue anyway?"
- **If order differs:** show impact analysis

### Step 3: Build context

- Read CLAUDE.md (system context)
- **Read `ARCHITECTURE_DESIGN.md`** — the lead document: ADRs, quality attributes, guiding principles. Check whether the story violates existing ADRs or quality attributes (e.g. ADR-6: zero external dependencies, ADR-5: kill-switch first). References all further architecture docs.
- Identify affected code files (from issue description + your own analysis)
- Check related completed issues (what's already built?)
- Check the architecture dimensions relevant for this story:
  See [references/architecture-checklist.en.md](references/architecture-checklist.en.md)

### Step 3b: Governance validation (mandatory)

Validate the governance artifacts of the issue before drafting the plan.
See [references/governance-validation.en.md](references/governance-validation.en.md)

1. **8-dimensions check:** is the table in the issue present? Is the assessment sound?
   Is a dimension missing that the planned change affects?
2. **Security checklist:** read the Security-by-Design section in the issue.
   Walk through the SECURITY.md checklist for the change type (new API? webhook? external input?).
3. **Validate ADD (for features):** check the Architecture Design Document against current code.
   Do the listed files still exist? Are the integration points correct?
4. **Missing artifacts:** if 8-dimensions, security section or ACs are missing:
   - **Warn the operator:** "Issue PREFIX-XX is missing [section]. Should I add it retroactively?"
   - **Do NOT silently continue** — governance gaps must be visible

### Step 3c: Spec-file gate ⛔ HARD GATE — no plan without a spec

> **This gate is additionally enforced by `.claude/hooks/spec-gate.sh`.**
> The hook blocks any `git commit PREFIX-XXX` if `specs/PREFIX-XXX.md` is missing.

**Flow:**

1. Check: does `specs/PREFIX-XXX.md` exist?

2. **If YES:** read the spec — does the content match the current issue?
   If outdated: update the spec, then continue to step 4.

3. **If NO → STOP. Create the spec now:**
   a. Read `specs/TEMPLATE.md`
   b. Fully populate `specs/PREFIX-XXX.md`:
      - Why (take from the issue)
      - What (deliverable + done criteria)
      - Constraints (Must / Must Not / Out of Scope)
      - Current State (affected files + existing patterns)
      - Tasks (T1, T2… — max 3 files per task, concrete verify step)
   c. Commit the spec: `git commit -m "docs: specs/PREFIX-XXX.md created"`
   d. **Ask the operator to confirm explicitly:**
      Output: `"Spec file created: specs/PREFIX-XXX.md — please review and confirm, then we continue."`
   e. **Wait for operator OK** — only then continue to step 4
   f. Linear issue comment: link to the spec file

4. **No exceptions** — even for small fixes, hotfixes, config changes.
   Only exception: pure doc commits without code changes.

### Step 4: Create plan + operator approval

- Present a concrete implementation plan
- Files, changes, risks, test strategy
- **Wait for operator approval** (human in the loop)
- In daemon execution (auto-execute): skip this step

### Step 5: Implementation (after approval)

- Sub-tasks: before implementation → "In Progress", after completion → "Done"
- Execute the plan fully
- Mark all new functions, methods, and code paths with comment `// AI-generated: {STORY_ID}` (rollback identification, BOO-17). For Python: `# AI-generated: {STORY_ID}`.
- Update all doc files (CLAUDE.md, SYSTEM_ARCHITECTURE.md, etc.)
- Git commit + push
- **Write Session-Reference to Spec-File (BOO-19):**
  ```bash
  # Get commit SHA
  COMMIT_SHA=$(git rev-parse HEAD)
  # Most recent session file for this project (best-effort)
  SESSION_FILE=$(ls -t ~/.claude/projects/*/sessions/*.jsonl 2>/dev/null | head -1)
  SESSION_ID=$(basename "${SESSION_FILE}" .jsonl 2>/dev/null || echo "unknown")
  SESSION_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  ```
  Write to `specs/CLAW-XXX.md` under `## Session-Reference`:
  ```markdown
  ## Session-Reference

  **Session-Timestamp:** {SESSION_TS}
  **Session-ID:** `{SESSION_ID}` (best-effort — most recent session at commit time)
  **Session-Log:** `~/.claude/projects/.../sessions/{SESSION_ID}.jsonl`
  **Commit-SHA:** `{COMMIT_SHA}`
  **Audit-Trace:** `bash .claude/scripts/audit-trace.sh {SPEC_ID}` (requires jq)
  ```
  Then commit the spec file: `git commit -m "docs: specs/CLAW-XXX.md session reference (BOO-19)"`

  > If SESSION_FILE is empty (no session file found): Write only COMMIT_SHA + SESSION_TS, mark SESSION_ID as "unknown" — no STOP.

- No questions unless there's a real blocker

### Step 5.5: Sensitive Paths Gate ⛔ STOP FOR SENSITIVE PATH (BOO-18)

> This step runs ONLY if `.claude/sensitive-paths.json` exists in the project.
> Without this file: proceed directly to Step 6.

**Process:**

1. Read `.claude/sensitive-paths.json` — load `patterns` array.
2. Determine changed files:
   ```bash
   git diff --name-only HEAD
   ```
3. Check each changed file against the pattern list (glob matching, `**` = recursive):
   - `auth/**` matches `auth/token.js`, `auth/middleware/jwt.js`, etc.
   - `**/*pii*` matches `lib/pii-handler.js`, `src/models/pii.js`, etc.
4. **No match → Gate passed**, proceed to Step 6.
5. **Match found → MANDATORY STOP:**

```
[STOP — SENSITIVE PATH] The following changed files touch sensitive areas:
  - auth/token.js  (Pattern: auth/**)
  - lib/pii-handler.js  (Pattern: **/*pii*)

Mandatory Human Review required (BOO-18, Schrader Ch. 3 §Enterprise Governance).

FULL DIFF FOR REVIEW:
[diff output here]

Please review the diff line-by-line and confirm with:
  review-ok: {your-name} - {brief comment on what was reviewed}

Without explicit confirmation, the commit will not proceed.
```

6. **Wait for review confirmation** — Operator responds with `review-ok: ...`
7. **After confirmation:**
   a. Write review comment to Spec-File under `## Human Review`:
      ```markdown
      ## Human Review
      - **Date:** {{TODAY}}
      - **Reviewer:** {{REVIEWER_NAME}}
      - **Comment:** {{REVIEW_COMMENT}}
      - **Sensitive Paths Touched:** {{LIST_OF_SENSITIVE_FILES}}
      ```
   b. Commit Spec-File: `git commit -m "docs: specs/CLAW-XXX.md human review documented (BOO-18)"`
   c. Then regular commit with the code changes.

> **Without `review-ok` confirmation:** Step 6 is NOT reached. No exceptions, no auto-bypass.

### Step 6: Post-implement validation

Validation BEFORE the issue is set to "Done". See [references/validation-checklist.en.md](references/validation-checklist.en.md)

**6-Prelude) Iteration-run setup — persistence directory for raw tool outputs (BOO-36)**

Before the individual gates (6a/6a-bis/6a-quart/...) iterate, **once per implement run** a persistence directory for raw tool outputs is created. All iteration outputs (ESLint, Semgrep, tests, coverage) land — in parallel to the declarative iteration — in that directory; `/sprint-review` reads from it later and aggregates L2 lessons. **`/implement` writes only raw outputs**, NOT directly into `journal/learnings.db` (L3). The separation is hard: implement persists, sprint-review aggregates.

```bash
# Default path (can be overridden via paths.reports_local in .claude/environment.json)
REPORTS_BASE="journal/reports/local"
STAMP=$(date -u +%Y-%m-%d_%H%M)
STORY_ID="${ISSUE_KEY}"   # e.g. BOO-36
RUN_DIR="${REPORTS_BASE}/${STAMP}_${STORY_ID}"
mkdir -p "${RUN_DIR}"

# Initialise start timestamp and iteration counters (shell variables for meta.json)
RUN_STARTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ITER_ESLINT=0
ITER_TESTS=0
ITER_SEMGREP=0
ITER_COVERAGE=0
RUN_FINAL_STATUS="in_progress"
```

**Path convention:**
- Default: `journal/reports/local/{YYYY-MM-DD_HHMM}_{STORY-ID}/` (lives under project root)
- gitignored (bootstrap adds the entry to `.gitignore` — see `references/file-templates.en.md` §.gitignore)
- Files per run:
  - `eslint-iter{N}.sarif` — per ESLint iteration (`--format @microsoft/eslint-formatter-sarif --output-file ...` or `--format json --output-file ...` as fallback)
  - `tests-iter{N}.junit.xml` — per test iteration (`pytest --junit-xml=...` / `jest --reporters=default --reporters=jest-junit` with `JEST_JUNIT_OUTPUT_FILE`)
  - `coverage-final.json` — coverage end state (c8 / pytest-cov, JSON reporter, one-time copy at iteration end)
  - `semgrep-final.sarif` — Semgrep end state (`semgrep --sarif --output ...`, one-time copy at iteration end)
  - `meta.json` — run metadata (schema see step 6 closeout)

**Important:** the write path is independent — if a gate is skipped (e.g. no `eslint.config.mjs`), the corresponding file does not appear in the run directory. `meta.json.iterations.<gate>` then stays at `0`.

**If `tools_available.<tool> == false`** (from `.claude/environment.json`): persistence for that gate is also skipped — the behaviour mirrors the regular gate logic, the raw output simply does not exist.

**6a) Code-quality gate — ESLint + SonarLint + Error Lens (declarative iteration)**

> **Tool chain:** `eslint.config.mjs` defines rules (industry standard since BOO-2:
> ESLint Recommended + Airbnb Base + Security + SonarJS) → ESLint CLI checks →
> SonarQube for IDE shows deep analysis → Error Lens shows both inline in VS Code.

**Declarative mode (Schrader Code Crash lines 2105-2141, compound-engineering mechanism #1):**
The skill iterates over the ESLint output until 0 errors — the skill formulates code fixes
based on the findings, re-checks, and stops only when the gate is green or the iteration
limit is reached.

```bash
# Check all JS files changed in this commit — mandatory run + per-iteration SARIF persistence
ITER_ESLINT=$((ITER_ESLINT + 1))
git diff --name-only HEAD | grep -E '\.(js|mjs)$' | \
  xargs npx eslint --max-warnings=0 \
    --format @microsoft/eslint-formatter-sarif \
    --output-file "${RUN_DIR}/eslint-iter${ITER_ESLINT}.sarif"
# Fallback without SARIF formatter: --format json --output-file "${RUN_DIR}/eslint-iter${ITER_ESLINT}.json"
```

> **SARIF vs JSON:** if `@microsoft/eslint-formatter-sarif` is installed as a devDependency, use SARIF (CI-friendly, GitHub Action compatible). Otherwise fall back to built-in `--format json` — the file is then `eslint-iter{N}.json`. ESLint has no native SARIF support yet; the `@microsoft/eslint-formatter-sarif` plugin is the established path.

**Iteration loop (mandatory):**

1. Run ESLint on changed files — output ALWAYS lands additionally in `${RUN_DIR}/eslint-iter${ITER_ESLINT}.sarif` (or `.json` in fallback).
2. If `errors > 0`:
   a. Formulate code fixes based on the output (skill reads findings, suggests patches)
   b. Apply patches (Edit tool)
   c. Increment `ITER_ESLINT`, re-run step 1 (new iteration output lands in `eslint-iter{N+1}.sarif`)
3. If `errors == 0`: gate passed — continue to step 6b.
4. **Maximum 5 iterations.** At iteration 5 without green: STOP with a clear note to the
   operator: which findings persist, which fixes were attempted, why they didn't take.
   Operator decides (manual fix, rule exception, or mark the story as carry-over).

**Gate behaviour:**
- **0 errors + 0 warnings:** gate passed — continue to step 6b.
- **Errors + iterations remaining:** keep iterating.
- **Errors + iteration limit reached:** STOP, operator intervention.
- **Warnings only:** operator decides whether acceptable (with justification in Linear comment).
- No `eslint.config.mjs` in the project: skip gate + inform operator the rules file is missing (BOO-2 migration).

**Python equivalent:** same scheme with `npx eslint` -> `ruff check`, `eslint.config.mjs`
-> `pyproject.toml`. Ruff iteration runs with the same 5-iteration limit. SARIF persistence is analogous: `ruff check --output-format sarif --output-file "${RUN_DIR}/ruff-iter${ITER_ESLINT}.sarif"` (Ruff has native SARIF support since `ruff` 0.4.x). The counter variable stays `ITER_ESLINT`; the file name reflects the linter (`ruff-iter{N}.sarif` instead of `eslint-iter{N}.sarif`).

**6a-bis) Security gate — Semgrep (declarative iteration, BOO-4)**

> **Tool chain:** `.semgrep.yml` (manifest from BOO-3) → hook script reads active packs
> and constructs `--config p/...` flags → Semgrep CLI checks → findings in output.
> Second quality gate after ESLint, same iteration mechanics.

**Manifest reader (same logic as the pre-commit hook and the GitHub Action):**

```bash
# Extract active packs from .semgrep.yml
PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//')
ARGS=""
for pack in $PACKS; do
    ARGS="$ARGS --config $pack"
done

# Semgrep on changed files — SARIF persistence for the final run
ITER_SEMGREP=$((ITER_SEMGREP + 1))
git diff --name-only HEAD | xargs semgrep $ARGS --error --quiet \
    --sarif --output "${RUN_DIR}/semgrep-final.sarif"
```

> **Semgrep persistence convention:** we write per iteration TO `${RUN_DIR}/semgrep-final.sarif` — the file name `-final` reflects that only the end state matters for sprint-review (Semgrep iterates less often than ESLint and the last file wins by overwrite). The counter `ITER_SEMGREP` is incremented anyway for `meta.json.iterations.semgrep`.

**Iteration loop (same mechanics as 6a):**

1. Manifest reader loads active packs from `.semgrep.yml`.
2. Run Semgrep on changed files with the constructed flags — output overwrites `${RUN_DIR}/semgrep-final.sarif`.
3. If findings exist:
   a. Formulate code fixes based on the output
   b. Apply patches (Edit tool)
   c. Increment `ITER_SEMGREP`, re-run step 2
4. If 0 findings: gate passed — continue to 6b.
5. **Maximum 5 iterations.** At iteration 5 without green: STOP, operator intervention.

**Gate behaviour:**
- 0 findings: gate passed — continue to 6b.
- High/Critical findings + iterations remaining: keep iterating.
- High/Critical findings + iteration limit reached: STOP, operator intervention.
- Medium/Low only: operator decides (with justification in the Linear comment).
- No `.semgrep.yml`: skip gate + inform operator "rules file missing — re-run /bootstrap" (BOO-3 migration).
- No active packs in `.semgrep.yml` (all commented out): skip gate + hint.

**Runtime budget:** must stay under 10 seconds. For larger repos optimize with `--baseline-ref HEAD~1` instead of a full scan.

**6a-tris) Dependency gate — slopsquatting protection (BOO-12)**

> **Tool chain:** `git diff --cached` -> `hooks/dependency-check.sh` -> registry lookup
> (npm view / pip / curl fallback) -> existence + age + CVE check.
> Schrader Code Crash ch. 3-4: AI hallucinations are their own attack vector.

**Trigger:** runs ONLY when `package.json`, `requirements.txt`, `pyproject.toml`, or
`Cargo.toml` is in the diff. Otherwise immediate exit 0 (performance).

**Three checks per newly added dependency:**

1. **Existence check** — registry lookup (npmjs/pypi). 404 → BLOCKED (hallucination?).
2. **Age check** — package <30 days old? Warning (typosquatter risk, manual verification).
3. **CVE check** — `npm audit --audit-level=high` / `pip-audit`. High/Critical → BLOCKED.

**Gate behaviour:**
- 0 findings: gate passed — continue to 6b.
- Existence 404 / High/Critical CVE: gate BLOCKED, operator must verify or remove the package.
- Age warning: gate passed, but a note in the output. Operator decides whether that is a risk.
- Cargo diff: hint "full Cargo support in a future iteration", operator runs `cargo audit` manually.
- Tool fallback: when `npm` / `pip-audit` is missing, the script falls back to curl against the registry.

**Runtime budget:** with the registry lookup typically 2-5 seconds. With many new
dependencies parallelisable — currently a serial implementation, optimisable on demand.

**6a-quart) Coverage gate — diff coverage >=80% for new code (BOO-15)**

> **Tool chain:** test run (c8 / pytest-cov) -> coverage.json -> hooks/coverage-check.sh
> -> correlates `git diff --added` with coverage data -> gate decision.
> Schrader Code Crash ch. 3: total coverage on legacy repos is unfair —
> only diff coverage on newly added lines counts.

**Important:** this step runs inside the skill, NOT in the pre-commit hook (tests
take too long — would blow the hook's 10s budget).

**Iteration loop:**

1. Test run with coverage output and JUnit XML per iteration:
   - Node: `npx c8 --reporter=json --reporter=text-summary npx jest --reporters=default --reporters=jest-junit` with `JEST_JUNIT_OUTPUT_FILE="${RUN_DIR}/tests-iter${ITER_TESTS}.junit.xml"`. Coverage output lands in `coverage/coverage-final.json`.
   - Python: `pytest --cov --cov-report=json --junit-xml="${RUN_DIR}/tests-iter${ITER_TESTS}.junit.xml"`. Coverage output lands in `coverage.json`.
   - Increment the counter beforehand: `ITER_TESTS=$((ITER_TESTS + 1))`.
   - At each iteration: `ITER_COVERAGE=$((ITER_COVERAGE + 1))` in sync.
2. Invoke `bash .claude/hooks/coverage-check.sh` — compares added lines from
   `git diff --cached -U0` against the coverage data.
3. Copy the coverage end state to the run directory (one-time copy at iteration end):
   - Node: `cp coverage/coverage-final.json "${RUN_DIR}/coverage-final.json"`
   - Python: `cp coverage.json "${RUN_DIR}/coverage-final.json"`
4. Gate behaviour:
   - **>=80% (pass):** gate passed — continue to 6b.
   - **60-80% (warn):** operator decides, rationale in the Linear comment.
   - **<60% (block):** add tests + repeat iteration step 1.
5. **Maximum 5 iterations.** On iteration 5 without green: STOP, operator step in
   (manual test-reach plan or split the story).

> **JUnit XML convention:** both pytest (`--junit-xml=...`) and jest-junit (env var `JEST_JUNIT_OUTPUT_FILE`) write JUnit XML — the standard format for test reports, parseable by `/sprint-review`. If the test runner cannot emit JUnit XML (e.g. Mocha without a reporter): test persistence is skipped, `ITER_TESTS` is not incremented, `meta.json.iterations.tests` stays at 0 — the coverage run itself continues.

**Gate behaviour edge cases:**
- No coverage data (no `coverage-final.json` / `coverage.json`): gate skipped
  with a hint to "/bootstrap to set up the test tooling".
- Diff contains only test files / configs / docs: gate skipped.
- Diff has 0 added lines: gate skipped.

**Configuration:** thresholds are constants inside the script (`COVERAGE_PASS=80`,
`COVERAGE_WARN=60`). Operator override via env vars:
`COVERAGE_PASS=90 bash .claude/hooks/coverage-check.sh`.

**Runtime budget:** script run <2 seconds. The test run itself can take several
minutes — that is why it is NOT in the pre-commit hook.

Step 2 — syntax & runtime:
- `node --check` on all changed .js files (syntax errors?)
- If agent: run 1× in DRY_RUN/TEST_MODE — does it run without crashing?
- If library/module: does it import correctly for all consumers?

**Background of the 6 tools:**
| Tool | Role | When active |
|------|------|-------------|
| **ESLint** (`.eslintrc.js`) | Defines + checks coding rules (syntax, security, style) | CLI in step 6a + passively in VS Code |
| **Semgrep** (`.semgrep.yml`) | Pre-commit SAST with pack-based ruleset | CLI in step 6a-bis + pre-commit hook + CI layer |
| **Slopsquatting hook** (`.claude/hooks/dependency-check.sh`) | Supply-chain check (existence + age + CVE) | Pre-commit hook after Semgrep, only on manifest diff |
| **Coverage hook** (`.claude/hooks/coverage-check.sh`) | Diff-coverage gate (>=80% added lines) | When active: /implement step 6a-quart, NOT the pre-commit hook |
| **SonarQube for IDE** (SonarLint) | Deeper security analysis, code smells, bug patterns | Passive in editor while coding |
| **Error Lens** | Shows ESLint + SonarLint findings inline in the line | Passive in editor — no hiding of errors |

**6b) Acceptance criteria + Linear comment** (mandatory)
- Walk through every acceptance criterion from the issue description
- Checkbox by checkbox: is the criterion fulfilled? Note evidence
- If a criterion is NOT fulfilled: implement fix or inform operator
- **Write a Linear comment** with AC verification:
  ```
  ## AC-Verification
  - [x] AC 1: [description] — ✅ [evidence]
  - [x] AC 2: [description] — ✅ [evidence]
  - [ ] AC 3: [description] — ❌ [reason / what's missing]
  ```

**6c) Architecture quick-check**
- Only check the relevant dimensions (see architecture-checklist.en.md)
- Focus: was anything introduced that violates existing patterns?
- Config SSoT violated? Hardcoded values instead of config.js?
- Error handling present where needed? (API calls, file I/O)

**6d) Smoke test**
- Run agent/feature 1× for real (not just syntax check)
- Plausible output? Signal file written correctly?
- No unexpected side effects on other agents/signals?

**6e) Document security findings**
- What was checked? (from step 3b security checklist)
- What is safe? What was mitigated?
- Open risks that were accepted?
- For LOW-risk stories: "Security: no new attack vectors" is enough

**6f) Result**
- **PASS:** continue to step 7 (Linear → Done, change log, push)
- **FAIL:** back to step 5, fix, re-validate
- Document validation result as a comment in the Linear issue

After successful validation:
- Linear → Done + comment (incl. validation result)
- Obsidian change log via `linear.writeChangeLog()`

**6f-bis) Write meta.json (BOO-36)**

At the end of the run — pass, fail, or stop — `meta.json` is written into the run directory. Audit trail for `/sprint-review`.

```bash
RUN_COMPLETED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
# Set RUN_FINAL_STATUS from step 6f: "passed" | "failed" | "stopped_iteration_limit"
# Load ENVIRONMENT from .claude/environment.json (mac/vps/ci) — default "unknown" if file missing
ENVIRONMENT=$(jq -r .environment .claude/environment.json 2>/dev/null || echo "unknown")

cat > "${RUN_DIR}/meta.json" <<EOF
{
  "story_id": "${STORY_ID}",
  "started_at": "${RUN_STARTED_AT}",
  "completed_at": "${RUN_COMPLETED_AT}",
  "iterations": {
    "eslint": ${ITER_ESLINT},
    "tests": ${ITER_TESTS},
    "semgrep": ${ITER_SEMGREP},
    "coverage": ${ITER_COVERAGE}
  },
  "final_status": "${RUN_FINAL_STATUS}",
  "environment": "${ENVIRONMENT}"
}
EOF
```

**Schema (fixed, not extended in this iteration):**

```json
{
  "story_id": "BOO-15",
  "started_at": "2026-04-27T14:30:00Z",
  "completed_at": "2026-04-27T14:34:00Z",
  "iterations": {
    "eslint": 3,
    "tests": 2,
    "semgrep": 1,
    "coverage": 1
  },
  "final_status": "passed",
  "environment": "mac"
}
```

**Field convention:**
- `story_id`: Linear issue key (e.g. `BOO-36`)
- `started_at` / `completed_at`: ISO-8601 UTC (`date -u +%Y-%m-%dT%H:%M:%SZ`)
- `iterations.<gate>`: number of iterations per gate, 0 if the gate was skipped
- `final_status`: `passed` (all gates green) | `failed` (gate blocked without hitting the iteration limit) | `stopped_iteration_limit` (iteration 5 reached without green)
- `environment`: `mac` | `vps` | `ci` | `unknown` (from `.claude/environment.json`)

**Important — responsibility separation:**
- `/implement` writes ONLY raw outputs to `journal/reports/local/` — including `meta.json`.
- `/sprint-review` READS `journal/reports/local/` + `ci/` and aggregates into `journal/sprint-{date}.md` (L2). In a second phase `/sprint-review` parses the aggregated data into `journal/learnings.db` (L3).
- **`/implement` does NOT write directly into `learnings.db`.** This separation keeps implement fast (no DB lock, no schema knowledge) and makes sprint-review the single writer of the learnings DB.

### Step 7: Backlog update

- Check whether the implementation affects other issues in the backlog
- If yes: update descriptions (new dependencies, changed prerequisites)
- If issues became obsolete: inform the operator

### Step 8: Closing table (mandatory)

After completion ALWAYS print a summary table:

```markdown
| What | Status |
|------|--------|
| Config change | ✅ detail |
| Code change | ✅ detail |
| Tests/verification | ✅ detail |
| Documentation | ✅ detail |
| Git push | ✅ commit hash |
| Linear → Done | ✅ |
| Obsidian change log | ✅ |
```

Adjust rows depending on the implementation. Each row with checkmark and short detail.
The operator should see at a glance what was done, without asking.

After that: **Fill in `## Summary` in the spec file** (`specs/PREFIX-XXX.md`).
No jargon — explain as if to someone who doesn't know the system.
3 paragraphs: (1) what was the problem? (2) what was built / how does it work? (3) what changes because of it?
Then commit: `git commit -m "docs: specs/PREFIX-XXX.md summary added"`

## Change checklist (mandatory after every code change)

See [references/change-checklist.en.md](references/change-checklist.en.md)
