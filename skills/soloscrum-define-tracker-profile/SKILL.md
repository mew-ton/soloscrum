---
name: soloscrum-define-tracker-profile
description: "Reference: tracker profile (github-only or linear+github), how to resolve which profile is active, the storage/API mapping for every concept, and the routing rule that maps profile to operation skills."
user-invocable: false
---

# soloscrum-define-tracker-profile

Defines where each soloscrum concept is stored, how to access it, and how agents/commands route tracker operations to the correct skill — per **tracker profile**. Concepts and lifecycle are profile-independent; only the storage location, API, and dispatched skill change.

## Profiles

| Profile | When to use |
|---|---|
| `github-only` | Default. Repo allows only GitHub Issues (org constraint, public OSS, etc.) |
| `linear+github` | Repo has Linear MCP available and GitHub→Linear native sync configured |

## Profile Resolution

When an agent or command needs the active profile, resolve in this order and stop at the first match:

1. **Repo override** — `.claude/rules/tracker.md` frontmatter `profile: <name>`, if present
2. **User config** — `${user_config.tracker_profile}` (set via plugin install prompt; saved in `.claude/settings.json`)
3. **Built-in default** — `github-only`

`github-only` is the conservative fallback: if neither override nor user config is set, the workflow operates inside a single repo's GitHub-only constraints.

### Repo override file format

```markdown
---
profile: github-only
---
```

Place at `.claude/rules/tracker.md` to pin a repo to a specific profile regardless of the user's plugin-level default.

## Concept → Storage Matrix

| Concept | `github-only` | `linear+github` |
|---|---|---|
| Issue (parent) | GH Issue | GH Issue (canonical) |
| Subtask | GH Sub-issue (native) | Linear subtask (synced from parent Issue) |
| Subtask ID | GH issue number `#123` | Linear ID `PRJ-42` |
| SP (Issue level) | not registered (size-check only) | not registered (size-check only) |
| SP (Subtask level) | GH Projects v2 — `SP` Number field | Linear estimate field |
| Priority | GH label `priority:{urgent\|high\|medium\|low}` | GH label `priority:{urgent\|high\|medium\|low}` (canonical on GH; Linear priority field is not used) |
| State | label `state:{in-progress\|in-review\|done}` (open until merge — GH "closed" means "merged into main" via `Closes #N` auto-close, decoupled from soloscrum's `done` state) | Linear state (Backlog/In Progress/In Review/Done) |
| Type | GH label `type:{develop\|design-ui}` | Linear label `type:{develop\|design-ui}` |
| Parent–child link | GH Sub-issue (native) | Linear parent field |
| Blocking dependency | body line `Depends on: #N` (GH renders as cross-link) | Linear "Blocked by" relation |
| Backlog query | `gh issue list` + Projects v2 GraphQL | Linear MCP |
| Auto-sync | n/a (GH is canonical) | GH Issue → Linear Task (Linear native integration) |

## Routing Layer (Operation Skills)

Tracker-dependent operations are implemented as **profile-specific skills**. Agents and commands resolve the active profile, then invoke the matching operation skill by name. There is no separate dispatcher — naming is the dispatch.

### Profile → Skill prefix

| Active profile | Skill prefix |
|---|---|
| `github-only` | `soloscrum-tracker-github-` |
| `linear+github` | `soloscrum-tracker-linear-` |

### Operations

| Operation | github-only skill | linear+github skill |
|---|---|---|
| Create subtask | `soloscrum-tracker-github-create-subtask` | `soloscrum-tracker-linear-create-subtask` |
| Transition state | `soloscrum-tracker-github-transition-state` | `soloscrum-tracker-linear-transition-state` |
| Set subtask SP | `soloscrum-tracker-github-set-sp` | `soloscrum-tracker-linear-set-sp` |
| Query backlog | `soloscrum-tracker-github-query-backlog` | `soloscrum-tracker-linear-query-backlog` |
| Query current state | `soloscrum-tracker-github-query-state` | `soloscrum-tracker-linear-query-state` |
| Add dependency | `soloscrum-tracker-github-add-dependency` | `soloscrum-tracker-linear-add-dependency` |

### How agents/commands consume this

1. Resolve profile via the order above
2. Compute the skill prefix from the profile
3. Invoke `<prefix><operation>` for each tracker operation needed
4. Never call Linear MCP or `gh` for tracker operations directly — always go through an operation skill

When a concept has no equivalent in the active profile, the corresponding operation skill documents the substitute or surfaces a clear "not applicable" notice.

## Notes

- The Issue (parent) is **always GH Issue** — both profiles agree
- In `linear+github`, treat Linear as a downstream tracker; never edit a Linear Task without the corresponding GH Issue existing first
- Profile-agnostic skills (`soloscrum-define-issue-format`, `soloscrum-define-priority`, `soloscrum-define-story-points`, `soloscrum-define-dod`, etc.) are shared by both profiles and never need profile-specific copies
- Repo-local overrides in `.claude/rules/` take precedence over plugin-level user config
