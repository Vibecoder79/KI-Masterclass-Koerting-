---
title: Anti-Pattern Catalogue (Schrader Ch. 7)
version: 1.0.0
created: 2026-05-11
language: en
source: Schrader "Code Crash" (2026), Chapter 7 "Risks and Anti-Patterns"
---

# Anti-Pattern Catalogue — Sprint and Programme Level

Schrader's 11 anti-patterns from Ch. 7 as an active diagnostic tool. Consumed by the `/sprint-review` skill in the anti-pattern self-diagnosis (Step 7).

**Demarcation from BOO-24 (Ch. 4 architectural APs):**
- Ch. 4 APs (monolith, implicit knowledge, no module boundaries, tests added later) → code/module level → hooked in `/bootstrap` + `/architecture-review`
- **Ch. 7 APs (this file)** → sprint/programme/team level → hooked in `/sprint-review` + HANDBUCH.md

---

## Category I: Process Pathologies

### AP1: Tool Chaos

**Symptom in sprint day-to-day:**
- More than 2 different AI coding tools in use — without central evaluation
- No standardised prompts or workflows
- Each team has its own methods; onboarding grows more complex instead of simpler

**Diagnostic question for /sprint-review:**
> "More than 2 different AI coding tools in use — without central evaluation?"

**Countermeasures:**
1. Define an official toolset (1–2 primary tools) — uniformity beats tool variety
2. Channel experiments with new tools into sandbox environments
3. Share findings centrally (wiki, regular meetings)
4. Evaluate new tools centrally before rollout — no individual rollout

**Skill coverage:** open (no BOO-issue directly)

---

### AP2: Review Overload

**Symptom in sprint day-to-day:**
- Code reviews regularly take >24h
- Experienced developers spend >50% of their time on reviews
- Teams report "waiting for approval" as main blocker

**Diagnostic question for /sprint-review:**
> "Did PR reviews regularly take >24h in the last sprint?"

**Countermeasures:**
Tier reviews by risk level:

| Code type | Review tier |
|-----------|-------------|
| Critical (auth, payment, PII) | Full review + security scan |
| Standard (business logic, APIs) | Normal code review |
| Low risk (tests, docs) | Automated check + spot-check |
| Generated standard code | Automated check only |

Expand automated reviews (linting, SAST, coverage). Train junior developers to review AI-generated code.

**Skill coverage:** ✅ partial — BOO-18 (Mandatory Human Review for critical paths — auth/payment/PII)

---

### AP3: Feature Inflation

**Symptom in sprint day-to-day:**
- "We can build it quickly" as the most common argument for new features
- Nobody measures whether features are actually used
- Users complain about "too much" rather than "too little"

**Diagnostic question for /sprint-review:**
> "Were features built without intent-linkage — just because they were 'quick to do'?"

**Countermeasures:**
1. **Outcome check:** every feature must contribute to a clear goal. If not visible, don't build it.
2. **Make opportunity costs visible:** every hour on feature A is missing from feature B.
3. **Kill criteria:** when is a feature removed again? (e.g. <5% usage after 30 days)
4. **User validation before development** — saves the most time.

"Because we can" is not a reason. "Because customers need it" is.

**Skill coverage:** ✅ partial — BOO-1 (/intent skill), BOO-10 (intent propagation through pipeline)

---

## Category II: Quality Pathologies

### AP4: Security as Finish Line

**Symptom in sprint day-to-day:**
- Security review only happens at the end of the pipeline, just before production
- Regular conflicts with the security team due to late feedback
- High rate of "accepted risks" due to deadline pressure

**Diagnostic question for /sprint-review:**
> "Are security checks done as the last step before deployment rather than in the pipeline?"

**Countermeasures:**
Shift security left:
1. Security checks in the IDE — while writing
2. Automatic scans on every commit (pre-commit + CI)
3. Dependency checks before merging
4. Security training for all developers (not only specialists)

AI-generated code needs especially early review. AI optimises for "works", not for "is secure".

**Skill coverage:** ✅ BOO-3 (Semgrep auto-setup), BOO-4 (Semgrep gate in /implement), BOO-5 (SonarQube Cloud), BOO-18 (Human Review for critical paths)

---

### AP5: Technical Debt in Turbo Mode

**Symptom in sprint day-to-day:**
- Rising duplication rates in the code (SonarQube shows it)
- Conflicting architecture patterns between modules ("why is that built differently?")
- Coding tools can no longer fit the whole project in the context window
- DORA Report 2024: 25% more AI usage → 7.2% less delivery stability

**Diagnostic question for /sprint-review:**
> "Are duplication rates or conflicting architecture patterns rising in the code?"

**Countermeasures:**
1. **Architecture reviews** regularly — not just code reviews
2. **Duplication metrics on a par** with coverage
3. **15% rule:** reserve 15% of the development budget for debt reduction
4. **Use AI for debt analysis** — irony: AI finds the debt AI caused
5. **Debt ceilings as hard limits:** "no new feature if duplication exceeds X%"
6. **Strict modularisation** — every module fully representable within the context window

