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
| **Architecture Pattern** | DDD + Modular Monolith + Clean Architecture |
| **Python Version** | >=3.11 |
| **Source Root** | `src` |
| **Module Path** | `src/modules` |
| **Shared Path** | `src/shared` |

---

## Tech Stack Supplements

> **Full Version Matrix**: See [rules/tech-stack.md](rules/tech-stack.md) (Single Source of Truth)
>
> Only project-specific choices **not covered** in tech-stack.md are listed below.

| Category | Technology | Description |
|----------|-----------|-------------|
| **Database** | <!-- TODO: Please fill in --> | <!-- TODO: Description --> |
| **Authentication** | <!-- TODO: Please fill in --> | <!-- TODO: Description --> |
| **Database Migration** | Alembic >=1.13.0 | Based on SQLAlchemy |

---

## Business Modules

> **Maintenance Note**: Update this table and the `src/modules/` directory when adding new modules.

| Module | Responsibility | Core Entities |
|--------|---------------|---------------|
| <!-- TODO: Module name --> | <!-- TODO: Description --> | <!-- TODO: Core entities --> |
<!-- Example:
| `auth` | User authentication and authorization | `User` |
| `orders` | Order management | `Order`, `OrderItem` |
| `products` | Product management | `Product`, `Category` |
-->

---

## Core Domain Events

> **Design Principle**: Events are used for decoupled inter-module communication; subscribers should not directly depend on the publisher's implementation.

| Module | Event | Trigger Scenario | Subscribers |
|--------|-------|-----------------|-------------|
| <!-- TODO: Module name --> | <!-- TODO: Event name --> | <!-- TODO: Trigger scenario --> | <!-- TODO: Subscribers --> |
<!-- Example:
| `auth` | `UserCreatedEvent` | User creation | notification |
| `orders` | `OrderCreatedEvent` | Order creation | audit, notification |
| `orders` | `OrderCompletedEvent` | Order completion | billing, audit |
-->

---

## Import Path Configuration

> **Principle**: Refer to [rules/architecture.md](rules/architecture.md) Section 3 Module Isolation Rules.

### Shared Kernel Imports

```python
# Domain layer shared
from src.shared.domain import (
    BaseEntity, PydanticEntity,
    IRepository,
    DomainError, EntityNotFoundError, ValidationError,
    DomainEvent, event_bus, event_handler,
    # IQuotaChecker,  # Cross-module interface (enable as needed)
)

# Infrastructure layer shared
from src.shared.infrastructure import get_db, get_settings, PydanticRepository
# from src.shared.infrastructure.security import hash_password, verify_password

# API layer shared
from src.shared.api import domain_exception_handler
from src.shared.api.schemas import EntitySchema, PaginatedResponse
```

### Auth Dependencies (Only Cross-Module Exception)

```python
# Only allowed in the API layer
from src.modules.auth.api.dependencies import (
    get_current_active_user,
    # require_admin,
    # require_engineer,
)
# from src.modules.auth.api.current_user import CurrentUser
```

---

## External Service Configuration

> **Convention**: All external service adapters go under `infrastructure/external/`.

| Service | Purpose | Adapter Location |
|---------|---------|-----------------|
| <!-- TODO: Service name --> | <!-- TODO: Purpose --> | <!-- TODO: Adapter location --> |
<!-- Example:
| AWS S3 | File storage | `infrastructure/external/aws/s3/` |
| AWS SES | Email notifications | `infrastructure/external/email/` |
| Redis | Caching | `infrastructure/external/cache/` |
-->

---

## Architecture Compliance

> See [rules/architecture.md](rules/architecture.md) Section 0.1, Section 3, and Section 9 for violation detection rules, dependency legality matrix, allowed exceptions, and compliance tests.
