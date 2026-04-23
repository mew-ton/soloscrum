---
name: design-ui
description: Designs a Linear subtask of type design-ui in Figma with tokens, components, and state flows. Transitions the subtask to In Review on completion.
argument-hint: <subtask-id>
disable-model-invocation: true
---

# /design-ui

Design a design-ui subtask in Figma.

## Behavior

1. Receive target Linear subtask (type: design-ui) (`$ARGUMENTS`)
2. Launch `soloscrum-ui` to:
   - Check design tokens and pattern conventions via `soloscrum-define-ui-standards`
   - Produce design in Figma MCP:
     - Component creation
     - Design token application
     - UI pattern consistency check
   - Create state transition diagram (if applicable)
   - Verify DoD with `soloscrum-define-dod`
3. Transition Linear subtask to In Review
4. Present Figma URL to user

## Input

- Linear subtask URL or ID
- (If omitted) auto-select the subtask in Linear In Progress state

## Output

- Created Figma file URL
- Design summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-ui`
- Skills: `soloscrum-design-ui-task`, `soloscrum-define-ui-standards`, `soloscrum-define-dod`
- MCP: Figma MCP (`mcp.figma.com/mcp`)
