# PR Review Checklist

> **Purpose**: Single Source of Truth (SSoT) for the PR Review checklist, covering architecture, code style, security, testing, and API design checks.

---

## Layering & Architecture

- [ ] Domain layer has no external framework dependencies (FastAPI, SQLAlchemy, boto3)
- [ ] Domain layer entities use Pydantic BaseModel or PydanticEntity base class
- [ ] Application layer depends only on Domain layer and interfaces
- [ ] Repository interfaces defined in Domain layer, implementations in Infrastructure layer
- [ ] API layer executes business operations through Application Services
- [ ] Module Domain layer does not import from other modules
- [ ] Inter-module communication uses EventBus or shared/interfaces
- [ ] `__init__.py` only exports public API, not implementation details

See [architecture.md](architecture.md) for details.

---

## Code Style

- [ ] All public interfaces have type hints
- [ ] No usage of `Any` type
- [ ] Naming follows conventions (snake_case/PascalCase)
- [ ] Docstrings follow the "types as documentation" principle (omitted when types are self-explanatory)
- [ ] No wildcard imports
- [ ] Async code correctly uses async/await

See [code-style.md](code-style.md) for details.

---

## Security

- [ ] No hardcoded secrets or passwords
- [ ] All user input is validated
- [ ] Uses parameterized queries, no SQL string concatenation
- [ ] Sensitive information is not written to logs
- [ ] No usage of eval/exec/pickle
- [ ] Passwords are stored using secure hashing algorithms
- [ ] Error responses do not expose internal information

See [security.md](security.md) for details.

---

## Testing

- [ ] Tests are in `tests/modules/{module}/`
- [ ] AAA pattern + clear naming
- [ ] Mocks only for boundary dependencies + tests run independently
- [ ] Uses test markers (`@pytest.mark.unit`, etc.)
- [ ] Coverage meets minimum (>={{COVERAGE_MIN}}%)

See [testing.md](testing.md) for details.

---

## API Design

- [ ] Routes use plural nouns, not verbs
- [ ] HTTP methods have correct semantics
- [ ] Returns correct HTTP status codes
- [ ] Error responses use ErrorResponse format
- [ ] Pagination parameters use `page` and `page_size`

See [api-design.md](api-design.md) for details.

---

## SDK Usage

- [ ] Official SDK is preferred
- [ ] Custom implementations have sufficient justification
- [ ] Wrapper layer < 100 lines
- [ ] SDK exceptions are converted to domain exceptions

See [sdk-first.md](sdk-first.md) for details.

---

## Logging

- [ ] Uses structlog structured key-value pairs, not string concatenation
- [ ] Sensitive data is masked (passwords, tokens, emails)
- [ ] No `print()` debug output
- [ ] Exception records include full traceback

See [logging.md](logging.md) for details.

---

## Observability

- [ ] Health Check endpoints (`/health`, `/health/ready`) are available
- [ ] Critical operations have Span or Metrics records
- [ ] Correlation ID is propagated through the request chain

See [observability.md](observability.md) for details.

---

## Project Structure

- [ ] New files are placed in the correct directory
- [ ] Tests are under `tests/`, mirroring `src/` structure
- [ ] New Python packages have `__init__.py`
- [ ] No temporary files committed

See [project-structure.md](project-structure.md) for details.

---

## Pre-Commit One-Step Validation

```bash
uv run ruff check src/ && uv run ruff format --check src/ && uv run mypy src/ && uv run pytest --cov=src --cov-fail-under={{COVERAGE_MIN}}
```
