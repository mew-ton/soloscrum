---
name: soloscrum-define-story-points
description: "Reference: story point scale and estimation criteria. SP 1=2h, 2=half day, 3=1 day, 5=2 days. Issues estimated over SP 5 must be split before proceeding."
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
- **Owner**: `po-agent` (during `/refine`)
- **Precision**: Rough is fine. Estimate from intuition without detailing every aspect
- **Threshold**: Trigger `suggest_split` when SP > 5 or estimated days > 2
- **Registered in Linear**: No — this is a size-check value only

When Issue SP exceeds the threshold, split the Issue per `soloscrum-define-issue-size` and re-estimate.

### Subtask SP (Dev Layer)

- **Purpose**: The actual value registered in Linear, used for planning and progress tracking
- **Owner**: `dev-agent` (during `/breakdown`)
- **Precision**: Calculate after carefully reviewing AC, affected files, and novelty
- **Registered in Linear**: Yes — set on the subtask's estimate field

---

## SP Table

| SP | Estimated effort | Complexity guide |
|---|---|---|
| 1 | Up to 2 hours | Clear change, 1-2 files, easy to test |
| 2 | Half day (~4 hours) | Small feature addition, 3-5 files |
| 3 | 1 day (~8 hours) | Medium feature addition, multiple components |
| 5 | 2 days (~16 hours) | Large feature addition, new patterns introduced |
| >5 | Do not use | → Split the Issue and re-estimate |

The SP table is shared by both Issue SP and subtask SP.

## Estimation Procedure

### Issue SP (PO Layer)

1. Survey the volume and complexity of the Issue's Goal and AC
2. Estimate intuitively: "How many days would it take one person to implement this?"
3. Map to the SP table
4. If SP > 5 or estimated days > 2, split the Issue

### Subtask SP (Dev Layer)

1. Evaluate AC count, affected file count, and novelty of the subtask
2. Increase by one step if uncertainty is high
3. If estimate exceeds SP 5, a missed Issue split is likely — confirm with user

## Notes

- SP measures **complexity and uncertainty**, not lines of code
- Solo development — do not factor in team velocity
- Avoid under- or over-estimation by comparing against past experience
