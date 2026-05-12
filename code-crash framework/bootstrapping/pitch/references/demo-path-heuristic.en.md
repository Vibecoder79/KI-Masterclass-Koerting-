# Demo path heuristic

This heuristic implements step 4 of the `/pitch` skill — the demo path suggestion. It is read by the skill, not executed by the operator manually.

## Purpose

The skill proposes a user journey (e.g. `"User-Onboarding → Search → Checkout"`) that best demonstrates intent fulfillment in the live system. The suggestion ends up in the frontmatter (`demo_path`) and in the body section `## 4. Demo path suggestion` of `PITCH-XX.md`. The operator can override the suggestion during review.

## Two factors

The heuristic combines two signals:

1. **Change intensity since last pitch** — which components have the most commits/LOC delta during the sprint window? Rationale: what changed a lot is worth showing.
2. **Intent relevance** — which components are named in the success criteria of the `related_intents`? Rationale: the demo should visualize intent fulfillment, not random changes.

Both factors are weighted equally (see score calculation).

## Score calculation

Per component:

```
change_score = (commit_count_in_scope * 0.4) + (loc_delta_normalized * 0.6)
intent_score = intents_mentioning_component / total_related_intents
total        = change_score * 0.5 + intent_score * 0.5
```

Definitions:

- `commit_count_in_scope` — commits that touch at least one file of the component, within the sprint window (`git log --since=<sprint-start>`).
- `loc_delta_normalized` — LOC delta (added + removed) of the component divided by the largest LOC delta of any component in the sprint. Yields a value between 0 and 1.
- `intent_score` — share of `related_intents` whose success-criterion text contains the component name (simple keyword search). Value between 0 and 1.

Component ranking is descending by `total`. The top 3–5 are arranged into a user journey order — the skill tries to find a logical path (entry component → core logic → output). When multiple paths are possible, the one with the highest cumulative score is chosen.

## Data sources

| Signal | Source |
|---|---|
| Commits + LOC delta per file | `git log --shortstat --since=<sprint-start>` |
| File → component mapping | `COMPONENT_INVENTORY.md` (BOO-21 — domain knowledge, operator-maintained) |
| Success-criterion text | `intents/INTENT-XX.md` — sections `## 5. Erfolgsmetrik` / `## 5. Success metric` and `## Intent-Statement (final)` |
| Component names for keyword search | From `COMPONENT_INVENTORY.md` (component column) |

## Edge cases

- **First pitch** (no prior `PITCH-XX.md`): there is no "diff since last pitch". The skill falls back to pure intent relevance and proposes the path that demonstrates all `related_intents` for the first time.
- **No `related_intents` specified**: the skill uses change intensity alone and proposes a "highlights" path (top-3 components by `change_score`).
- **No `COMPONENT_INVENTORY.md`**: the skill works at the file level instead of the component level and emits a note in the output: "Recommendation: maintain `COMPONENT_INVENTORY.md` for better path suggestions (see BOO-21)."
- **No commits in the sprint window** (e.g. documentation sprint): `change_score = 0` for all components. `intent_score` alone decides. If that is also 0: the skill proposes no path, sets `demo_path: null`, and emits the note "no automatic suggestion — operator selection required".

## Operator override

The skill's suggestion appears in `PITCH-XX.md` under `## 4. Demo path suggestion` and as the frontmatter field `demo_path`. The operator can freely edit the path during review (step 5 of the skill). The `demo_path` frontmatter field is not overwritten by the skill when the operator has manually adjusted it — on a second run against the same file, the skill respects the existing value.
