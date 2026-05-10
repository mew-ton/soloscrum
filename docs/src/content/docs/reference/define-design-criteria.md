---
title: define-design-criteria
description: Spec summary — feature design validation across scope clarity, dependency identification, and technical feasibility.
sidebar:
  order: 4
---

`soloscrum-define-design-criteria` is the checklist `/validate` (and the planning stage of `/breakdown`) uses to decide whether an Issue is ready to be broken down into subtasks, or whether the PO needs to do another pass first.

## What it does

It defines three evaluation perspectives and turns them into a Pass / Conditional Pass / Fail verdict:

1. **Scope clarity** — is the Goal stated in 1–2 sentences, is the AC verifiable ("user can …" rather than "implement …"), is Out of Scope explicit, does the scope fit a single feature?
2. **Dependencies** — are dependencies on other Issues stated, are external API / service dependencies confirmed, are data changes (schema migrations, etc.) considered?
3. **Technical feasibility** — does the design align with existing architecture, is the tech stack capable (cross-referenced with `.claude/rules/stack.md`), are there performance or security concerns?

## When it is consumed

`soloscrum-validate-feature` (the engine behind `/validate`) reads it directly. The Design agent also consults it when proposing breakdowns during `/breakdown`.

## Key inputs and outputs

Input is an Issue body — Goal, AC, Out of Scope, plus whatever the PO wrote in Notes. Output is a structured evaluation:

- Per perspective: OK / Needs revision plus notes.
- Overall verdict: **Pass** (all OK), **Conditional Pass** (minor revisions needed), or **Fail** (scope unclear, infeasible, or dependency problems).

A Conditional Pass typically loops back to `/refine` for a small touch-up; a Fail loops back for a redesign.

## See also

- Canonical contract: [`skills/soloscrum-define-design-criteria/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-design-criteria/SKILL.md).
- For the AC writing rules used by the scope check, see [`define-issue-format`](/reference/define-issue-format/).
