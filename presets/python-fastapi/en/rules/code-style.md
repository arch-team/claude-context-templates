# Code Style Standards

> **Purpose**: Python code style standards defining type hints, naming conventions, and docstring principles.

---

## 0. Quick Reference Card

### Type Hints Quick Reference

| Rule | Example |
|------|---------|
| ✅ All public interfaces must have type hints | `def get_user(user_id: int) -> User \| None:` |
| ✅ Use `X \| None` instead of `Optional[X]` | `name: str \| None = None` |
| ✅ Use built-in generics (Python 3.9+) | `list[str]`, `dict[str, int]` |
| ❌ Do not use `Any` | Use `TypeVar` or concrete types instead |

### Naming Quick Reference

| Element | Style | Example |
|---------|-------|---------|
| Functions/Variables | `snake_case` | `get_user_by_id` |
| Classes | `PascalCase` | `UserRepository` |
| Constants | `UPPER_SNAKE` | `MAX_RETRY` |
| Private | `_prefix` | `_cache` |
| Type Variables | `PascalCase` + T | `EntityT` |
| Modules/Packages | `snake_case` | `user_repository.py` |

### Docstring Quick Reference

```
Types are self-explanatory → Omit Docstring | Has side effects/exceptions → Describe behavior
```

### Async Code Quick Reference

```python
# ✅ Correct - Execute independent tasks concurrently
results = await asyncio.gather(task1(), task2())

# ✅ Correct - Context management
async with get_db_session() as session: ...

# ❌ Wrong - Sequential execution when parallelizable
user = await fetch_user(user_id)
permissions = await fetch_permissions(user_id)
```

### Ruff Auto-Checked Items (No Manual Review Needed)

Import sorting (isort) | Line length 120 characters | Blank line conventions | Formatting style

---

## 1. Type Hints

```python
# Generic class pattern
T = TypeVar("T")
class Repository(Generic[T]):
    def get(self, id: int) -> T | None: ...
```

---

## 2. Naming Conventions

### Naming Principles

1. **Clarity over brevity**: `get_user_by_email()` over `get_user()`
2. **Methods start with verbs**: `create_user()`, `validate_input()`, `calculate_total()`
3. **Boolean naming**: `is_active`, `has_permission`, `can_edit`
4. **Collections use plurals**: `users`, `items`, `tasks`

---

## 3. Docstring Standards

> **Types as Documentation**: Type hints + good naming = self-documenting code. Docstrings should only describe what types cannot express.

| Scenario | Required |
|----------|----------|
| Class/Module | ✅ One-sentence responsibility description |
| Method - Types are self-explanatory | ❌ Omit |
| Method - Has side effects/exceptions | ✅ Describe behavior |
| Private method | ❌ Omit |

```python
# ❌ Redundant - Types are self-explanatory
def get_user(user_id: int) -> User | None:
    """Get user by ID.
    Args: user_id: User ID
    Returns: User entity or None
    """

# ✅ Correct - Omit unnecessary comments
def get_user(user_id: int) -> User | None: ...

# ✅ Necessary - Has side effects and exceptions to document
def create_user(dto: CreateUserDTO) -> User:
    """Create user and send welcome email.
    Raises: ValidationError, DuplicateEmailError
    """

class UserService:
    """User business service."""  # Classes need only one sentence
```

---

## 4. Async Code Standards

```python
# ✅ Correct - asyncio.gather for concurrent independent tasks
user, permissions = await asyncio.gather(
    fetch_user(user_id),
    fetch_permissions(user_id),
)

# ❌ Wrong - Sequential execution when parallelizable, wastes time
user = await fetch_user(user_id)
permissions = await fetch_permissions(user_id)

# ❌ Wrong - Using asyncio.run inside an existing event loop
def get_user(user_id: int) -> User | None:
    return asyncio.run(self._fetch_user(user_id))  # Prohibited
```

---

## 5. Import Standards

> Import grouping and sorting are handled automatically by Ruff (isort). The following are rules requiring manual attention.

- ✅ Specific imports: `from src.domain.entities import User`
- ❌ Wildcard imports: `from src.domain.entities import *`
- ✅ Long path aliases: `import some_long_client as client`

---

## Checklist

See [checklist.md](checklist.md) Section: Code Style for the full checklist.
