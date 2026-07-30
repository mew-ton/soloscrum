---
name: <kebab-case-name>
description: >
  <WHEN — the condition that makes this perspective apply. Name the kind of
  change, the area, or the signal in the diff. This is what the selector
  matches on, so be concrete: "when a change adds a database migration",
  not "when working with data".>
  <WHAT — what to examine once it applies. Enough to tell this perspective
  apart from a neighbouring one; not the checklist, which goes in the body.>
  <SCOPE — the language, framework, or ecosystem this targets, or an explicit
  "Applies to any language." Never leave this out: the selector cannot
  distinguish a genuinely universal perspective from one whose author forgot.>
  <BOUNDARY — where this does not apply, or an explicit statement that it
  applies broadly. A perspective with no boundary matches everything.>
  <Two rules have no placeholder because they constrain the whole description
  rather than a part of it: keep the finished text under 2048 characters, and
  make it decidable on its own — a reader must be able to tell whether this
  perspective applies without opening the body. Delete this note once the four
  elements above are written.>
---

<!-- soloscrum-review-perspective -->

## Checks

- [ ] <A concrete thing to look for. One per line, each independently checkable
      against a diff.>
- [ ] <Another.>

## Telling a real instance from a false positive

<The part that most affects whether a finding is worth raising. What looks like
a violation but is not? What makes an apparent instance intentional? A
perspective without this section produces confident findings on code that was
deliberately written that way.>

## Examples

**Should be flagged:**

```text
<A short example that this perspective is meant to catch.>
```

**Should not be flagged:**

```text
<A near-miss — something that trips the trigger but is fine on inspection.
This is what stops the perspective from firing on everything adjacent.>
```

## Where this came from

<Optional. The case that produced this judgement, written so a reader can decide
whether it still applies. Carry no identifier from the source that is not needed
to understand the perspective — no repository or organisation name, no host, no
internal path.>

---

_Following the [soloscrum](https://github.com/mew-ton/soloscrum) review perspective format._
