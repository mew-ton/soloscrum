---
name: soloscrum-design-ui-task
description: Designs a Subtask (type design-ui) in Figma with design tokens, components, all component states, and state transition diagrams. Checks DoD on completion. Tracker-profile-agnostic except for state transitions.
argument-hint: <subtask-id>
disable-model-invocation: true
---

# soloscrum-design-ui-task

Produce Figma design with tokens and patterns for a Subtask of type `design-ui`.

## Overview

Produces design in Figma for a Subtask (type: design-ui) based on its AC. Follows `soloscrum-define-ui-standards` conventions. Subtask state transitions delegate to the active profile's tracker operation skill.

## Steps

1. Read target Subtask AC, description, and related Issue: $ARGUMENTS
2. Check design token and pattern conventions with `soloscrum-define-ui-standards`
3. Produce design in Figma MCP:
   - Check and reuse existing components
   - Create new components (if needed)
   - Apply design tokens
   - Verify UI pattern consistency
4. Define all states:
   - Default / Hover / Focus / Active / Disabled / Error / Loading (as applicable)
5. Create state transition diagram (if interactions exist)
6. Verify accessibility:
   - Contrast ratio: WCAG AA or above
   - Touch target: 44px × 44px or larger
7. Verify DoD with `soloscrum-define-dod`

## Output

- Figma file URL
- List of created components
- List of applied design tokens

## Depends On

- `soloscrum-define-ui-standards`
- `soloscrum-define-dod`
- `soloscrum-define-tracker-profile` (for resolving subtask ID conventions)
