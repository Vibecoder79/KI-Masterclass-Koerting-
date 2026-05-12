# Migration Checklist Governance v1 → v2

This checklist guides existing projects with Governance v1 through a systematic upgrade to v2. Apply once a project targets v2 conformance. Reading order: one block per BOO issue with steps, test, rollback and dependencies; phases mirror the PMO hub structure.

**Growth note:** This file grows alongside the rollout. Every BOO issue that touches the skill or project config completes its block (or replaces placeholders with the final steps) once it reaches Done.

**Status legend:** ☐ pending | ✓ done | ✗ n/a | ⏸ blocked
**Effort legend:** small (<30 min) | medium (<2h) | large (<1 day)

**Sister file (German):** [`migration-checklist-v1-to-v2.md`](./migration-checklist-v1-to-v2.md)
**Companion script for deterministic auto steps:** [`../scripts/migrate-to-v2.sh`](../scripts/migrate-to-v2.sh)

---

## Per-Project Tracking

Each existing project gets its own `migration-status.md` in the repo root, mirroring this master checklist with project-specific status. The master checklist is the **plan**; each project's `migration-status.md` is the **state**. That keeps it traceable which BOO issue has landed in which project.

Workflow:

1. Walk the master checklist phase by phase.
2. Per step in the project: execute, test, flip status to ✓ in `migration-status.md`, record date and notes.
3. For `<filled in once BOO-N is Done>` placeholders: wait until BOO-N ships, then re-pull the master checklist.

Copy template below.

## Copy Template migration-status.md

```markdown
---
project: <name>
started: 2026-MM-DD
governance-baseline: v1
governance-target: v2
operator: <handle>
---

# Migration Status <Project>

Mirror of the master checklist in `bootstrapping/bootstrap/references/migration-checklist-v1-to-v2.md`. Maintain status here, not in the master.

| BOO  | Title                                               | Status | Date       | Notes                    |
| ---- | --------------------------------------------------- | ------ | ---------- | ------------------------ |
| BOO-1  | Build /intent skill                               | ☐      |            |                          |
| BOO-2  | Harden ESLint ruleset                             | ☐      |            |                          |
| BOO-3  | .semgrep.yml auto-setup                           | ☐      |            |                          |
| BOO-4  | Semgrep as pre-commit gate                        | ☐      |            |                          |
| BOO-5  | SonarQube Cloud auto-setup                        | ☐      |            |                          |
| BOO-6  | SonarQube API in /architecture-review + /sprint-review | ✓      | git pull   | see §BOO-6 |
| BOO-7  | AI-readiness checklist                            | ☐      |            |                          |
| BOO-8  | Testability as 7th standard dimension             | ☐      |            |                          |
| BOO-10 | Intent propagation                                | ☐      |            |                          |
| BOO-11 | Issue writing guidelines                          | ☐      |            |                          |
| BOO-12 | Slopsquatting check pre-commit                    | ☐      |            |                          |
| BOO-13 | Scalability with 4 invariants                     | ☐      |            |                          |
| BOO-14 | Observability skeleton                            | ☐      |            |                          |
| BOO-15 | Coverage gate >=80% new code                      | ☐      |            |                          |
| BOO-16 | Performance baseline gate                         | ☐      |            |                          |
| BOO-17 | Feature flag convention                           | ☐      |            |                          |
| BOO-18 | Sensitive paths human review                      | ☐      |            |                          |
| BOO-19 | Prompt audit trail                                | ☐      |            |                          |
| BOO-20 | HANDBOOK Schrader appendix                        | ✗      | n/a        | skill only, no migration   |
| BOO-21 | Domain knowledge in project                       | ☐      |            |                          |
| BOO-24 | 4 AI architecture principles mandatory block      | ☐      |            |                          |
| BOO-25 | Reliability as architecture dimension             | ☐      |            |                          |
| BOO-26 | Anti-pattern catalogue                            | ☐      |            |                          |
| BOO-27 | Issue template mandatory fields                   | ☐      |            |                          |
| BOO-28 | ESLint as GitHub Action                           | ☐      |            |                          |
| BOO-29 | Branch protection required status checks          | ☐      |            |                          |
| BOO-31 | Hermes frontmatter block                          | ✓      | git pull   | see §BOO-31 + HANDBUCH Appendix D |
| BOO-32 | CI output standardisation Hermes                  | ✓      | partial    | see §BOO-32 + HANDBUCH Appendix E |
| BOO-33 | Hermes setup guide                                | ✗      | n/a        | skill only, no migration   |
| BOO-34 | .claude/environment.json                          | ☐      |            |                          |
| BOO-35 | ARCHITECTURE_DESIGN freshness pre-flight          | ☐      |            |                          |
| BOO-36 | journal/reports/local/ persistence                | ☐      |            |                          |
| BOO-37 | /pitch skill                                      | ✓      | partial    | see §BOO-37 + HANDBUCH Appendix L |
| BOO-45 | Lighthouse-CI frontend performance                | ✓      | migrate_boo_45 | see §BOO-45 + HANDBUCH Appendix H |
| BOO-46 | Self-hosted runner + 10% threshold                | ✓      | partial    | see §BOO-46 + HANDBUCH Appendix I |
| BOO-49 | Framework tool-independence (docs)                | ✓      | git pull   | see §BOO-49 + CONVENTIONS.md + HANDBUCH Appendix K |
| BOO-38 | Sprint sizing convention                          | ✓      | manual     | see §BOO-38 + HANDBUCH Appendix G |
| BOO-39 | Token heuristics /ideation                        | ✓      | git pull   | see §BOO-39 + token-heuristik.md |
| BOO-40 | Token window pre-flight /implement                | ✓      | git pull   | see §BOO-40 + HANDBUCH Appendix G |
```

---

## Phase 1 — Foundation

### BOO-1 — Build /intent skill (Schrader Ch. 4)

**Status:** ☐ pending
**Effort:** small-medium (skill itself is available in `bootstrapping/intent/` since 2026-05-01 — per existing project only the `intents/` folder needs to be added)
**Linear:** https://linear.app/owlist/issue/BOO-1
**Auto step:** yes (steps 1-3 automated, idempotent)
**Steps:**
0. From the existing project root run: `bash <path-to-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-1` — performs steps 1-3 automatically.
1. Create `intents/` directory in the repo root (storage for one intent file per initiative).
2. Create `intents/.gitkeep` so the directory persists in the repo.
3. Add `intents/README.md` describing the `/intent` skill and the file convention `intents/INTENT-XX.md` + parallel `INTENT-XX.validation.md`.
4. **Manual:** check whether a legacy `docs/intent.md` or similar notes exist; if so, migrate them to `intents/legacy.md` with a pointer to the new convention.
5. **Manual:** make the skill available — either via a `/bootstrap` update (phase 5 pulls all sub-skills) or by copying `bootstrapping/intent/` to `~/.claude/skills/intent/` or `<project>/.claude/skills/intent/`.
6. **Test:** `ls intents/ && cat intents/README.md` → directory and README exist. Trigger `/intent` works inside the project.

**Rollback:** `rm -rf intents/`, restore `docs/intent.md` from git history if needed.
**Dependencies:** none

### BOO-2 — Harden ESLint ruleset (Airbnb + security + sonarjs)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-2
**Auto step:** partial (npm install + config display can be automated; file replacement is intentionally manual to allow for house-rule overrides)
**Steps:**
1. **Auto preparation:** From the project root run `bash <path-to-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-2` — installs the npm packages (Node projects) or shows the operator hint for Python.
2. **Node.js / full-stack:** `npm install --save-dev eslint @eslint/js eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat` (with React: use `eslint-config-airbnb` instead of `-base`).
3. **Node.js:** copy `eslint.config.mjs` from the updated `bootstrap/references/file-templates.md` §eslint.config.mjs (4-layer stack: recommended + Airbnb + security + SonarJS + house rules).
4. **Python:** copy the `[tool.ruff.lint]` block from `file-templates.md` §pyproject.toml — `select` includes `S` (flake8-bandit), `B` (bugbear), `C4` (comprehensions). Plus `[tool.ruff.lint.per-file-ignores]` for tests/migrations.
5. **Manual:** initial run of `npx eslint . --max-warnings 0` resp. `ruff check .` — findings are expected (legacy code is not suddenly industry-standard-conformant). Operator decides: (a) let `/implement` iterate declaratively until green, (b) plan a separate "lint cleanup" story, or (c) selectively suppress rules per `// eslint-disable-next-line` with justification.
6. **Test:** `npx eslint --version && npx eslint -c eslint.config.mjs --print-config <one-test-file>.js | head` shows loaded configs (recommended, Airbnb, security, SonarJS visible). Python: `ruff check --show-settings | grep -E "select|S|B|C4"`.

**Rollback:** uninstall packages (`npm uninstall eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat`), restore `eslint.config.mjs` and `pyproject.toml` from git history.
**Dependencies:** none
**Skill source:** `bootstrapping/bootstrap/references/file-templates.md` §eslint.config.mjs + §pyproject.toml (BOO-2 v3.2.2, 2026-05-01) — and `bootstrapping/implement/SKILL.md` §Step 6a for the declarative iteration loop.

---

## Phase 2 — Production Readiness (Security + Coverage)

### BOO-3 — /bootstrap: .semgrep.yml auto-setup

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-3
**Auto step:** yes (language-aware)
**Steps:**
1. **Auto preparation:** From the project root run `bash <path-to-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-3` — creates `.semgrep.yml` and `.semgrepignore` with a language-detected default ruleset. Idempotent — existing files are not overwritten.
2. **Auto:** `.semgrep.yml` contains three layers:
   - **Layer 1 (mandatory, all stacks):** `p/security-audit`, `p/secrets`
   - **Layer 2 (language-specific, auto-detected):** `p/javascript` active if `package.json` is present, `p/python` active if `pyproject.toml` is present
   - **Layer 3 (commented out):** `p/owasp-top-ten` — operator decides per web project manually
