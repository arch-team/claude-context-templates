# Architecture Principles

> Cross-stack architecture engineering principles. For stack-specific implementations, see the corresponding preset's rules/architecture.md.

---

## Dependency Direction

- Dependencies must flow in one direction only (top-down)
- Circular dependencies are forbidden
- Higher-level modules must not depend on lower-level implementation details

---

## Module Isolation

- Modules communicate through well-defined interfaces
- Hide internal implementation details; only export the public API
- Changes to one module should not cause cascading changes in others

---

## Explicit Exports

- Use index files or export declarations to control the public API
- Internal implementations must not be directly accessible externally
- Wildcard exports (`export *` / `import *`) are forbidden

---

## Interface Abstraction

- Depend on abstractions (interfaces/protocols), not concrete implementations
- Core business logic must not directly depend on specific frameworks or third-party libraries
- Isolate external dependencies through adapters

---

## Separation of Concerns

- Each module/component is responsible for a single concern
- Separate business logic from technical infrastructure
- Separate configuration from code
