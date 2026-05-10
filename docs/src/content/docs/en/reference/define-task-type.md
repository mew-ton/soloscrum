---
title: define-task-type
description: Spec summary — subtask types `develop` and `design-ui`, assignment criteria, and the rule that UI features must be split.
sidebar:
  order: 11
---

`soloscrum-define-task-type` is the small but load-bearing rule that subtasks come in exactly two types and that UI features always get split into a design-then-develop pair.

## What it does

It pins two type values and which agent owns each.

| Type | Definition | Assigned agent |
|---|---|---|
| `develop` | Any work involving code changes | `soloscrum-dev` |
| `design-ui` | Figma, design tokens, and UI pattern work | `soloscrum-ui` |

The type lives as a label on the subtask: `type:develop` or `type:design-ui`. In `github-only`, this is a GH label on the Sub-issue; in `linear+github`, this is a Linear label on the subtask. The label values are identical across profiles.

## Assignment criteria

Assign **`develop`** for backend implementation, frontend implementation, component behavior, tests, and infrastructure configuration.

Assign **`design-ui`** for new Figma component production, design token definition and updates, UI pattern definition, and screen transition / state flow design.

## The split rule

A single subtask must never carry both types. When a feature has UI:

- Create the `design-ui` subtask first.
- The `develop` subtask follows and depends on it — it does not start until the design subtask is reviewed and complete.

This keeps the Figma source of truth ahead of the implementation, which avoids the failure mode where the developer agent invents a UI that contradicts the designer agent's intent.

## When it is consumed

`soloscrum-split-into-tasks` (`/breakdown`) calls this skill when assigning a type to each proposed subtask. The Dev agent applies the corresponding label when it registers the subtask via `soloscrum-tracker-{github|linear}-create-subtask`.

## Key inputs and outputs

Input is the subtask's AC and intent. Output is one of `develop` / `design-ui`, plus the matching label.

## See also

- Canonical contract: [`skills/soloscrum-define-task-type/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-task-type/SKILL.md).
- For UI tokens and pattern conventions referenced by `design-ui` subtasks, see [`define-ui-standards`](/reference/define-ui-standards/).
