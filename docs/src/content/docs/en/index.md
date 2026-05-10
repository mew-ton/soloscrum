---
title: soloscrum docs (work in progress)
description: Human-facing companion documentation for the soloscrum framework.
---

This site is the **human-facing companion** to the [soloscrum](https://github.com/mew-ton/soloscrum) framework. It is a place for hand-written explanations aimed at people — onboarding notes, conceptual overviews, command walkthroughs, and reference material — written separately from the framework's machine-readable spec files.

The site is currently a stub. Concept, Reference, Commands, and Onboarding sections will be added in subsequent subtasks (see issues [#47](https://github.com/mew-ton/soloscrum/issues/47) and [#48](https://github.com/mew-ton/soloscrum/issues/48)).

## Where the AI contract lives

The authoritative source of soloscrum's behaviour for AI agents lives in the repository itself, **not** on this site:

- `skills/` — skill specifications (the contract every command and agent reads)
- `agents/` — agent role definitions
- `commands/` — `/refine`, `/breakdown`, `/develop`, `/review` command specs
- `CLAUDE.md` — repo-level instructions

This documentation site **references** those files but does not import or transform them. The two surfaces are kept independent on purpose: the spec files are tuned for AI consumption, while these pages are written for humans to read top-to-bottom.
