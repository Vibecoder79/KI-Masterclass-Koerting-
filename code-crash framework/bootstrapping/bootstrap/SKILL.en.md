---
name: bootstrap
version: 3.23.0
language: en
description: Sets up a new project with a governance framework — interactive 4-block interview flow, docs architecture with automatic hub linking, optional learning loop L1/L2/L3. Use when the operator wants to set up a new project or says "/bootstrap".
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [setup, project-init, governance-config]
    requires_toolsets: [terminal, git, github, obsidian]
    related_skills: []
---

# Bootstrap — Set up a new project (v3.0)

Sets up a new project with a governance framework. The flow is structured in **4 blocks (A–D)** — each block has a clear focus, no question batches.

References:
- `references/info-gathering.en.md` — core questions (block A)
- `references/existing-infra-check.en.md` — existing infrastructure (block B)
- `references/doc-architecture-proposal.en.md` — docs architecture (block C)
- `references/optional-components.en.md` — self-healing / docsync / daemon / learning loop (block D)
- `references/learning-loop.en.md` — L1/L2/L3 design
- `references/file-templates.en.md` — file scaffolds
- `references/skills-setup.en.md` — pulling skills from GitHub
- `references/global-registry-update.en.md` — SecondBrain integration
- `references/hooks-setup.en.md` — governance hooks

---

## Phase 0: Briefing (before any questions)

Inform the operator first, then start:

```
Bootstrap v3.0 — I'll walk you through 4 blocks:

  Block A — Project core          (7 questions, ~3 min)
  Block B — Existing infra        (5 questions, ~3 min)
  Block C — Docs architecture     (proposal + review)
  Block D — Optional components   (4 yes/no at the end)

After that I'll scaffold the project. Total ~15 min.
Ready? [yes / later]
```

Wait for `yes`.

---

## Phase 1: Block A — Project core

Read `references/info-gathering.en.md` for the full question list. Ask the questions **individually or in small groups** (max 3 per exchange), not as a batch.

### A.1 Stack question (first)

```
What do you want to build?
  a) Node.js / JavaScript backend (API, CLI, daemon)
  b) Frontend (React, Vue, vanilla JS)
  c) Full-stack (backend + frontend)
  d) Python (AI/ML, scripts, FastAPI, Django)
  e) Something else / not decided yet
```

Remember the answer as `STACK_CHOICE` — determines which linting tools get scaffolded:

| Choice | Linter config | Formatter |
|--------|---------------|-----------|
| a) Node.js | `eslint.config.mjs` | — |
| b) Frontend | `eslint.config.mjs` + `.prettierrc` | Prettier |
| c) Full-stack | both | Prettier |
| d) Python | `pyproject.toml` (Ruff + Black) | Black |
| e) Other | `eslint.config.mjs` (generic) | — |

### A.1b Lighthouse CI for frontend performance (BOO-45, only when STACK_CHOICE = b or c)

If `STACK_CHOICE = b` (frontend) or `c` (full-stack with frontend portion), follow-up question:

```
Enable Lighthouse CI for web performance?
  Counterpart to BOO-16's performance gate for backend services, but against the browser URL.
  Measures LCP, FID, CLS + bundle size + accessibility and blocks merges on budget violations.
  [yes / later]
```

On `yes`:
- Render `lighthouserc.json` with performance budgets (LCP <2.5s, CLS <0.1, TBT <300ms, mobile throttling 3G-slow) — template in `references/file-templates.en.md` §`lighthouserc.json (BOO-45)`
- Render `.github/workflows/lighthouse.yml` (treosh/lighthouse-ci-action@v12, on every push + PR) — template in `references/file-templates.en.md` §`.github/workflows/lighthouse.yml (BOO-45)`
- Both files write reports to `journal/reports/ci/run-${{ github.run_id }}/lighthouse.json` (BOO-32 convention)
- HANDBUCH §Lighthouse integration (Appendix H) explains the manual operator tasks: enter the frontend URL per environment, tune performance budgets, pick the mobile throttling profile

On `later`: no templates are scaffolded. The operator can catch up via `migrate_boo_45()`.

Remember `LIGHTHOUSE_CHOICE = yes | later` for Phase 4.

### A.2 Project identity (3 questions)

```
1. Project name? (e.g. MyAnalytics)
2. One-sentence description: what does the system do?
3. Starting version? (default 0.1.0)
```

### A.3 Backlog (2 questions)

```
4. Issue prefix? (default derived from project name, e.g. "MA-" for MyAnalytics)
5. Primary language for docs? (de / en, default: de)
```

### A.4 Architecture dimensions + add-ons (1 question)

```
6. Standard dimensions (always on): Reliability, Data Integrity, Security,
   Performance, Observability, Maintainability, Testability, Scalability, AI-Readiness.

   Activate additional add-ons (multi-select)?
   [ ] Privacy / GDPR — for voice assistants, personal data, tier models
   [ ] Cost Efficiency — for LLM-heavy / SaaS-subscription projects
   [ ] Signal Quality — for ML / analytics / signal systems
   [ ] Compliance — for regulated industries (health, finance, legal)
```

Each activated add-on extends the architecture dimensions in `ARCHITECTURE_DESIGN.md` + the corresponding section in `SECURITY.md` / `GOVERNANCE.md`.

**Remember:** `ADDONS = [...activated]`

Phase 1 checkpoint: print a short confirmation of the answers.

---

## Phase 2: Block B — Existing infrastructure

Read `references/existing-infra-check.en.md` for the full dialog flow.

The skill respects existing infrastructure — it doesn't re-create everything.

```
Do you already have the following? (answer each individually)

1. Project directory?
   [a] Yes + absolute path
   [b] No, create it — where? (absolute path)

2. GitHub repo?
   [a] Yes + URL
   [b] No, create later (no remote for now)
   [c] No GitHub wanted

3. Obsidian vault for docs?
   [a] Yes + absolute path
   [b] No, document in the repo only

4. Backlog system?
   [a] Linear + team slug
   [b] Microsoft 365 Planner
   [c] GitHub Issues
   [d] None

5. API keys for the project?
   [a] Already exist in .env
   [b] .env.example is enough, keys later
```

**Merge mode:** If a folder/repo/vault exists and already contains files, **before overwriting** ask:

```
Warning: {PROJECT_PATH} already contains files.
  [a] Create backup + continue bootstrap
  [b] Only add missing governance files (merge)
  [c] Abort
```

**Remember:** `EXISTING_INFRA = {...}` for the following phases.

Phase 2 checkpoint: print a summary.

---

## Phase 3: Block C — Docs architecture proposal

Read `references/doc-architecture-proposal.en.md` for the full rationale.

Based on the stack choice (A.1) and infra status (block B), present a concrete docs structure proposal:

