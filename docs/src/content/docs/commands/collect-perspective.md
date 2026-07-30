---
title: "/soloscrum:collect-perspective"
description: Extracts reusable review perspectives from another project's PR review comments or from the current conversation, and stores them machine-locally for /soloscrum:review to select from.
sidebar:
  order: 6
---

Review knowledge is otherwise disposable. It surfaces while you think a problem through with the agent, or while you read someone else's review, and then the session ends. [`/soloscrum:review`](/commands/review/) re-derives the same lenses from scratch every time, so a judgement you already paid for never becomes something the next review applies on its own.

`/soloscrum:collect-perspective` is how that knowledge is kept.

## Usage

```bash
/soloscrum:collect-perspective https://github.com/other-org/other-repo/pull/123
/soloscrum:collect-perspective
```

With a PR URL, the source is that PR's review comments. With no argument, the source is the conversation you are already in.

Reviews of **other people's** projects are the richest source: the reasoning is stated explicitly, for a reader who lacks the author's context. That is exactly the form a reusable perspective needs.

## What it produces

A **review perspective** — one reusable judgement about what to look for — stored at:

```text
~/.claude/review-perspectives/<name>/PERSPECTIVE.md
```

Machine-local, outside any repository, shared across every project you work on. soloscrum is a solo-developer framework, so the durable unit is your accumulated judgement, not a project's convention.

The file's frontmatter mirrors a skill's — `name` and `description` — but perspectives are deliberately **not** stored under `~/.claude/skills/`. A skill competes for activation in every conversation; a perspective must not. It is a passive asset that exactly one consumer reads, at exactly one moment, on purpose.

## The steps

1. **Collect** from the PR's review comments, or from the conversation.
2. **Extract** the statements that would still be true on a different change. Anything that only reports a fact about the specific diff is dropped.
3. **Generalise** past the originating case — the framework, not the file; the class of mistake, not the instance. The concrete example moves into the body.
4. **Reconcile** against what you already have, by reading every existing perspective's description. An overlapping candidate becomes an *update*, not a sibling — near-duplicate triggers force the selector to guess, and then both fire or neither does.
5. **Confirm once**, then write.

## Why it asks

This command writes outside the repository, into your home directory. soloscrum's autonomy contract is scoped to repository state and to PRs; nothing in it authorises a command to modify your machine. And the perspective corpus is personal and long-lived — a wrong entry degrades every future review, quietly.

So it shows the full proposed content and takes **one** confirmation per invocation, not one per file. Updates show a diff, since you are being asked to approve a change to something you already accepted.

Adding `Write(~/.claude/review-perspectives/**)` to your own `~/.claude/settings.json` removes the harness prompt. The confirmation above is soloscrum's own gate and stays.

## Writing a description that works

`/soloscrum:review` selects perspectives by reading **descriptions only**. The description is not a summary — it is the activation contract, and it is why the constraints exist:

- **English**, so descriptions compare consistently regardless of the language the review runs in.
- **At most 2048 characters.** They are loaded together, so each one's length is paid by every selection.
- **When** it applies, and **what** it examines. A negative trigger is strongly recommended — a perspective with no stated boundary matches everything, and a corpus of those is the same as having none.
- **Decidable without the body.** If relevance can only be determined by reading the body, the description has failed at its only job.

The full contract, with worked good and bad examples, is in [`skills/soloscrum-define-review-perspective`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-review-perspective/SKILL.md).

## Output

Per perspective: created or updated, its path, and its description. Plus what was discarded as too case-specific to generalise — the discards matter, because they are what you would otherwise assume had been captured.

## See also

- [`/soloscrum:review`](/commands/review/) — selects from and applies the corpus.
- [Code review process](/concept/code-review-process/) — where perspective findings land in the pipeline.
- Canonical contract: [`commands/collect-perspective.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/collect-perspective.md).
