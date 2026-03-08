# Architecture Standards

> **Purpose**: Architecture design principles, layer structure, and modularization standards.

> For cross-stack architecture principles, see `_common/rules/principles/architecture.md`

---

## Architecture Pattern

<!-- {{AI_GENERATED:architecture_pattern}}
  Describe the architecture pattern(s) adopted and how they integrate. Example format:
  ```
  Pattern A (concern)  -> Corresponding core concepts
  Pattern B (concern)  -> Corresponding core concepts
  ```
  Examples: MVC, DDD, Clean Architecture, Microservices, Modular Monolith, etc.
-->

---

## Layer Structure

<!-- {{AI_GENERATED:layer_structure}}
  Generate a layer responsibility table based on the project architecture. Example format:
  | Layer | Responsibility | Allowed Dependencies | Prohibited |
  |-------|---------------|---------------------|------------|
  | **Core/Domain** | Business logic | Standard library | Frameworks, external libs |
  | **Application** | Use case orchestration | Core layer | Frameworks, external libs |
  | **Infrastructure** | Technical implementation | Core, Application | - |
  | **Presentation** | User interaction | Application | Infrastructure (use DI) |
-->

---

## Dependency Direction

<!-- {{AI_GENERATED:dependency_direction}}
  Describe the dependency direction with ASCII diagram. Example format:
  ```
  Intra-module: Presentation -> Application -> Core <- Infrastructure
  Cross-module: modules/A ---X---> modules/B (cross-module dependency prohibited)
                  └---> shared/ (shared dependency allowed)
  ```
-->

### General Dependency Rules

- Dependencies must flow in one direction only (unidirectional)
- Circular dependencies are prohibited
- Higher-level modules must not depend on lower-level implementation details
- Depend on abstractions (interfaces/protocols), not concrete implementations

---

## Module Design Principles

<!-- {{AI_GENERATED:module_principles}}
  Generate a module design principles table based on the project architecture. Example format:
  | Principle | Description |
  |-----------|-------------|
  | **Module Autonomy** | Each module owns its own domain model |
  | **Explicit Dependencies** | Inter-module dependencies must be declared through interfaces |
-->

### General Isolation Rules

| Rule | Description |
|------|-------------|
| **Interface-based communication** | Modules communicate through explicit interfaces, hiding internal implementation |
| **Explicit exports** | Only export public APIs, no wildcard exports |
| **Single responsibility** | Each module/component is responsible for a single concern |
| **Separation of concerns** | Business logic is separated from technical infrastructure |

---

## Module Communication

<!-- {{AI_GENERATED:communication_pattern}}
  Describe inter-module communication patterns based on project needs. Example format:
  | Scenario | Recommended Pattern | Implementation |
  |----------|-------------------|----------------|
  | Synchronous calls | Interface invocation | shared/interfaces |
  | Asynchronous notifications | Event-driven | EventBus / Message Queue |
-->

---

## Related Documents

| Document | Description |
|----------|-------------|
| [project-structure.md](project-structure.md) | Project directory structure standards |
| [tech-stack.md](tech-stack.md) | Tech stack version constraints |
| [checklist.md](checklist.md) | PR Review checklist |
