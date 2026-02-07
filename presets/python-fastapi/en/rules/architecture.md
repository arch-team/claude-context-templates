# Backend Architecture Standards

> **Purpose**: Single Source of Truth (SSoT) for backend architecture standards, defining layering rules, module isolation, and DDD patterns.

> **Architecture Pattern**: DDD + Modular Monolith + Clean Architecture
> **Scope**: Python backend projects

<!-- CLAUDE placeholders: {PROJECT}=src, {Entity}/{entity}=entity name, {module}=module name -->

---

## 0. Quick Reference Card

> Claude should consult this section first when generating code

### 0.1 Dependency Legality Quick Reference Matrix

> **Inter-Module Communication**: Prefer EventBus (async decoupling), fallback to shared/interfaces (sync calls), direct dependency on other module implementations is prohibited.

| From ↓ Import → | `shared/*` | `auth.api.dependencies` | Other Module Domain | Other Module Service | Other Module ORM Model |
|-----------------|:----------:|:-----------------------:|:-------------------:|:--------------------:|:----------------------:|
| **Domain** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Application** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Infrastructure** | ✅ | ❌ | ❌ | ❌ | ⚠️ FK only |
| **API** | ✅ | ✅ | ❌ | ❌ | ❌ |

### 0.2 Data Model Selection Quick Reference

| Layer | Component Type | Recommended | Rationale |
|-------|---------------|-------------|-----------|
| **Domain** | Entity | Pydantic | Business rule validation, mutable state |
| **Domain** | Value Object | dataclass(frozen) | Immutable, value-based equality |
| **Application** | DTO | dataclass | Internal transfer, pre-validated data |
| **Infrastructure** | External Response | Pydantic | Requires validation and type conversion |
| **Infrastructure** | ORM Model | SQLAlchemy | Persistence-only |
| **API** | Request/Response | Pydantic | External input validation, FastAPI integration |

**Decision Flow**:
```
Data from external source? ──Yes──► Pydantic
      │
     No
      ↓
Needs business validation? ──Yes──► Pydantic
      │
     No
      ↓
Needs immutability? ──Yes──► dataclass(frozen=True)
      │
     No
      ↓
dataclass
```

### 0.3 PR Review Checklist

See [checklist.md](checklist.md) Section: Layering & Architecture for the full checklist.

---

## 1. Core Principles

### 1.1 Architecture Pattern Fusion

```
DDD (Tactical Design)          → Entity, Value Object, Aggregate, Domain Event, Repository
Modular Monolith (Modularity)  → Vertical business module slicing, loose inter-module coupling, shared infrastructure
Clean Architecture (Layering)  → Dependency inversion, core business isolated from external dependencies
```

### 1.2 Modularity Principles

| Principle | Description |
|-----------|-------------|
| **Module Autonomy** | Each module owns its independent domain model and business logic |
| **Explicit Dependencies** | Inter-module dependencies must be explicitly declared via interfaces |
| **Least Knowledge** | Modules only expose necessary interfaces; internal implementation is hidden |
| **Unidirectional Dependencies** | Circular dependencies are prohibited; use events for decoupling |

---

## 2. Layering Rules

### 2.1 Four-Layer Structure Within a Module

```
┌──────────────────────────────────────────────────┐
│                   API Layer                       │  ← Exposes HTTP endpoints
│       (endpoints, schemas, middleware)            │
├──────────────────────────────────────────────────┤
│               Application Layer                   │  ← Business use case orchestration
│     (services, dto, interfaces, exceptions)       │
├──────────────────────────────────────────────────┤
│                 Domain Layer                      │  ← Core business logic
│  (entities, value_objects, services, repositories)│
├──────────────────────────────────────────────────┤
│             Infrastructure Layer                  │  ← Technical implementation
│         (persistence, external adapters)          │
└──────────────────────────────────────────────────┘
```

### 2.2 Dependency Rules

| Layer | May Depend On | Must Not Depend On |
|-------|--------------|-------------------|
| **Domain** | Pydantic (data validation), shared/domain | FastAPI, SQLAlchemy, boto3 |
| **Application** | Domain | FastAPI, SQLAlchemy, boto3 |
| **Infrastructure** | Domain, Application | - |
| **API (Presentation)** | Application, Domain (types) | Infrastructure (via DI) |

