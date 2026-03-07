# Testing Standards

> **Purpose**: Testing standards defining TDD workflow, test layering, and fixture patterns.

> See CLAUDE.md for the TDD workflow

---

## 0. Quick Reference Card

### Commands (Supplement to CLAUDE.md)

```bash
uv run pytest -m "not slow"           # Exclude slow tests
uv run pytest --lf                    # Last failed
uv run pytest tests/modules/auth/     # Specific module
uv run pytest tests/modules/ -m unit  # All module unit tests
```

### Naming

| Element | Pattern | Example |
|---------|---------|---------|
| Directory | `tests/modules/{module}/` | `tests/modules/auth/` |
| File | `test_{component}.py` | `test_task_service.py` |
| Class | `Test{Class}` | `TestTaskService` |
| Method | `test_{method}_{scenario}_{expected}` | `test_create_with_invalid_email_raises` |

### Layering

| Layer | Coverage | Mock | Speed |
|-------|----------|------|-------|
| Unit | Entity/Service | External dependencies | ms |
| Integration | API/Repo | External services | s |
| E2E | Full flow | None | min |

### Pitfalls

- ❌ Mock the subject under test → ✅ Only mock external dependencies
- ❌ Test order dependency → ✅ Independent data per test
- ❌ Fake assertions → ✅ Fix the code

### PR Check

See [checklist.md](checklist.md) Section: Testing for the full checklist.

---

## 1. Directory Structure

Test directories **mirror the source module structure** to ensure module autonomy and test discoverability.

```
tests/
├── conftest.py                    # session: DB engine, global configuration
├── factories.py                   # Global factory definitions
├── shared/                        # shared/ layer tests
│   ├── conftest.py
│   ├── domain/
│   │   └── test_base_entity.py
│   └── infrastructure/
│       └── test_pydantic_repository.py
├── modules/                       # Mirrors src/modules/ structure
│   └── {module}/                  # Each business module
│       ├── conftest.py            # module: Factory/Mock
│       ├── unit/                  # Unit tests (Domain, Application)
│       │   ├── domain/
│       │   │   ├── test_{entity}_entity.py
│       │   │   └── test_{value_object}.py
│       │   └── application/
│       │       └── test_{entity}_service.py
│       ├── integration/           # Integration tests (Repository, API)
│       │   ├── test_{entity}_repository.py
│       │   └── test_{module}_endpoints.py
│       └── e2e/                   # Module-level end-to-end tests
│           └── test_{workflow}.py
└── e2e/                           # Cross-module end-to-end tests
    ├── conftest.py
    └── test_full_{workflow}.py
```


---

## 2. Test Patterns

**AAA Pattern** (mandatory):

```python
def test_create_task_returns_task(self) -> None:
    dto = CreateTaskDTO(name="Data Processing", owner="John")  # Arrange
    result = service.create_task(dto)                           # Act
    assert result.name == "Data Processing"                     # Assert
```

**Parameterized**: `@pytest.mark.parametrize("input,expected", [(val1, exp1), ...])`

**Exceptions**: `with pytest.raises(ValidationError, match="Name cannot be empty"): ...`

---

## 3. Fixtures

| Scope | Scenario | Location |
|-------|----------|----------|
| `session` | Database engine | `tests/conftest.py` |
| `module` | Module factory | `tests/modules/{m}/conftest.py` |
| `function` | Test data | Default |

**Pattern**: `yield` + cleanup (before yield is setup, after yield is teardown)

```python
@pytest.fixture
def db_session(engine) -> Session:
    session = sessionmaker(bind=engine)()
    yield session
    session.rollback()
    session.close()
```

---

## 4. Mocking

**Principle**: Only mock boundaries (Repo/External API/File System/Time)

```python
mock_repo = Mock(spec=ITaskRepository)
mock_repo.save.return_value = task
service = TaskService(repository=mock_repo)
# Verify: mock_repo.save.assert_called_once()
```

**Async**: `AsyncMock(spec=IRepository)`

---

## 5. Markers

```ini
# pytest.ini / pyproject.toml
markers = unit, integration, e2e, slow, aws
```

```python
@pytest.mark.unit
class TestTask: pass

@pytest.mark.integration
@pytest.mark.slow
def test_s3_upload(): pass

@pytest.mark.skip(reason="Feature not yet implemented")
@pytest.mark.xfail(reason="Known Bug #123")
```

---

## 6. Factory Pattern

```python
# tests/factories.py
class TaskFactory(factory.Factory):
    class Meta:
        model = Task
    name = factory.Sequence(lambda n: f"Task{n}")
    owner = factory.LazyAttribute(lambda o: f"{o.name}@example.com")
```

---

## 7. Coverage

See [CLAUDE.md](../CLAUDE.md) Section: Coverage Requirements for per-layer targets. See `pyproject.toml` `[tool.coverage]` for configuration details.
