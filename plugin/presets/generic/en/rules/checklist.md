# PR Review Checklist

> **Purpose**: Single Source of Truth (SSoT) for the PR Review checklist, covering architecture, code style, security, testing, and project structure checks.

---

## Architecture

<!-- {{AI_GENERATED:checklist_architecture}}
  Generate architecture check items based on the project architecture. Example format:
  - [ ] Core layer has no external framework dependencies
  - [ ] Dependency direction is correct (unidirectional, no cycles)
  - [ ] Inter-module communication uses prescribed patterns
  - [ ] Public exports include only necessary interfaces
-->

See [architecture.md](architecture.md) for details.

---

## Code Style

<!-- {{AI_GENERATED:checklist_code_style}}
  Generate code style check items based on the project language. Example format:
  - [ ] All public interfaces have type annotations
  - [ ] No use of any/Any escape types
  - [ ] Naming follows project conventions
  - [ ] No wildcard imports
-->

See [code-style.md](code-style.md) for details.

---

## Security

- [ ] No hardcoded secrets or credentials
- [ ] All user input is validated
- [ ] Sensitive information is not written to logs
- [ ] Error responses do not expose internal details

<!-- {{AI_GENERATED:checklist_security_extra}}
  Add extra security check items based on project specifics. Example format:
  - [ ] Uses parameterized queries, no SQL concatenation
  - [ ] No use of dangerous functions like eval/exec
  - [ ] Passwords stored with secure hashing algorithms
-->

See [security.md](security.md) for details.

---

## Testing

- [ ] New features have corresponding tests
- [ ] AAA pattern + clear naming
- [ ] Mocks only at boundary dependencies + independently runnable
- [ ] Coverage meets requirements

<!-- {{AI_GENERATED:checklist_testing_extra}}
  Add extra testing check items based on project specifics. Example format:
  - [ ] Uses test markers (unit/integration/e2e)
  - [ ] Tests are in designated directories
-->

See [testing.md](testing.md) for details.

---

## Project Structure

- [ ] New files are placed in the correct directory
- [ ] No temporary files committed

<!-- {{AI_GENERATED:checklist_structure_extra}}
  Add extra structure check items based on project specifics. Example format:
  - [ ] Tests mirror source directory structure
  - [ ] New modules include required initialization files
-->

See [project-structure.md](project-structure.md) for details.

---

## Pre-Commit Validation

<!-- {{AI_GENERATED:pre_commit_command}}
  Generate a one-line pre-commit command chaining all check steps. Example format:
  ```bash
  npm run lint && npm run typecheck && npm run test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
  ```
-->
