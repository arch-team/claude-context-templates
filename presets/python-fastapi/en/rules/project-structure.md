# Project Directory Structure Standards

> **Purpose**: Project directory structure standards defining file organization and configuration file conventions.

> Claude should consult this document first when initializing or checking project structure

---

## 0. Quick Reference Card

> For the monorepo structure overview, refer to the root-level common.md

### Backend Directory Structure

```
{{SUBPROJECT_NAME}}/                # Backend project root
├── .claude/                    # Claude Code context (standards documents)
│   ├── CLAUDE.md               # Backend entry point
│   ├── project-config*.md
│   └── rules/                  # Backend-specific rules
├── .github/workflows/          # CI/CD workflows
├── migrations/                 # Database migrations (Alembic)
├── scripts/                    # Utility scripts
├── src/                        # Source code → architecture.md
│   ├── modules/                # Business modules
│   ├── shared/                 # Shared kernel
│   └── presentation/api/       # FastAPI entry point
├── tests/                      # Test code → testing.md
│   ├── conftest.py             # Global fixtures
│   ├── modules/                # Mirrors src/modules/ structure
│   ├── shared/                 # shared/ layer tests
│   └── e2e/                    # End-to-end tests
├── .env.example                # Environment variable template
├── .pre-commit-config.yaml     # pre-commit hooks
├── pyproject.toml              # Project configuration (uv/ruff/mypy/pytest)
└── README.md                   # Backend README
```

### Configuration File Quick Reference

| File | Purpose | Required |
|------|---------|:--------:|
| `pyproject.toml` | Project and tool configuration | ✅ |
| `.env.example` | Environment variable template | ✅ |
| `README.md` | Project documentation | ✅ |
| `.pre-commit-config.yaml` | pre-commit hooks | Recommended |
| `docker-compose.yml` | Local development environment | Optional |

### Prohibited Practices

| Rule | Description |
|------|-------------|
| ❌ Business code in root directory | All business code must be under `src/` |
| ❌ Tests scattered in source directories | Tests must be in `tests/`, mirroring `src/` structure |
| ❌ Config files scattered around | Configuration unified in root directory or `.claude/` |
| ❌ Temporary files in version control | `.gitignore` must exclude them |

---

## 1. Cross-Document References

| Content | Reference Document |
|---------|-------------------|
| `src/modules/{module}/` internal structure | [architecture.md](architecture.md) Section 6 |
| `tests/modules/{module}/` structure | [testing.md](testing.md) Section 1 |

---

## 2. New Project Initialization Checklist

### Directories
- [ ] `src/` + `src/modules/` + `src/shared/` created
- [ ] `src/presentation/api/main.py` exists
- [ ] `tests/` + `tests/conftest.py` created
- [ ] `.claude/CLAUDE.md` configured

### Configuration Files
- [ ] `pyproject.toml` includes uv/ruff/mypy/pytest configuration
- [ ] `.env.example` lists required environment variables
- [ ] `README.md` includes project description

---

## PR Review Checklist

See [checklist.md](checklist.md) Section: Project Structure for the full checklist.
