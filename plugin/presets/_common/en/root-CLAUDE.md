# {{PROJECT_NAME}} - Monorepo

## Response Language
**All conversations and documentation must be in English.**
**Unless otherwise specified, please respond in English.**

### Requirements

- All conversations must be in English
- Code comments in English
- Documentation in English
- Git commit messages in English

### Exceptions

The following should remain in their original language:
- Code variable names, function names, class names
- Technical terms (e.g., API, SDK, TDD)
- Third-party library/framework names
- Error messages and logs (optional)

---

## Project Overview

{{PROJECT_DESCRIPTION}}

## Monorepo Structure

{{SUBPROJECT_TABLE}}

## Development Guide

When entering a sub-project directory, Claude Code automatically loads that sub-project's specifications:

```bash
# Example:
# cd backend/   # Load backend specs
# cd frontend/  # Load frontend specs
# cd infra/     # Load infrastructure specs
```

## Related Documentation

| Sub-project | Specification |
|-------------|--------------|
| Common Rules | [.claude/rules/common.md](.claude/rules/common.md) |
