---
version: 1.0.0
last_updated: {{DATE}}
tech_stack_ref: rules/tech-stack.md
---

# CLAUDE.md - AWS CDK Infrastructure Project Standards

> **Purpose**: Claude Code entry standards for the AWS CDK infrastructure project, providing tech stack overview, development commands, and standards navigation.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note**: For common standards (response language, project overview), refer to the root-level [../.claude/CLAUDE.md](../../.claude/CLAUDE.md)

---

## Tech Stack

> **Detailed version requirements**: See [rules/tech-stack.md](rules/tech-stack.md) (Single Source of Truth)

**Core**: AWS CDK | TypeScript | Node.js

**Testing**: Jest | CDK Assertions | CDK Nag

**Tools**: pnpm (package management) | ESLint | Prettier

---

## Environment Setup

```bash
# First-time setup
pnpm install
pnpm cdk bootstrap  # First time using CDK (once per AWS account/Region)

# Verify environment
node -v && pnpm -v && pnpm exec tsc --version && pnpm exec cdk --version
pnpm cdk synth       # Ensure synthesis succeeds
pnpm test            # Ensure tests pass
```

---

## Development Commands

### CDK Commands

```bash
# Synthesize CloudFormation template
pnpm cdk synth

# View changes (diff)
pnpm cdk diff

# Deploy to AWS
pnpm cdk deploy

# Deploy specific Stack
pnpm cdk deploy <StackName>

# Deploy all Stacks
pnpm cdk deploy --all

# Destroy Stack
pnpm cdk destroy <StackName>

# List all Stacks
pnpm cdk list

# Bootstrap CDK (first time)
pnpm cdk bootstrap
```

### Code Quality

```bash
# Lint
pnpm lint

# Lint with auto-fix
pnpm lint --fix

# Format check
pnpm format:check

# Format code
pnpm format

# Type check
pnpm typecheck

# Run all checks at once
pnpm lint && pnpm format:check && pnpm typecheck
```

### Testing

```bash
# Run all tests
pnpm test

# Run tests + coverage report
pnpm test:coverage

# Watch mode
pnpm test:watch

# Run specific test file
pnpm test lib/constructs/
```

---

## Core Principles

### Construct Design Principles

**Core principles**: Layered abstraction + Secure defaults + Least privilege.

For detailed information, refer to [rules/construct-design.md](rules/construct-design.md)

### TDD Workflow

This project fully adopts Test-Driven Development (TDD). See [rules/testing.md](rules/testing.md)

---

## Code Style

For code style standards, see [construct-design.md](rules/construct-design.md) and [project-structure.md](rules/project-structure.md)

---

## Project Structure

**Architecture pattern**: CDK Construct layering (L1 → L2 → L3), see [rules/architecture.md](rules/architecture.md)

**Project directory structure**: See [rules/project-structure.md](rules/project-structure.md)

---

## Security Standards

See [rules/security.md](rules/security.md)

---

## Gotchas

| Item | Description |
|------|-------------|
| **CDK Context cache** | `cdk.context.json` caches VPC/AZ lookup results; delete this file and re-synth if values are unexpected |
| **CfnOutput pitfall** | After using Fn.importValue, the exporting Stack cannot modify/delete the export value; prefer passing via Props |
| **NAT Gateway cost** | Use NAT Gateway cautiously in dev (~$30/month); prefer a single NAT or NAT Instance |
| **Package manager** | Use pnpm only; npm/yarn are prohibited |
| **--hotswap** | `cdk deploy --hotswap` is for dev rapid iteration only; prohibited in staging/prod |
| **CDK Nag version** | cdk-nag rules change with versions; new violations may appear after upgrades |

---

## PR Review Checklist

For the complete checklist, see [rules/checklist.md](rules/checklist.md)

**Pre-commit one-click validation**:
```bash
pnpm lint && pnpm format:check && pnpm typecheck && pnpm cdk synth && pnpm test:coverage
```
