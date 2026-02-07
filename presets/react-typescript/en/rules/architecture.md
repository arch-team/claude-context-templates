> **Purpose**: Single Source of Truth (SSoT) for FSD architecture standards - Layering rules, dependency matrix, slice structure templates

# Frontend Architecture Standards

> **Architecture Pattern**: Feature-Sliced Design (FSD)
> **Scope**: React + TypeScript frontend projects

<!-- CLAUDE placeholder notes:
  {Feature}    → Feature name PascalCase, e.g. Auth, Tasks, Dashboard
  {feature}    → Feature name kebab-case, e.g. auth, tasks, dashboard
  {Entity}     → Entity name PascalCase, e.g. User, Task
  {entity}     → Entity name kebab-case, e.g. user, task
  {Component}  → Component name PascalCase, e.g. LoginForm, TaskCard
  {Widget}     → Component composition PascalCase, e.g. Header, Sidebar
-->

---

## 0. Quick Reference Card

> Claude should consult this section first when generating code

### 0.1 FSD Layer Dependency Matrix

| From ↓ Import → | shared | entities | features | widgets | pages | app |
|-----------------|:------:|:--------:|:--------:|:-------:|:-----:|:---:|
| **app** | ✅ | ✅ | ✅ | ✅ | ✅ | - |
| **pages** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **widgets** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **features** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **entities** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **shared** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**Legend**: ✅ Allowed | ❌ Prohibited

**Core Rule**: Dependencies may only point downward; upward or same-level dependencies are prohibited

### 0.2 Layer Responsibilities Quick Reference

| Layer | Responsibility | Examples | ✅ Allowed | ❌ Prohibited |
|-------|---------------|----------|-----------|-------------|
| **app** | App initialization, routing, global providers | `App.tsx`, `routes.tsx`, `providers.tsx` | Providers, routing, global styles | Concrete business implementation |
| **pages** | Page components, compose widgets/features | `LoginPage`, `DashboardPage` | Compose widgets/features, page layout | Business logic |
| **widgets** | Independent UI blocks, compose multiple features | `Header`, `Sidebar`, `UserMenu` | Compose lower-layer components, simple state | Direct business logic, API calls |
| **features** | Business features with business logic | `auth/LoginForm`, `tasks/TaskList` | Business logic, API calls, state management | Cross-feature dependencies |
| **entities** | Business entities, data models and basic UI | `user/model`, `task/ui/TaskCard` | Data models, basic UI, type definitions | Complex business logic, cross-entity dependencies |
| **shared** | Shared utilities, no business logic | `ui/Button`, `api/client`, `lib/utils` | Utility functions, basic UI, API client | Any business logic, business entities |

### 0.3 Slice Structure Template

```
{layer}/{slice}/
├── index.ts              # Public API exports
├── api/                  # API calls (features/entities only)
│   └── queries.ts
├── model/                # State management
│   ├── store.ts          # Zustand store
│   └── types.ts          # Type definitions
├── ui/                   # UI components
│   ├── {Component}.tsx
│   └── {Component}.test.tsx
└── lib/                  # Utilities
    └── utils.ts
```


---

## 1. Module Export Rules

### 1.1 Public API Principle

Every slice must have an `index.ts` defining its public API:

```typescript
// features/auth/index.ts
// UI components
export { LoginForm } from './ui/LoginForm';
export { RegisterForm } from './ui/RegisterForm';

// Hooks
export { useAuth } from './model/store';
export { useLogin, useLogout } from './api/queries';

// Types
export type { LoginCredentials, AuthState } from './model/types';
```

### 1.2 Prohibited Exports

- Internal utility functions
- Private components
- Implementation details

```typescript
// ❌ Wrong - Should not export internal implementation
export { validateEmail } from './lib/validation';
export { useInternalState } from './model/internal';
```

---

## 2. Cross-Layer Communication

### 2.1 Recommended Patterns

| Scenario | Recommended Approach | Detailed Standards |
|----------|---------------------|-------------------|
| Data passing between components | Props drilling / Context | - |
| Global state | Zustand store | [state-management.md](state-management.md) Section 2 |
| Server data | React Query | [state-management.md](state-management.md) Section 1 |
| Event communication | Custom Events / Zustand | - |
