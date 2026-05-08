---
name: design-ui
description: Designs a Subtask of type design-ui in Figma with tokens, components, and state flows. Transitions the Subtask to In Review on completion.
argument-hint: <subtask-id>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue view:*)
---

# /design-ui

Design a design-ui Subtask in Figma.

## Behavior

1. Receive target Subtask (type: design-ui) (`$ARGUMENTS`)
2. Launch `soloscrum-ui` to:
   - Check design tokens and pattern conventions via `soloscrum-define-ui-standards`
   - Produce design in Figma MCP:
     - Component creation
     - Design token application
     - UI pattern consistency check
   - Create state transition diagram (if applicable)
   - Verify DoD with `soloscrum-define-dod`
3. Resolve active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the Subtask to `in-review`
4. Present Figma URL to user

## Input

- Subtask URL or ID (GH issue number `#N` or Linear ID `PRJ-N` depending on active profile)
- (If omitted) auto-select an `in-progress` Subtask via `soloscrum-tracker-{profile}-query-state`

## Output

- Created Figma file URL
- Design summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-ui`
- Skills: `soloscrum-design-ui-task`, `soloscrum-define-ui-standards`, `soloscrum-define-dod`, `soloscrum-define-tracker-profile`
- MCP: Figma MCP (`mcp.figma.com/mcp`)