3. **Auto:** `.semgrepignore` with standard excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`).
4. **Requirement:** Semgrep CLI installed (`brew install semgrep` or `pip install semgrep`). For an active `pyproject.toml` you may install via venv: `pip install semgrep`.
5. **Test (validate):** `semgrep --config=.semgrep.yml --validate` — exit 0, manifest is YAML-conformant.
6. **Note (manifest, not native config):** `.semgrep.yml` is a manifest file — running `semgrep --config=.semgrep.yml --error` directly yields "No config given" and is expected. Pack loading comes in BOO-4 (pre-commit hook reads the manifest and builds `--config p/...` flags). Until then run manually: `semgrep --config p/security-audit --config p/secrets [...]`.
7. **Manual (web project):** For web frontend / REST API / GraphQL uncomment `p/owasp-top-ten` in `.semgrep.yml` (Layer 3).

**Rollback:** delete `.semgrep.yml` and `.semgrepignore`.
**Dependencies:** none
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §.semgrep.yml + §.semgrepignore (BOO-3 v3.2.3, 2026-05-06) — and `bootstrapping/bootstrap/SKILL.en.md` §4.4b for the bootstrap flow of new projects.

### BOO-4 — /implement step 6a-bis: Semgrep as second gate (pre-commit + CI)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-4
**Auto step:** yes
**Steps:**
1. **Auto preparation:** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-4` — installs the pre-commit hook in `.git/hooks/pre-commit` (with manifest reader for ESLint and Semgrep) and creates the GitHub Action `.github/workflows/semgrep.yml`. Idempotent — existing hooks/workflows are not overwritten.
2. **Requirement:** Semgrep CLI installed (`brew install semgrep` on Mac, `pip install semgrep` on Linux). For VPS, auto-install lands in BOO-44.
3. **Requirement:** `.semgrep.yml` from BOO-3 in place with at least Layer 1 (`p/security-audit`, `p/secrets`).
4. **Test 1 (hook syntax):** `bash -n .git/hooks/pre-commit` — exit 0.
5. **Test 2 (manifest reader):** `grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//'` — lists active packs.
6. **Test 3 (hook runnable):** `git commit --allow-empty -m "test pre-commit"` — hook runs without crashing. With `eslint.config.mjs`/`pyproject.toml` present the gates activate.
7. **Test 4 (workflow syntax):** `cat .github/workflows/semgrep.yml | head -5` — YAML-conformant, `name:` and `on:` present.
8. **Manual (optional):** enable branch protection in GitHub — required status check "Semgrep" (see BOO-29).

**Rollback:** delete `.git/hooks/pre-commit` and `.github/workflows/semgrep.yml`.
**Dependencies:** BOO-3 (Semgrep manifest must exist)
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §.git/hooks/pre-commit + §.github/workflows/semgrep.yml (BOO-4 v3.2.4, 2026-05-06) — and `bootstrapping/implement/SKILL.en.md` §step 6a-bis for the iteration loop.

### BOO-5 — /bootstrap: SonarQube Cloud auto-setup

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-5
**Auto step:** partial
**Steps:**
1. **[MANUAL]** Operator: verify SonarCloud account, ensure org is `owlist`.
2. **[MANUAL]** Operator: create the project in SonarCloud, store `SONAR_TOKEN` in GitHub secrets.
3. Create `sonar-project.properties` in the repo root (auto, content from `bootstrap/references/file-templates.md`).
4. Create `.github/workflows/sonarcloud.yml` (auto, content from `file-templates.md`).
5. **Test:** push a branch → action turns green, SonarCloud dashboard shows the first analysis.

**Rollback:** delete the workflow file and `sonar-project.properties`, remove the secret.
**Dependencies:** none

### BOO-6 — /architecture-review + /sprint-review: read SonarQube Cloud API

**Status:** ✓ included in v2 skill source (skill code with graceful fallback)
**Effort:** small (operator side: git pull; `SONAR_TOKEN` may already exist from BOO-5)
**Linear:** https://linear.app/owlist/issue/BOO-6
**Auto step:** yes (included in the skill update)
**Steps:**
1. **`[AUTO]`** Pull skills again: `cd ~/.claude/skills && git pull origin main`. `/architecture-review` v1.10.0 has the new "SonarQube Cloud API read block" (security hotspots, technical-debt ratio, reliability/maintainability rating). `/sprint-review` v2.3.0 has the new step 2b "reports aggregation + metrics" (SonarQube API + local reports + CI reports + L3 DB).
2. **`[AUTO/precondition]`** `SONAR_TOKEN` must be available as a GitHub secret or in `.env` — already set up by the BOO-5 migration. If missing: skills run with a graceful-skip note "SonarQube Cloud not configured — metrics unavailable", no error.
3. **`[MANUAL]`** Optional: verify `sonar-project.properties` has `sonar.projectKey` and `sonar.organization` (`grep -E "sonar.(projectKey|organization)" sonar-project.properties`) — the skill reads these for the API call.

**Test:**
- Run `/architecture-review` on a project with active SonarQube → review table has a new "SonarQube" column with hotspot count + debt ratio + reliability/security rating.
- Run `/sprint-review` → sprint-file frontmatter contains `metrics.sonarqube_hotspots_new` + `metrics.sonarqube_hotspots_resolved` + `metrics.coverage_trend`.
- Without `SONAR_TOKEN`: both skills run without the SonarQube block, emit `[!info] SonarQube block skipped`.

**Rollback:** revert skills to v1.9.0 / v2.2.0 (`git checkout <pre-boo6-commit> -- architecture-review/ sprint-review/`). Effect: no SonarQube read block, reviews run without these metrics.
**Dependencies:** BOO-5 (SonarQube Cloud setup + sonar-project.properties + SONAR_TOKEN). Also uses BOO-32 (`journal/reports/ci/` convention) and BOO-36 (`journal/reports/local/` convention) for the extended sprint-review aggregation.
**Skill source:** `bootstrapping/architecture-review/SKILL.en.md` §SonarQube Cloud API read block + `bootstrapping/sprint-review/SKILL.en.md` §Step 2b.

### BOO-12 — Dependency + hallucination check pre-commit (slopsquatting protection)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-12
**Auto step:** yes
**Steps:**
1. **Auto preparation:** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-12` — creates `.claude/hooks/dependency-check.sh`, makes it executable, and extends the pre-commit hook (BOO-4) with the invocation after Semgrep. Idempotent.
2. **Requirement:** `curl` is standard. Optional: `npm` (Node project — for existence/age/CVE), `pip-audit` (Python — for CVE).
3. **Requirement:** Pre-commit hook from BOO-4 in place — otherwise exit with a hint.
4. **Test 1 (script syntax):** `bash -n .claude/hooks/dependency-check.sh` — exit 0.
5. **Test 2 (trigger logic):** invoke the hook without a manifest diff — immediate exit 0 (performance).
6. **Test 3 (hallucination block):** stage a test commit with `react-totally-not-malware-3000` in `package.json` — the gate must block with "package does not exist — hallucination?".
7. **Test 4 (age warning):** optional, with a fresh package (<30 days) — output shows the warning.
8. **Test 5 (CVE block):** optional, with a deliberately outdated dependency version carrying a High/Critical CVE.

**Rollback:** delete `.claude/hooks/dependency-check.sh`, remove the invocation line from the pre-commit hook (`.git/hooks/pre-commit`).
**Dependencies:** BOO-4 (pre-commit hook infrastructure)
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §hooks/dependency-check.sh (BOO-12 v3.2.5, 2026-05-06) — and `bootstrapping/implement/SKILL.en.md` §step 6a-tris for the workflow tie-in.

### BOO-15 — /implement coverage gate (>=80% for new code)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-15
**Auto step:** yes
**Steps:**
1. **Auto preparation:** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-15` — creates `.claude/hooks/coverage-check.sh` and makes it executable.
2. **Requirement:** test tooling installed.
   - **Node:** `npm install --save-dev c8` (if missing), test script runs with `npx c8 --reporter=json npm test`.
   - **Python:** `pytest-cov` as a test dependency, run with `pytest --cov --cov-report=json`.
3. **Requirement:** `python3` available (for JSON parsing). Standard on Mac/Linux.
4. **Test 1 (script syntax):** `bash -n .claude/hooks/coverage-check.sh` — exit 0.
5. **Test 2 (skip without coverage data):** invoke the hook with no `coverage.json` — exit 0 with the "no coverage data" hint.
6. **Test 3 (skip without diff):** with `coverage.json` but no staged diff — exit 0 with the "no newly added lines" hint.
7. **Test 4 (real run):** run the test suite with coverage, stage a new function without tests, then invoke the hook → BLOCK at <60% coverage.
8. **Manual:** `/implement` step 6a-quart calls the hook automatically through the skill. The operator can run it manually with `bash .claude/hooks/coverage-check.sh`.

**Rollback:** delete `.claude/hooks/coverage-check.sh`.
**Dependencies:** none (runs independently of the BOO-4 hook)
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §hooks/coverage-check.sh (BOO-15 v3.2.6, 2026-05-06) — and `bootstrapping/implement/SKILL.en.md` §step 6a-quart for the workflow tie-in.

