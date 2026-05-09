---
name: soloscrum-design-ui-task
description: Designs a Subtask (type design-ui) in Figma with design tokens, components, all component states, and state transition diagrams. Checks DoD and transitions the Subtask to In Review via the active profile's tracker operation skill on completion.
argument-hint: <subtask-id>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue view:*)
  - mcp__claude_ai_Figma__get_design_context
  - mcp__claude_ai_Figma__get_screenshot
  - mcp__claude_ai_Figma__get_metadata
  - mcp__claude_ai_Figma__get_figjam
  - mcp__claude_ai_Figma__get_libraries
  - mcp__claude_ai_Figma__get_variable_defs
  - mcp__claude_ai_Figma__search_design_system
  - mcp__claude_ai_Figma__create_new_file
  - mcp__claude_ai_Figma__use_figma
  - mcp__claude_ai_Figma__upload_assets
  - mcp__claude_ai_Figma__generate_diagram
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
8. Resolve the active tracker profile via `soloscrum-define-tracker-profile`, then invoke the matching `transition-state` operation skill to move the Subtask to `in-review`:
   - `github-only` → `soloscrum-tracker-github-transition-state`
   - `linear+github` → `soloscrum-tracker-linear-transition-state`
   Reversible per `soloscrum-define-pr-lifecycle`'s autonomy table; runs without pre-confirm. This is the creator-side `→ in-review` transition assigned to `ui` in `soloscrum-define-agent-responsibilities`.

## Output

- Figma file URL
- List of created components
- List of applied design tokens

## Depends On

- `soloscrum-define-ui-standards`
- `soloscrum-define-dod`
- `soloscrum-define-pr-lifecycle` (autonomy of reversible transitions)
- `soloscrum-define-tracker-profile` (for resolving subtask ID conventions and routing the transition)
- `soloscrum-define-agent-responsibilities` (creator-side Subtask State ownership)
- `soloscrum-tracker-{github|linear}-transition-state` (delegated `→ in-review` transition in step 8)
