# CLAUDE.md - React Frontend Project Standards

> **Purpose**: Frontend project entry document - Tech stack overview, development commands, standards navigation

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note**: For common standards (response language, project overview), refer to the root [../.claude/CLAUDE.md](../../.claude/CLAUDE.md)

---

## Tech Stack

> **Detailed Tech Stack Standards**: See [rules/tech-stack.md](rules/tech-stack.md) (Single Source of Truth)

**Overview**: React | TypeScript | Vite | TailwindCSS | React Query | Zustand

---

## Development Commands

### Code Quality

```bash
# Lint
{{PACKAGE_MANAGER}} lint

# Lint with auto-fix
{{PACKAGE_MANAGER}} lint --fix

# Format check
{{PACKAGE_MANAGER}} format:check

# Format code
{{PACKAGE_MANAGER}} format

# Type checking
{{PACKAGE_MANAGER}} typecheck

# Run all checks at once
{{PACKAGE_MANAGER}} lint && {{PACKAGE_MANAGER}} format:check && {{PACKAGE_MANAGER}} typecheck
```

### Testing

```bash
# Run all tests
{{PACKAGE_MANAGER}} test

# Run tests with coverage report
{{PACKAGE_MANAGER}} test:coverage

# Run UI mode
{{PACKAGE_MANAGER}} test:ui

# Run E2E tests (Playwright)
{{PACKAGE_MANAGER}} test:e2e

# Run specific test files
{{PACKAGE_MANAGER}} test src/features/auth/
```

### Development Server

```bash
# Development mode
{{PACKAGE_MANAGER}} dev

# Build production version
{{PACKAGE_MANAGER}} build

# Preview production build
{{PACKAGE_MANAGER}} preview
```

---

## Core Principles

| Principle | Description | Detailed Standards |
|-----------|-------------|-------------------|
| **Component Design** | Single responsibility + Composition over inheritance + Type safety | [component-design.md](rules/component-design.md) |
| **TDD Workflow** | Red-Green-Refactor cycle, test integrity principle | [testing.md](rules/testing.md) |
| **State Management** | Server state → React Query, Client state → Zustand | [state-management.md](rules/state-management.md) |
| **Code Style** | Naming conventions, TypeScript, import ordering | [code-style.md](rules/code-style.md) |

---

## Project Structure

**Architecture Pattern**: Feature-Sliced Design (FSD)

**Core Layering**: app → pages → widgets → features → entities → shared

See [rules/architecture.md](rules/architecture.md) for detailed architecture standards, directory structure, and dependency rules.

**Project Directory Structure**: See [rules/project-structure.md](rules/project-structure.md)

---

## PR Review Checklist

See [rules/checklist.md](rules/checklist.md) for the full checklist.

**Pre-commit one-step validation**:
```bash
{{PACKAGE_MANAGER}} lint && {{PACKAGE_MANAGER}} format:check && {{PACKAGE_MANAGER}} typecheck && {{PACKAGE_MANAGER}} test:coverage
```