### BOO-27 — Issue template: 4 Schrader prompt components as mandatory fields + pre-flight check

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-27
**Auto step:** yes (GitHub issue template)
**Steps:**
1. `[AUTO]` `.github/ISSUE_TEMPLATE/story.yml` is created with 4 mandatory fields (Insight / Constraints / Success Criteria / Desired Outcome) + execution mode dropdown + DoD checklist. Idempotent — existing file is skipped.
2. `[MANUAL]` `/implement` now has a HARD GATE at Step 1b since BOO-27: existing Linear issues must contain all 4 Schrader prompt components (each min. 20 chars) before `/implement` can run. Review open backlog issues and fill in any missing components.
3. `[MANUAL]` Optional: add the following rule to the project's `CLAUDE.md`:
   ```
   Every Linear issue must contain all 4 Schrader prompt components
   (Insight / Constraints / Success Criteria / Desired Outcome).
   /implement blocks at Step 1b if any are missing.
   ```

**Test:** `test -f .github/ISSUE_TEMPLATE/story.yml && echo 'OK' || echo 'MISSING'`
**Rollback:** delete `.github/ISSUE_TEMPLATE/story.yml`.
**Dependencies:** none

**Skill source:** `bootstrapping/bootstrap/references/issue-writing-guidelines-template.md` v3.0 (BOO-27) + `bootstrapping/implement/SKILL.md` v2.1.0 §Step 1b for the HARD GATE.

### BOO-28 — /bootstrap: ESLint as GitHub Action (CI gate)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-28
**Auto step:** yes (files dropped by `migrate_boo_28()`, stack detection automatic)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-28` — drops stack-dependent workflow file(s):
   - **Node stack** (`package.json` present) → `.github/workflows/eslint.yml`. Workflow runs `npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif` and uploads the SARIF via `github/codeql-action/upload-sarif@v3` into the GitHub Security tab. SARIF output is mandatory — read by BOO-32 (CI output standardisation) for Hermes consumption.
   - **Python stack** (`pyproject.toml` OR `requirements.txt` present) → `.github/workflows/ruff.yml`. Workflow runs `ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif` and uploads similarly.
   - **Mixed stack** (both manifest files present) → both workflows in parallel.
   - **Unknown stack** (no manifest file) → `log_warn` + hint, no workflow created.

   Existing workflow files are `[SKIP]`ped — `--force` overwrites. `.ci-reports/` is idempotently appended to `.gitignore`.
2. **`[AUTO]`** (Node stack only) — If `jq` is present: `migrate_boo_28()` appends `"@microsoft/eslint-formatter-sarif": "^3.1.0"` to `package.json` devDependencies (prerequisite for the `--format=@microsoft/eslint-formatter-sarif` flag).
3. **`[MANUAL]`** (Node stack only, when jq is missing or for operator verification): run `npm install --save-dev @microsoft/eslint-formatter-sarif` — verifies that the SARIF formatter ends up under `node_modules/`.
4. **`[MANUAL]`** Operator: wait for the first CI run (push to main or PR open) — a green `ESLint` (or `Ruff` for Python) check should appear.
5. **`[MANUAL]`** Operator: verify the SARIF upload in the GitHub Security tab (`Settings -> Security -> Code scanning alerts`) — findings land there and appear inline in the PR.
6. **`[MANUAL]`** After BOO-28 is done, enable branch protection in BOO-29 with required status check `ESLint` (or `Ruff` for Python).

**Test:**
- `ls .github/workflows/eslint.yml` (Node) or `ls .github/workflows/ruff.yml` (Python) → present.
- `grep -F '.ci-reports/' .gitignore` → entry present.
- (Node) `jq '.devDependencies."@microsoft/eslint-formatter-sarif"' package.json` → `"^3.1.0"` (or higher).
- Open a PR → workflow runs, SARIF upload appears in the Security tab.

**Rollback:**
1. `rm .github/workflows/eslint.yml` (and/or `.github/workflows/ruff.yml`).
2. (Node) `jq 'del(.devDependencies."@microsoft/eslint-formatter-sarif")' package.json > package.json.tmp && mv package.json.tmp package.json` + `npm install`.
3. Remove the `.ci-reports/` entry from `.gitignore` (manual edit).

**Dependencies:** BOO-2 (ESLint config must already be hardened), BOO-32 (SARIF consumption by Hermes — mandatory output format is prepared here already).
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` + §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` (v3.17.0, 2026-05-12) — plus `bootstrapping/bootstrap/SKILL.en.md` phase 4.4 for the bootstrap flow on new projects.

### BOO-29 — /bootstrap: branch protection with required status checks

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-29
**Auto step:** yes (via `migrate_boo_29()` and `scripts/setup-branch-protection.sh`)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-29` — `migrate_boo_29()` checks the prerequisites (`gh` installed, `gh auth status`, `git remote get-url origin`) and then invokes `scripts/setup-branch-protection.sh`. With `DRY_RUN=true` only the planned call is logged.

2. **`[AUTO]`** `setup-branch-protection.sh` dynamically reads every workflow file under `.github/workflows/*.yml` and `.github/workflows/*.yaml`. For each file it reads the first top-level `name:` line — that is the GitHub Actions context name. The resulting list becomes `required_status_checks[contexts][]`. Workflows that do not exist (e.g. when `BOO-16` Perf is not yet enabled) are omitted.

   Default set with all workflows enabled: `ESLint`, `Ruff`, `Semgrep`, `Tests`, `Coverage`, `Perf`, `SonarQube` (or `SonarCloud`).

3. **`[AUTO]`** The `gh api` call is invoked 1:1 from the BOO-29 issue body:
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

   Idempotent — the PUT call is a replace, so repeated runs are safe.

4. **`[MANUAL]`** Prerequisites if any of the auto checks fail (the script aborts with a clear operator message):
   - `brew install gh` (Mac) / https://cli.github.com/ (otherwise) when `gh CLI not found`.
   - `gh auth login` with a token holding the `repo` scope when `gh CLI not logged in`.
   - `git remote add origin git@github.com:<owner>/<repo>.git` when no `origin` is set.
   - Run `git push -u origin main` once when the remote `main` branch does not yet exist.

5. **`[MANUAL]`** Operator: verify in the GitHub UI — `https://github.com/<owner>/<repo>/settings/branches` shows the active protection rule for `main`.

6. **`[MANUAL]`** Operator: open a test PR without green checks — the merge must be blocked.

**Test:**
- `bash <path>/migrate-to-v2.sh --issue BOO-29 --dry-run` → `[DRY] bash ... setup-branch-protection.sh --dry-run` is logged.
- `gh api repos/<owner>/<repo>/branches/main/protection` → 200 with `required_status_checks.contexts` populated.
- A PR without green checks cannot be merged (GitHub blocks via UI + API).

**Rollback:** `gh api -X DELETE repos/<owner>/<repo>/branches/main/protection` (removes the protection completely).

**Dependencies:** BOO-28 (ESLint workflow), BOO-4 (Semgrep workflow), BOO-5 (SonarQube workflow), BOO-15 (Coverage), BOO-16 (Perf) — at least one workflow must exist, otherwise the protection is set without required status checks (script warning).

**Skill source:** `bootstrapping/bootstrap/scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12), `bootstrapping/bootstrap/scripts/migrate-to-v2.sh` §`migrate_boo_29` (v3.18.0) — plus `bootstrapping/bootstrap/SKILL.en.md` phase 4.4k for the bootstrap flow on new projects.

### BOO-30 — Linear workflow states + Definition of Done

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-30
**Auto step:** partial — issue-template extension is automated (`migrate_boo_30()`); Linear setup (six workflow states + GitHub integration) stays manual per project (effort/benefit ratio is poor for API automation)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-30`. `migrate_boo_30()` performs idempotently:
   - **Part 1:** patch `.github/ISSUE_TEMPLATE/story.yml` — the `dod` textarea block is replaced with the canonical 5-item checklist from BOO-30 (the older 5-item list from BOO-27 without Linear workflow context is overwritten). Idempotency marker: `Story darf erst auf Linear-Status "Done" wenn:` — present → `[SKIP]`. Implementation via inline Python (regex-based, BSD/GNU compatible). If `python3` is missing: `[WARN]` + pointer to the manual template in HANDBOOK §8g.
   - **Part 2:** extend `.claude/ISSUE_WRITING_GUIDELINES.md` — if the file exists (rendered by the bootstrap skill) and the DoD marker is missing, the mandatory DoD section (BOO-30, 5-item checklist + rules) is appended at the end. Idempotent via the same marker.
   - **Part 3:** six `[MANUAL]` log lines for the Linear setup (see steps 2-5 below).
2. **`[MANUAL]`** Operator: Linear → Settings → <Team> → Workflow. Create six states in this exact order (names exact — they drive the auto transitions):

   | State | Meaning | Auto transition |
   |---|---|---|
   | Backlog | Triage | initial |
   | In Progress | Skill working, local gates iterating | manual |
   | In Review | PR open, CI running | auto on PR open |
   | QA Failed | CI red, story re-opened | manual or webhook |
   | Done | PR merged, all checks green | auto on PR merge |
   | Cancelled | Discarded | manual |

3. **`[MANUAL]`** Operator: Linear → Settings → Integrations → GitHub → Connect Repository → select project repo. After the OAuth handshake, auto-recognition fires for:
   - branch names with `{ISSUE_PREFIX}-XX` prefix (e.g. `BOO-30-feature-foo`)
   - PR titles with `{ISSUE_PREFIX}-XX`
   - commit messages with `{ISSUE_PREFIX}-XX`
   - PR body with `Closes {ISSUE_PREFIX}-XX`