```
Proposal: 3-layer docs with ARCHITECTURE_DESIGN.md as central hub

  Layer 1 — Story specs (repo)
    Path:    {PROJECT_PATH}/specs/<PREFIX>XXX.md
    Purpose: One spec per story, git-versioned
    Trigger: Required before any code change (spec-gate.sh)

  Layer 2 — Component docs (Obsidian)
    Path:    {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/*.md
    Purpose: Living doc per component (stack, status, open questions)
    Trigger: Update on every /implement (T_last requirement)
    Component proposal (based on stack): {STACK_SUGGESTION}

  Layer 3 — Architecture guidelines (Obsidian)
    Path:    {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Architektur-Vorgaben.md
    Purpose: Consolidated guiding principles, stack decisions, rejected alternatives
    Trigger: Update on ADR changes

  Hub (repo)
    Path:    {PROJECT_PATH}/ARCHITECTURE_DESIGN.md
    Purpose: Entry point for /ideation, /architecture-review, /implement
    §9 References links automatically to all the files above

Does this work? [yes / adjust / skip Obsidian layer]
```

**Component proposal (STACK_SUGGESTION) per A.1:**
- Node.js backend → `api.md`, `db.md`, `background-jobs.md`, `auth.md`
- Frontend → `ui.md`, `state.md`, `routing.md`, `api-client.md`
- Full-stack → `frontend.md`, `backend.md`, `api.md`, `db.md`
- Python → `cli.md`, `core.md`, `integrations.md`, `data.md`
- Other → asks the operator for component names

Operator can adjust components or enter their own.

**On `yes`:**
- Component skeletons get scaffolded in phase 4
- `ARCHITECTURE_DESIGN.md §9 References` is initially populated
- Optional `orphan-check.sh` hook gets installed in phase 4 (explicit ask: "Hook that checks every new `*.md` is registered in the hub? [yes, recommended / no]")

**On `adjust`:** dialog asks which layers + paths are wanted.

**On `skip Obsidian layer`:** all docs in the repo (`docs/components/`), no SecondBrain part.

Phase 3 checkpoint: confirm the docs structure.

---

## Phase 4: Scaffold base structure

### 4.1 Directory structure

```bash
mkdir -p {PROJECT_PATH}/{lib,agents,.claude/skills,.claude/hooks,specs,docs,journal,intents,pitch}
```

### 4.2 Initialize git repo (if not yet present)

```bash
cd {PROJECT_PATH}
git init
# Set remote only if B.2 == yes + URL
git remote add origin {GITHUB_REPO}
```

Create `.gitignore` from `references/file-templates.en.md` — since BOO-36 the template contains the block `journal/reports/local/` (iteration outputs from `/implement` step 6 — these live only locally and are NOT committed, because they are produced fresh on every run and are re-creatable. `/sprint-review` aggregates them into `journal/sprint-{date}.md`, which is committed). Counterpart: `journal/reports/ci/` is reserved for GitHub Actions runs (separate path, independent decision).

### 4.3 Render core files from templates

From `references/file-templates.en.md`, populate with block A values:

| File | Template section |
|------|------------------|
| `lib/config.js` | config.js |
| `CLAUDE.md` | CLAUDE.md (with hub rule) |
| `SYSTEM_ARCHITECTURE.md` | SYSTEM_ARCHITECTURE.md |
| `ARCHITECTURE_DESIGN.md` | ARCHITECTURE_DESIGN.md (hub with §9 References) |
| `INDEX.md` | INDEX.md |
| `COMPONENT_INVENTORY.md` | COMPONENT_INVENTORY.md |
| `.env.example` | .env.example |
| `CHANGELOG.md` | CHANGELOG.md |
| `specs/TEMPLATE.md` | specs/TEMPLATE.md |

> **AI architecture block (BOO-24):** the `ARCHITECTURE_DESIGN.md` template already contains the mandatory block "AI architecture principles + anti-patterns" in §2 (Design Rationale). Reference: `bootstrapping/references/ki-architektur-prinzipien.md`. The block is populated automatically during template rendering — no manual step needed. `/architecture-review` (BOO-7) reactively checks all 8 checks on every story.

From `references/governance-template.en.md`:
- `GOVERNANCE.md` with project name + prefix + activated add-ons

From `references/issue-writing-guidelines-template.md` (version 3.1, BOO-30):
- `.claude/ISSUE_WRITING_GUIDELINES.md` with ISSUE_PREFIX
- Contains since v3.1 the mandatory section `## Definition of Done (Required)` as a 5-item checklist (local gates, PR merge, required status checks, no "QA Failed", spec file update) — 1:1 from BOO-30
- Operator note: Linear workflow states (Backlog → In Progress → In Review → QA Failed → Done → Cancelled) must be created manually per project in the Linear team once — see phase 4.4l

Plus skeletons:
- `DEVELOPMENT_PROCESS.md` — reference to GOVERNANCE.md
- `SECURITY.md` — minimal skeleton (add-on sections: privacy/compliance if activated)

> **CORE RULE in CLAUDE.md:** every new file MUST be registered immediately in `ARCHITECTURE_DESIGN.md §9 References` AND `INDEX.md` — before `git commit`.

### 4.4 Linting configuration

Based on `STACK_CHOICE` — see `references/file-templates.en.md`:
- Node.js / Full-stack / Other → `eslint.config.mjs` (ESLint v9 flat config)
- Frontend / Full-stack → additionally `.prettierrc`
- Python → `pyproject.toml` (Ruff + Black)

Additionally a stack-dependent **CI lint workflow (BOO-28)** — only created when `B.2 == yes` (GitHub repo present). Mirror of the Semgrep CI Action (phase 4.4c) — same Layer-3 mechanism, different tool class (lint instead of SAST):

| STACK_CHOICE | CI workflow file | Source |
|--------------|------------------|--------|
| a) Node.js backend | `.github/workflows/eslint.yml` | `references/file-templates.en.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` |
| b) Frontend | `.github/workflows/eslint.yml` | see above |
| c) Full-stack | `.github/workflows/eslint.yml` | see above |
| d) Python | `.github/workflows/ruff.yml` | `references/file-templates.en.md` §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` |
| e) Other | none — operator decides manually | — |

Both workflows write SARIF to `.ci-reports/` (mandatory — read by BOO-32 for Hermes consumption and by BOO-29 as the required status check `eslint` / `ruff`) and upload via `github/codeql-action/upload-sarif@v3` into the GitHub Security tab.

If `B.2 == no/c` (no GitHub wanted): skip the BOO-28 step; only Layer 2 (pre-commit hook, phase 4.6) covers linting locally.

### 4.4b SAST configuration (Semgrep — all stacks)

From `references/file-templates.en.md` §.semgrep.yml + §.semgrepignore:

- `.semgrep.yml` — Three-layer default ruleset:
  - **Layer 1 (mandatory, all stacks):** `p/security-audit`, `p/secrets`
  - **Layer 2 (language-specific, auto-detected):** `p/javascript` if `package.json` is present, `p/python` if `pyproject.toml` is present
  - **Layer 3 (optional, commented out):** `p/owasp-top-ten` — operator decides per web project
- `.semgrepignore` — default excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`)

