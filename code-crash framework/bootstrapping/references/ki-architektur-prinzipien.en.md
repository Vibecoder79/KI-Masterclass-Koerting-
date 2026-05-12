# AI-Ready Architecture Principles (Schrader Ch. 4)

> Single source of truth for `/bootstrap` (proactive anchoring) and `/architecture-review` (reactive checks).
> Schrader Code Crash Ch. 4 §SYSTEM (l. 1806-1808) + §"Why AI-assisted development fails" (l. 1485-1510).

## §1 The 4 Principles (What to do)

These 4 principles are **prerequisites, not options** (Schrader l. 1806) — they must exist before code is written, not after.

| # | Principle | Criterion | Check tool |
|---|-----------|-----------|------------|
| P1 | **Small, independent modules** | Max. 500 LOC, single purpose per module | `cloc`, `wc -l` |
| P2 | **Explicit interfaces** | Strong types, API docs for every public function, ADR for every architecture decision | TypeScript / JSDoc / OpenAPI |
| P3 | **Testability as a baseline** | Unit + Contract + Integration tests, runnable independently, coverage >=80% on new code (BOO-15) | `c8`, `pytest-cov` |
| P4 | **Observable from day one** | Structured JSON logging, distributed tracing, metrics + alerts from commit one (BOO-14) | `pino`, `structlog`, Prometheus |

### Detail: P1 — Small, independent modules

- Each module has exactly **one clearly named purpose** — if the module name contains two verbs ("fetchAndParse"), that is a split signal.
- Hard limit: **500 LOC** excluding tests and comments. Exceptions require an explicit ADR.
- Dependencies always flow **outward** (hub-and-spoke, never circular). Circular imports are a module design fault, not a build problem.
- AI context: Modules >500 LOC typically exceed the context window of an AI assistant — it loses overview and hallucinates dependencies.

### Detail: P2 — Explicit interfaces

- Strong types at **all** module boundaries (TypeScript interfaces, Python dataclasses, OpenAPI schemas).
- Every public function has a short doc line (JSDoc `@param`/`@returns` or Python docstring).
- Every architecture decision gets an ADR in `ARCHITECTURE_DESIGN.md §3` — "that's just how it was" is not an interface.
- AI context: Without explicit types and docs, the AI infers contracts from context — this leads to silent incompatibilities on changes.

### Detail: P3 — Testability as a baseline

- Tests come **before or alongside** code — never as a follow-up step.
- Test pyramid: unit tests (many, fast) > contract tests (module interfaces) > integration tests (few, slow).
- Every new code path has at least one unit test for the happy path and one for the most important failure mode.
- Coverage gate (BOO-15): >=80% on the staged diff — not overall coverage.

### Detail: P4 — Observable from day one

- Structured JSON logging with 6 required fields from the first commit: `timestamp`, `level`, `service`, `trace_id`, `message`, `context`.
- No `console.log` / `print` in production code.
- `/metrics` endpoint in Prometheus format per service (BOO-14).
- 3 required alerts per service: `_down`, `_error_rate_high`, `_p95_slow`.
- AI context: Silent systems cannot be debugged — AI-generated code fails quietly more often than manual code because edge cases are harder to foresee.

---

## §2 The 4 Anti-Patterns (What to avoid)

Direct mirrors of the 4 principles — from Schrader Ch. 4 §"Why AI-assisted development fails" (l. 1485-1510).

| Anti-Pattern | Violates | Symptom | Threshold (BLOCK) |
|-------------|----------|---------|------------------|
| **AP1: The grown monolith** | P1 (small modules) | Modules >500 LOC, mixed purposes, circular imports | >500 LOC or >1 purpose |
| **AP2: Implicit knowledge as architecture** | P2 (explicit interfaces) + P4 (observability) | Decisions only in people's heads, missing ADRs, unstructured logs | Missing ADR for architecture decision, `console.log` in production |
| **AP3: No real module boundaries** | P2 (explicit interfaces) | Direct DB access from multiple modules, no types, circular imports, shared state | Circular import, untyped module boundary |
| **AP4: Tests as an afterthought** | P3 (testability) | Tests written after code (or not at all), coverage <50%, no contract tests | Coverage <60% on new code (warn 60-80%, block <60%) |

### Detail: AP1 — The grown monolith

- **Detection:** Module size >500 LOC (without tests), more than one verb in the module name, functions that have nothing to do with each other sharing the same file.
- **Cause:** Fast feature iteration without module discipline. AI assistants often follow the existing pattern — if the pattern is "everything in one file", it continues that way.
- **Remedy:** Split refactoring via ADR, draw module boundaries explicitly before writing code.

### Detail: AP2 — Implicit knowledge as architecture

- **Detection:** "Ask Peter, he knows." No ADR for decisions. `console.log("I am here")` instead of structured logging. Magic strings without explanation.
- **Cause:** Time pressure + "it was obvious." AI assistants cannot read implicit knowledge — they guess, which leads to drift.
- **Remedy:** ADR for every non-obvious decision, structured logging from day 0.

### Detail: AP3 — No real module boundaries

- **Detection:** Module A directly accesses the DB even though module B is responsible. Circular imports. Shared global state. No TypeScript interfaces or Python dataclasses at module boundaries.
- **Cause:** "It's faster that way." AI assistants reach for the nearest accessor — without an explicit boundary, that is often the wrong module.
- **Remedy:** Interface-first design, type all module boundaries, flag circular imports as ESLint errors.

### Detail: AP4 — Tests as an afterthought

- **Detection:** Tests will be written "later." Coverage <50%. Only manual testing. No CI gate blocking red code.
- **Cause:** "The AI will get the code right." Statistically false — AI code has edge cases that stay invisible without tests.
- **Remedy:** Coverage gate (BOO-15) in `/implement`, test pyramid as a mandatory check in architecture review (BOO-7).

---

## Usage

| Skill | Role | How |
|-------|------|-----|
| `/bootstrap` | Proactive | Writes principles + anti-patterns into `ARCHITECTURE_DESIGN.md §2` during project setup |
| `/architecture-review` | Reactive | Checks all 8 items (4 pro + 4 anti) against the running project |

Schrader: "Those who only check principles in the review have anchored them too late." (Code Crash Ch. 4 l. 1806)
