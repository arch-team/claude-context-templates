# Common Rules

> Universal standards applicable to all sub-projects

---

## Git Commit Convention

### Commit Message Format

```
<type>(<scope>): <short description>

<detailed description (optional)>

<related Issue (optional)>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation update |
| `style` | Code formatting (no functional change) |
| `refactor` | Refactoring (not a new feature or bug fix) |
| `test` | Test-related changes |
| `chore` | Build/tooling/dependency updates |

### Scopes

| Scope | Description |
|-------|-------------|
| `backend` | Backend service |
| `frontend` | Frontend application |
| `infra` | Infrastructure |
| `docs` | Documentation |
| `*` | Multiple sub-projects |

### Examples

```bash
feat(backend): add user authentication module
fix(frontend): fix login form validation
docs(*): update README documentation
chore(backend): upgrade dependency versions
```

---

## Code Review Standards

### General Checklist

- [ ] Code follows sub-project specifications
- [ ] Adequate test coverage
- [ ] No obvious security vulnerabilities
- [ ] Consistent documentation/comment language
- [ ] Correct commit message format

---

## Documentation Standards

### File Naming

| Type | Convention | Example |
|------|-----------|---------|
| Main spec | `CLAUDE.md` | Sub-project entry point (Claude Code convention) |
| Topic spec | `rules/{topic}.md` | `rules/testing.md`, `rules/checklist.md` |
| Project config | `project-config.md` | Project-specific config (not auto-loaded by Claude Code) |
| Project readme | `README.md` | Project root description |

**Naming principle**: Except for `CLAUDE.md` (Claude Code convention) and `README.md`, all documents use `kebab-case.md`

### Documentation Language

- All documentation content in English
- Code examples remain in their original language

---

## Monorepo Structure Overview

> This section is the **Single Source of Truth (SSoT)** for Monorepo structure

{{MONOREPO_STRUCTURE}}

For detailed directory structures of each sub-project, refer to the corresponding `project-structure.md` document.
