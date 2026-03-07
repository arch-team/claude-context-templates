# PR Review Checklist

> **Purpose**: Single Source of Truth (SSoT) for the PR Review checklist, covering architecture, component design, code style, security, testing, and performance checks.

---

## Layering & Architecture

- [ ] New files are placed in the correct FSD layer
- [ ] Dependency direction is correct (only downward)
- [ ] No direct cross-feature imports
- [ ] Shared layer has no business logic
- [ ] Each slice has a unified `index.ts` export

See [architecture.md](architecture.md) for details.

---

## Component Design

- [ ] Component type is correct (presentational/container/compound)
- [ ] Props are defined using interface
- [ ] Event handler functions are prefixed with `handle`
- [ ] children type is `React.ReactNode`
- [ ] Optional props have reasonable defaults
- [ ] Compound components use Context for shared state

See [component-design.md](component-design.md) for details.

---

## Code Style

- [ ] Naming follows conventions
- [ ] No `any` types
- [ ] Props use `interface` definitions
- [ ] Imports follow ordering conventions
- [ ] No unused variables/imports

See [code-style.md](code-style.md) for details.

---

## State Management

- [ ] Server data uses React Query
- [ ] Global state uses Zustand
- [ ] Store has selector hooks exported
- [ ] Query Keys follow naming conventions
- [ ] Sensitive data is not persisted in Store

See [state-management.md](state-management.md) for details.

---

## Security

- [ ] No `dangerouslySetInnerHTML` (unless necessary and using DOMPurify)
- [ ] No `eval()`, `new Function()`
- [ ] URL redirects are validated
- [ ] User input is validated and constrained
- [ ] Sensitive data is not in localStorage
- [ ] No hardcoded secrets

See [security.md](security.md) for details.

---

## Testing

- [ ] Test files are co-located with components
- [ ] Uses accessibility queries
- [ ] Async operations properly awaited
- [ ] Mocks only for boundary dependencies
- [ ] Coverage meets minimum (>={{COVERAGE_MIN}}%)

See [testing.md](testing.md) for details.

---

## Performance

- [ ] Route-level components use lazy loading
- [ ] Large lists use virtual lists
- [ ] memo usage has clear justification
- [ ] Images have loading="lazy"

See [performance.md](performance.md) for details.

---

## Accessibility

- [ ] Images have descriptive alt text
- [ ] Form controls have associated labels
- [ ] Interactive elements are keyboard accessible
- [ ] Color contrast >= 4.5:1
- [ ] Icon buttons have `aria-label`

See [accessibility.md](accessibility.md) for details.

---

## Project Structure

- [ ] Components and test files are co-located
- [ ] No temporary files committed
- [ ] Environment variables are declared in `.env.example`

See [project-structure.md](project-structure.md) for details.