4. **`[MANUAL]`** Operator: create a test story with a branch `{ISSUE_PREFIX}-XX-test` — PR open automatically transitions the issue to `In Review`.
5. **`[MANUAL]`** Operator: read the full guide in HANDBOOK §8g "Linear setup per project" — it explains the rationale of the workflow pairing (Backlog↔Cancelled, In Progress↔In Review, QA Failed↔Done) and gives the exact DoD snippet.

**Test:**
- `grep -F 'Story darf erst auf Linear-Status "Done" wenn:' .github/ISSUE_TEMPLATE/story.yml` → match.
- `grep -F 'Story darf erst auf Linear-Status "Done" wenn:' .claude/ISSUE_WRITING_GUIDELINES.md` → match (when the file exists).
- Second `--issue BOO-30` run → `[SKIP]` for both files (idempotence).
- Linear UI: six states present, order correct.
- Test PR → issue state auto-jumps to `In Review`.

**Rollback:**
1. Issue template: edit `.github/ISSUE_TEMPLATE/story.yml` `dod` block back to the BOO-27 default (manual edit).
2. Guidelines: delete the BOO-30 section at the end of `.claude/ISSUE_WRITING_GUIDELINES.md`.
3. Linear states: delete or rename in the Linear UI (this destroys the history of existing issues, however).

**Dependencies:** BOO-27 (issue template must exist, otherwise `[WARN]` + patch step aborts), BOO-29 (required status checks are referenced in the DoD checklist).
**Skill source:** `bootstrapping/bootstrap/references/issue-writing-guidelines-template.md` v3.1 (BOO-30), `bootstrapping/bootstrap/scripts/migrate-to-v2.sh` §`migrate_boo_30` (v3.19.0, 2026-05-12), `bootstrapping/bootstrap/SKILL.en.md` phase 4.4l, `bootstrapping/HANDBUCH.md` §8g Linear setup per project.