Language detection happens in the existing-project migration path via `migrate_boo_3()` — for a new project (bootstrap flow), the matching Layer 2 line is inserted directly active based on `STACK_CHOICE`:

| STACK_CHOICE | Layer 2 activation |
|--------------|-------------------|
| a) Node.js backend | `p/javascript` active |
| b) Frontend | `p/javascript` active |
| c) Full-stack | `p/javascript` active |
| d) Python | `p/python` active |
| e) Other | both commented out (operator decides manually) |

For frontend / full-stack projects also surface a hint when creating the file:

```
Recommendation: for a web app also enable Layer 3 (p/owasp-top-ten) in .semgrep.yml.
Uncomment via: sed -i '' 's/^  # - p\/owasp/  - p\/owasp/' .semgrep.yml
```

Consumed by the pre-commit hook (Layer 2, see phase 4.6) and the GitHub Action (Layer 3, see phase 4.4c).

### 4.4c CI layer (Semgrep, BOO-4)

If `B.2 == yes` (GitHub repo created), `.github/workflows/semgrep.yml` is additionally created from `references/file-templates.en.md` §`.github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)`.

The Action reads the same `.semgrep.yml` manifest as the pre-commit hook (Layer 2, phase 4.6) — same manifest-reader logic, same pack selection. Blocks merges into `main` via the required status check `Semgrep` (branch protection is enabled in BOO-29).

| Layer | Where | When | What |
|-------|-------|------|------|
| Layer 2 | `.git/hooks/pre-commit` | on `git commit` | locally blocking, ESLint + Semgrep |
| Layer 3 | `.github/workflows/semgrep.yml` | on `push`/`pull_request` to `main` | CI-blocking, Semgrep with SARIF output to `.ci-reports/` |

**Important:** Both layers read `.semgrep.yml`. Anyone bypassing the hook locally with `--no-verify` is caught in Layer 3 — belt-and-suspenders.

If `B.2 == no/c` (no GitHub wanted): skip phase 4.4c — only Layer 2 (the hook) is installed in phase 4.6.

### 4.4d Test setup (BOO-15)

Prerequisite for the coverage gate (BOO-15) inside the `/implement` skill (step 6a-quart). Without JSON coverage output the gate is skipped with a hint. Stack-dependent:

- **Node (a/b/c):** install `c8` as a devDependency — `npm install --save-dev c8` — and add a coverage test script in `package.json`:
  ```json
  "scripts": {
    "test:coverage": "c8 --reporter=json --reporter=text-summary npm test"
  }
  ```
  Coverage output lands in `coverage/coverage-final.json`.

- **Python (d):** add `pytest-cov` to `pyproject.toml` as a test dependency, run with `pytest --cov --cov-report=json --cov-report=term-missing`. Coverage output lands in `coverage.json`.

- **Other (e):** operator decides manually — pick a stack-appropriate coverage tool with JSON export.

Test directory convention: `tests/` (Python), `__tests__/` or `test/` (Node) — the filter logic inside the hook recognises these paths automatically and excludes test files themselves from the diff coverage calculation.

Coverage output paths (the hook expects):
| Stack | Path |
|-------|------|
| Node (c8) | `coverage/coverage-final.json` |
| Python (pytest-cov) | `coverage.json` |

Note: the coverage gate itself is installed in phase 4.6 (`coverage-check.sh`), but is NOT called from the pre-commit hook.

### 4.4e Environment awareness (BOO-34)

Prerequisite for downstream skills (implement, sprint-review, breakfix, ...) reading their mac/VPS/CI awareness from a **single source of truth** instead of running detection themselves. The single source of truth is `.claude/environment.json` (manifest), produced by the bundled bash generator.

From `references/file-templates.en.md` §`.claude/environment.json (BOO-34 — skill environment awareness)` and §`.claude/generate-environment-json.sh (BOO-34)`:

- `.claude/generate-environment-json.sh` — bash generator (~120 lines, BSD- and Linux-compatible, idempotent: only writes when the file is missing or `--force` is passed). No deps beyond `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`.
- First run right after creation: `bash .claude/generate-environment-json.sh`
- Result: `.claude/environment.json` with `environment` (mac/vps/ci, CI check first), `tools_available` (eslint, semgrep, test framework, SonarQube), `paths` (journal/reports/lessons/specs), `metadata` (created_at, bootstrap_version=3.3.0, stack).

> **Detection order matters:** CI check (env var `$CI`) BEFORE mac/VPS — a CI runner can be Linux OR mac. Otherwise a mac CI job would be incorrectly marked as `mac`.

`metadata.stack` is set analogously to BOO-3 stack detection:

| Indicator | stack value |
|-----------|-------------|
| `package.json` + (`tsconfig.json` OR `"typescript"` in deps) | `node-typescript` |
| `package.json` without TypeScript | `node-javascript` |
| `pyproject.toml` | `python` |
| Both (`package.json` + `pyproject.toml`) | `mixed` |
| Neither | `unknown` |

