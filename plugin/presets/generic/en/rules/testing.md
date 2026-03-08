# Testing Standards

> **Purpose**: Testing standards - TDD workflow, test layering, coverage requirements, test commands, mock strategy

---

## TDD Core Cycle

> This cycle is universal and applies regardless of tech stack.

```
RED    -> Write a failing test that defines desired behavior
GREEN  -> Write the minimum code to make the test pass
REFACTOR -> Improve code quality while keeping tests green
```

**TDD Discipline Rules**:
1. Never write production code without a failing test
2. Write only enough test to demonstrate a failure
3. Write only enough production code to pass the test
4. Refactor only when all tests are green
5. Each cycle should take minutes, not hours

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

## Test Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| Test file | Co-located or in `tests/` directory | `test_user.py`, `User.test.ts` |
| Test suite | `describe('ModuleName')` or class-based | `describe('UserService')` |
| Test case | `it('should {expected behavior}')` | `it('should return user by id')` |

---

## Mock Boundary Strategy

> This strategy is universal and applies regardless of tech stack.

**What to mock**:
- External services (APIs, databases, file systems, message queues)
- Time-dependent operations (clocks, timers, schedulers)
- Non-deterministic operations (random, UUIDs)

**What NOT to mock**:
- Internal modules and functions (test real integration)
- Simple data transformations (test actual logic)
- The unit under test itself

**Mock boundary rule**: Mock at the architectural boundary, not inside modules. If you find yourself mocking internal implementation details, your test is too coupled to the implementation.

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
