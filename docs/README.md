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