Consumed by **all** sub-skills via a step-0 read (rollout in BOO-34 sub-agent #2). Example pattern:

```bash
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
fi
```

When tooling changes (e.g. semgrep installed later) regenerate the file with `bash .claude/generate-environment-json.sh --force`. The file gets committed — `metadata.created_at` is the audit trail.

### 4.4f Observability skeleton (BOO-14)

Prerequisite that every project ships from day 0 with a **structured logging, metrics, and alerting convention** — not retrofitted later. Schrader Code Crash chap. 3 §Production Readiness §Observability + chap. 4 §Run the System (pillar 3 observability): "deploy without observability and you fly blind."

From `references/file-templates.en.md` §`observability.md (BOO-14 — observability skeleton)`, §`observability/alerts/<service>.yml (BOO-14)` and §`observability/.env.observability (BOO-14)`:

- `observability.md` (project root) — central skeleton with three mandatory sections:
  - **Logging schema** — structured JSON logs with required fields (`timestamp`, `level`, `service`, `trace_id`, `message`, `context`)
  - **Metrics endpoint** — `/metrics` in Prometheus format per service, port convention `9090+N` (auth=9091, api=9092, ...)
  - **Alert rules** — three mandatory alerts per service: `{service}_down` (`up == 0` for >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% for 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s for 5 min, severity warning)
- `observability/alerts/<service>.yml` — one Prometheus alert-rules file per service from block C.
- `observability/.env.observability` — routing config (Telegram/Slack/Email webhooks). **Gitignored**, only `.env.observability.example` is committed.
- `.gitignore` entry: `observability/.env.observability`.

**Block C coupling:** for each service from block C (`STACK_SUGGESTION` — e.g. `api.md`, `db.md`, `auth.md` for Node.js) `observability.md` gets a `### Service: <name>` section + a file `observability/alerts/<name>.yml` with the three required alerts.

**Stack defaults** (proposal — operator can override, document as ADR):

| Stack | Logger lib | Metrics lib |
|-------|-----------|-------------|
| Node.js (a/b/c) | `pino` | `prom-client` |
| Python (d) | `structlog` | `prometheus_client` |
| Frontend (b) | Note: browser logs go via a backend service, not directly to Prometheus |
| Other (e) | Operator decides — document as ADR under `docs/domain/adrs/` |

**Validation (optional — only if `promtool` is installed locally):**

```bash
promtool check rules observability/alerts/*.yml
```

If `promtool` is not installed: skip with a hint. Recommendation: `brew install prometheus` (mac) or `apt install prometheus` (VPS) when the first service grows real alert rules.

> **Issue reference:** BOO-14, Schrader Code Crash chap. 3 §Production Readiness §Observability and chap. 4 §Run the System (pillar 3 observability).

### 4.4g Performance baseline (BOO-16)

Prerequisite for catching performance regressions **before** merge — not in production. BOO-14 already established the production alarm `{service}_p95_slow`; BOO-16 adds the pre-production gate: CI bench against a living baseline, blocks merge when p95 > baseline +20 %. Schrader Code Crash chap. 3 §Production Readiness (Gate 3: Performance Baseline) — no baseline, no visible regression.

From `references/file-templates.en.md` §`Performance baseline gate (BOO-16 — P95 + 20% regression alarm)` with the four sub-sections:

- `journal/perf-baseline.json` (project root, committed) — living baseline with `p50_ms`, `p95_ms`, `p99_ms`, `req_per_sec`, `recorded_at`, `commit_sha`, `bench_tool` per service. Created at bootstrap with `services: []`; the operator fills it after the first green CI run.
- `bench/<service>.bench.js` (Node stack) OR `bench/<service>_bench.py` (Python stack) — service benchmark with autocannon (Node, 30s run, 10 connections, 5s warmup) or pytest-benchmark + httpx (Python, approximation `p95 ≈ mean + 1.645*stddev`).
- `.github/workflows/perf.yml` — CI gate (`pull_request` against `main` + `workflow_dispatch`), thresholds `<=1.05` PASS / `1.05-1.20` WARNING (PR comment) / `>1.20` FAIL. Override via PR label `perf-override` OR commit trailer `Perf-Override: <reason>`, append-only into `journal/reports/perf/overrides.log`.
- `journal/reports/perf/overrides.log` — created on the first override; append-only audit trail.

**Block C coupling:** for each service from block C (`STACK_SUGGESTION`) a bench file is created plus an entry in the workflow matrix `service: [...]`. Service names identical to `observability.md` (kebab-case).

**Stack defaults** (operator can override — document as ADR):

| Stack | Bench tool | Bench file | bench_tool value in baseline |
|-------|-----------|-----------|------------------------------|
| Node.js (a/c) | autocannon (devDep) | `bench/<service>.bench.js` | `autocannon` |
| Python (d) | pytest-benchmark + httpx (test dep) | `bench/<service>_bench.py` | `pytest-benchmark` |
| Frontend (b) | Lighthouse CI (separate issue) | — | excluded from BOO-16 scope |
| Other (e) | operator choice with JSON output (p50/p95/p99) | — | `other` |

> [!important] autocannon has no native p95
> autocannon's `result.latency` exposes `p2_5, p50, p75, p90, p97_5, p99, ...` — no `p95`. We use `p97_5` as a conservative approximation (worst-case bias upward — a real regression is detected, harmless fluctuations may appear slightly larger). This is explicitly documented in the baseline via `bench_tool: "autocannon"`. Details see template section.

> [!important] GitHub-hosted runner variance
> Standard runners are shared hardware with +/- 30 % variance between identical runs. The 20% FAIL threshold is intentionally generous — it catches real regressions, not noise. Follow-up issue (after BOO-16): self-hosted runners with reserved CPU/memory; on those the threshold can be tightened to 10%.

> [!note] Initial baseline population
> Fresh repo state: `services: []`. The first CI run fails with "baseline missing". The operator downloads the bench artifact, copies the values manually into `perf-baseline.json` and commits with a justification — only then does the gate run green. Auto-population would be an anti-pattern: every regression would automatically become the new baseline.

> **Issue reference:** BOO-16, Schrader Code Crash chap. 3 §Production Readiness (Gate 3: Performance Baseline). Counterpart to the production alarm `{service}_p95_slow` from BOO-14.

### 4.4h Reliability skeleton (BOO-25)

Sixth pillar of the Schrader model: reliability as an architectural property. Whoever just deploys and hopes builds a demo. BOO-25 lands five invariants as concrete skeleton files: idempotency, retry+backoff, circuit breaker, graceful degradation, and SLO+error budget. Schrader Code Crash ch. 4 §Run the System (pillar 6 reliability) — the difference between "it ran on day one" and "it still runs in month two".

From `references/file-templates.en.md` §`Reliability skeleton (BOO-25 — 5 invariants idempotency/retry/circuit-breaker/graceful-degradation/SLO)` with the four sub-sections:

- `docs/SLO.md` (project root, committed) — Service Level Objective manifest with three SLIs (Availability / Latency P95 / Error Rate), PromQL measurement method (reads from the `/metrics` endpoint introduced in BOO-14), error-budget table per quarter with consumption tracker, review cadence in `/sprint-review` (monthly).
- `lib/idempotency.{js,py}` — Idempotency-Key middleware (Express middleware or FastAPI dependency). Reads header `Idempotency-Key` (UUID v4), persists request hash + response in Redis for 24h TTL. Repeat with same key: cached response. Same key + different body: HTTP 422.
- `lib/retry.{js,py}` — retry wrapper with exponential backoff + jitter. Default: 3 attempts, factor 2, jitter on. **Hard constraint:** only transient errors (5xx, timeout, connection reset) are retried — NO retry on 4xx or 422.
- `lib/circuit-breaker.{js,py}` — circuit-breaker wrapper, **one instance per external dependency** (DB, external API, message bus). Three states (Closed/Open/Half-Open), logging via Pino/structlog (BOO-14), fallback as operator choice (cache / default value / 503 + `Retry-After`).

**Phase 4.4h is OPTIONAL** — not every service needs all four skeletons from day 0. Operator question at the start of the phase:

```
Generate reliability skeleton from BOO-25? (Schrader pillar 6)
  a) yes, all four (SLO + idempotency + retry + circuit breaker)  — recommended for backend with external dependencies
  b) idempotency + SLO only  — minimal write-side service without external dependencies
  c) SLO only  — read-only services; reliability measurement manifest is enough
  d) no  — skip (default for pure frontend / scripts / experimental setups)
```

**Default recommendation per stack:**

| Stack | Default answer | Rationale |
|-------|----------------|-----------|
| Node.js (a/c) | a) all four | backend with side effects, external calls expected |
| Python (d) | a) all four | same |
| Frontend (b) | d) no | no server endpoint, backend handles it |
| Other (e) | c) SLO only | tool-agnostic; the measurement manifest always makes sense |

