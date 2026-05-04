# Project Directory Structure

> **Purpose**: Project directory structure standards - file organization and configuration file conventions.

> Claude should consult this document first when initializing or checking project structure.

---

## 0. Quick Reference Card

### Directory Tree

<!-- {{AI_GENERATED:directory_tree}}
  Generate a directory tree based on the actual project structure. Example format:
  ```
  project-root/
  ├── .claude/                    # Claude Code context (standards documents)
  │   ├── CLAUDE.md               # Project entry point
  │   ├── project-config.md       # Project configuration
  │   └── rules/                  # Rule documents
  ├── src/                        # Source code
  │   ├── modules/                # Business modules
  │   └── shared/                 # Shared kernel
  ├── tests/                      # Test code
  ├── scripts/                    # Utility scripts
  ├── docs/                       # Documentation
  └── README.md
  ```
-->

### Configuration File Quick Reference

<!-- {{AI_GENERATED:config_files}}
  List key project configuration files. Example format:
  | File | Purpose | Required |
  |------|---------|:--------:|
  | package.json / pyproject.toml | Project and tool configuration | Yes |
  | .env.example | Environment variable template | Yes |
  | README.md | Project description | Yes |
-->

### Prohibited Practices

| Rule | Description |
|------|-------------|
| No source files in root directory | All source code must be under the designated source root |
| No scattered test files | Tests must be in dedicated test directories |
| No scattered config files | Configuration unified in root or designated locations |
| No temporary files in version control | .gitignore must exclude them |

---

## File Naming Conventions

<!-- {{AI_GENERATED:naming_rules}}
  Generate file naming conventions based on the project language. Example format:
  | Type | Convention | Example |
  |------|-----------|---------|
  | Component files | PascalCase | UserProfile.tsx |
  | Utility files | kebab-case | date-utils.ts |
  | Test files | xxx.test.ts / test_xxx.py | user.test.ts |
  | Style files | kebab-case | user-profile.css |
-->

---

## New Module Template

<!-- {{AI_GENERATED:new_module_template}}
  Provide the standard directory structure for new modules. Example format:
  ```
  modules/{module-name}/
  ├── index.ts / __init__.py      # Public API exports
  ├── domain/                     # Core business logic
  ├── application/                # Use case orchestration
  ├── infrastructure/             # Technical implementation
  └── api/                        # External interfaces
  ```
  And a checklist for new modules:
  - [ ] Directory structure created
  - [ ] Public API exported
  - [ ] project-config.md updated
-->

---

## Related Documents

| Document | Description |
|----------|-------------|
| [architecture.md](architecture.md) | Module internal structure |
| [code-style.md](code-style.md) | Code style standards |
| [testing.md](testing.md) | Test directory structure |
| [checklist.md](checklist.md) | PR Review - Project Structure section |
