---
title: Getting started
description: Adopt soloscrum into a new repository — install the plugin, choose a tracker profile, configure repo rules, and file your first Issue with /refine.
sidebar:
  order: 1
---

This page is for the developer adopting soloscrum into a new repository. By the end of it you will have the plugin installed, a tracker profile selected, optional repo-level rules configured, and your first Issue filed via `/refine`.

## Prerequisites

- **Claude Code** installed and authenticated.
- **GitHub CLI (`gh`)** installed, authenticated against the GitHub account that owns the repo, and able to read / create / edit Issues and PRs on the target repo.
- **Repository on GitHub** — soloscrum treats GitHub as the canonical Issue store regardless of tracker profile.
- (Optional) **CodeRabbit CLI** authenticated — `/review` runs CodeRabbit as part of the multi-agent pipeline; it works without it but the local quality gate is weaker.
- (Optional) **Linear MCP** connected with GitHub→Linear native sync configured — only required if you plan to use the `linear+github` tracker profile.

## Step 1 — install the plugin

soloscrum ships as a Claude Code plugin distributed via its marketplace. From inside Claude Code:

```bash
/plugin marketplace add mew-ton/soloscrum
/plugin install soloscrum
```

If you have installed it before in a different repo, run `/plugin marketplace update soloscrum` to pull the latest version.

After install, the soloscrum commands (`/refine`, `/breakdown`, `/develop`, `/review`) are available in any Claude Code session against the repo.

## Step 2 — choose a tracker profile

soloscrum supports two **tracker profiles** that control where Subtasks, SP, dependencies, and state are stored:

| Profile | When to use |
|---|---|
| `github-only` | Default. Repo allows only GitHub Issues (organisation constraint, public OSS, etc.). Subtasks use native GitHub Sub-issues; SP lives in a GitHub Projects v2 number field. |
| `linear+github` | Repo has Linear MCP available and GitHub→Linear native sync configured. Issues remain canonical on GitHub; Subtasks and SP live on Linear and sync back. |

The concept is covered in detail in [tracker profile](/concept/tracker-profile/).

The plugin user config exposes a `tracker_profile` setting captured at install time. To override it for a specific repo (e.g. you default to `linear+github` globally but a particular OSS repo only allows GitHub), drop a `.claude/rules/tracker.md` file at the repo root with frontmatter:

```markdown
---
profile: github-only
---
```

The repo-local override takes precedence over the user-level default. Without either, `github-only` is the built-in fallback.

## Step 3 — configure repo rules (optional)

soloscrum reads optional repository-specific rules from `.claude/rules/`. None are required to run the flow; each one tightens the agent's behaviour for that repo.

| File | What it controls |
|---|---|
| `.claude/rules/tracker.md` | Tracker profile override (see Step 2). |
| `.claude/rules/stack.md` | Tech stack, directory layout, and naming conventions Dev consults during `/develop`. |
| `.claude/rules/branch.md` | Branch strategy specific to this repo (e.g. trunk-based vs gitflow), if it diverges from soloscrum's default `<type>/<issue-id>-<slug>` form. |
| `.claude/rules/dod-extra.md` | Extra DoD items appended to the [core checklist](/policies/dod/) — e.g. "Storybook story exists for every new component" or "i18n strings registered in both locales". |
| `.claude/rules/pr.md` | Optional override of the always-draft PR default (rarely needed; see [PR lifecycle](/concept/pr-lifecycle/)). |
| `.claude/rules/agent-overrides.md` | Repo-specific tweaks to the agent ownership matrix — almost never needed. |

Each file is plain Markdown. Add only what you want to override; missing files just mean the soloscrum defaults apply.

## Step 4 — file your first Issue with `/refine`

You are now ready to drive the lifecycle end-to-end. Open a Claude Code session in the repo and run:

```bash
/refine "<your idea here>"
```

The first line of output will be the janitor sweep — on a brand-new repo this is `No stale Issues found`. The PO agent then structures your idea into a four-section Issue body (Background / Goal / AC / Out of Scope), assigns a priority label, and computes a size-check SP. You confirm; the Issue is created.

From there, the lifecycle is:

- If the size-check SP is at or below 5 and the work fits a single PR, run [`/develop`](/commands/develop/) on the Issue directly.
- If the SP exceeds 5 or the change obviously spans multiple subsystems, run [`/breakdown`](/commands/breakdown/) first to slice the Issue into Subtasks, then `/develop` each one.
- After `/develop` opens the draft PR, run [`/review`](/commands/review/) on it. On Pass, `/review` promotes the PR to ready and surfaces the `gh pr merge` command — that final merge is your gate, not the agent's.

## Where to go next

- [Concept section](/concept/tracker-profile/) — the why behind the tracker profile, the agent ownership rules, the PR lifecycle, and the code review process.
- [Policies section](/policies/issue-format/) — the rules `/refine` and `/review` decide against (Issue format, priority, story points, issue size, DoD).
- [Commands section](/commands/refine/) — per-command walkthroughs for `/refine`, `/breakdown`, `/develop`, `/review`.
- Canonical specs: [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills), [`agents/`](https://github.com/mew-ton/soloscrum/tree/main/agents), [`commands/`](https://github.com/mew-ton/soloscrum/tree/main/commands) in the repository.