### 2.3 Dependency Direction

```
Within module: API Layer → Application Layer → Domain Layer ← Infrastructure Layer
Cross-module: modules/A ───X───► modules/B (horizontal dependencies prohibited)
                   └──► shared/ (only allowed shared dependency)
```

- **API Layer**: Can only execute business operations through Application Services
- **Infrastructure**: Implements both Domain layer Repository interfaces and Application layer external service interfaces

---

## 3. Module Isolation Rules

### 3.1 Golden Rules

| Rule | Description | Enforcement |
|------|-------------|-------------|
| **R1** | A module's Domain layer **must never** import code from any other module | 🔴 Mandatory |
| **R2** | A module's Application layer may only depend on **interfaces**, not concrete implementations | 🔴 Mandatory |
| **R3** | Inter-module communication must go through **EventBus** or **shared interfaces** | 🔴 Mandatory |
| **R4** | The `auth` module's authentication dependencies are the **only exception**, importable by other modules' API layers | 🟡 Exception |
| **R5** | Domain Events serve as a module's public contract; other modules' Application layers may import them for event subscription | 🟡 Exception |

### 3.2 Allowed Shared Kernel Dependencies

```python
# ✅ All modules may import from shared/
from {PROJECT}.shared.domain import PydanticEntity, IRepository, DomainError, DomainEvent, event_bus
from {PROJECT}.shared.infrastructure import get_db, get_settings, PydanticRepository
from {PROJECT}.shared.api import domain_exception_handler
```

**Constraint**: `shared/` contains only technical infrastructure and cross-module abstractions; **business logic is strictly prohibited**

### 3.3 Prohibited Dependencies

```python
# ❌ Prohibited: Direct cross-module imports
from {PROJECT}.modules.{other_module}.application.services import {Service}       # ❌
from {PROJECT}.modules.{other_module}.domain.entities import {Entity}             # ❌
from {PROJECT}.modules.{other_module}.infrastructure.repositories import {RepoImpl}  # ❌
```

**Only Exception**: ORM model files (`*_model.py`) may import other modules' ORM Models to define foreign key relationships

---

## 4. Inter-Module Communication

### 4.1 Integration Pattern Decision

| Scenario | Recommended Pattern | Implementation |
|----------|-------------------|----------------|
| Real-time synchronous calls | Open Host Service | `shared/domain/interfaces/` |
| Asynchronous notifications | Published Language | Domain Events + EventBus |
| Complex external systems | Anti-Corruption Layer | Infrastructure adapters |

### 4.2 Event-Driven Communication (Recommended)

```python
# Define → Publish → Subscribe
@dataclass
class TaskCompletedEvent(DomainEvent):
    task_id: int
    owner_id: int

# Publish: await event_bus.publish_async(TaskCompletedEvent(...))
# Subscribe: @event_handler(TaskCompletedEvent)
```

#### Event Reliability Requirements

| Requirement | Description | Implementation |
|-------------|-------------|----------------|
| **Idempotency** | Handlers must be safe to execute repeatedly | Deduplicate via `event_id`, check before processing |
| **Retry Strategy** | Exponential backoff on failure | `max_retries=3`, backoff intervals `1s → 2s → 4s` |
| **Outbox Pattern** | Atomic commit of events with business operations | Write events to `outbox` table first, publish via background polling |
| **Ordering Guarantee** | Events for the same aggregate root must be processed in order | Partition by `aggregate_id` |

### 4.3 Interface Location Distinction

- `shared/domain/interfaces/`: **Cross-module capability interfaces** (e.g., `IQuotaChecker`)
- `modules/{module}/application/interfaces/`: **Module-internal external service abstractions** (e.g., `IS3Client`)

---

## 5. DDD Tactical Patterns

### 5.1 Entity

Inherits from `PydanticEntity`, automatically gains `id`, `created_at`, `updated_at`.

