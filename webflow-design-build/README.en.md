# webflow-design-build

A Claude Code skill that builds Webflow sections and pages via the Webflow MCP with **discipline
and without slop**. It prevents the generic AI look not through "good taste" but through three
constraints: a hard design-system gate, an approval gate via a clickable Artifact prototype before
the live build, and verify-before-publish. For recurring website work on own brands and client
projects.

## Problem it solves

By default, AI builds websites in the generic look (cream + serif + terracotta, Inter, everything
centered, `rounded-lg`). This skill instead forces: pin a fixed design system first, then build,
then verify. It also bundles the hard-won Webflow-MCP craft (collection-list binding, CMS locales,
HtmlEmbed code, self-contained visualizations) so it need not be re-derived every project.

## Installation & usage

The skill lives under `~/.claude/skills/webflow-design-build/` and is auto-detected. Invoke via
trigger sentences (German, see SKILL.md) or `/webflow-design-build`. Requires an active Webflow MCP
server; write access to collections for CMS work.

## Flow (phases)

- **Phase 0 — design-system gate (hard):** no build without fixed tokens/form language; routes to
  `design-md-generator` or `ci-extraktor`, or forces explicit definition.
- **Phase 1 — inspect:** structure, styles (where the CSS lives), freeform scripts, CMS fields.
- **Phase 2 — prototype + approval:** clickable Artifact prototype, wait for sign-off.
- **Phase 3 — build live:** per the Webflow-MCP playbook (CMS → structure → binding → styles),
  preserving dependent scripts.
- **Phase 4 — verify + publish:** structural + render/E2E checks, then publish with approval.
- **Phase 5 — anti-slop pass:** mandatory checklist against the visual slop clusters.

## File structure

```
webflow-design-build/
├── SKILL.md / SKILL.en.md
├── README.md / README.en.md
├── references/
│   ├── webflow-mcp-playbook.md
│   ├── anti-slop-gate.md
│   └── prototyp-gate.md
├── webflow-design-build-overview.excalidraw / .png
└── webflow-design-build-overview.en.excalidraw / .en.png
```

## Composition with other skills

Orchestrates existing skills instead of reimplementing them: `design-md-generator`/`ci-extraktor`
(system), `anti-slop` (text), `design-motion-principles` (motion), `nanobanana2` (images),
`journal` (docs). Brand/CI context lives in SecondBrain, not the skill.

## Background

Distilled from real build work on owlist.ch/team (core-team tiles "Richtung C", locations map,
partner slider). Goal: build multiple websites at consistent quality without falling back into the
AI default or relearning the Webflow pitfalls each time.

## Sources

- Anthropic `artifact-design` (anti-slop clusters, design fundamentals).
- SecondBrain `00 Kontext/Anti-Slop.md`, `Branding.md`, `Schreibstil.md`.
- Webflow MCP `webflow_guide_tool` (tool playbook).