**Stack defaults per skeleton** (operator can override — record as ADR):

| Stack | Idempotency | Retry | Circuit Breaker | SLO |
|-------|-------------|-------|-----------------|-----|
| Node.js (a/c) | `lib/idempotency.js` + `redis@5.x` | `lib/retry.js` + `p-retry@8.x` | `lib/circuit-breaker.js` + `opossum@9.x` | `docs/SLO.md` |
| Python (d) | `lib/idempotency.py` + `redis>=5.0` | `lib/retry.py` + `tenacity>=9.0` | `lib/circuit-breaker.py` + `pybreaker>=1.0` | `docs/SLO.md` |
| Frontend (b) | not active (backend handles it) | not active | not active | not active |
| Other (e) | operator choice | operator choice | operator choice | `docs/SLO.md` |

> [!important] SLO is an architectural artefact, not a marketing promise
> Whoever writes 99.99% without multi-region or active-passive failover is being dishonest. Default recommendation: 99.9% for single-region (43.8 min downtime/month), 99.95% with failover, 99.99% only with multi-region + chaos tests. Higher is a lie until proven otherwise.

> [!important] Idempotency is for write endpoints only
> Apply on POST / PUT / PATCH / DELETE — not on GET (idempotent per HTTP spec, the layer is overhead). Also not globally for all routes — only where side effects happen (DB writes, external API calls, money movement).

> [!important] One circuit breaker per external dependency, not a global one
> Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate instances with their own thresholds. If the DB is slow, auth must not fail along with it. Tune thresholds per dependency, document them in code.

> [!note] Coupling to the reliability dimension in `architecture-review`
> The reliability dimension in `architecture-review/references/dimensions-detail.en.md` §1 lists these five invariants as mandatory checks. The skeletons created here are the operationalised form of the same invariants — `/architecture-review` holds the `lib/` files and `docs/SLO.md` against the mandatory checks.

> **Issue reference:** BOO-25, Schrader Code Crash ch. 4 §Run the System (pillar 6 reliability). Counterpart to the reliability dimension in `architecture-review/references/dimensions-detail.en.md` §1.

### 4.4i Sensitive-paths configuration (BOO-18)

Ensures that code changes to sensitive paths (auth, payment, PII) trigger a **mandatory human review** — step 5.5 in the `/implement` skill blocks the commit until the operator explicitly approves. Schrader Code Crash ch. 3 §Enterprise Governance.

Operator question:

```
Configure sensitive paths for mandatory human review? (BOO-18)
  a) yes — scaffold `.claude/sensitive-paths.json` with default patterns (recommended for any project with auth/payment/PII)
  b) no — skip (default for purely experimental projects without sensitive data)
```

On `a) yes`:
- Render `.claude/sensitive-paths.json` from `references/file-templates.en.md` §`.claude/sensitive-paths.json (BOO-18)`
- Populate `{{OPERATOR_NAME}}` with the project name or the operator's GitHub handle
- Hint to the operator: extend the pattern list for project-specific sensitive paths (e.g. `src/api/**`, `stripe/**`)
- Commit the file: `git commit -m "chore: .claude/sensitive-paths.json — Mandatory Human Review Patterns (BOO-18)"`

On `b) no`: skip with log entry "BOO-18 human review: disabled".

> **Important:** `.claude/sensitive-paths.json` is NOT added to `.gitignore` — audit-trail requirement. Whoever defines sensitive paths must commit them.

> **Issue reference:** BOO-18, Schrader Code Crash ch. 3 §Enterprise Governance — "Mandatory human review for sensitive areas (authentication, payment, PII)".

### 4.5 Component skeletons (if block C = yes)

For each component from the docs architecture proposal:
- **If Obsidian layer:** `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/{component}.md`
- **If Obsidian skipped:** `{PROJECT_PATH}/docs/components/{component}.md`

Skeleton structure see `references/doc-architecture-proposal.en.md` (frontmatter + purpose + stack + architecture + configuration + phase status + connected stories + open questions + references).

All component docs get registered in `ARCHITECTURE_DESIGN.md §9 References`.

### 4.6 Install governance hooks

See `references/hooks-setup.en.md` for details.

Hooks:
- `spec-gate.sh` — blocks `git commit` with `<PREFIX>XXX` if spec file missing
- `doc-version-sync.sh` — blocks if `lib/config.js` VERSION bumped but DOC_FILES out of sync
- Optional (if block C = yes, orphan-check = yes): `orphan-check.sh` — blocks if a new `*.md` is not registered in the hub §9
- `pre-commit` (BOO-4) — Quality-Gate Layer 2: ESLint + Semgrep with manifest reader. Reads `.semgrep.yml` (BOO-3), extracts active packs via `grep` + `sed`, builds `--config p/...` flags and invokes the Semgrep CLI. Content from `references/file-templates.en.md` §`.git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)`. The mirroring CI Layer 3 (`semgrep.yml` workflow) is created in phase 4.4c — both layers read the same manifest.
- `dependency-check.sh` (BOO-12) — slopsquatting protection: third gate in the pre-commit hook after ESLint and Semgrep. Standalone Bash script under `.claude/hooks/dependency-check.sh` that only runs when `package.json`/`requirements.txt`/`pyproject.toml`/`Cargo.toml` is in the staged diff. Three stages: existence check (404 -> BLOCK, hallucination?), age check (package <30 days old -> warning, typosquatter risk), CVE check (`npm audit` / `pip-audit`, High/Critical -> BLOCK). With BOO-12 the `.git/hooks/pre-commit` hook from BOO-4 gets a fourth invocation at the end: `bash .claude/hooks/dependency-check.sh`. Content from `references/file-templates.en.md` §`hooks/dependency-check.sh (BOO-12 — slopsquatting protection)`. Schrader Code Crash ch. 3-4: 19.7% of AI-recommended packages do not exist.
- `coverage-check.sh` (BOO-15) — diff coverage gate: measures coverage only on NEWLY added lines (`git diff --cached -U0`) against `coverage/coverage-final.json` (c8) or `coverage.json` (pytest-cov). Three thresholds: `>=80%` pass, `60-80%` warning with operator override, `<60%` BLOCK. Standalone Bash script under `.claude/hooks/coverage-check.sh`. **NOT** invoked from the pre-commit hook — tests take too long and would blow the 10s budget. Instead the `/implement` skill calls the hook in step 6a-quart, after the test suite has run with coverage output. Content from `references/file-templates.en.md` §`hooks/coverage-check.sh (BOO-15 — coverage gate >=80% for new code)`. Schrader Code Crash ch. 3 §Production Readiness — Gate 2: test coverage >=80% on new code, not total coverage.

