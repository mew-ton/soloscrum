---
name: soloscrum-define-task-type
description: "Reference: task type definitions. develop=code changes handled by soloscrum-dev, design-ui=Figma and design tokens handled by soloscrum-ui. UI features always split into design-ui then develop."
user-invocable: false
---

# soloscrum-define-task-type

Subtask type definitions (develop / design-ui) and assignment criteria.

## Type Definitions

| Type | Definition | Assigned agent |
|---|---|---|
| `develop` | Any work involving code changes | `soloscrum-dev` |
| `design-ui` | Figma, design tokens, and UI pattern work | `soloscrum-ui` |

## Assignment Criteria

### Assign `develop` when:

- Backend implementation (API, DB, batch, etc.)
- Frontend implementation (logic, state management, API calls, etc.)
- Component behavior implementation (after design is finalized)
- Test implementation
- Infrastructure configuration

### Assign `design-ui` when:

- Figma production of new UI components
- Design token definition and updates
- UI pattern definition
- Screen transition and state flow design

## Never assign both types to a single subtask

- Features with UI must be split into separate subtasks: `design-ui` first, then `develop`
- The `develop` subtask should not start until the `design-ui` subtask is complete

## Labels

Use the following labels in Linear:
- `type:develop`
- `type:design-ui`