### BOO-34 — /bootstrap: .claude/environment.json — skill environment awareness

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-34
**Auto step:** yes
**Steps:**
1. **Auto preparation:** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-34` — drops `.claude/generate-environment-json.sh` (executable), invokes the generator, and writes `.claude/environment.json` with detection for `environment` (mac/vps/ci), `tools_available` (eslint, semgrep, tests, sonarqube_*), `paths`, and `metadata` (created_at, bootstrap_version, stack). Idempotent — existing files are skipped.
2. **Pre-check:** if `.claude/` is missing the script creates it — no operator action required.
3. **Schema source:** before running, optionally read `bootstrap/references/file-templates.en.md` §`.claude/environment.json` to understand the fields. Generator-script source: §`.claude/generate-environment-json.sh` (same file).
4. **Test 1 (script syntax):** `bash -n .claude/generate-environment-json.sh` — exit 0.
5. **Test 2 (JSON validity):** `cat .claude/environment.json` — required fields `environment`, `tools_available`, `paths`, `metadata` are present. Optional: `python3 -m json.tool .claude/environment.json` — exit 0.
6. **Test 3 (idempotence):** invoke `--issue BOO-34` twice — the second run shows `[SKIP]` lines for both the generator and the JSON file.
7. **Test 4 (re-generation):** after installing tooling (e.g. `brew install semgrep`) run `bash .claude/generate-environment-json.sh --force` — `tools_available.semgrep` flips from `false` to `true`.
8. **`.gitignore` decision — deliberately NOT ignored:** `.claude/environment.json` **should be committed**. Rationale: shared tooling assumptions across the team, audit trail via `metadata.created_at`, and project migrations want to know "which bootstrap version produced this snapshot". Machine-specific drift (Mac operator vs. Linux VPS) is resolved via `--force` and a re-commit, not via ignoring. No `.gitignore` entry needed.
9. **Manual:** if the SonarLint VS Code plugin is active on Mac, flip `tools_available.sonarqube_ide_plugin` in `.claude/environment.json` from `false` to `true` — CLI detection is not possible. If the project does NOT use SonarCloud, flip `tools_available.sonarqube_cloud` from `true` to `false`.
10. **Re-run after a bootstrap update (optional):** when a future `/bootstrap` skill version reshapes phase 4.4e, simply run `bash .claude/generate-environment-json.sh --force` — the old file is overwritten with an updated `metadata.bootstrap_version`.

**Rollback:** delete `.claude/environment.json` and `.claude/generate-environment-json.sh`.
**Dependencies:** none
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §`.claude/environment.json` + §`.claude/generate-environment-json.sh` (BOO-34 v3.3.0, 2026-05-06) — and `bootstrapping/bootstrap/SKILL.en.md` phase 4.4e for the bootstrap flow on new projects.

### BOO-36 — /implement: persist local iteration outputs to journal/reports/local/

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-36
**Auto step:** yes
**Steps:**
1. Create `journal/reports/local/` with a `.gitkeep`.
2. Add an entry to `.gitignore`: `journal/reports/local/*` plus `!journal/reports/local/.gitkeep` — local iteration stays local.
3. **Test:** `ls journal/reports/local/` and `git check-ignore journal/reports/local/foo.json` — Foo is ignored.

**Rollback:** remove the directory and the .gitignore entries.
**Dependencies:** none

### BOO-38 — Document sprint sizing convention on a token-window basis

**Status:** ✓ docs in bundle (HANDBUCH Appendix G), project governance template extended
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-38
**Auto step:** no
**Steps:**
1. **`[MANUAL]`** Extend local `Projekt-Governance.md` with §9 sprint sizing (template: `bootstrap/references/governance-template.md` §9). Contains: 80% rule, SP table, no-velocity policy, SP→mode mapping, pre-flight reference.
2. **`[MANUAL]`** Add `thresholds.token_warn_threshold: 70` and `thresholds.token_hard_threshold: 80` to `.claude/environment.json` (if not already present from BOO-35 migration).
3. **`[MANUAL]`** Team briefing: disable velocity tracking (no burndown, no SP statistics). Outcome tracking via intent fulfilment (BOO-1 + BOO-10).

**Test:** `Projekt-Governance.md` has §9 with the SP table (5 rows 1/2/3/5/8 points). `environment.json` contains both threshold fields.

**Rollback:** remove §9 from `Projekt-Governance.md`, revert the threshold fields from environment.json. Effect: skill no longer warns about window exhaustion (BOO-40 becomes ineffective).
**Dependencies:** none. Prerequisite for BOO-39 (token heuristic references the SP table) and BOO-40 (pre-flight uses the thresholds).
**Skill source:** `bootstrapping/HANDBUCH.md` Appendix G + `bootstrap/references/governance-template.md` §9.

### BOO-39 — /ideation: token heuristics + execution mode recommendation

**Status:** ✓ included in v2 skill source (no per-project migration needed)
**Effort:** small (operator-side: just git pull the skills)
**Linear:** https://linear.app/owlist/issue/BOO-39
**Auto step:** yes (included in the skill update)
**Steps:**
1. **`[AUTO]`** Pull skills again: `cd ~/.claude/skills && git pull origin main`. `/ideation` v2.4.0 ships the new step 5b (token heuristic + SP + mode + operator hybrid prompt). Reference file `ideation/references/token-heuristik.md` (DE+EN) ships along automatically.
2. **`[MANUAL]`** Existing `specs/` files do not strictly need the new frontmatter. New stories created via `/ideation` from now on automatically get `token_estimate` + `execution_mode` + `estimation_basis`.
3. **`[MANUAL]`** Optional: update the project's `specs/TEMPLATE.md` so manually created specs also carry the frontmatter (template: `bootstrap/references/file-templates.en.md` §`specs/TEMPLATE.md`).

**Test:** after `git pull`: run `/ideation` on a fresh dummy story → expected step 5b operator hybrid prompt "Token estimate: Xk → Y SP → mode Z. Override? [y/n]". The spec file contains a frontmatter with the 4 new fields.

**Rollback:** revert the skill to v2.3.0 (`git checkout <pre-boo39-commit> -- ideation/`). Effect: step 5b disappears, SP is set manually again.
**Dependencies:** BOO-38 (HANDBUCH Appendix G with the SP table must be known because step 5b references it).
**Skill source:** `bootstrapping/ideation/SKILL.md` step 5b + `ideation/references/token-heuristik.md`.

### BOO-40 — /implement: token window pre-flight (step 0b)

**Status:** ✓ included in v2 skill source (skill + environment.json defaults)
**Effort:** small (operator-side: git pull + optional environment.json patch)
**Linear:** https://linear.app/owlist/issue/BOO-40
**Auto step:** yes (included in the skill update)
**Steps:**
1. **`[AUTO]`** Pull skills again: `cd ~/.claude/skills && git pull origin main`. `/implement` v2.7.0 ships the new step 0b (token-window pre-flight between steps 0 and 1).
2. **`[MANUAL]`** Extend `.claude/environment.json` with the two new thresholds (unless already added during the BOO-38 migration):
   ```json
   "thresholds": {
     "architecture_doc_freshness_days": 30,
     "token_warn_threshold": 70,
     "token_hard_threshold": 80
   }
   ```
   Defaults (70/80) are sensible to start with — tighten (60/75) if the project tends to produce large stories.
3. **`[MANUAL]`** Check the token-counter prerequisite: `claude-code measure-context` must be available. If not: the skill falls back to a chat-length estimate (output marks it as "imprecise").

**Test:** trigger a story with an artificially high context (e.g. read a large test file, then start the story). Step 0b shows `[!warning]` with the projection + sprint-switch instructions when answered `no`.

**Rollback:** revert the skill to v2.6.0 (`git checkout <pre-boo40-commit> -- implement/`). Effect: step 0b disappears, no warning system anymore — compaction emergencies possible.
**Dependencies:** BOO-38 (HANDBUCH Appendix G + thresholds fields), BOO-39 (`token_estimate` in spec frontmatter), BOO-36 (meta.json extended with `pre_flight_warning` field).
**Skill source:** `bootstrapping/implement/SKILL.md` step 0b + HANDBUCH Appendix G §threshold configuration.

---

## Phase 3 — Observability + Performance

### BOO-8 — Introduce Testability as 7th standard dimension

**Issue history note:** The issue was originally phrased "Operations -> Testability + Observability" on 2026-04-23. During the BOO-8 re-scope (2026-05-06) we established that neither "Operations" exists as a catch-all dimension nor does Observability need to be added — Observability is already standard dimension #5. BOO-8 thereby reduces to a purely **additive** step: introduce Testability as the 7th standard dimension.

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-8
**Auto step:** no (operator-driven — auto-editing project content would be too risky)
**Steps:**
1. **Auto prep:** From the project root run `bash <path-to-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-8` — emits the `[MANUAL]` hint with the operator steps. The script writes **no** file (too project-specific).
2. **Manual:** Open `ARCHITECTURE_DESIGN.md` (or the project's equivalent hub file), locate §3 "Quality Attributes" / "Qualitaets-Dimensionen".
3. **Manual:** Insert a new **Testability** row between Maintainability (#6) and the optional columns (Cost Efficiency / Domain Quality). Template:
   - Dimension: **Testability**
   - Project-specific check question: Coverage on new code (change value)? Test pyramid (unit/contract/integration)? Pass rate stable?
   - Detail content: copy from `bootstrapping/architecture-review/references/dimensions-detail.en.md §7 Testability`.
4. **Manual (assessment):** Check whether test aspects today are mixed under Maintainability or Reliability — e.g. "tests for critical paths?" as a sub-bullet under Maintainability. If so: operator decides per project whether those bullets should migrate to Testability or both dimensions reference them.
5. **Test (sanity):** `grep -E "Testability" ARCHITECTURE_DESIGN.md` → at least one hit in the quality-attributes table.
6. **Test (end-to-end, optional):** Run the `architecture-review` skill on an existing project — verify the new dimension is recognized and reviewed. This is the DoD item from the original Linear issue.

**Rollback:** remove the Testability row from `ARCHITECTURE_DESIGN.md`. Add-on dimensions shift one position back up.
**Dependencies:** none
**Skill source:** `bootstrapping/bootstrap/references/architecture-design-template.en.md` + `bootstrapping/architecture-review/references/dimensions-detail.en.md §7 Testability` (BOO-8 v3.4.0, 2026-05-06).

### BOO-13 — Introduce Scalability as 8th standard architecture dimension

**Issue history note:** The issue was originally phrased as a section extension in `ARCHITECTURE_DESIGN.md` with four scalability invariants. During the BOO-13 re-scope (2026-05-08) the cut was harmonized with BOO-8 (Testability as the 7th standard dimension): Scalability is anchored as the **8th standard architecture dimension** in the skill set (analogous to Reliability/Testability), with 4 pro-invariants and 4 anti-patterns. The original stub content (4 invariants in the existing project's quality-attributes table) is preserved as an operator step — but is now sourced from `architecture-review/references/dimensions-detail.en.md §8 Scalability`.

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-13
**Auto step:** no (operator-driven — scalability applies to all stacks equally, no skeleton file needed)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path-to-skill-repo>/bootstrapping/bootstrap/scripts/migrate-to-v2.sh --issue BOO-13` — emits the `[MANUAL]` hint with the operator steps. The script writes **no** file (scalability is an architecture dimension, not a code skeleton).
2. **`[MANUAL]`** Open `docs/ARCHITECTURE_DESIGN.md` (or the project's equivalent hub file), locate §3 "Quality Attributes" / "Qualitaets-Dimensionen". Insert a **Scalability** row between Testability (#7) and the optional columns (Cost Efficiency / Domain Quality). Capture the 4 pro-invariants (stateless, horizontal scalability, 12-factor config, async decoupling) and 4 anti-patterns either as sub-bullets or as a pointer to `architecture-review/references/dimensions-detail.en.md §8 Scalability`.
3. **`[MANUAL]`** Audit the existing project's architecture against the 4 pro-invariants — per invariant: status (met / unmet / n/a) + rationale. Check what is unmet (stateless: no in-process sessions / no module-global state; horizontal scalability: the service can run N times without coordination; 12-factor: config in ENV, not in code; async decoupling: long-running jobs go through a queue/bus, not inline).
4. **`[MANUAL]`** Anti-pattern sweep: `grep -RIn "globalThis\.sessions\|\.lock\b\|setInterval\|node-cron\|node-schedule" src/ lib/ services/` and a manual scan for module-global mutables / singleton state / in-process cron. Document findings — either as an ADR under `docs/domain/adrs/NNN-scalability-debt.md` or as a backlog issue. Deliberate debt is acceptable, when documented.
5. **`[MANUAL]`** Decide on the `architecture-design-template.md` choice: do you keep Scalability deliberately on as a default (recommended for any project with multi-instance ambition or a backpressure requirement), or do you disable it for this existing project (e.g. single-user CLI, local tool with no scaling path)? Justify with an ADR if disabled: `docs/domain/adrs/NNN-scalability-disabled.md`.
6. **`[MANUAL]`** Run `/architecture-review --system` — the skill now checks 8 standard dimensions. Archive the resulting report under `journal/reports/architecture-review-<date>.md`. Prioritize risk entries for scalability anti-patterns.
7. **`[MANUAL]`** If one of the 4 pro-invariants is unmet and not consciously accepted as debt: open a backlog issue (Linear / GitHub Issues / journal depending on the project's backlog tool) and prioritize it. Not everything has to be fixed immediately — order by risk (stateless before 12-factor before async decoupling, because stateless is the prerequisite for horizontal scalability).
8. **`[AUTO]`** Verify that the existing skill installation's `architecture-review/references/dimensions-detail.en.md` contains §8 Scalability: `grep -E "^## §?8\.? Scalability" .claude/skills/architecture-review/references/dimensions-detail.en.md`. If missing: skill update via `git pull` inside the `.claude/skills/architecture-review` clone or reinstall via phase 5 of `/bootstrap` (`a/b/c/d` selection).

**Test:**
- `grep -E "Scalability" docs/ARCHITECTURE_DESIGN.md` → at least one hit in the quality-attributes table.
- The section contains 4 pro-invariants with status (met/unmet/n/a) and 4 anti-patterns.
- `grep -E "^## §?8\.? Scalability" .claude/skills/architecture-review/references/dimensions-detail.en.md` → skill reference present.
- Optional (DoD): a `/architecture-review --system` run shows Scalability as a reviewed dimension in the output report.

**Rollback:** remove the Scalability row from `docs/ARCHITECTURE_DESIGN.md`; mark the ADR `NNN-scalability-disabled.md` (if created) as `superseded` instead of deleting it. Add-on dimensions shift one position back up.
**Dependencies:** no hard ones — additive to BOO-8 (Testability as the 7th standard dimension) and BOO-25 (reliability pillars). The content overlap with BOO-25 backpressure strategy is intentional — Scalability checks the structural question (can the service scale?), Reliability checks the robustness question (does it hold up under pressure?).
**Skill source:** `bootstrapping/architecture-review/references/dimensions-detail.en.md §8 Scalability` (4 pro-invariants + 4 anti-patterns) since skill version v1.6.0 (BOO-13, 2026-05-08) — plus `bootstrapping/bootstrap/references/architecture-design-template.en.md` for the bootstrap flow on new projects.

### BOO-14 — /bootstrap observability skeleton (structured logging + metrics endpoint + alert rules)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-14
**Auto step:** partial (files scaffolded by `migrate_boo_14()`, service-specific content filled manually)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-14` — drops `observability.md` (skeleton with the three required sections), `observability/alerts/.gitkeep` (directory marker), and `observability/.env.observability` (routing stub with Telegram placeholder). Idempotently appends `observability/.env.observability` to `.gitignore`. Existing files are `[SKIP]`ped — `--force` overwrites.
2. **`[MANUAL]`** Operator lists services from `ARCHITECTURE_DESIGN.md §4 component overview` (or the project's component inventory) in `observability.md` as `### Service: <name>` sections (one per service).
3. **`[MANUAL]`** Operator assigns the **port convention 9090+N** per service (auth=9091, api=9092, db=9093, ...) and records the port in each service section.
4. **`[MANUAL]`** Operator picks the **logger library per stack** — defaults: Node.js → `pino`, Python → `structlog`. Document deviations as an ADR under `docs/domain/adrs/NNN-logger-choice.md`.
5. **`[MANUAL]`** Operator creates one file per service: `observability/alerts/<service>.yml` with the three required alerts: `{service}_down` (`up == 0` for >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% for 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s for 5 min, severity warning). Template: `bootstrap/references/file-templates.en.md` §`observability/alerts/<service>.yml (BOO-14)`. Thresholds are defaults — adjust per project.
6. **`[MANUAL]`** Operator configures routing in `observability/.env.observability` (Telegram bot token, Slack webhook, email SMTP). Real secrets do NOT belong in the repo — the file is gitignored. Commit a `.env.observability.example` (no secrets) instead.
7. **`[AUTO]`** `.gitignore` entry `observability/.env.observability` (added idempotently by step 1; `[SKIP]` if already present).
8. **`[MANUAL]`** Validate locally with `promtool check rules observability/alerts/*.yml` — DoD checkpoint. If `promtool` is missing: `brew install prometheus` (mac) or `apt install prometheus` (VPS).

**Test:**
- `ls observability.md observability/alerts/ observability/.env.observability` → all three exist.
- `grep -E "^### Service:" observability.md` → at least one service entry.
- `grep -F "observability/.env.observability" .gitignore` → entry present.
- Optional (DoD): `promtool check rules observability/alerts/*.yml` → `SUCCESS`.

**Rollback:**
1. `rm observability.md`
2. `rm -rf observability/`
3. Remove the `observability/.env.observability` entry from `.gitignore` (manual edit).

**Dependencies:** BOO-8 (observability is already standard dimension #5; BOO-14 only adds the physical skeleton).
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §`observability.md` + §`observability/alerts/<service>.yml` + §`observability/.env.observability` (BOO-14 v3.5.0, 2026-05-07) — plus `bootstrapping/bootstrap/SKILL.en.md` phase 4.4f for the bootstrap flow on new projects.

### BOO-16 — Performance baseline gate (P95 + alarm on 20% regression)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-16
**Auto step:** partial (files scaffolded by `migrate_boo_16()`, baseline values and service start command filled manually)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-16` — drops `journal/perf-baseline.json` initialised with `services: []` (living baseline, committed in the repo). Existing files are `[SKIP]`ped — `--force` overwrites.
2. **`[MANUAL]`** Operator derives the **service list**. Sources in this order: ENV `BOO16_SERVICES="auth-service api-gateway"` takes precedence, otherwise parsed from `observability.md` (heading `### Service: <name>` — BOO-14), otherwise from the `Block C` components in `ARCHITECTURE_DESIGN.md §4`. When parsed from `observability.md`: verify the list in the log output.
3. **`[AUTO]`** Per service one bench stub: `bench/<service>.bench.js` (Node) or `bench/<service>_bench.py` (Python). Stack auto-detected via `package.json` (Node), `pyproject.toml` OR `requirements.txt` (Python); mixed stacks scaffold both variants in parallel. Templates: `bootstrap/references/file-templates.en.md` §`bench/<service>.bench.js` (autocannon-based) and §`bench/<service>_bench.py` (pytest-benchmark + httpx). Service name substitution happens automatically (`{{SERVICE_NAME_KEBAB}}` / `{{SERVICE_NAME_SNAKE}}`).
4. **`[AUTO]`** Stack-specific dev dependencies added idempotently: Node → `package.json` devDeps `autocannon` via `jq` merge (skipped if present, operator hint if `jq` missing); Python → `pyproject.toml` `[project.optional-dependencies].test` `pytest-benchmark` + `httpx` (skipped if present, `log_manual` hint if `pyproject.toml` needs editing).
5. **`[AUTO]`** `.github/workflows/perf.yml` rendered from the template heredoc, service matrix wired automatically from the service list (`{{SERVICE_MATRIX}}` substituted via `sed`). Template: `bootstrap/references/file-templates.en.md` §`.github/workflows/perf.yml`. Thresholds: `<=5%` PASS, `5-20%` WARNING (PR comment), `>20%` FAIL (unless overridden). Override mechanic: PR label `perf-override` OR commit message trailer `Perf-Override: <reason>`.
6. **`[MANUAL]`** First CI bench run intentionally fails with "baseline missing" (comparator output): operator downloads the `perf-bench-<service>` artifact, copies `p50_ms` / `p95_ms` / `p99_ms` / `req_per_sec` / `commit_sha` / `recorded_at` / `bench_tool` into `journal/perf-baseline.json` under `services[]` and commits as `BOO-16: initial baseline for <service>`. Operator also: enter the service start command in `.github/workflows/perf.yml` step `Start service (background)` (replace the `exit 1` placeholder).
7. **`[MANUAL]`** Enable branch protection: register `Perf` as a Required Status Check (`Settings → Branches → Branch protection rules → Require status checks to pass → Perf`). Anyone deliberately disabling the gate (e.g. single-user CLI without a server endpoint) writes an ADR `docs/domain/adrs/NNN-perf-gate-disabled.md` with the rationale.
8. **`[AUTO]`** `journal/reports/perf/.gitkeep` + empty `journal/reports/perf/overrides.log` (append-only audit trail) created. `.gitignore` idempotently extended with `coverage/` and `journal/reports/perf/*.json` (reports are artifact output, not commit material — the comparator step only promotes selected values into the baseline).

**Test:**
- `ls journal/perf-baseline.json .github/workflows/perf.yml journal/reports/perf/overrides.log` → all three exist.
- `jq '.services | length' journal/perf-baseline.json` → `0` initially, `>= 1` after operator fills in baselines.
- `ls bench/` → at least one `<service>.bench.js` or `<service>_bench.py` per service.
- `grep -F "journal/reports/perf/*.json" .gitignore` → entry present.
- Optional (DoD): first PR with a dummy change triggers the `Perf` workflow → FAIL with "baseline missing" (expected).

**Rollback:**
1. `rm -rf bench/`
2. `rm journal/perf-baseline.json`
3. `rm -rf journal/reports/perf/`
4. `rm .github/workflows/perf.yml`
5. Remove the `coverage/` and `journal/reports/perf/*.json` entries from `.gitignore` (manual edit).
6. Revert `package.json` devDeps `autocannon` or the `pyproject.toml` `test` block manually (`npm uninstall autocannon` / edit).
7. Branch protection: disable the `Perf` Required Status Check.

**Dependencies:** BOO-14 (the service list is optionally parsed from `observability.md` — when BOO-14 has not been migrated yet, the list is sourced from ENV `BOO16_SERVICES` or the default service entry).
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §`journal/perf-baseline.json` + §`bench/<service>.bench.js` + §`bench/<service>_bench.py` + §`.github/workflows/perf.yml` (BOO-16 v3.8.0, 2026-05-11) — plus `bootstrapping/bootstrap/SKILL.en.md` phase 4.4g for the bootstrap flow on new projects.

### BOO-25 — Reliability as a dedicated architecture dimension (Schrader's 6th pillar)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-25
**Auto step:** partial (skeletons scaffolded by `migrate_boo_25()`, service-specific activation manual)
**Steps:**
1. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-25` — drops the four skeleton files: `lib/idempotency.{js,py}`, `lib/retry.{js,py}`, `lib/circuit-breaker.{js,py}`, `docs/SLO.md`. Stack detection via `package.json` (Node), `pyproject.toml` / `requirements.txt` (Python); for mixed stacks (both manifests present) both variants are scaffolded in parallel. Existing files are `[SKIP]`ped — `--force` overwrites with a `.bak` backup.
2. **`[MANUAL]`** Operator decides per service which of the four pillars to activate — not every service needs idempotency (e.g. read-only services don't), not every downstream call needs its own circuit breaker. Skeleton bodies: `bootstrap/references/file-templates.en.md` §`lib/idempotency` / §`lib/retry` / §`lib/circuit-breaker` / §`docs/SLO.md`.
3. **`[MANUAL]`** Wire the idempotency middleware into the service entry point — Express via `app.use()` for a required route group or per writing endpoint, FastAPI via `Depends()`. **Not globally** across all endpoints, but explicitly per POST/PUT/PATCH/DELETE. Add the Redis connection as `REDIS_URL` in `.env` (sample value committed in `.env.example`).
4. **`[MANUAL]`** Configure one circuit breaker per external dependency (DB, auth service, external API, message bus). Default config: `errorThresholdPercentage: 50`, `resetTimeout: 30000`, `volumeThreshold: 10`. Adjust thresholds per dependency (DB may be slower than auth service; external APIs may be more restrictive).
5. **`[MANUAL]`** Apply the retry helper to all downstream calls (HTTP client, DB adapter, message-bus publisher). Check the status-code filter — **no retry on 4xx** (client errors are not transient). Idempotency conflicts (HTTP 422 with idempotency-key mismatch) must not be retried either.
6. **`[MANUAL]`** Fill `docs/SLO.md`: define availability target (99.9 / 99.95 / 99.99), error-budget table per quarter, at least three SLIs with measurement method (point at the BOO-14 metrics endpoint as the source: `error_rate`, `p95_latency`, `up` probe). Schedule the review cadence in `/sprint-review` — check the error-budget status on every sprint-review run.
7. **`[MANUAL]`** Add tests for idempotency and the retry path: (a) duplicate submit with the same `Idempotency-Key` → cached response, (b) same key + diverging body → HTTP 422, (c) transient 503 → 3 retries → success, (d) 4xx → no retry. The coverage gate (BOO-15) requires >=80% on new code anyway — these tests fall under that gate.
8. **`[MANUAL]`** Review `docs/ARCHITECTURE_DESIGN.md` §3 Quality Attributes — document the reliability invariants as a deliberate decision: which of the five pillars (idempotency, retry+backoff, circuit breaker, graceful degradation, SLO+error budget) are active? Which are deliberately omitted? Why? For existing projects without a Quality-Attributes section: record the operator decision as an ADR under `docs/domain/adrs/NNN-reliability-pillars.md`. (This step folds in the original stub — the "Reliability" section in `ARCHITECTURE_DESIGN.md` ends up covering retry strategy, circuit breaker, idempotency, SLO/SLI plus graceful degradation as the 5th pillar.)

**Test:**
- `ls lib/idempotency.* lib/retry.* lib/circuit-breaker.* docs/SLO.md` → all four skeletons present (at least one stack variant per pillar).
- `grep -E "^## (Reliability|Quality Attributes)" docs/ARCHITECTURE_DESIGN.md` → section present with a reliability entry.
- Idempotency + retry tests are green (see step 7).
- Optional (DoD): the error-budget table in `docs/SLO.md` lists the current quarter with a concrete value.

**Rollback:**
1. `rm -f lib/idempotency.{js,py} lib/retry.{js,py} lib/circuit-breaker.{js,py} docs/SLO.md`
2. Revert the idempotency middleware in entry points, remove `REDIS_URL` from `.env`.
3. Strip the retry wrapper from downstream calls, dismantle circuit-breaker instances.
4. Mark the ADR `docs/domain/adrs/NNN-reliability-pillars.md` as `superseded` instead of deleting it.

**Dependencies:** BOO-8 (reliability as the 6th standard dimension; BOO-25 ships the physical skeleton), BOO-13 (scalability invariants overlap with the backpressure strategy). No hard dependency on BOO-14 — can run without observability, but `docs/SLO.md` references the BOO-14 metrics endpoint as the SLI source.
**Skill source:** `bootstrapping/bootstrap/references/file-templates.en.md` §`lib/idempotency` + §`lib/retry` + §`lib/circuit-breaker` + §`docs/SLO.md` (BOO-25 v3.7.0, 2026-05-07) — plus `bootstrapping/bootstrap/SKILL.en.md` phase 4.4h for the bootstrap flow on new projects. Cross-link to architecture dimensions: `architecture-review/references/dimensions-detail.en.md` §1.1-§1.5 (the five reliability pillars).

---

## Phase 4 — Intent Propagation + AI-friendly Architecture

### BOO-7 — /architecture-review: AI-readiness checklist (4 principles + 4 anti-patterns)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-7
**Auto step:** no
**Steps:**
1. <filled in once BOO-7 is Done — planned: skill update, in the project only a reference in README/HANDBOOK>
2. **Test:** <filled in once BOO-7 is Done>

**Rollback:** remove the doc reference.
**Dependencies:** BOO-24, BOO-26

### BOO-10 — Intent propagation through the pipeline (ideation + backlog + implement)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-10
**Auto step:** partial
**Steps:**
1. Extend the issue template with an "Intent reference" field (path to `intents/<key>.md`).
2. Extend the PR template with a block "Intent satisfied? (prove via test/ADR)".
3. **Test:** a new issue / PR shows the mandatory fields.

**Rollback:** restore the templates from git history.
**Dependencies:** BOO-1

### BOO-21 — Domain knowledge in the project (research + domain context + domain ADRs)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-21
**Auto step:** yes
**Steps:**
1. Create the `docs/domain/` directory.
2. Add `docs/domain/README.md` with a content overview and conventions.
3. Create `docs/domain/research/` and `docs/domain/adrs/` as subdirectories.
4. Copy the domain ADR template from `bootstrap/references/file-templates.md` to `docs/domain/adrs/000-template.md`.
5. **Test:** `tree docs/domain` shows the structure.

**Rollback:** `rm -rf docs/domain`.
**Dependencies:** none

### BOO-24 — /bootstrap: 4 AI architecture principles + 4 anti-patterns as a mandatory block in ARCHITECTURE_DESIGN.md §1

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-24
**Auto step:** partial
**Steps:**
1. Insert a mandatory block in `docs/ARCHITECTURE_DESIGN.md` §1: "AI architecture principles (4) and anti-patterns (4)".
2. Pull content from `bootstrap/references/file-templates.md` (single source of truth block).
3. **Test:** `grep "AI architecture principles" docs/ARCHITECTURE_DESIGN.md` finds the block.

**Rollback:** remove the block.
**Dependencies:** none

### BOO-26 — Anti-pattern catalogue (Schrader Ch. 7, 11 APs) as reference file + /sprint-review hook

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-26
**Auto step:** no
**Steps:**
1. <filled in once BOO-26 is Done — planned: reference file in the skill, only a reference in the project>
2. **Test:** <filled in once BOO-26 is Done>

**Rollback:** remove the doc reference.
**Dependencies:** none

### BOO-35 — /ideation: pre-flight check ARCHITECTURE_DESIGN.md freshness

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-35
**Auto step:** no
**Steps:**
1. <filled in once BOO-35 is Done — planned: skill update, no project migration>
2. **Test:** <filled in once BOO-35 is Done>

**Rollback:** n/a
**Dependencies:** BOO-24

---

## Phase 5 — Enterprise Governance

### BOO-11 — Issue writing guidelines: three-tier execution mode + sub-agent context per role

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-11
**Auto step:** partial
**Steps:**
1. Copy `docs/issue-writing-guidelines.md` from `bootstrap/references/issue-writing-guidelines-template.de.md` (or its English sibling).
2. For Linear setups: extend the issue template with fields "Execution mode" (linear/sub-agents/agentic) and "Sub-agent context".
3. **Test:** the file exists, template fields appear on a new issue.

**Rollback:** delete the file, remove template fields.
**Dependencies:** none

### BOO-17 — Feature flag convention for AI code (staged rollout in spec)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-17
**Auto step:** no
**Steps:**
1. <filled in once BOO-17 is Done — planned: extend the spec template with a "rollout stages" block, optionally wire in a feature flag library>
2. **Test:** <filled in once BOO-17 is Done>

**Rollback:** remove the spec block.
**Dependencies:** none

### BOO-18 — Mandatory human review for sensitive paths (.claude/sensitive-paths.json)

**Status:** ☐ pending
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-18
**Auto step:** yes
**Steps:**
1. Create `.claude/sensitive-paths.json` with default paths (`.env`, `secrets/`, `infra/terraform/`, `migrations/`).
2. Extend the pre-commit hook: hard-stop on changes inside any of these paths and require manual approval.
3. **Test:** `cat .claude/sensitive-paths.json | jq .paths` lists the defaults.

**Rollback:** delete the file, remove the hook block.
**Dependencies:** BOO-4

### BOO-19 — Prompt audit trail (session logs + spec reference)

**Status:** ☐ pending
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-19
**Auto step:** partial
**Steps:**
1. <filled in once BOO-19 is Done — planned: `journal/sessions/` directory with a session log convention, extend the PR template with a "session log reference" field>
2. **Test:** <filled in once BOO-19 is Done>

**Rollback:** revert the directory and PR template change.
**Dependencies:** none

---

## Phase 6 — Documentation + Rollout

### BOO-20 — HANDBOOK.md Schrader appendix

**Status:** ✗ n/a
**Effort:** medium
**Linear:** https://linear.app/owlist/issue/BOO-20
**Auto step:** no
**Steps:** skill-internal documentation — no project migration.

**Rollback:** n/a
**Dependencies:** none

### BOO-37 — Build /pitch skill — gather data, human writes the story (Schrader Ch. 5)

**Status:** ✓ shipped in v2 skill source (skill code via `git pull`, project setup via this step)
**Effort:** small (operator: one migrate call + one generator refresh)
**Linear:** https://linear.app/owlist/issue/BOO-37
**Auto step:** yes (`migrate_boo_37`)
**Steps:**
1. **`[AUTO]`** Pull bundle skills: `cd ~/.claude/skills && git pull origin main` — `pitch/` ships in bundle v3.23.0.
2. **`[AUTO]`** From the project root run `bash <path>/migrate-to-v2.sh --issue BOO-37` — creates `pitch/.gitkeep` and `intents/.gitkeep` (idempotent), checks `paths.pitches` in `.claude/environment.json`.
3. **`[MANUAL]`** If `.claude/environment.json` exists but lacks `paths.pitches`: run `bash .claude/generate-environment-json.sh --force` — the v3.23.0 generator writes `paths.intents` and `paths.pitches`. If the file is missing entirely: run `migrate_boo_34` first, then repeat this step.
4. **`[OPTIONAL]`** Create the first pitch briefing: invoke `/pitch` in Claude Code — the skill asks for sprint + intents + stories and writes `pitch/PITCH-1.md`.

**Verification:**
- `ls pitch/` shows at least `.gitkeep`
- `grep '"pitches"' .claude/environment.json` yields `"pitches": "pitch/"`
- `ls intents/` shows at least `.gitkeep` (prerequisite for reading `INTENT-XX.md`)

**Rollback:** `git checkout .` on the two `.gitkeep` files and `rm -rf pitch/ intents/` (only if no briefings or intents live in there — otherwise you lose work).
**Dependencies:** BOO-34 (environment.json must exist so `paths.pitches` can be regenerated), BOO-1 (intent skill provides the `INTENT-XX.md` source), BOO-17 (feature-flag convention provides the `.claude/feature-flags.json` source)

---

## Phase 7 — Hermes Integration (post-2026-04-27)

### BOO-31 — metadata.hermes block in every skill frontmatter

**Status:** ✓ included in v2 skill source (no per-project migration needed)
**Effort:** small (operator-side: just git pull the skills)
**Linear:** https://linear.app/owlist/issue/BOO-31
**Auto step:** yes (included in the skill update)
**Steps:**
1. **`[AUTO]`** Pull skills from the repo: `cd ~/.claude/skills && git pull origin main` (or project-specific skills clone). The `metadata.hermes` block has been part of every bundle skill frontmatter since BOO-31.
2. **`[MANUAL]`** Verify: `grep -l "metadata:" ~/.claude/skills/<skill>/SKILL.md` — should match all 10 bundle skills (bootstrap, intent, ideation, backlog, implement, architecture-review, sprint-review, cloud-system-engineer, grafana, visualize).
3. **`[MANUAL]`** Optional (only if Hermes is installed locally): `hermes catalog refresh` — lets Hermes re-scan the skill catalog.

**Test:** `grep -A 5 "metadata:" ~/.claude/skills/bootstrap/SKILL.md` shows the `hermes:` sub-block with `category`, `tags`, `requires_toolsets`, `related_skills`.

**Rollback:** revert skill to v1 frontmatter (`git checkout <pre-boo31-commit> -- SKILL.md`). Hermes routing degrades to inference; other skill functions unchanged.

**Dependencies:** none. Prerequisite for BOO-32 (CI output consumption) and BOO-33 (setup guide).
**Skill source:** `bootstrapping/HANDBUCH.md` Appendix D (schema + mapping table).

### BOO-32 — CI output standardisation for Hermes consumption

**Status:** ✓ partial (directory + .gitignore automatic; CI workflow patches operator-side)
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-32
**Auto step:** partial
**Steps:**
1. **`[AUTO]`** Create `journal/reports/ci/` and `journal/reports/local/` as gitignored directories. Idempotently append `journal/reports/` to `.gitignore`. (`migrate_boo_32()` in `migrate-to-v2.sh`.)
2. **`[MANUAL]`** For every existing CI workflow (`eslint.yml`, `ruff.yml`, `semgrep.yml`, `perf.yml`, `sonar.yml`) add two steps at the end of the job:
   - **`Collect reports`** with `if: always()` plus `mkdir -p journal/reports/ci/run-${{ github.run_id }}` and `cp -f` commands that move tool-specific outputs there.
   - **`Upload reports as artifact`** with `actions/upload-artifact@v4`, `name: ci-reports-${{ github.run_id }}`, `path: journal/reports/ci/run-${{ github.run_id }}/`, `retention-days: 30`.
   Template snippet: see HANDBUCH Appendix E §Aggregator step.
3. **`[MANUAL]`** For each tool, route the output flag into a consistent path (inside the workflow step, not at the end):
   - ESLint: `--output-file=.ci-reports/eslint.sarif` (existing) → keep; collect step copies further.
   - Semgrep: `--sarif --output semgrep.sarif` → add if currently stdout only.
   - pytest: `--junit-xml=tests.junit.xml`.
   - Coverage: Vitest/Jest standard `coverage/coverage-final.json` + `coverage.lcov` (nothing to change, only copy).
   - SonarQube: after `SonarSource/sonarqube-scan-action`, add a post-step that fetches `https://sonarcloud.io/api/measures/component?...` and stores it as `sonarqube.json` (token from `SONAR_TOKEN` secret).
4. **`[MANUAL]`** Leave branch-protection config unchanged — artifacts are not a required status check, only an observation signal.

**Test:**
- `bash -n` on all modified workflows → exit 0.
- Trigger a PR (e.g. with a deliberate ESLint error), let CI run, download the `ci-reports-{id}` artifact from the Actions tab → it should contain `eslint.sarif`.
- Repeat with a green CI run — the artifact also exists (`if: always()`).

**Rollback:** remove the collect + upload-artifact steps from workflows, remove the `.gitignore` entry, delete the directory. CI output behaviour reverts to pre-BOO-32 (no signal collection, no Hermes docking).
**Dependencies:** BOO-2, BOO-3, BOO-5, BOO-15

### BOO-33 — Hermes setup guide in the HANDBOOK

**Status:** ✗ n/a
**Effort:** small
**Linear:** https://linear.app/owlist/issue/BOO-33
**Auto step:** no
**Steps:** skill-internal documentation — no project migration.

**Rollback:** n/a
**Dependencies:** none

---

### BOO-45 — Lighthouse CI setup integration (frontend performance gate)

**Status:** ✓ included in v2 skill source (bootstrap question in block A.1b + templates + migrate_boo_45())
**Effort:** small (existing projects with frontend portion) / not applicable (backend-only)
**Linear:** https://linear.app/owlist/issue/BOO-45
**Auto step:** yes, with frontend detection
**Steps:**
1. **`[AUTO]`** Run `bash migrate-to-v2.sh --issue BOO-45`. The function checks `package.json` for frontend frameworks (React/Vue/Svelte/Astro/Next/Nuxt/Vite/Webpack). On hit: scaffold `lighthouserc.json` + `.github/workflows/lighthouse.yml` from template. On backend-only stack: skip with a hint. Override for non-standard frontend: `FRONTEND_OVERRIDE=true bash migrate-to-v2.sh --issue BOO-45`.
2. **`[MANUAL]`** Tune `lighthouserc.json`: set `ci.collect.url` to the real preview-deploy / staging / prod URL (default `http://localhost:3000/` is smoke test only). Tune performance budgets (LCP/CLS/TBT/minScore). Pick mobile-throttling profile (`desktop` vs. `mobile`).
3. **`[MANUAL]`** Adapt `.github/workflows/lighthouse.yml` to the stack: build command (`npm run build` vs. `next build` vs. `vite build`) and preview-server command (`npx serve` vs. `npm run start` vs. `npm run preview`).
4. **`[MANUAL]`** Optional: set `LHCI_GITHUB_APP_TOKEN` as GitHub secret for Lighthouse-CI server status checks. Without the token: filesystem reports (default).

**Test:** trigger a PR with a deliberately large bundle import → the Lighthouse gate should FAIL. Check the `ci-reports-{id}` artifact in the Actions tab — should contain `lighthouse.json` + `lighthouse-out/*.json`.

**Rollback:** delete `lighthouserc.json` and `.github/workflows/lighthouse.yml`, optionally revert `journal/reports/ci/lighthouse-out/` from `.gitignore`. Effect: no frontend performance gate, stack runs as before BOO-45.
**Dependencies:** BOO-2 (ESLint hardening), BOO-32 (reports convention `journal/reports/ci/`). Counterpart to BOO-16.
**Skill source:** `bootstrap/SKILL.en.md` block A.1b + `bootstrap/references/file-templates.en.md` §`lighthouserc.json` + §`lighthouse.yml`.

### BOO-46 — Self-hosted runner + 10% threshold sharpening

**Status:** ✓ partial (perf.yml patch automatic via migrate_boo_46; VPS setup operator-side)
**Effort:** medium (operator setup VPS + runner install) — bundle side small
**Linear:** https://linear.app/owlist/issue/BOO-46
**Auto step:** partial
**Steps:**
1. **`[MANUAL]`** Choose hardware/VPS (see HANDBUCH Appendix I §1): Hostinger sidecar / dedicated VPS / Mac mini. Decision depends on performance-gate frequency and cost sensitivity.
2. **`[MANUAL]`** Install GitHub Actions runner software: Settings -> Actions -> Runners -> New self-hosted runner, then `./config.sh --url ... --token ...` on the VPS (see HANDBUCH Appendix I §2).
3. **`[MANUAL]`** Create systemd service unit: `sudo ./svc.sh install && sudo ./svc.sh start` (HANDBUCH Appendix I §3).
4. **`[AUTO]`** Run `bash migrate-to-v2.sh --issue BOO-46` in the project. The function patches `perf.yml`: `runs-on: ubuntu-latest` -> `runs-on: self-hosted` (with `.boo46-backup` backup), threshold `1.20` -> `1.10` (20% -> 10%), comments updated.
5. **`[MANUAL]`** Runner health check via cron every 6h (HANDBUCH Appendix I §5). Alert when `status != online > 10min`.

**Test:** trigger a bench run via PR → it should run on the self-hosted runner (visible in the Actions tab by the runner name). After multiple runs, watch threshold behaviour — if too many false positives, relax to 15%.

**Rollback:** `cp .github/workflows/perf.yml.boo46-backup .github/workflows/perf.yml` (backup created by migrate_boo_46). Deactivate runner software on the VPS: `sudo ./svc.sh stop && sudo ./svc.sh uninstall && ./config.sh remove --token {RUNNER_TOKEN}`. Effect: back to GitHub-hosted runner with 20% threshold.
**Dependencies:** BOO-16 (performance gate active — otherwise nothing to patch).
**Skill source:** `bootstrap/SKILL.en.md` block D.6 + `bootstrap/scripts/migrate-to-v2.sh` §migrate_boo_46.

### BOO-49 — Document framework tool-independence (CONVENTIONS.md + Tool-Adapter)

**Status:** ✓ included in v2 bundle (docs initiative, no skill-code change)
**Effort:** small (operator side: git pull + read new docs)
**Linear:** https://linear.app/owlist/issue/BOO-49
**Auto step:** yes (docs are part of the bundle)
**Steps:**
1. **`[AUTO]`** `cd ~/Documents/GitHub/claudecodeskills && git pull origin main` — new `bootstrapping/CONVENTIONS.md` + HANDBUCH Appendix K now in the bundle.
2. **`[MANUAL]`** Operator: read `CONVENTIONS.md` once — describes the framework tool-neutrally. Lets you switch tools later (Claude Code → Codex → Cursor → local LLM) without losing the framework.
3. **`[MANUAL]`** Optional: read HANDBUCH Appendix K "Tool-Adapter" if you plan to use a second AI tool (e.g. Codex for background tasks, see BOO-50).

**Test:** `CONVENTIONS.md` is at the `bootstrapping/` top level. HANDBUCH has Appendix K. README.md points to CONVENTIONS.md.

**Rollback:** n/a — pure docs extension, no risk for existing projects.
**Dependencies:** none. Conceptual prerequisite for BOO-50 (Codex integration).
**Skill source:** `bootstrapping/CONVENTIONS.md` + `HANDBUCH.md` Appendix K.

---

## Non-skill Issues (Skipped)

These issues touch operator tooling, meta work or duplicates and require **no** migration in existing projects. They appear in `migration-status.md` with status ✗.

- **BOO-9** — Rollout to the three Hostinger VPS. The rollout itself is not a skill migration; it is the application of this checklist to the VPS projects.
- **BOO-22** — Duplicate (canceled).
- **BOO-23** — This migration checklist (meta issue, self-reference).
- **BOO-30** — Configure Linear workflow states + DoD. Pure operator tool configuration, no repository change.