Registration:
```json
// {PROJECT_PATH}/.claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [
        { "type": "command", "command": "bash {PROJECT_PATH}/.claude/hooks/spec-gate.sh" },
        { "type": "command", "command": "bash {PROJECT_PATH}/.claude/hooks/doc-version-sync.sh" }
      ]
    }]
  }
}
```

> **Note:** the Claude Code harness may auto-regenerate `.claude/settings.json` on permission grants and strip hook sections. As a robust fallback: also register hooks in `.claude/settings.local.json` (gitignored).

Hook test (dry run):
```bash
cd {PROJECT_PATH}
echo "test" > test.txt && git add test.txt
git commit -m "test: {ISSUE_PREFIX}1 — should be blocked"
# Expected: governance block
git restore --staged test.txt && rm test.txt
```

### 4.7 Create .env

If `B.5 == yes (exists)`: the operator manages `.env` — the skill only references it.

If `B.5 == no`:
```
I've created .env.example. Please fill your keys into {PROJECT_PATH}/.env.
Variable names are in .env.example.
NEVER name real keys in chat.
```

Wait for confirmation `done` before continuing.

### 4.8 Set up backlog labels

If `B.4 == Linear`: the skill offers to create standard labels via Linear MCP:
- `architecture`, `bug`, `feature`, `refactor`, `docs`, `infra`
- Plus add-on labels: `privacy` (if Privacy activated), `compliance` (if Compliance activated)

If `B.4 == M365 Planner` / `GitHub Issues`: the operator gets the label list to create manually.

If `B.4 == None`: skip.

### 4.9 First git commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Initial Governance Setup"
# Push only if B.2 == yes
git push -u origin main
```

### 4.4j Audit-trail configuration (BOO-19)

Session logging is active by default in Claude Code (`~/.claude/settings.json`). This step ensures the audit-trail mechanism is anchored in the project.

**Steps:**

1. Copy `scripts/audit-trace.sh` from `bootstrapping/bootstrap/scripts/audit-trace.sh` into the project directory:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/audit-trace.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/audit-trace.sh
   ```
2. The `## Session reference` block is already included in the spec template (`specs/TEMPLATE.md`) — no manual step needed.
3. Extend **GOVERNANCE.md** with a `## Audit trail` section:
   ```markdown
   ## Audit trail

   Every `/implement` session automatically writes a session reference into the spec file (BOO-19).
   Reconstruction: `bash .claude/scripts/audit-trace.sh {SPEC_ID}`

   **Retention policy (record as ADR under `docs/domain/adrs/`):**
   - Keep session logs for 90 days
   - Read access: operator only (local `~/.claude/`)
   - Sensitive prompts containing production data: avoid project scope — do not feed into `/implement`
   ```

> **Issue reference:** BOO-19, Schrader "Code Crash" ch. 3 §Enterprise Governance — "Audit trails: every prompt and every change are logged for later reconstruction."

### 4.4k Branch-protection setup (BOO-29)

Prerequisite to ensure no merge into `main` lands without green CI checks. **Runs only when `B.2 == yes`** (GitHub repo created) **and** Phase 4.9 (first git commit + `git push -u origin main`) has already executed — branch protection requires the remote `main` branch to exist.

**Steps:**

