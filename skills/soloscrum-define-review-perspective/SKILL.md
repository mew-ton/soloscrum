---
name: soloscrum-define-review-perspective
description: "Reference: the Review Perspective format — a machine-local, self-describing unit of review knowledge stored at ~/.claude/review-perspectives/<name>/PERSPECTIVE.md. Defines the directory contract, the skill-shaped frontmatter, the description rules /soloscrum:review selects on (English, <=2048 chars, when + what + a stated boundary, decidable without the body), and why perspectives are deliberately not stored as skills."
user-invocable: false
---

# soloscrum-define-review-perspective

The format for review knowledge that outlives the session it came from.

## Concept

A **Review Perspective** is one reusable judgement about what to look for in a change — the kind of thing a developer learns once, at cost, and would otherwise re-learn. "This framework has a canonical way to do that; check before hand-rolling one." "Anything touching this boundary needs the error path exercised, not just the happy path."

Perspectives exist because that knowledge is otherwise disposable. It surfaces while thinking a problem through, or while reading someone else's review, and then the session ends. `/soloscrum:review` re-derives the same lenses from scratch every time, so a judgement the user already paid for never becomes something the next review applies on its own.

soloscrum is a solo-developer framework, so the durable unit is **the individual's accumulated judgement**, not a project's. Perspectives are therefore machine-local and shared across every repository the user touches — they are not a repository artefact and are not committed anywhere.

`/soloscrum:collect-perspective` writes them. `/soloscrum:review` reads them.

### Why not skills

The format deliberately mirrors a skill's, but perspectives are **not** stored under `~/.claude/skills/`.

A skill is loaded by the harness and competes for activation in every conversation. A perspective must not: it is a passive asset that exactly one consumer reads, at exactly one moment, on purpose. Putting review knowledge in the skill namespace would make an arbitrary chat about authentication drag in a perspective about auth reviews — noise the user did not ask for, growing with every perspective collected.

Separate namespace, same shape. The shape is worth keeping because the selection problem is the same one skill descriptions solve.

## Storage

```text
~/.claude/review-perspectives/
  canonical-first/
    PERSPECTIVE.md
  error-path-coverage/
    PERSPECTIVE.md
```

- One directory per perspective, named in **kebab-case**, matching the frontmatter `name`.
- The file is always `PERSPECTIVE.md` — fixed, mirroring `SKILL.md`.
- The directory may hold supporting files (examples, checklists) referenced from the body. Only `PERSPECTIVE.md` is read during selection.
- The tree is **not** version-controlled by soloscrum and is never committed to a repository.

An absent directory is not an error. It means no perspectives have been collected yet, and every consumer treats that as the normal starting state.

## Frontmatter

```yaml
---
name: canonical-first
description: >
  When a change adds a custom plugin, transform, helper, or wrapper to a
  project that already depends on a framework — build tooling, a docs
  generator, a web framework, an ORM — check whether the framework already
  provides the behaviour. Look for a hand-rolled implementation of something
  the framework documents, and for the absence of any note explaining why the
  built-in option was rejected. Not applicable when the change modifies an
  existing custom implementation without expanding its scope, or when the
  project has no framework in the affected area.
---
```

Two keys, both required: `name` (kebab-case, matching the directory) and `description`.

## The description rules

`/soloscrum:review` selects perspectives by reading **descriptions only** — no bodies. That is the whole reason the description is constrained: it is not a summary of the perspective, it is the perspective's activation contract.

- **Written in English.** The corpus is read by a model choosing among many descriptions at once; one language keeps that comparison consistent regardless of the language the review is conducted in.
- **At most 2048 characters.** Descriptions are loaded together, so each one's length is a cost paid by every selection. The limit forces the description to carry the trigger and nothing else.
- **States When.** The condition under which this perspective applies — the kind of change, the area, the signal in the diff. Without it the selector must guess, and guessing means either applying everything or applying nothing.
- **States What.** What the perspective examines once it applies. Enough for the selector to tell it apart from a neighbouring perspective; not the full checklist, which belongs in the body.
- **States a boundary.** Either where it does *not* apply, or an explicit statement that it applies broadly. A perspective with no stated boundary tends to match everything, and a corpus of those is the same as having none — so "broadly applicable" must be a claim the author made on purpose, not the default that results from omission. This is the one rule most often skipped, and skipping it is what degrades a corpus fastest.
- **Self-sufficient.** Applicability must be decidable from the description alone. A description that requires reading the body to know whether it is relevant has failed at its only job.

### Good and bad

**Bad** — a topic label, not a trigger:

```yaml
description: About testing.
```

Nothing here says when it applies or what it looks at. It matches every change with a test file and contributes nothing to the decision.

**Bad** — a summary of the body, with the trigger missing:

```yaml
description: >
  Explains the project's philosophy on error handling, covering the history of
  how the current approach was chosen, the alternatives considered, and a set
  of examples showing the preferred style in several languages.
```

Accurate and useless for selection. It describes the *document*; the selector needs to know about the *change*.

**Good** — trigger, scope, boundary:

```yaml
description: >
  When a change adds or modifies a public API handler that performs I/O
  (database, network, filesystem), check that every failure mode of that I/O
  has a defined response — not just the success path. Look for unhandled
  rejections, swallowed errors, and error responses that leak internal detail
  such as stack traces or query fragments. Not applicable to pure functions,
  internal helpers with no I/O, or test code.
```

### Language and ecosystem scope

Selection reads descriptions, never bodies. So a description phrased ecosystem-neutrally ("when a change touches error handling…") whose body encodes ecosystem-specific guidance will be selected on a project where that guidance does not apply, and the applying model will force it — producing a plausible-looking finding that is simply wrong for the language.

If a perspective's advice is specific to a language, framework, or ecosystem, **say so in the description**, not only in the body. The boundary rule above is where that belongs.

## Corpus size

Every description is read on every review. At the 2048-character limit that is roughly 500 tokens each, paid before the diff is even considered — negligible at five perspectives, material at fifty, and a real cost at several hundred. `/soloscrum:collect-perspective` pays the same scan again at write time, to deduplicate.

Nothing currently prunes, archives, or prioritises (tracked in #101). A corpus is expected to stay small because it holds judgements the user found worth keeping, not everything they ever read. Treat unbounded growth as a signal that perspectives are being collected too eagerly rather than as a problem the format will solve.

## Body

Free-form Markdown. What the description cannot carry:

- The concrete checks, as a list.
- How to tell a real instance from a false positive — the part that most affects whether a finding is worth raising.
- Worked examples, ideally one that should be flagged and one that should not.
- Where the judgement came from, when that context helps someone decide whether it still applies.

Keep it to what a reviewer needs at the moment of reviewing. A perspective that grows into an essay stops being read.

## Consumers

| Command | Reads | Behaviour |
|---|---|---|
| `/soloscrum:collect-perspective` | all descriptions (for deduplication) | Creates or updates a perspective from a PR's review comments or the current conversation |
| `/soloscrum:review` | all descriptions, then the bodies of the selected few | Applies the selected perspectives as additional review lenses per `soloscrum-define-code-review-process` |

## Depends On

- `soloscrum-define-code-review-process` (how perspective findings enter the review pipeline and the PR comment)
