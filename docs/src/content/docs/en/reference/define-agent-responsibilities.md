---
title: define-agent-responsibilities
description: Spec summary — who creates, mutates, and verifies each soloscrum concept across the lifecycle.
sidebar:
  order: 1
---

`soloscrum-define-agent-responsibilities` is the ownership matrix that ties every concept on the soloscrum board (Issue, subtask, branch, PR, Figma artifact, code, DoD self-check, and the various labels and state values) to exactly one Creator and one set of legal Mutators. Every command and agent declares this skill as a reference and refuses to write to a column it does not own.

## What it does

It pins three rules that prevent races and silent overlaps:

1. Single creator per concept — two roles never create the same kind of record.
2. State transitions are role-gated — only `soloscrum-review` may transition any record to a terminal state (Done / Closed).
3. The verifier is always Review — except for entry-gate SP (PO) and the type label (Dev or UI), which are decisions, not verifications.

The matrix is profile-independent. Concepts and ownership are the same regardless of where the data is stored; storage location is delegated to [`define-tracker-profile`](/reference/define-tracker-profile/).

## When it is consumed

Every soloscrum agent (`soloscrum-po`, `soloscrum-design`, `soloscrum-dev`, `soloscrum-ui`, `soloscrum-review`) declares this skill in its frontmatter. Commands consult it implicitly by deferring to the agents.

## Key inputs and outputs

The skill itself produces no output — it is a reference. Its content is a static matrix mapping each concept to:

- Creator (the role that writes it first)
- Mutator (the role that legitimately changes it during the lifecycle)
- Verifier (the role that confirms it before close)

A row in this matrix is what an agent checks before proposing a write. If the row says some other agent owns the field, the current agent reads the value but does not write it.

## Lifecycle summary

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (type, AC)
               dev      → registers subtasks (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + tokens + states; subtask → in-review
/review        review   → DoD + AC + code; promote PR to ready;
                          subtask → done; surface merge command to user
user           user     → runs `gh pr merge`
```

## See also

- For the human walkthrough, read [Agents and responsibilities](/concept/agent-responsibilities/).
- Canonical contract: [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md).
- Repo-local overrides go in `.claude/rules/agent-overrides.md`.
