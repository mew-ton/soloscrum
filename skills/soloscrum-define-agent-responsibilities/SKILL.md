---
name: soloscrum-define-agent-responsibilities
description: "Reference: which agent or command creates, transitions, and verifies each soloscrum concept (Issue, Subtask, SP, type, priority, state, branch, PR, etc.). Tracker-profile-independent — use together with soloscrum-define-tracker-profile."
user-invocable: false
---

# soloscrum-define-agent-responsibilities

Defines who is responsible for what across the soloscrum lifecycle. **Tracker-profile-independent** — concepts are the same regardless of where they are stored. For storage location and API per concept, see `soloscrum-define-tracker-profile`.

## Roles

| Role | Agent | Primary command(s) |
|---|---|---|
| Product Owner | `soloscrum-po` | `/refine` |
| Design | `soloscrum-design` | `/validate`, `/breakdown` (plan stage) |
| Dev | `soloscrum-dev` | `/breakdown` (register stage), `/develop` |
| UI | `soloscrum-ui` | `/design-ui` |
| Review | `soloscrum-review` | `/review` |

## Concept Ownership Matrix

For each concept, the **Creator** writes it first, the **Mutator** changes it during the lifecycle, and the **Verifier** confirms it before close. Every other role reads the value.

| Concept | Creator | Mutator | Verifier |
|---|---|---|---|
| Issue (parent) | po | po (refine; close via `/refine` janitor when sub-issues are all done) — agents do **not** close at verdict time; merge-time GH auto-close + janitor cover this (see `soloscrum-define-pr-lifecycle`, "Issue close happens at merge") | review |
| Issue SP (size-check) | po | po | po (entry gate) |
| Issue Priority | po | po | — |
| Issue dependencies | po | design (refine plan) | review |
| Issue AC | po | po (refinement only — design does **not** derive Subtask AC since Subtasks have no AC per `soloscrum-define-issue-format`) | review (intent-level sign-off when all Subtasks of the parent close, OR full-AC verification on Issues without Subtasks) |
| Subtask record | dev (during `/breakdown`) | dev/ui (own state), review (Done) | review |
| Subtask Type | design (proposes) → dev (applies) | — | dev/ui (consumes for routing) |
| Subtask SP | dev | — | review |
| Subtask Checklist | design (during `/breakdown` — slice scope: "what" + concrete steps; not AC) | dev/ui (during implementation) | review (per-Subtask correctness + no regression; intent-level AC sign-off is at the parent Issue, not here) |
| Subtask / no-Subtask Issue State (`/develop` target) | dev (develop type) / ui (design-ui type) — to In Review | review — to Done | review |
| Branch | dev | — | review (PR check) |
| Commit | dev | — | review |
| PR | dev (creates as draft) | review (promote to ready) — **user merges** | review |
| Figma artifact | ui | ui | review (optional design fidelity check) |
| Code | dev | dev | review |
| DoD self-check | dev/ui (own work) | — | review (final) |
| Type label registration | dev (during breakdown) | — | — |

## Lifecycle Summary

```
/refine        po       → Issue (with size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (with type, Checklist / slice scope — Subtasks have no AC per soloscrum-define-issue-format)
               dev      → registers subtasks (with SP, type label)
/develop       dev      → branch + code + draft PR; transitions target (Subtask or no-Subtask Issue per
                           soloscrum-define-branch-commit) to In Review
/design-ui     ui       → Figma + tokens + states; transitions Subtask to In Review
/review        review   → DoD + AC + code; promotes PR to ready; transitions Subtask to Done;
                           surfaces merge command to user (Issue close happens at merge,
                           not at verdict — see soloscrum-define-pr-lifecycle)
user           user     → runs `gh pr merge` (the only irreversible PR transition is the user's gate);
                           merge fires GH `Closes #` auto-close on referenced Issues
/refine        po       → janitor sweep at start: (a) closes parent Issues whose Sub-issue tree is fully closed
                           (the only close path for parents, since per-Subtask PRs do not reference the parent
                           via Closes #); (b) closes standalone Issues whose direct merged PR did not fire GH's
                           auto-close (safety-net case)
```

## Cross-cutting Rules

- **Single Creator per concept** — never let two roles create the same record (avoids duplicate Subtasks etc.)
- **State transitions are role-gated** — only `review` may transition any record to a terminal state (Done / Closed)
- **Verifier is always `review`** — except for the entry-gate SP (po) and type-routing (dev/ui), which are decisions, not verifications
- **Repo-local overrides** in `.claude/rules/agent-overrides.md` take precedence

## How to consume this skill

Every agent and command must:

1. Resolve **which concepts it touches** in this matrix
2. Resolve **where each concept is stored** in `soloscrum-define-tracker-profile`
3. Refuse to create or mutate concepts outside its assigned column

Agents must declare both skills as references in their frontmatter.
