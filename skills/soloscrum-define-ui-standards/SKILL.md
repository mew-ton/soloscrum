---
name: soloscrum-define-ui-standards
description: "Reference: UI design standards including token categories and naming convention, required component states (Default/Hover/Focus/Disabled/Error), and WCAG AA accessibility requirements."
user-invocable: false
---

# soloscrum-define-ui-standards

Design token and UI pattern conventions.

## Design Tokens

Manage project design tokens in Figma Variables or Tokens Studio.

### Token Categories

| Category | Purpose |
|---|---|
| `color` | Brand colors and semantic colors |
| `typography` | Font family, size, weight, line height |
| `spacing` | Margin, padding, gap |
| `radius` | Border radius |
| `shadow` | Box shadow |
| `motion` | Transition duration and easing |

### Naming Convention

```
{category}/{semantic}/{variant}

Examples:
color/brand/primary
color/status/error
typography/body/md
spacing/component/md
```

## Component Conventions

### Required States

Define the following for all interactive components:

| State | Required |
|---|---|
| Default | ✅ Required |
| Hover | ✅ Required (desktop) |
| Focus | ✅ Required (accessibility) |
| Active / Pressed | Optional |
| Disabled | ✅ Required (when disabled state exists) |
| Loading | ✅ Required (when async operations exist) |
| Error | ✅ Required (when input validation exists) |

### Accessibility

| Standard | Value |
|---|---|
| Text contrast ratio | WCAG AA: 4.5:1 or above (normal text) |
| Large text contrast ratio | WCAG AA: 3:1 or above (18px or larger) |
| Touch target size | 44px × 44px or larger |
| Focus indicator | Visibly highlighted |

## Adding New Patterns

When existing patterns cannot cover a use case:
1. Confirm with user before creating
2. Add to Figma component library
3. Document naming and usage criteria in the Figma component description

## Notes

This file contains generic initial values. Project-specific design tokens and patterns should override these in the Figma file or in `.claude/rules/`.
