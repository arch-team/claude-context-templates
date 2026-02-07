> **Purpose**: Code style standards - Naming conventions, TypeScript standards, import ordering

# Code Style Standards

---

## 0. Quick Reference Card

### Naming Quick Reference

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

### TypeScript Quick Reference

| Rule | ✅ Correct | ❌ Wrong |
|------|-----------|---------|
| Props definition | `interface ButtonProps {}` | `type ButtonProps = {}` |
| Export types | `export type { User }` | `export { User }` |
| Avoid any | Specific type / unknown | `any` |
| Union types | `'sm' \| 'md' \| 'lg'` | `string` |

### Import Ordering

```typescript
// 1. React core
import { useState, useEffect } from 'react';

// 2. Third-party libraries
import { useQuery } from '@tanstack/react-query';
import { clsx } from 'clsx';

// 3. Internal aliases (by FSD layer)
import { Button } from '@/shared/ui';
import { useAuth } from '@/features/auth';
import { TaskCard } from '@/entities/task';

// 4. Relative imports
import { useLocalState } from './hooks';

// 5. Type imports (separate line)
import type { User } from '@/entities/user';
```


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