**Standards**: Must configure `ConfigDict(validate_assignment=True)` | State transitions happen inside the Entity (call `self.touch()` to update timestamps) | Must not depend on external services | Only throws Domain exceptions | Pydantic is treated as a standard tool, not an "external framework"

### 5.2 Value Object

Use `@dataclass(frozen=True)` to ensure immutability; equality is value-based.

### 5.3 Domain Service

Defined using `@dataclass`, stateless | Depends only on value objects and domain exceptions | Must not depend on Repositories

### 5.4 Repository

Interface in Domain layer (`I{Entity}Repository(IRepository[{Entity}, int])`), implementation in Infrastructure layer (`{Entity}RepositoryImpl(PydanticRepository[...])`).

**Standards**: `IRepository[E, ID]` generic interface defined in shared | `PydanticRepository` includes built-in CRUD | Control updatable fields via `_updatable_fields` whitelist

---

## 6. Module Structure Template

### 6.1 Directory Structure

```
modules/{module}/
├── __init__.py             # Module public API exports
├── api/
│   ├── endpoints.py        # FastAPI router
│   ├── dependencies.py     # Dependency injection functions
│   ├── middleware/
│   └── schemas/
│       ├── requests.py     # Request models (Pydantic)
│       └── responses.py    # Response models (Pydantic)
├── application/
│   ├── dto/                # Data transfer objects (dataclass)
│   ├── interfaces/         # Module-internal external service abstractions
│   ├── exceptions/         # Application layer exceptions
│   └── services/
│       └── {entity}_service.py
├── domain/
│   ├── entities/{entity}.py
│   ├── value_objects/
│   ├── services/           # Domain services
│   ├── repositories/{entity}_repository.py  # Interfaces
│   ├── events.py
│   └── exceptions.py
└── infrastructure/
    ├── persistence/
    │   ├── models/{entity}_model.py
    │   └── repositories/{entity}_repository_impl.py
    └── external/           # External service adapters
```

### 6.2 File Naming Conventions

| Type | Naming Convention | Example |
|------|------------------|---------|
| Entity | `{entity}.py` | `task.py` |
| Repository Interface | `{entity}_repository.py` | `task_repository.py` |
| Repository Implementation | `{entity}_repository_impl.py` | `task_repository_impl.py` |
| ORM Model | `{entity}_model.py` | `task_model.py` |
| Application Service | `{entity}_service.py` | `task_service.py` |
| External Adapter | `{service}_adapter.py` | `s3_adapter.py` |

### 6.3 `__init__.py` Export Rules

Export: `router`, Service, Entity, Domain Events | Do not export: ORM Model, RepositoryImpl, external client implementations

---

## 7. Dependency Injection

```
Layer 1: Database Session (get_db)
    → Layer 2: Repository (get_xxx_repository)
    → Layer 3: External Client (get_xxx_client) - @lru_cache Singleton recommended
    → Layer 4: Application Service (get_xxx_service)
    → Layer 5: Permission Check (require_xxx)
```

---

## 8. Exception Handling

Exceptions are defined in `shared/domain/exceptions.py` and automatically mapped to HTTP status codes by `shared/api/exception_handlers.py`:

| Exception Type | HTTP Status Code | Scenario |
|---------------|-----------------|----------|
| `EntityNotFoundError` | 404 | Resource not found |
| `DuplicateEntityError` | 409 | Resource already exists |
| `InvalidStateTransitionError` | 409 | Illegal state transition |
| `ValidationError` | 422 | Parameter validation failure |
| `ResourceQuotaExceededError` | 429 | Quota exceeded |

---

## 9. Architecture Compliance Tests

> **Test Location**: `tests/unit/test_architecture_compliance.py`

| Test Class | Validated Rule |
|------------|---------------|
| `TestCleanArchitectureLayers` | Layering dependency direction |
| `TestModuleDomainLayerIsolation` | Domain layer absolute isolation |
| `TestModuleApplicationLayerDependencies` | Application layer depends on interfaces |
| `TestModuleApiLayerAuthDependency` | Auth dependency exception verification |

```bash
# Run architecture compliance tests
uv run pytest tests/unit/test_architecture_compliance.py -v
```
