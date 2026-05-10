---
title: define-ui-standards
description: Spec summary — design token categories, naming convention, required component states, and WCAG AA accessibility requirements.
sidebar:
  order: 13
---

`soloscrum-define-ui-standards` is the conventions skill that `soloscrum-ui` (and the design pass during `/breakdown`) follows when producing Figma artifacts and design tokens.

## What it does

It pins three groups of conventions:

1. **Design tokens** — categories (`color`, `typography`, `spacing`, `radius`, `shadow`, `motion`) and the naming convention `{category}/{semantic}/{variant}`, e.g. `color/brand/primary`, `typography/body/md`, `spacing/component/md`.
2. **Component states** — every interactive component must define Default, Hover (desktop), Focus (accessibility), Disabled (when applicable), Loading (when async), and Error (when validation exists). Active / Pressed is optional.
3. **Accessibility** — WCAG AA contrast (4.5:1 for normal text, 3:1 for large 18px+), 44 × 44px minimum touch target, visible focus indicator.

## When it is consumed

`soloscrum-design-ui-task` (the engine behind `/design-ui`) reads it directly. The Design agent also references it when proposing UI subtasks during `/breakdown`.

## Key inputs and outputs

Input is the subtask AC plus the existing Figma file (components, tokens). Output is a Figma artifact with all required states defined, tokens applied per the naming convention, and accessibility checks passed.

## Adding new patterns

When existing patterns cannot cover a use case:

1. Confirm with the user before creating a new pattern.
2. Add it to the Figma component library.
3. Document its naming and usage criteria in the Figma component description.

## Notes

The skill ships generic initial values. Project-specific tokens and patterns should override these in the project's Figma file or in `.claude/rules/`.

## See also

- Canonical contract: [`skills/soloscrum-define-ui-standards/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-ui-standards/SKILL.md).
- For the type that drives this skill's invocation (`design-ui`), see [`define-task-type`](/reference/define-task-type/).
