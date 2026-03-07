# Tech Stack Standards

> **Purpose**: Single Source of Truth (SSoT) for tech stack version requirements, including Python, FastAPI, SQLAlchemy, and other core dependency versions.

---

## Section 0 Quick Reference Card

### Version Requirements Matrix

| Category | Technology | Minimum Version | Recommended Version |
|----------|-----------|----------------|-------------------|
| **Language** | Python | >=3.11 | 3.12+ |
| **Web Framework** | FastAPI | >=0.110.0 | 0.115+ |
| **ASGI Server** | Uvicorn | >=0.27.0 | 0.30+ |
| **Data Validation** | Pydantic | >=2.6.0 | 2.x |
| **ORM** | SQLAlchemy (async) | >=2.0.25 | 2.0+ |
| **Database Migration** | Alembic | >=1.13.0 | 1.13+ |
| **Database** | MySQL | 8.0+ | Aurora MySQL 3.x |
| **AWS SDK** | boto3 | >=1.34.0 | 1.34+ |
| **Authentication** | python-jose, passlib | - | - |
| **Logging** | structlog | >=24.1.0 | 24.x |
| **Package Manager** | uv | - | Latest |
| **Linting** | Ruff | - | Latest |
| **Type Checking** | MyPy | - | Latest |
| **Testing** | pytest | >=8.0.0 | 8.x |

### Key Constraints

- **Package Manager**: Use uv only; pip/poetry are prohibited
- **Linting**: Use Ruff only; flake8/black/isort are prohibited
- **Type Checking**: MyPy in `strict` mode

### Quick Verification Commands

```bash
# Check core versions
python --version && uv --version

# Check dependency versions
uv run python -c "import fastapi; print(fastapi.__version__)"
uv run python -c "import sqlalchemy; print(sqlalchemy.__version__)"
```

---

## Related Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | Tech stack overview and development commands |
| [testing.md](testing.md) | Testing standards |
| [code-style.md](code-style.md) | Code style standards |
