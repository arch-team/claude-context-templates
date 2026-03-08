# CLAUDE.md - Python Backend Project Standards

> **Purpose**: Entry-point standards for the backend project, defining tech stack, development commands, and core principles.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note**: For common standards (response language, project overview), refer to the root [../.claude/CLAUDE.md](../../.claude/CLAUDE.md)

---

## Tech Stack

**Core**: Python 3.11+ | FastAPI | SQLAlchemy 2.0+ | Pydantic v2 | MySQL 8.0+

**Tools**: {{PACKAGE_MANAGER}} (package management) | Ruff (lint) | MyPy (type checking) | pytest 8.0+

See [rules/tech-stack.md](rules/tech-stack.md) for full version matrix and constraints.

---

## Development Commands

### Code Quality

```bash
# Lint
uv run ruff check src/

# Lint with auto-fix
uv run ruff check src/ --fix

# Format
uv run ruff format src/

# Type checking
uv run mypy src/

# Run all checks at once
uv run ruff check src/ && uv run ruff format --check src/ && uv run mypy src/
```

### Testing

```bash
# Run all tests
uv run pytest

# Run tests with coverage report
uv run pytest --cov=src --cov-report=term-missing

# Run tests for a specific module
uv run pytest tests/modules/auth/

# Run marked tests
uv run pytest -m "unit"
uv run pytest -m "integration"
```

### Running the Service

```bash
# Development mode
uv run uvicorn src.presentation.api.main:app --reload --port 8000

# Production mode
uv run uvicorn src.presentation.api.main:app --host 0.0.0.0 --port 8000 --workers 4
```

---

## Core Principles

### SDK-First Principle

**Core Principle**: Use SDKs whenever possible to simplify implementation and avoid reinventing the wheel.

See [rules/sdk-first.md](rules/sdk-first.md) for details.

### TDD Workflow

This project fully adopts Test-Driven Development (TDD).

**Core Loop**:
```
1. Red: Write a failing test first
2. Green: Write the minimum code to make the test pass
3. Refactor: Refactor the code while keeping tests green
```

**Testing Layer Strategy**:

| Layer | Description |
|-------|-------------|
| **Unit** | Entities, value objects, domain logic |
| **Integration** | API endpoints, repository implementations |
| **E2E** | End-to-end flows, external service integrations |

**Test Integrity Principle**: Never fake results to make tests pass. A failing test = a code problem that must be fixed.

See [rules/testing.md](rules/testing.md) for details.

---

## Code Style Quick Reference

See [rules/code-style.md](rules/code-style.md) for type hints, naming conventions, docstrings, and async code guidelines.

---

## Project Structure

**Project-Level Directories**: See [rules/project-structure.md](rules/project-structure.md) - Full directory structure standards

**Architecture Pattern**: DDD + Modular Monolith + Clean Architecture

**Core Layering**: Domain -> Application -> Infrastructure -> Presentation (dependency direction from outer to inner)

See [rules/architecture.md](rules/architecture.md) for detailed architecture standards, module structure templates, and dependency rules.

---

## Security Quick Reference

See [rules/security.md](rules/security.md) for cheat sheets and detection commands.

---

## Logging & Observability

**Logging Standards**: See [rules/logging.md](rules/logging.md) - structlog structured logging, Correlation ID, data masking rules

**Observability**: See [rules/observability.md](rules/observability.md) - Metrics naming, Distributed Tracing, Health Check endpoints

---

## API Design Standards

See [rules/api-design.md](rules/api-design.md) - RESTful routing, HTTP status codes, error response format

---

## Coverage Requirements

| Layer | Minimum Coverage | Target Coverage |
|-------|-----------------|-----------------|
| Domain | 95% | 100% |
| Application | 90% | 95% |
| Infrastructure | 80% | 85% |
| Presentation | 80% | 85% |
| **Overall** | **{{COVERAGE_MIN}}%** | **90%** |

---

## Gotchas

| Item | Description |
|------|-------------|
| **Database** | MySQL 8.0+ / Aurora MySQL 3.x, NOT PostgreSQL. Watch for SQLAlchemy dialect differences |
| **Async Driver** | Requires asyncmy as the async MySQL driver |
| **Package Manager** | Use {{PACKAGE_MANAGER}} only, pip/poetry are prohibited |

---

## PR Review Checklist

See [rules/checklist.md](rules/checklist.md) for the full checklist.

**Pre-commit one-step validation**:
```bash
uv run ruff check src/ && uv run ruff format --check src/ && uv run mypy src/ && uv run pytest --cov=src --cov-fail-under={{COVERAGE_MIN}}
```
