# CLAUDE.md - {{PROJECT_NAME}} Project Standards

> **Purpose**: Project entry document - Tech stack overview, development commands, and core principles.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note**: For common standards (response language, project overview), refer to the root [../.claude/CLAUDE.md](../../.claude/CLAUDE.md)

---

## Tech Stack

<!-- {{AI_GENERATED:tech_stack_summary}}
  Generate a tech stack summary based on the actual project stack. Example format:
  **Core**: Language | Framework | Database
  **Tools**: Package Manager | Linter | Type Checker | Test Framework
-->

See [rules/tech-stack.md](rules/tech-stack.md) for version matrix and constraints.

---

## Development Commands

<!-- {{AI_GENERATED:dev_commands}}
  Generate common development commands based on the project toolchain:
  - Code quality checks (lint, format, type-check)
  - Testing (run all, coverage, specific module)
  - Service (development mode, production mode)
  - Run all checks at once
-->

---

## Core Principles

<!-- {{AI_GENERATED:core_principles}}
  Generate 2-4 core principles based on the project. Example format:
  ### Principle Name
  **Key point**: One-line summary
  See [rules/xxx.md](rules/xxx.md) for details.
-->

### TDD Workflow

This project follows Test-Driven Development (TDD).

**Core cycle**:
```
1. Red: Write a failing test first
2. Green: Write minimal code to make the test pass
3. Refactor: Refactor the code while keeping tests passing
```

**Test integrity principle**: Never fake results to make tests pass. A failing test = a code problem that must be fixed.

See [rules/testing.md](rules/testing.md) for details.

---

## Code Style Quick Reference

See [rules/code-style.md](rules/code-style.md) for type annotations, naming conventions, and import ordering.

---

## Project Structure

**Directory Structure**: See [rules/project-structure.md](rules/project-structure.md) - Complete directory structure standards

**Architecture Pattern**: See [rules/architecture.md](rules/architecture.md) - Architecture design and layering principles

---

## Security Quick Reference

See [rules/security.md](rules/security.md) for cheat sheet and scanning commands.

---

## Coverage Requirements

<!-- {{AI_GENERATED:coverage_table}}
  Generate a coverage table based on project architecture layers. Example format:
  | Layer | Minimum | Target |
  |-------|---------|--------|
  | Core/Domain | 95% | 100% |
  | Application | 90% | 95% |
  | Infrastructure | 80% | 85% |
  | **Overall** | **80%** | **90%** |
-->

---

## PR Review Checklist

See [rules/checklist.md](rules/checklist.md) for the full checklist.

**Pre-commit one-step validation**:

<!-- {{AI_GENERATED:pre_commit_one_liner}}
  Generate a one-line pre-commit command chaining lint + format check + type check + test. Example:
  ```bash
  npm run lint && npm run typecheck && npm run test -- --coverage
  ```
-->

---

## Gotchas

<!-- {{AI_GENERATED:gotchas}}
  List project-specific pitfalls and gotchas. Example format:
  | Item | Description |
  |------|-------------|
  | **Database** | Uses xxx, be aware of yyy |
  | **Package Manager** | Use only xxx, do not use yyy |
-->
