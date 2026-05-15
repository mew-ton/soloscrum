---
name: soloscrum-define-story-points
description: "Reference: story point scale and estimation criteria. SP is anchored on scope x uncertainty (size class, not a time unit); SP 5 is the upper bound and Issues estimated above it are mis-scope smells signalling likely intent bundling — return to /refine for Issue split per soloscrum-define-issue-size."
user-invocable: false
---

# soloscrum-define-story-points

SP definition and estimation criteria.

## Two-Level SP Structure

soloscrum uses SP estimation at two levels: **Issue level (PO layer)** and **subtask level (Dev layer)**.

### Why Two Levels?

Tasks can be decomposed infinitely. The scope of a root task is entirely flexible — "implement the app", "build the auth feature", "build the login screen" are all valid roots. Because of this, a layer is needed before breakdown to ask: "is this Issue actually a manageable size?" Entering breakdown with an oversized Issue causes subtask explosion and makes tracking unmanageable.

The lightweight estimate in the PO layer serves as this **entry gate**.

### Issue SP (PO Layer)

- **Purpose**: Determine whether the Issue is a manageable size
- **Owner**: `soloscrum-po` (during `/refine`)
- **Precision**: Rough is fine. Estimate scope and uncertainty from intuition without enumerating every file
- **Threshold**: Trigger `suggest_split` when SP > 5
- **Registered in tracker**: No — this is a size-check value only, never written to any tracker storage

When Issue SP exceeds the threshold, treat as a mis-scope smell — the Issue likely bundles multiple intents — and return to `/refine` for Issue split per `soloscrum-define-issue-size`, then re-estimate each split Issue. (A coherent single intent that genuinely needs > 5 SP worth of work is delivered through `/breakdown` Subtask slices, not by Issue split — see `soloscrum-define-issue-size` for the distinction.)

### Subtask SP (Dev Layer)

- **Purpose**: The actual value registered in the tracker, used for planning and progress tracking
- **Owner**: `soloscrum-dev` (during `/breakdown`)
- **Precision**: Calculate after carefully reviewing the Subtask's slice scope (the "what" sentence and any checklist items per `soloscrum-define-issue-format`'s Subtask Body section; Subtasks do not carry their own AC), affected files, and novelty
- **Registered in tracker**: Yes — storage location depends on the active profile (per `soloscrum-define-tracker-profile`):
  - `github-only` → GH Projects v2 `SP` Number field
  - `linear+github` → Linear subtask `estimate` field
- Set via `soloscrum-tracker-{github|linear}-set-sp` (typically inlined at subtask creation)

---

## SP Table

SP is a **size class anchored on scope x uncertainty** — not a time unit. The "Calibration" column lists observed agent runtimes / token budgets so the scale can be sanity-checked, but those numbers are not the unit and must not be used as the primary input.

| SP | Scope | Uncertainty | Calibration (observed, not the unit) |
|----|-------|-------------|---|
| 1  | 1 file / 1 concern | All decisions known (AC fully prescribes the change) | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 files / single skill area | 1 minor decision | ~100K-200K tokens, agent ~10-20 min |
| 3  | Single subsystem cross-cut | 1-2 design decisions | ~200K-500K tokens, agent ~20-45 min |
| 5  | Multi-subsystem cross-cut | Multiple design decisions | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (mis-scope signal) | (mis-scope signal) | Do not register — treat as "this Issue likely bundles multiple intents," return to `/refine` and split per `soloscrum-define-issue-size`, re-estimate each split Issue. A coherent single intent that genuinely needs >5 SP worth of work is delivered through `/breakdown` Subtask slices rather than by Issue split. |

The SP table is shared by both Issue SP and subtask SP.

## Estimation Procedure

### Issue SP (PO Layer)

1. Read the Goal and AC to identify scope: how many subsystems does the change touch, and how many concerns are bundled into the Issue?
2. Identify uncertainty: how many open design decisions remain after AC? Is any part novel (no precedent in this repo)?
3. Map (scope, uncertainty) to the SP table — both axes must fit; pick the higher row when in doubt
4. If SP > 5, treat as a mis-scope smell — return to `/refine` and split per `soloscrum-define-issue-size`. A coherent single intent that genuinely needs > 5 SP worth of work goes to `/breakdown` (delivery slicing) instead, not Issue split.

### Subtask SP (Dev Layer)

1. Count affected files and concerns from the Subtask's slice scope (its "what" and checklist per `soloscrum-define-issue-format`'s Subtask Body — Subtasks do not have their own AC; refer to the parent Issue's AC for the broader contract); locate the corresponding Scope column
2. Count remaining design decisions (anything the parent's AC and the Subtask's "what" do not prescribe verbatim) and judge novelty against this repo's existing patterns; locate the corresponding Uncertainty column
3. Pick the higher row if scope and uncertainty disagree
4. If estimate exceeds SP 5, a missed Issue split is likely — confirm with user

## Notes

- **SP measures scope and uncertainty, not time.** This is the primary basis for the scale; the Calibration column is observation only, used to sanity-check the chosen row.
- Time anchors were intentionally removed: model speed shifts release-to-release (today's "2 hours" becomes next month's "20 minutes"), agents run in parallel which warps wall-clock comparisons, and human time vs AI agent time do not map linearly — pinning SP to a clock unit made the scale unstable.
- Past Issues with established SP can be used to triangulate: if the current Issue is "obviously bigger than #X (SP 2) and obviously smaller than #Y (SP 5)", SP 3 is the answer regardless of any timing intuition.
- Solo development — do not factor in team velocity.
