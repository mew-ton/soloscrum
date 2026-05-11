---
title: soloscrum — solo dev scrum loop with Claude agents
description: A Claude Code plugin that lets a solo developer run a scrum-style loop (refine → breakdown → develop → review) end-to-end with AI agents.
---

**soloscrum is a Claude Code plugin framework for running a scrum-style development loop as a solo developer, with AI agents doing the heavy lifting at every stage.**

## The problem

A solo developer carrying a project end-to-end has to play every role: shape the idea, file the Issue, break it down, implement it, review it, decide when it ships. Context-switching between those roles burns focus, and the parts that exist to enforce quality — the review gate, the DoD check, the "is this Issue actually well-formed?" pass — are the first to get skipped when there is only one person in the room.

soloscrum's bet: a Claude agent can credibly hold those roles for you, **if** the framework provides a strict enough contract for each role to operate against. The contract is what keeps the loop honest when nobody else is watching.

## What you get

soloscrum is composed of four moving parts:

- **skills** — machine-readable specs the framework reads as its contract (`-define-*` for shared definitions, `-tracker-*` for tracker-profile-specific operations, plus operation-level skills). Stored under `skills/` in the repo.
- **agents** — five role definitions: `soloscrum-po` (Product Owner), `soloscrum-design` (Design), `soloscrum-dev` (Dev), `soloscrum-ui` (UI), `soloscrum-review` (Review). Each agent only mutates the concepts it owns.
- **commands** — the entry points you actually type: `/refine`, `/breakdown`, `/develop`, `/review`.
- **tracker profile** — `github-only` (default) or `linear+github`. Decides where Subtasks, SP, and state live; the rest of the framework stays profile-agnostic. See [tracker profile](/concept/tracker-profile/) for the contract.

## The flow

```text
/refine     → idea becomes a GitHub Issue with Background / Goal / AC / Out of Scope
/breakdown  → Issue is split into Sub-issues when it exceeds the size threshold
/develop    → branch, implement, open a draft PR with `Closes #N`
/review     → DoD + AC + CodeRabbit + multi-agent review; verdict; ready handoff
```

The user runs `gh pr merge` at the end — that is the only irreversible step kept on the human side. Everything before it (creating the PR, posting the verdict, promoting draft to ready, transitioning state) is reversible and runs autonomously inside the commands.

## Fit / not-fit

soloscrum fits when:

- You are a **solo developer** (or operating like one — one human reviewer max per change).
- You center your workflow on **Claude Code** and trust it to act autonomously inside an explicit contract.
- Your work flows through **GitHub Issues + PRs** (optionally Linear on top for the breakdown layer).
- You want a quality gate that fires every PR, not "when I remember to ask for review."

soloscrum is not a fit when:

- Your team needs **multiple human reviewers** as a hard requirement before merge.
- You need **portability across AI agents** — soloscrum is specifically a Claude Code plugin and bakes that in.
- You want a process framework that primarily organises people, not one that codifies a contract for an agent.

## Next steps

- [Getting started](/onboarding/) — install the plugin, pick a tracker profile, file your first Issue.
- [Concept](/concept/tracker-profile/) — tracker profiles, agent responsibilities, PR lifecycle, code review process.
- [Policies](/policies/issue-format/) — the rules `/refine` and `/review` decide against (Issue format, size, SP, priority, DoD).
- [Commands](/commands/refine/) — `/refine`, `/breakdown`, `/develop`, `/review` in lifecycle order.

## Where the AI contract lives

The authoritative source of soloscrum's behaviour for AI agents lives in the [repository](https://github.com/mew-ton/soloscrum) itself, **not** on this site — `skills/`, `agents/`, `commands/`, and `CLAUDE.md` are the contract. This site is the human-readable companion: hand-written orientation, concept explanations, and command walkthroughs. The two surfaces are intentionally independent — spec files are tuned for AI consumption, these pages are written for humans to read top-to-bottom.
