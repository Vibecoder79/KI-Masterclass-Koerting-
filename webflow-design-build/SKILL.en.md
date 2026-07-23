---
name: webflow-design-build
description: |
  Builds and reworks Webflow sections/pages via the Webflow MCP with discipline and without
  AI slop. Enforces a hard design-system gate (no build without fixed tokens/DESIGN.md), an
  approval gate via a clickable Artifact prototype BEFORE any live build, and a Webflow-MCP
  playbook of proven build and CMS patterns. Prevents the generic AI look through discipline,
  not through "make it pretty". For recurring website work (own brands and clients).
  Trigger sentences remain in the working language (German) — see SKILL.md.
version: 1.0.0
---

# Webflow Design Build

Disciplined building and redesigning of Webflow sections via the Webflow MCP so the result looks
like a **fixed design system**, not a generic AI default.

## Core idea (honest)

This skill does not make results slop-free through good AI taste, but through three constraints:

1. **Design-system gate (hard):** No build without fixed tokens/form language for this site. The
   skill blocks and routes you through system definition first.
2. **Approval gate:** New design is ALWAYS shown as a clickable Artifact prototype and approved
   before anything is built live (no browser tool → building blind is risky).
3. **Verify, not "looks good":** Render/E2E check and an honest verdict before every publish.

The **direction** (which design) comes from the human/designer. The skill encapsulates craft +
discipline + Webflow knowledge — not a design decision.

## When NOT this skill

- Pure content entry (filling existing CMS items) → do it directly, no skill needed.
- Non-Webflow sites (Next.js/Astro/code) → this skill is Webflow-specific; apply the
  design-system gate and anti-slop thinking analogously, but the MCP playbook does not apply.
- Pure slop check of a finished page → `anti-slop` skill + `references/anti-slop-gate.md`.

## Flow (mandatory order)

### Phase 0 — Design-system gate (HARD, blocks)

Before any build, a **fixed design system** must exist for the site: color tokens (4-6 named hex),
type roles (display + body, real faces), form language (radius, divider pattern, spacing rhythm,
photo treatment), motion rules.

- **Exists?** (site DESIGN.md, `00 Kontext/Branding.md`, an existing style guide, or a
  user-supplied reference like "Richtung C") → proceed to Phase 1.
- **Missing?** → **STOP.** Pin it first:
  - Existing site/reference → skill `design-md-generator` (extract DESIGN.md).
  - Client with CI documents → skill `ci-extraktor` (colors/fonts from client documents).
  - Nothing → define 4-6 tokens + 2 fonts + form language explicitly with the user, in writing,
    before building.
  - Never start from the generic default (see `references/anti-slop-gate.md`, cluster list).

### Phase 1 — Inspect (never build blind)

Always read the existing structure first, capture real IDs and styles:
- `data_sites_tool > get_site` — locales (incl. `cmsLocaleId`), custom domains for publish.
- `data_pages_tool > list_pages` — pageId.
- `data_element_tool > query_elements` / `get_all_elements` — target section, element IDs, classes.
- `data_style_tool > query_styles` (`include_properties`) — **where the CSS actually lives**
  (Webflow classes vs. head freeform). Never assume, always read.
- `data_cms_tool > get_collection_details` — real field slugs when CMS is involved.
- Footer/head freeform (`data_scripts_tool`) for dependent scripts (scroll-pin, slider logic) so
  the rework does not break them.

### Phase 2 — Prototype + approval gate

- Build the new design as a **clickable Artifact prototype** (real tokens/font fallback, real
  content/placeholders). If interactive (slider/tabs): interactive in the Artifact.
- State caveats openly (Artifact CSP blocks external fonts/CDN → fallbacks; live renders real fonts).
- **Wait for approval.** Corrections in the prototype, not live. See `references/prototyp-gate.md`.

### Phase 3 — Build live (Webflow-MCP playbook)

Only after approval. Order + patterns strictly per `references/webflow-mcp-playbook.md`:
- CMS first (collection/fields/items) when dynamic, then structure, then binding, then styles.
- Reuse existing styles instead of inventing; prefix classes to avoid collisions.
- Preserve dependent scripts (the class/structure the script targets must remain).
- Custom visualizations: **self-contained** (no runtime CDN), precomputed offline.

### Phase 4 — Verify + publish

- Verify structurally (bindings set? exactly one target class? code stored fully?).
- Where possible render/E2E check (SVG→PNG via rsvg-convert + Read; or live HTML via curl for
  expected strings). See `references/webflow-mcp-playbook.md` (Verify section).
- **Publish pushes the WHOLE staged site** — get approval first and say so.
- Honest limit: no browser tool → final visual check is on the user.

### Phase 5 — Anti-slop pass (before finishing)

Mandatory pass against `references/anti-slop-gate.md` (the visual counterpart to text `anti-slop`).
For motion also `design-motion-principles` (audit mode).

## Composition with existing skills (do not duplicate)

| Purpose | Skill |
|---|---|
| Extract/define design system | `design-md-generator`, `ci-extraktor` |
| Text slop | `anti-slop` + `00 Kontext/Anti-Slop.md` |
| Motion slop | `design-motion-principles` |
| Image assets | `nanobanana2` |
| Document session | `journal` / daily note |

This skill orchestrates these as sub-steps; it does not reimplement them.

## References

- `references/webflow-mcp-playbook.md` — build/CMS/embed patterns + the proven pitfalls.
- `references/anti-slop-gate.md` — visual slop clusters + mandatory pre-publish checklist.
- `references/prototyp-gate.md` — how the approval prototype is built/communicated.

Do NOT duplicate brand context here — reference SecondBrain: `00 Kontext/Branding.md`,
`00 Kontext/Anti-Slop.md`, project-specific DESIGN.md.
