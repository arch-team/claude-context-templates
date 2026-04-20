# Project Configuration - {{PROJECT_NAME}}

> **Purpose**: Project-specific configuration for {{PROJECT_NAME}}, including module list and import paths.

> **Positioning**: This file supplements CLAUDE.md with **project-specific business configuration**.
> **Principle**: Common standards go in `rules/`, project-specific information goes here.
> See [rules/architecture.md](rules/architecture.md) for architecture standards.

---

## Project Information

| Configuration | Value |
|---------------|-------|
| **Project Name** | {{PROJECT_NAME}} |
| **Project Description** | {{PROJECT_DESCRIPTION}} |
| **Source Root** | <!-- TODO: Fill in source root path, e.g. src/ --> |

---

## Tech Stack Supplements

> **Full Version Matrix**: See [rules/tech-stack.md](rules/tech-stack.md) (Single Source of Truth)
>
> Below are only **project-specific technology choices** not covered by tech-stack.md.

| Category | Technology | Description |
|----------|-----------|-------------|
| <!-- TODO: Category --> | <!-- TODO: Technology --> | <!-- TODO: Description --> |
<!-- Example:
| **Database** | PostgreSQL 15 | Primary database |
| **Cache** | Redis 7.x | Session and data caching |
| **Authentication** | JWT + OAuth2 | User authentication scheme |
-->

---

## Business Modules

> **Maintenance Note**: Update this table when adding new modules, along with the source directory.

| Module | Responsibility | Key Entities |
|--------|---------------|-------------|
| <!-- TODO: Module name --> | <!-- TODO: Description --> | <!-- TODO: Key entities --> |
<!-- Example:
| `auth` | User authentication and authorization | `User` |
| `orders` | Order management | `Order`, `OrderItem` |
| `products` | Product management | `Product`, `Category` |
-->

---

## Import Path Conventions

> **Principle**: Refer to [rules/architecture.md](rules/architecture.md) module isolation rules.

<!-- TODO: Fill in import path examples based on the project tech stack
Example (Python):
```python
from src.modules.auth import AuthService
from src.shared.domain import BaseEntity
```

Example (TypeScript):
```typescript
import { AuthService } from '@/modules/auth';
import { BaseEntity } from '@/shared/domain';
```
-->

---

## External Service Configuration

> **Location Convention**: All external service adapters should be centrally managed.

| Service | Purpose | Adapter Location |
|---------|---------|-----------------|
| <!-- TODO: Service name --> | <!-- TODO: Purpose --> | <!-- TODO: Adapter location --> |
<!-- Example:
| AWS S3 | File storage | infrastructure/external/s3/ |
| Redis | Caching | infrastructure/external/cache/ |
-->

---

## Architecture Compliance

> See [rules/architecture.md](rules/architecture.md) for violation detection rules and dependency direction.