1. Copy `scripts/setup-branch-protection.sh` from `bootstrapping/bootstrap/scripts/setup-branch-protection.sh` into the project directory:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/setup-branch-protection.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/setup-branch-protection.sh
   ```

2. Run the script — it reads all `.github/workflows/*.yml` dynamically and builds the `required_status_checks[contexts][]` list from each workflow's first `name:` field:
   ```bash
   cd {PROJECT_PATH}
   bash .claude/scripts/setup-branch-protection.sh
   ```

   Expected detection set depending on active workflows (phase 4.4 + 4.4c + 4.4d + 4.4g + phase 6 D.5):

   | Workflow file (BOO) | Detected context |
   |---------------------|------------------|
   | `eslint.yml` (BOO-28) | `ESLint` |
   | `ruff.yml` (BOO-28) | `Ruff` |
   | `semgrep.yml` (BOO-4) | `Semgrep` |
   | `tests.yml` / `coverage.yml` (BOO-15) | `Tests` / `Coverage` |
   | `perf.yml` (BOO-16) | `Perf` |
   | `sonar.yml` (BOO-5/D.5) | `SonarQube` (or `SonarCloud` depending on workflow) |

   Workflows that do not exist are simply omitted from `contexts[]` — the script does not hard-fail, it logs the detected workflows in `[INFO]` lines.

3. Internally the script calls (1:1 from BOO-29):
   ```bash
   gh api -X PUT "repos/${OWNER}/${REPO}/branches/main/protection" \
     -F required_status_checks[strict]=true \
     -F required_status_checks[contexts][]=<dynamic> \
     -F enforce_admins=false \
     -F required_pull_request_reviews[dismiss_stale_reviews]=true \
     -F required_pull_request_reviews[required_approving_review_count]=1 \
     -F restrictions=null \
     -F allow_force_pushes=false
   ```

   Idempotent — the PUT call is a replace, so re-runs are safe. Repeated execution overwrites the protection identically.

4. **Prerequisites the script checks itself (with operator message on failure):**
   - `gh --version` (CLI installed?)
   - `gh auth status` (logged in with `repo` scope?)
   - `git remote get-url origin` (remote present?)
   - Remote `main` branch exists (`gh api repos/<owner>/<repo>/branches/main`)

   On failure the script logs the next step clearly (e.g. `gh auth login`, `git push -u origin main`) — no silent fail.

5. Verify in the GitHub UI: `https://github.com/<owner>/<repo>/settings/branches` — protection rule should be active with the detected checks.

6. Open a test PR without green checks — the merge must be blocked.

If `B.2 == no/c` (no GitHub wanted): skip phase 4.4k completely — branch protection is GitHub-specific and has no equivalent on local or self-hosted setups without GitHub.

> **Issue reference:** BOO-29. Source: `scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12). Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-29.

### 4.4l Linear workflow states + GitHub integration (BOO-30, manual operator step)

**Run only when `B.4 == Linear`** (backlog tool is Linear). Skip for `M365 Planner` / `GitHub Issues` / `None`.

**Clear separation:**
- **Automated (by /bootstrap):** Issue template is rendered in phase 4.3 with mandatory DoD section (see above). DoD checklist lives in `.claude/ISSUE_WRITING_GUIDELINES.md` v3.1 and is anchored in the issue template `.github/ISSUE_TEMPLATE/story.yml` via `migrate_boo_27()`.
- **Manual per project (operator task):** Create Linear workflow states + activate the GitHub integration in Linear. The Linear API could automate this, but the effort/benefit ratio is poor (one-off setup per project, the Linear UI is well-guided) — deliberate decision.

**Operator instructions:** full step-by-step guide in HANDBOOK §8g Linear setup per project. The skill only lists the checkpoint here.

**Workflow states (1:1 from BOO-30):**

| State | Meaning | Auto transition |
|---|---|---|
| Backlog | Triage | initial |
| In Progress | Skill working, local gates iterating | manual |
| In Review | PR open, CI running | auto on PR open |
| QA Failed | CI red, story re-opened | manual or webhook |
| Done | PR merged, all checks green | auto on PR merge |
| Cancelled | Discarded | manual |

**GitHub integration (manual inside the Linear team):**
1. Linear → Settings → Integrations → GitHub → Connect Repository → select the project repo.
2. Auto-recognition kicks in immediately for:
   - branch names with `{ISSUE_PREFIX}-XX` prefix (e.g. `BOO-30-feature-foo`)
   - PR titles with `{ISSUE_PREFIX}-XX`
   - commit messages with `{ISSUE_PREFIX}-XX`
   - PR body with `Closes {ISSUE_PREFIX}-XX`
3. PR-open transitions issue → `In Review`, merge transitions issue → `Done`.

**Operator checkpoint:**
- [ ] 6 workflow states created in the Linear team (exact names: `Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`)
- [ ] GitHub integration connected to the project repo
- [ ] Test story with branch `{ISSUE_PREFIX}-XX-test` created — PR open transitions the issue to `In Review`

> **Issue reference:** BOO-30. Source: `references/issue-writing-guidelines-template.md` v3.1 + HANDBOOK §8g. Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-30 (issue-template extension is auto-applied, Linear setup remains manual).

### Phase 4.10: Domain Deep Research (MANDATORY)

**Purpose:** persist domain knowledge before stories get written. AI operator teams have no distributed subject-matter team knowledge — this step compensates systematically (Schrader ch. 2 §Differentiation crisis).

**Steps:**

1. Ask the operator: "Which industry / which subject-matter domain context applies to this project?"
2. Invoke `/research` with the project topic — DEEP mode:
   - Domain terminology + glossary
   - Regulation (GDPR/BDSG/nDSG, PSD2, MiFID, HIPAA — depending on industry)
   - User personas + stakeholders
   - Industry metrics + KPIs
   - Competitors + market standards
3. Write the output to `Research/Domain-Overview.md` (frontmatter: `source: claude`, `type: domain-research`)
4. Create the `docs/domain/` folder with a `README.md` skeleton:

```markdown
# Domain Context

Curated key terms for [project name]. One term per file under `docs/domain/`.
Format: 1 file per key term, <30 lines, examples + counter-examples.

## Known terms
<!-- Extended during /ideation and /implement -->

| Term | File | Description |
|------|------|-------------|
```

5. For each key term from the research, create its own file: `docs/domain/{term}.md`
   Template per term file:
   ```markdown
   # {Term}

   **Definition:** [1–2 sentences]

   **Example:** [concrete real-world example]

   **Counter-example / delimitation:** [what it is NOT]

   **Regulation:** [if relevant — norm/law + core obligation]
   ```

**Not optional.** Even if the operator says "I know the industry": the research step costs 5–10 min and saves hours of story rework later from missing subject-matter vocabulary.

Phase 4 checkpoint: summary of files created.

---

## Phase 5: Install skills

Read `references/skills-setup.en.md` for details.

Skills are fetched from the official GitHub repo via `git clone` into a temp folder and copied into `{PROJECT_PATH}/.claude/skills/`.

```bash
# Temp folder for skill source
SKILL_SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vibercoder79/claudecodeskills "$SKILL_SRC"
```

### Repo structure

The `claudecodeskills` repo groups skills in two areas:

- **`$SKILL_SRC/bootstrapping/<skill>/`** — governance sub-skills (architecture-review, backlog, cloud-system-engineer, grafana, ideation, implement, sprint-review, visualize)
- **`$SKILL_SRC/<skill>/`** — standalone top-level skills (design-md-generator, research, security-architect, setup-checklist, skill-creator, among others)

### Skill selection

```
Which skills to install?
  a) Minimum (ideation, implement, backlog)
  b) Standard (+ architecture-review, sprint-review, research, security-architect, skill-creator, setup-checklist)
  c) Full (all available: + grafana, cloud-system-engineer, visualize, design-md-generator)
  d) Manual selection
```

### Copy

The copy logic needs to know if a skill lives under `bootstrapping/` or top-level:

```bash
# Skills located under bootstrapping/ in the claudecodeskills repo
BOOTSTRAPPING_SUBSKILLS="architecture-review backlog cloud-system-engineer grafana ideation implement sprint-review visualize"

for skill in $SELECTED_SKILLS; do
  if echo "$BOOTSTRAPPING_SUBSKILLS" | grep -qw "$skill"; then
    SRC_PATH="$SKILL_SRC/bootstrapping/$skill"
  else
    SRC_PATH="$SKILL_SRC/$skill"
  fi
  cp -R "$SRC_PATH" "{PROJECT_PATH}/.claude/skills/$skill"
done
```

Result: all skills land **flat** in `.claude/skills/<skill>/` — the `bootstrapping/` nesting only exists in the repo, not in the installation.

### Project-specific adjustments (generic, not trading-specific)

- `.claude/ISSUE_WRITING_GUIDELINES.md` is rendered from `references/issue-writing-guidelines-template.md` (issue prefix substituted)
- `implement/references/change-checklist.md` contains generic change types — no project-specific adjustment needed. Project-specific specialist checklists can later be packaged via `/skill-creator`.

### Cleanup

```bash
rm -rf "$SKILL_SRC"
```

Phase 5 checkpoint: list the installed skills.

---

## Phase 6: Block D — Optional components

Read `references/optional-components.en.md` for implementation details.

> **Operator note (BOO-30):** Block D is the right place to finalize the manual Linear setup from phase 4.4l — create workflow states + activate the GitHub integration — before the first stories are produced via `/ideation`. Issue-template rendering itself is already automated in phase 4.3 (mandatory DoD section). Full operator guide: HANDBOOK §8g Linear setup per project.

Ask each question individually with a clear recommendation and default:

### D.1 Self-healing agent

```
Set up self-healing agent?
(Cron every 15 min: checks doc versions, file integrity, sends alerts)

Recommended: from multiple contributors on, or when docs drift is critical.
[yes / no (default)]
```

On `yes`: render `agents/self-healing.js` from `references/self-healing-template.js` + generate cron entry.

### D.2 DocSync to the Obsidian vault

```
DocSync to the Obsidian vault?
(On every /implement, component docs in the vault are also updated)

No cron — runs as manual trigger via implement-skill T_last.
Recommended if an Obsidian vault is configured.
[yes (default if vault set) / no]
```

On `yes`: render `lib/doc-sync.js` from `references/doc-sync-template.js` + mapping repo → vault.

### D.3 Automation daemon (Linear webhook listener)

```
Automation daemon?
(Fully automatic story execution without operator approval — Linear webhook triggers /implement)

Only for advanced setups with Linear. Mind the security implications.
[yes / no (default)]
```

On `yes`: setup steps for Linear webhook + daemon.

### D.4 Learning-loop level

Read `references/learning-loop.en.md` for the full design.

```
Activate learning loop?
The loop systematically captures: what worked, what didn't, next experiments.
Trigger: /sprint-review. Storage: journal/ + optional Obsidian.

  L1 — Simple       (learnings.md, bullets — recommended for solo projects)
  L2 — Structured   (sprint journal with frontmatter — recommended from 10+ sprints)
  L3 — SQLite       (quantitative metrics — recommended from 50+ sprints)
  no                (no lessons-learned documentation)

Default: L1. Which level?
```

If `L1/L2/L3` selected:
- Create `journal/` structure accordingly
- `.learning-loop` config in the repo (stores the level)
- If Obsidian active: `04 Ressourcen/{PROJECT_NAME}/learnings.md` as a cross-link from the PMO hub

The learning loop is fed by `sprint-review` (mandatory step at the end of the review) and read by `ideation` during story creation (anti-pattern warning).

### D.5 SonarQube Cloud

```
Activate SonarQube Cloud?
(Code-quality dashboard: bugs, smells, security hotspots, coverage trends after every push)

Cost: public repos free. Private repos from ~10 EUR/month.
[Mac] Local: SonarLint VS Code connected mode.
[VPS] CI gate only — no IDE plugin.

[yes] Skill generates sonar-project.properties + .github/workflows/sonar.yml
[no] (default) — can be added later
```

On `yes`: read `references/optional-components.en.md §D.5` for implementation details including the verify step.
On `no`: `tools_available.sonarqube_cloud = false` in `.claude/environment.json`.

### D.6 Self-hosted runner (BOO-46, only when the performance gate is active)

If `STACK_CHOICE` has a backend share (`a`, `c`, `d`) AND BOO-16's performance gate is active:

```
Activate a self-hosted runner for performance tests?
  (Follow-up to BOO-16. GitHub-hosted runners carry ±30%% variance, hence
   BOO-16's default 20%% threshold. A self-hosted runner with reserved
   resources cuts variance to ~5%% — the threshold can then tighten to 10%%.)

  Cost: a Hostinger VPS sidecar or a dedicated Mac mini.
  Effort: install runner software (step-by-step in HANDBUCH Appendix I).

  [yes] HANDBUCH §Self-hosted runner setup with step-by-step + migrate_boo_46() tightens perf.yml
  [no] (default) — GitHub-hosted stays active, threshold stays at 20%%
```

On `yes`: pure HANDBUCH pointers (no auto-setup, because VPS installation is operator territory). `migrate_boo_46()` patches `perf.yml` later (`runs-on: ubuntu-latest` -> `self-hosted`, threshold 1.20 -> 1.10) once the operator has installed the runner.
On `no`: no entry in `environment.json`, no perf.yml patch.

Phase 6 checkpoint: optional-components status (D.1–D.6).

---

## Phase 7: Finalization

Read `references/global-registry-update.en.md` for the exact path list.

### 7.1 SecondBrain integration (if B.3 == Obsidian active)

- Create `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/`
- `{PROJECT_NAME} - PMO HUB.md` with project frontmatter, phase table, backlog link, references block
- Create `Components/`, `Decisions/`, `Meetings/`, `Research/` folders
- `Architektur-Vorgaben.md` skeleton (populated by /ideation during research consolidation)
- Entry in `{OBSIDIAN_VAULT}/00 Kontext/Projekte.md` (project index)

### 7.2 Global registry (~/.claude/)

If the operator has a project table in `~/.claude/CLAUDE.md`:
- Add the project row (name, path, GitHub, Obsidian path, sprint-review frequency)
- The skill presents the row; the operator confirms the insertion point

### 7.3 Final commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Complete Governance Bootstrap"
git push  # only if B.2 == yes
```

### 7.4 Closing table

| Phase | What | Status |
|-------|------|--------|
| Block A | Project core + stack + add-ons | done |
| Block B | Existing infrastructure | done |
| Block C | Docs architecture (3 layers + hub) | done |
| Phase 4 | Base structure (files, git, linting, hooks, labels) | done |
| Phase 5 | Skills installed ({skill_count}) | done |
| Block D | Optional components | {D-status} |
| Phase 7 | SecondBrain + registry + final commit | done |

### 7.5 VS Code extensions (optional, based on STACK_CHOICE)

**For all stacks:**
- ESLint `dbaeumer.vscode-eslint`
- SonarLint `SonarSource.sonarlint-vscode`
- Error Lens `usernamehw.errorlens`
- Claude Code `anthropic.claude-code`

**Node.js:** REST Client `humao.rest-client`

**Frontend / Full-stack:** Prettier `esbenp.prettier-vscode`, Auto Rename Tag `formulahendry.auto-rename-tag`, CSS Peek `pranaygp.vscode-css-peek`

**Python:** Python `ms-python.python`, Black Formatter `ms-python.black-formatter`, Ruff `charliermarsh.ruff`

### 7.6 Next steps

```
Bootstrap done. Continue with:

  1. Install VS Code extensions (list above)
  2. cd {PROJECT_PATH} && claude
  3. /ideation — create your first story
  4. If learning loop active: run /sprint-review after 1–2 sprints
```

---

## Error handling

| Problem | Solution |
|---------|----------|
| git push fails | Check SSH key: `ssh -T git@github.com` |
| Linear API error | Check Linear API key in .env, validate team slug |
| Obsidian path unreachable | Verify path with `ls`, check if iCloud sync is active |
| Hook blocks commit | Create spec file from `specs/TEMPLATE.md`, fill agent pattern |
| doc-version-sync blocks | Update all DOC_FILES to the new VERSION, then `git add` |
| Harness strips hooks from settings.json | Register hooks additionally in `.claude/settings.local.json` (gitignored) as fallback |
| Component doc missing after /implement | Check T_last task in specs/TEMPLATE.md — must include component update |
| Learning-loop entry forgotten | Call /sprint-review again, run step 7 |
