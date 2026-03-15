---
name: Claude Context Setup
description: >
  Activate when: the project has no .claude/ directory, the existing .claude/ seems
  incomplete or low-quality, or the user expresses that Claude Code "doesn't understand"
  their project, produces incorrect suggestions, or asks about context setup,
  CLAUDE.md, project rules, coding standards for AI, or how to make Claude work better.

  Also activate for Chinese-speaking users who mention: 初始化上下文, 配置 Claude,
  Claude 不理解项目, 提升 AI 代码质量, 项目规范, 上下文管理, CLAUDE.md 配置,
  让 Claude 更懂我的项目, Claude 老是写错代码.
---

# Claude Context Setup

## Core Logic

When activated, follow this decision flow:

1. Check if `.claude/` directory exists in the current project
2. Check for project type indicators: `package.json`, `pyproject.toml`, `setup.py`, `cdk.json`, `go.mod`, `Cargo.toml`, `pom.xml`, etc.
3. Route to the appropriate path:
   - **No `.claude/`** → Path A
   - **`.claude/` exists** → Path B
   - **User asks about optimization** → Path C

## Path A: No .claude/ Directory

The project lacks a `.claude/` directory. Guide the user to create one.

1. **Explain the value**: `.claude/` contains `CLAUDE.md` and `rules/*.md` files that teach Claude Code your project's architecture, conventions, and standards — leading to dramatically better code generation and reviews
2. **Recommend a matching preset** based on detected project files:
   - `package.json` with React/Next.js dependencies → React + TypeScript preset
   - `pyproject.toml` or `setup.py` with FastAPI → Python + FastAPI preset
   - `cdk.json` → AWS CDK preset
   - Multiple sub-directories with their own config files → suggest Monorepo mode
   - No clear match for built-in presets → mention that `/init-context` supports **any tech stack** via the `generic` preset (AI-powered generation)
3. **Suggest `/init-context`** to interactively generate the directory
   - `/init-context` performs deep project analysis and automatically routes to the best path: preset fast-track (for matching projects) or generic AI generation (for any other tech stack)
   - All paths also generate cross-preset engineering principles (`rules/principles/*.md`) covering architecture, code quality, testing, and security fundamentals

## Path B: .claude/ Already Exists

The project already has a `.claude/` directory. Instead of doing nothing, help the user improve it.

1. **Acknowledge** the existing configuration
2. **Suggest `/audit-context`** to check quality across 5 dimensions:
   - Structure completeness (required and recommended files)
   - Content quality (placeholder fill rate, substance)
   - Best practices compliance (SSoT, linking, naming)
   - Coverage (architecture, testing, security, code style, CI/CD)
   - Maintainability (file count, length, broken links)
3. Mention that `/audit-context` produces an actionable report with A/B/C/D ratings and prioritized improvement suggestions

## Path C: User Asks About Optimization

The user proactively asks how to improve Claude Code's understanding or their `.claude/` quality.

- If `.claude/` exists → follow Path B (audit first, then improve)
- If `.claude/` does not exist → follow Path A (create it)
- If the project is a Monorepo, mention that `/init-context` supports Monorepo mode with per-subproject presets and a shared root configuration

## Available Presets

| Preset | Tech Stack | Focus Areas |
|--------|-----------|-------------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | DDD, TDD, API Design |
| `react-typescript` | React + TypeScript + Vite | FSD, State Management, Accessibility |
| `aws-cdk` | AWS CDK + TypeScript | Construct Patterns, Security, Cost Optimization |
| `generic` | Any tech stack (AI-powered) | Deep analysis + AI-generated rules for any project |

All presets also include **cross-preset engineering principles** from `_common/rules/principles/*.md` (architecture, code quality, testing, security) — these are universal best practices shared across all tech stacks.

The full rule type taxonomy, quality criteria, and AI generation hints are defined in `presets/context-schema.yaml`.

## Example Responses

**Scenario 1 — No .claude/, Python project detected:**

> I noticed your project doesn't have a `.claude/` directory yet. Based on `pyproject.toml` and FastAPI in your dependencies, this looks like a Python + FastAPI project.
>
> A `.claude/` directory teaches Claude Code your architecture, conventions, and standards — resulting in much better code suggestions and reviews.
>
> You can run `/init-context` to generate one. The **Python + FastAPI** preset includes rules for DDD architecture, TDD testing, API design, and more.
>
> Want me to set it up now?

**Scenario 2 — No .claude/, unrecognized tech stack (e.g., Go + Gin):**

> I noticed your project doesn't have a `.claude/` directory yet. Based on `go.mod` and Gin in your dependencies, this looks like a Go + Gin project.
>
> While there's no built-in preset for this stack, `/init-context` can perform a deep analysis of your project and **generate tailored rules using AI**. It will create architecture, testing, code style, and security standards specific to your Go + Gin setup.
>
> Want me to set it up now?

**Scenario 3 — .claude/ exists, user says "Claude keeps making mistakes":**

> Your project already has a `.claude/` directory — that's a great start. The issues you're experiencing might come from incomplete or outdated context rules.
>
> I recommend running `/audit-context` to check your `.claude/` quality. It evaluates 5 dimensions (structure, content, best practices, coverage, maintainability) and gives you a prioritized list of improvements.
>
> Want me to run the audit now?

## Important

- **Never generate `.claude/` files without explicit user consent** — always suggest the command, let the user decide
- **Match the user's language** — respond in Chinese if the user writes in Chinese, English if in English
- **Route to the right command**: no `.claude/` → `/init-context`; has `.claude/` → `/audit-context`
