# soloscrum docs site

Hand-written, **human-facing** companion documentation for the [soloscrum](https://github.com/mew-ton/soloscrum) framework.

## Scope

This site is the place for:

- Conceptual overviews ("what is soloscrum, and why does it look this way")
- Onboarding walkthroughs (getting from "I just installed the plugin" to "I shipped my first issue")
- Command reference written for humans (`/refine`, `/breakdown`, `/develop`, `/review`)
- Glossary / cross-cutting reference material

It is **not** a transformed view of the framework's spec files. The Markdown under `skills/`, `agents/`, `commands/`, and the root `CLAUDE.md` is the AI contract — those files are read directly by Claude Code agents and are tuned for that audience. This site references them but does not import, symlink, or build-time-copy their content. The two surfaces are kept independent on purpose so each can evolve without dragging the other along.

If you are looking for the authoritative behaviour spec, read the source files at the repo root:

- [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills) — skill specifications
- [`agents/`](https://github.com/mew-ton/soloscrum/tree/main/agents) — agent role definitions
- [`commands/`](https://github.com/mew-ton/soloscrum/tree/main/commands) — `/refine`, `/breakdown`, `/develop`, `/review`
- [`CLAUDE.md`](https://github.com/mew-ton/soloscrum/blob/main/CLAUDE.md) — repo-level instructions

## Stack

- [Astro](https://astro.build/) + [Starlight](https://starlight.astro.build/)
- TypeScript (strict, via `astro/tsconfigs/strict`)
- Package manager: **pnpm**

## Internationalisation

The site ships with two locales configured in `astro.config.mjs`:

- `en` (English) — the default locale
- `ja` (日本語)

Each locale lives under its own subtree:

```
src/content/docs/
  en/
    index.md
    concept/...
    reference/...
  ja/
    index.md
    concept/...
    reference/...
```

The sidebar `autogenerate` directive references `directory: 'concept'` and `directory: 'reference'` once; Starlight resolves these per-locale. Cross-links in Markdown should be written as `/concept/foo/` or `/reference/bar/` — Starlight rewrites them to `/ja/concept/foo/` etc. when rendering the `ja` build.

Translation policy:

- Domain terms (`PR`, `Issue`, `Subtask`, `branch`, `merge`, `commit`, `Pass`, `Fail`, `draft`, `ready`, `lint`, `CI`, etc.) stay English.
- Skill names (`soloscrum-define-pr-lifecycle`, etc.) stay English.
- Code blocks, command examples, and file paths are identical across locales.
- `sidebar.order` frontmatter is kept identical between `en` and `ja` so the navigation order matches.
- External GitHub links to canonical `SKILL.md` files point at the English source — the spec is in English.

Starlight automatically renders a locale picker in the site header when more than one locale is configured.

## Local development

All commands are run from `docs/`.

```sh
pnpm install          # install dependencies
pnpm run dev          # start dev server at http://localhost:4321
pnpm run build        # build the static site to ./dist/
pnpm run preview      # preview the built site locally
```

## Status

This is the bare scaffold from soloscrum issue [#46](https://github.com/mew-ton/soloscrum/issues/46): the project is initialised, the build passes, and a single hand-written stub index page renders. Concept / Reference / Commands / Onboarding sections will be filled in by [#47](https://github.com/mew-ton/soloscrum/issues/47) and [#48](https://github.com/mew-ton/soloscrum/issues/48). CI deploy and a navigation entry from the repo root README are tracked in [#49](https://github.com/mew-ton/soloscrum/issues/49).
