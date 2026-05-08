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
| Issue (parent) | po | po (refine), review (close) | review |
| Issue SP (size-check) | po | po | po (entry gate) |
| Issue Priority | po | po | — |
| Issue dependencies | po | design (refine plan) | review |
| Issue AC | po | design (refine into subtask AC) | review |
| Subtask record | dev (during `/breakdown`) | dev/ui (own state), review (Done) | review |
| Subtask Type | design (proposes) → dev (applies) | — | dev/ui (consumes for routing) |
| Subtask SP | dev | — | review |
| Subtask AC | design (during breakdown) | — | review |
| Subtask State | dev (develop type) / ui (design-ui type) — to In Review | review — to Done | review |
| Branch | dev | — | review (PR check) |
| Commit | dev | — | review |
| PR | dev | review (merge) | review |
| Figma artifact | ui | ui | review (optional design fidelity check) |
| Code | dev | dev | review |
| DoD self-check | dev/ui (own work) | — | review (final) |
| Type label registration | dev (during breakdown) | — | — |

## Lifecycle Summary

```
/refine        po       → Issue (with size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (with type, AC)
               dev      → registers subtasks (with SP, type label)
/develop       dev      → branch + code + PR; transitions Subtask to In Review
/design-ui     ui       → Figma + tokens + states; transitions Subtask to In Review
/review        review   → DoD + AC + code; merges PR; transitions Subtask to Done;
                           closes Issue when all Subtasks are Done
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
