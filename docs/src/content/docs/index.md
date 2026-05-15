---
title: soloscrum — solo dev scrum loop with Claude agents
description: A Claude Code plugin that runs a scrum-style loop (refine → breakdown → develop → review) end-to-end with AI agents.
---

**soloscrum is a Claude Code plugin for running a scrum-style development loop as a solo developer.** Each stage is driven by a dedicated AI agent operating under a strict contract.

## The problem

A solo developer plays every role: shape the idea, file the Issue, break it down, implement it, review it, decide when it ships. Context switching between roles is costly, and the quality gates — review, DoD, "is this Issue well-formed?" — tend to be the first to be skipped.

soloscrum lets a Claude agent hold each role on your behalf. A per-role contract enforces the loop without requiring a second human reviewer.

## What you get

soloscrum has four parts:

- **skills** — machine-readable specs the framework reads as its contract. `-define-*` for shared definitions, `-tracker-*` for tracker-profile-specific operations, plus operation-level skills. Stored under `skills/`.
- **agents** — five role definitions: `soloscrum-po` (Product Owner), `soloscrum-design` (Design), `soloscrum-dev` (Dev), `soloscrum-ui` (UI), `soloscrum-review` (Review). Each agent only mutates the concepts it owns.
- **commands** — the entry points: `/refine`, `/breakdown`, `/develop`, `/review`.
- **tracker profile** — `github-only` (default) or `linear+github`. Selects where Subtasks, SP, and state live. The rest of the framework is profile-agnostic. See [tracker profile](/concept/tracker-profile/).

## The flow

```text
/refine     → idea becomes a GitHub Issue with Background / Goal / AC / Out of Scope
/breakdown  → Issue's delivery slices into reviewable Subtask PRs when one PR would be unreviewable
/develop    → branch, implement, open a draft PR with `Closes #N`
/review     → DoD + AC + CodeRabbit + multi-agent review; verdict; ready handoff
```

You run `gh pr merge` at the end — the only irreversible step kept on the human side. Everything before it runs autonomously inside the commands: creating the PR, posting the verdict, promoting draft to ready, transitioning state.

## Fit / not-fit

Use soloscrum when:

- You are a **solo developer** (or operate like one — one human reviewer max per change).
- You center your workflow on **Claude Code** and let it act autonomously inside an explicit contract.
- Your work flows through **GitHub Issues + PRs** (optionally Linear on top for the breakdown layer).
- You want a quality gate that fires on every PR.

soloscrum is not a fit when:

- Multiple human reviewers are required before merge.
- You need portability across AI agents. soloscrum is built specifically for Claude Code.
- You want a framework that organises people rather than codifies a contract for an agent.

## Next steps

- [Getting started](/onboarding/) — install the plugin, pick a tracker profile, file your first Issue.
- [Concept](/concept/tracker-profile/) — tracker profiles, agent responsibilities, PR lifecycle, code review process.
- [Policies](/policies/issue-format/) — the rules `/refine` and `/review` decide against (Issue format, size, SP, priority, DoD).
- [Commands](/commands/refine/) — `/refine`, `/breakdown`, `/develop`, `/review` in lifecycle order.

## Where the AI contract lives

The authoritative source of soloscrum's behaviour lives in the [repository](https://github.com/mew-ton/soloscrum) — `skills/`, `agents/`, `commands/`, and `CLAUDE.md`. This site is the human-readable companion. Spec files are structured for AI parsing; these pages are structured for human readers.
