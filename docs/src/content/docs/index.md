---
title: soloscrum docs
description: Human-facing companion documentation for the soloscrum framework.
---

This site is the **human-facing companion** to the [soloscrum](https://github.com/mew-ton/soloscrum) framework. It is a place for hand-written explanations aimed at people — onboarding notes, conceptual overviews, command walkthroughs, and the policies a human actively uses or judges against — written separately from the framework's machine-readable spec files.

If you are new, start at [Getting started](/onboarding/) — it walks you from `/plugin install` to filing your first Issue with `/refine`. From there:

- [Concept](/concept/tracker-profile/) explains the why (tracker profiles, agent responsibilities, PR lifecycle, code review process).
- [Policies](/policies/issue-format/) covers the five rules `/refine` and `/review` decide against.
- [Commands](/commands/refine/) walks through `/refine`, `/breakdown`, `/develop`, and `/review` in lifecycle order.

## Where the AI contract lives

The authoritative source of soloscrum's behaviour for AI agents lives in the repository itself, **not** on this site:

- `skills/` — skill specifications (the contract every command and agent reads)
- `agents/` — agent role definitions
- `commands/` — `/refine`, `/breakdown`, `/develop`, `/review` command specs
- `CLAUDE.md` — repo-level instructions

This documentation site **references** those files but does not import or transform them. The two surfaces are kept independent on purpose: the spec files are tuned for AI consumption, while these pages are written for humans to read top-to-bottom.
