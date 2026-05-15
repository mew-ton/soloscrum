---
name: soloscrum-define-issue-size
description: "Reference: Issue and Subtask split criteria. Issues split when they bundle multiple independent intents (SP > 5 or subtask count > 5 are mis-scope smells, not hard work-volume limits). /breakdown fires when delivering one intent as a single PR would be unreviewable. Defines the suggest_split action."
user-invocable: false
---

# soloscrum-define-issue-size

Issue size gate and Subtask split criteria.

## Concept

soloscrum's split criteria operate on **intent coherence**, not raw work volume:

- An **Issue** splits when it bundles more than one independent intent. The numeric thresholds below are *signals that mis-scoping is likely*, not hard limits on work size. A large but coherent single intent is not split — its delivery is sliced by `/breakdown` instead.
- **`/breakdown` (Subtask creation)** fires when delivering one Issue's intent as a single PR would produce an unreviewable PR. This is a delivery / reviewability question, not a scope question.

Both criteria flow from the two-tier model in `soloscrum-define-issue-format`: Issue = intent, Subtask = work slice of that intent. See the Issue-vs-Subtask discriminator in that file for the underlying conditions.

## Thresholds (signals, not hard limits)

```yaml
max_sp: 5
max_subtasks: 5
max_estimated_days: 2
action_on_exceed: suggest_split
```

## Evaluation

When any of the following holds, evaluate whether the Issue is actually bundling multiple intents:

| Metric | Threshold | What it signals |
|---|---|---|
| SP | > 5 | The (scope × uncertainty) estimate is so high that the Issue likely holds more than one independent "why + done." Re-read the AC: are there multiple "what makes this satisfied" answers that do not share a unifying intent? |
| Subtask count | > 5 | If a single intent needs more than ~5 reviewable PRs to deliver, it is **probably** multiple intents that were mistakenly combined. Mis-scope smell — return to `/refine`. |
| Estimated days | > 2 (calibration only) | Coarse signal that scope / uncertainty estimate is probably too low. Not a primary criterion. |

If the answer to the intent question is "no, this is one coherent intent that just happens to be large," the Issue stays — the work is then handled by `/breakdown` into multiple Subtasks (delivery slices), not by Issue split.

**Edge case — confirmed coherent intent but still > 5 reviewable PRs needed.** Re-evaluation says this is one intent (the candidate parents in the discriminator's condition 2 don't subsume it; the AC has one unifying done), but the delivery genuinely requires more than 5 reviewable PRs — e.g. a major migration, a sweeping internal refactor. Attempt one more delivery-slicing pass to see if related slices can collapse without losing reviewability. If still > 5 after that second pass, treat as analogous to the refactoring exception below: surface the situation and defer to user judgment before proceeding.

## `/breakdown` trigger

`/breakdown` produces Subtasks when delivering one Issue's intent as a single PR would produce an unreviewable PR. The question to ask: "If I tried to land this whole intent in one PR, would the diff be too large or too cross-cutting for a reviewer to verify the AC against?"

- One PR is reviewable → **no `/breakdown` needed**; go directly to `/develop` (per `CLAUDE.md`'s "Issues that fit within a single develop unit can skip this step"; branch-per-Issue mode of `soloscrum-define-branch-commit`).
- One PR would not be reviewable → `/breakdown` into Subtasks, each carrying its own reviewable slice. Subtasks slice the *delivery*, not the intent — see `soloscrum-define-issue-format`'s Subtask Body section.

## suggest_split Action

When evaluation indicates likely intent bundling (not just large delivery), `/refine` proposes a split.

### Split axes (Issue level)

When the diagnosis is "multiple intents bundled," propose splitting along one of:

- **Feature axis** — MVP vs extensions, or distinct user-facing capabilities. Each yields its own intent (own why, own done).
- **Phase axis** — *only when* the phase has its own independent "done" (e.g. "performance hardening" with its own SLO that can be verified on its own terms). A phase that has no done of its own is *not* a separate intent — it is delivery work and belongs in `/breakdown`, not in Issue split.

The historical **layer axis** (backend / frontend) is **not** an Issue split axis — backend and frontend of one feature share one intent and one done. Splitting an Issue along layer produces fragments whose AC ("user can reset password") cannot be satisfied independently — see the Issue-vs-Subtask discriminator in `soloscrum-define-issue-format`. Layer-axis splits belong in `/breakdown` as Subtask delivery slices.

### Procedure

1. Present split proposals along the axes above. Each candidate split is itself a candidate Issue — confirm it can carry its own Background / Goal / AC / Out of Scope per `soloscrum-define-issue-format` (apply the Issue-vs-Subtask discriminator's two conditions: self-contained checkable outcome + not-merely-a-slice).
2. Confirm each split Issue falls within thresholds.
3. Obtain user approval before creating split Issues.

## Notes

`max_sp: 5` operates on the scope × uncertainty SP scale defined in `soloscrum-define-story-points` — not a time budget. After this re-derivation, the dominant driver of the threshold is the **uncertainty axis** (multiple unresolved decisions across multiple subsystems), which correlates strongly with "are these actually multiple intents?" The scope axis (raw work volume) does not by itself force an Issue split — large-but-coherent intents are sliced by `/breakdown`, not by Issue split.

`max_estimated_days` is retained as a coarse calibration check for the PO during `/refine`: if the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope / uncertainty estimate is probably too low. Still not the primary criterion.

## Exceptions

- Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment. (A refactor's "intent" is "the codebase is in state X" — a single coherent intent regardless of file count or PR count.)
