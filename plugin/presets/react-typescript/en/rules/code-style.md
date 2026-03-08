# Code Style Standards

> **Purpose**: Code style standards - Naming conventions, TypeScript type principles, import ordering, event naming, generic naming

---

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Components | `PascalCase` | `UserProfile`, `LoginForm` |
| Functions/Variables | `camelCase` | `getUserData`, `isLoading` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Types/Interfaces | `PascalCase` | `UserData`, `ApiResponse` |
| Hooks | `use` + `camelCase` | `useAuth`, `useFetch` |
| CSS classes | `kebab-case` | `user-profile`, `login-form` |
| Files (components) | `PascalCase.tsx` | `UserProfile.tsx` |
| Files (utilities) | `camelCase.ts` | `formatDate.ts` |
| Directories | `kebab-case` | `user-profile/`, `auth/` |

---

## TypeScript Type Principles

| Rule | Correct | Wrong |
|------|---------|-------|
| Props definition | `interface ButtonProps {}` | `type ButtonProps = {}` |
| Export types | `export type { User }` | `export { User }` |
| Avoid any | Specific type / `unknown` | `any` |
| Union types | `'sm' \| 'md' \| 'lg'` | `string` |
| Object shapes, Props | `interface` | `type` |
| Union/Mapped/Utility types | `type` | `interface` |

---

## Import Ordering Principles

1. React core
2. Third-party libraries
3. Internal aliases (by FSD layer)
4. Relative imports
5. Type imports (separate line)

---

## Component File Organization Principles

- Use `@/` path aliases instead of deep relative paths
- Prohibit `import * as` wildcard imports (hinders tree shaking)
- Prohibit importing internal implementation files (breaks module encapsulation)

---

## 1. Naming Convention Details

### 1.1 Event Handler Functions

```typescript
// Inside component - handle prefix
const handleClick = () => { ... };
const handleSubmit = (e: FormEvent) => { ... };

// In Props - on prefix
interface ButtonProps {
  onClick: () => void;
  onHover?: () => void;
}
```

### 1.2 Boolean Naming

| Prefix | Usage | Example |
|--------|-------|---------|
| `is` | State check | `isLoading`, `isVisible` |
| `has` | Ownership check | `hasPermission`, `hasError` |
| `can` | Capability check | `canEdit`, `canSubmit` |
| `should` | Conditional check | `shouldRefetch`, `shouldShow` |

---

## 2. TypeScript Standards

### 2.1 Type Definition Locations

| Type | Location |
|------|----------|
| Component Props | In component file or co-located `.types.ts` |
| Entity types | `entities/{entity}/model/types.ts` |
| API response types | `features/{feature}/api/types.ts` |
| Common types | `shared/types/` |

### 2.2 Interface vs Type Decision

| Scenario | Choice |
|----------|--------|
| Object shapes, Props | `interface` |
| Union types | `type` |
| Mapped types, utility types | `type` |

### 2.3 Generic Naming

| Scenario | Naming | Example |
|----------|--------|---------|
| Simple cases | Single letter | `T`, `U`, `K`, `V` |
| Complex cases | Descriptive + `T` prefix | `TEntity`, `TState`, `TActions` |

---

## 3. Import Standards

### 3.1 Path Aliases

Use `@/` instead of deep relative paths:

```typescript
// ✅ Correct
import { Button } from '@/shared/ui';

// ❌ Wrong
import { Button } from '../../../shared/ui';
```

### 3.2 Prohibited Import Patterns

| Pattern | Reason |
|---------|--------|
| `import * as utils from '...'` | Hinders tree shaking |
| Importing internal implementation files | Breaks module encapsulation |
