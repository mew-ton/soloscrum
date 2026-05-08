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
  - mcp__claude_ai_Figma__get_design_context
  - mcp__claude_ai_Figma__get_screenshot
  - mcp__claude_ai_Figma__get_metadata
  - mcp__claude_ai_Figma__get_libraries
  - mcp__claude_ai_Figma__get_variable_defs
  - mcp__claude_ai_Figma__search_design_system
  - mcp__claude_ai_Figma__create_new_file
  - mcp__claude_ai_Figma__use_figma
  - mcp__claude_ai_Figma__upload_assets
  - mcp__claude_ai_Figma__generate_diagram
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__list_issue_statuses
  - mcp__claude_ai_Linear__save_issue
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
