# Testing Principles

> Cross-stack testing engineering principles. For stack-specific implementations, see the corresponding preset's rules/testing.md.

---

## TDD Core Cycle

```
1. Red: Write a failing test first
2. Green: Write the minimum code to make the test pass
3. Refactor: Refactor code while keeping tests green
```

---

## Test Integrity

- Never fake results to make tests pass
- Test failure = code is broken; fix the code, not the test
- Never comment out or skip failing tests

---

## Test Layering Model

| Layer | Scope | Speed | Ratio |
|-------|-------|-------|-------|
| Unit | Single function/class | Fast | ~70% |
| Integration | Cross-module interaction | Medium | ~20% |
| E2E | Full user workflow | Slow | ~10% |

---

## AAA Pattern

All tests follow the Arrange-Act-Assert pattern:

- **Arrange**: Set up test data and environment
- **Act**: Execute the code under test
- **Assert**: Verify the result

---

## Mock Boundary Strategy

- ✅ Only mock external dependencies (APIs, databases, file systems)
- ❌ Do not mock the system under test itself
- ❌ Do not mock internal module-to-module calls
- Mocks should reflect real behavior, not return hardcoded values

---

## Test Independence

- Each test must run independently, with no dependency on execution order
- Each test owns its own test data; no shared mutable state
- Test results must be repeatable (same input → same output)

---

## Test Naming

- Test names should clearly describe the behavior and expected outcome
- Recommended pattern: `test_{behavior}_{scenario}_{expected_result}`
