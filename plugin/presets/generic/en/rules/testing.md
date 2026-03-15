# Testing Standards

> **Purpose**: Testing standards - TDD workflow, test layering, coverage requirements, test commands, mock strategy

> For universal testing principles (TDD cycle, test integrity, AAA pattern, mock boundaries, test independence, naming), see `_common/rules/principles/testing.md`
> TDD workflow: see [CLAUDE.md](../CLAUDE.md)

---

## Universal Testing Principles

> For universal testing principles (TDD cycle, test integrity, AAA pattern, mock boundaries, test independence, naming), see `rules/principles/testing.md`

---

## Test Layering

<!-- {{AI_GENERATED:test_layering}}
  AI should generate a test layering strategy based on the project's architecture.
  Format:
  | Layer | Scope | Mock Strategy | Tools |
  |-------|-------|--------------|-------|
  | Unit        | Single function/class | External deps only | ... |
  | Integration | Module boundaries     | External services   | ... |
  | E2E         | Full user flows       | None (real system)  | ... |

  Include testing priority order (which layer to invest in most).
-->

---

## Coverage Requirements

<!-- {{AI_GENERATED:coverage_requirements}}
  AI should generate coverage requirements based on project configuration.
  Format:
  | Layer      | Minimum | Target |
  |------------|---------|--------|
  | Unit       | xx%     | xx%    |
  | Integration| xx%     | xx%    |
  | **Overall**| **xx%** | **xx%**|
-->

---

## Test Commands

<!-- {{AI_GENERATED:test_commands}}
  AI should generate test command reference from the project's build configuration.
  Format:
  ```bash
  # Run all tests
  <command>

  # Run tests with coverage
  <command>

  # Run specific test file
  <command> <path>

  # Run tests in watch mode
  <command>
  ```
-->

---

## Test File Organization

| Pattern | When to Use |
|---------|-------------|
| Co-located (next to source) | Unit tests for individual components/modules |
| Separate `tests/` directory | Integration tests, E2E tests, fixtures |
| Shared test utilities | `tests/helpers/`, `tests/fixtures/` |

---

## Related Documents

- **Architecture**: [architecture.md](architecture.md)
- **Code Style**: [code-style.md](code-style.md)
- **PR Checklist**: [checklist.md](checklist.md)
