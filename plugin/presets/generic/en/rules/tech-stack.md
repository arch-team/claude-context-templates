# Tech Stack Definition

> **Purpose**: Single Source of Truth (SSoT) for tech stack version constraints, including language, framework, and toolchain dependencies.

---

## 0. Quick Reference Card

### Version Matrix

<!-- {{AI_GENERATED:version_matrix}}
  Generate a version matrix table based on the actual project tech stack. Example format:
  | Category | Technology | Minimum Version | Recommended Version |
  |----------|-----------|----------------|-------------------|
  | **Language** | Python / TypeScript / Go ... | >=x.y | x.y+ |
  | **Framework** | FastAPI / React / Gin ... | >=x.y | x.y+ |
  | **Database** | PostgreSQL / MySQL / MongoDB ... | x.y+ | x.y |
  | **Package Manager** | uv / npm / pnpm / go mod ... | - | latest |
  | **Linter** | Ruff / ESLint / golangci-lint ... | - | latest |
  | **Type Checker** | MyPy / TypeScript / - ... | - | latest |
  | **Testing** | pytest / Jest / go test ... | >=x.y | x.y |
-->

### Key Constraints

<!-- {{AI_GENERATED:key_constraints}}
  List key technical constraints for the project. Example format:
  - **Package Manager**: Use only xxx, do not use yyy
  - **Linter**: Use only xxx, do not use yyy
  - **Type Checking**: Enable strict mode
-->

### Quick Verification Commands

<!-- {{AI_GENERATED:version_check_commands}}
  Generate commands to verify key versions. Example format:
  ```bash
  # Check core versions
  node --version && npm --version
  # Check dependency versions
  npm list react typescript
  ```
-->

---

## Toolchain Configuration

<!-- {{AI_GENERATED:toolchain_config}}
  Describe key tool configurations and config file locations. Example format:
  | Tool | Config File | Description |
  |------|------------|-------------|
  | Linter | .eslintrc.js / ruff.toml | Code style checking |
  | Formatter | .prettierrc / pyproject.toml | Code formatting |
  | Type Checker | tsconfig.json / mypy.ini | Type checking |
-->

---

## Upgrade Strategy

- **Major versions**: Team review required, assess breaking change impact
- **Minor versions**: Regular updates during development cycles
- **Patch versions**: Apply security patches immediately
- **Lock files**: Use lock files to pin dependency versions for reproducible builds

---

## Related Documents

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | Tech stack overview and development commands |
| [testing.md](testing.md) | Testing standards |
| [code-style.md](code-style.md) | Code style standards |