**Skill coverage:** ✅ partial — BOO-7 (/architecture-review AI-readiness checklist), BOO-15 (coverage gate ≥80%)

---

### AP6: Experience Debt

**Symptom in sprint day-to-day:**
- The "how do I do that again?" effect with regular users
- Rising support volume for questions an intuitive product would never trigger
- Features exist but are not found or used
- Conflicting interaction patterns across features

**Diagnostic question for /sprint-review:**
> "Were features shipped without a UX/design review — 'design comes later'?"

**Countermeasures:**
1. **Make experience debt visible:** count conflicting interaction patterns
2. **Design check as a gate** on a running candidate, not on a mockup
3. **15% budget for UX unification** — analogous to the 15% rule for technical debt
4. **Feedback loops with real users:** measure HOW features are used

A technically clean product with poor experience loses to one that feels good but is technically questionable. Experience is not an add-on — it is the product.

**Skill coverage:** → HANDBUCH.md (organisational, not skill-detectable through gates)

---

### AP10: Slopware Instead of Software

**Symptom in sprint day-to-day:**
- Features appear faster, but nobody measures their value
- Open bugs grow despite more fixes
- "47 features this week!" — but which ones does anyone use?
- Documentation systematically lags behind

**Diagnostic question for /sprint-review:**
> "More features than in previous sprints — but declining outcome measurement?"

**Countermeasures:**
1. **Outcome before output:** don't count what is delivered — measure what it achieves
2. **Automate quality gates:** no code without tests, no deployment without security scan. No exceptions.
3. **Deliberately small:** fewer features, but better. Requires courage when competitors flood the market.
4. **Slopware as opportunity:** those who maintain quality while others flood will float to the top.

**Skill coverage:** ✅ partial — BOO-12 (dependency + slopsquatting protection)

---

## Category III: Culture Pathologies

> The following APs (AP7, AP8, AP9, AP11) are not detectable through automatic gates. They are reflection points for sprint retros and leaders. Details and recommendations in HANDBUCH.md §Anti-Patterns at Programme Level.

### AP7: Responsibility Diffusion

**Symptom in sprint day-to-day:**
- When problems occur, people look for who is to blame rather than the root cause
- "The AI did it that way" as an excuse
- Retrospectives produce no clear accountabilities

**Diagnostic question for /sprint-review:**
> "Did anyone say 'the AI did it that way' when something went wrong?"

**Skill coverage:** → HANDBUCH.md §Anti-Patterns at Programme Level

---

### AP8: Speed Without System

**Symptom in sprint day-to-day:**
- No time for tests ("we need to ship")
- Rollbacks more frequent than stable deployments
- Team celebrates deployment frequency, not deployment quality

**Diagnostic question for /sprint-review:**
> "More than 1 rollback in the last sprint due to missing tests or missing observability?"

**Countermeasures (short form):** System first — tests, security checks, rollback <5min, alerts. Then increase speed.

**Skill coverage:** ✅ partial — BOO-14 (observability), BOO-15 (coverage), BOO-16 (performance baseline)

---

### AP9: Individual-First as Isolation

**Symptom in sprint day-to-day:**
- "I already built that" — "Me too, but better!"
- No shared architecture decisions
- Documentation is personal, not team-wide

**Diagnostic question for /sprint-review:**
> "Is there duplicate work because architecture decisions were not shared?"

**Skill coverage:** → HANDBUCH.md §Anti-Patterns at Programme Level

---

### AP11: The Political Saboteurs

**Symptom in sprint day-to-day (3 types):**
- *Envy saboteur:* code reviews that take too long, standards suddenly non-negotiable, scepticism packaged as constructive criticism
- *Power player:* strategic concerns in steering committees, pilot projects starved of resources
- *Fear blocker:* "we need a three-week analysis" for every simplification

**Diagnostic question for /sprint-review:**
> "Is there a pattern of systematic blockers from the same people?"

**Countermeasures:** Recognise the pattern, not individual actions in isolation. Follow the budget and influence — who loses from the transformation? Those are the risk zones. Address constructively before it becomes destructive.

**Skill coverage:** → HANDBUCH.md §Anti-Patterns at Programme Level

---

## Reference

Schrader "Code Crash" (2026), Chapter 7 "Risks and Anti-Patterns":
- AP1 Tool chaos — L. 3646
- AP2 Review overload — L. 3677
- AP3 Feature inflation — L. 3716
- AP4 Security as finish line — L. 3752
- AP5 Technical debt in turbo mode — L. 3788
- AP6 Experience debt — L. 3853
- AP7 Responsibility diffusion — L. 3908
- AP8 Speed without system — L. 3942
- AP9 Individual-first as isolation — L. 3975
- AP10 Slopware instead of software — L. 4011
- AP11 The political saboteurs — L. 4082
