---
name: Claude Context Setup
description: >
  Use when user wants to: set up Claude Code context for their project, initialize
  .claude/ directory, create CLAUDE.md or project rules, improve Claude's understanding
  of project architecture, or expresses that Claude repeatedly produces incorrect code
  across multiple files.

  Also activate for Chinese-speaking users who mention: 初始化 Claude 上下文, 创建 .claude 目录,
  生成 CLAUDE.md, 配置 Claude 项目规范, Claude 持续不理解项目架构, 提升 AI 代码生成质量,
  上下文管理, 让 Claude 更懂项目, Claude 总是写错代码需要重复修改.
---

# Claude Context Setup

## Core Logic

When activated, follow this decision flow:

1. Check if `.claude/` directory exists in the current project
2. Check for project type indicators: `package.json`, `pyproject.toml`, `setup.py`, `cdk.json`, `go.mod`, `Cargo.toml`, `pom.xml`, etc.
3. Route to the appropriate path:
   - **No `.claude/`** → Path A
   - **`.claude/` exists BUT empty or no files inside** → Path A (with warning: "Found empty .claude/ directory, will initialize from scratch")
   - **`.claude/` exists BUT no `rules/` directory** → Path A (suggest overwrite: "Found .claude/ without rules/, recommend re-initialization")
   - **`.claude/` exists with proper structure** → Path B
   - **User explicitly requests re-initialization** (keywords: "重新初始化", "re-init", "overwrite", "覆盖") → Path A with overwrite option
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

Read the available preset list from `presets/manifest.json`. Each preset entry contains `display_name` and `description`. The `generic` preset supports any tech stack via AI-powered generation.

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
> I recommend running `/audit-context` to identify specific issues causing incorrect suggestions. It will give you a prioritized list of actionable fixes.
>
> Want me to run the audit now?

## Example Responses (continued)

**Scenario 4 — Monorepo detected:**

> I noticed your project has a Monorepo structure with multiple subprojects (`backend/`, `frontend/`, `infra/`).
>
> `/init-context` supports Monorepo mode — it will create a root `.claude/` with shared rules, plus separate `.claude/` directories for each subproject with tech stack-specific configurations.
>
> Want me to set it up now?

## Important

- **Never generate `.claude/` files without explicit user consent** — always suggest the command, let the user decide
- **Match the user's language** — respond in Chinese if the user writes in Chinese, English if in English
- **Route to the right command**: no `.claude/` → `/init-context`; has `.claude/` → `/audit-context`
- **If user declines**, acknowledge their choice and offer: "No problem. If you change your mind, just ask me to 'initialize Claude context'."

## Parameter Pre-filling

When routing to `/init-context`, leverage detected context to reduce user interaction:

- **Detected preset match** (e.g., FastAPI in dependencies): mention the matching preset by name so the user knows it will be auto-selected
- **Detected Monorepo structure**: mention that `/init-context` will auto-detect the Monorepo layout
- **User says "re-initialize" or "overwrite"**: inform that `/init-context` will handle the existing `.claude/` conflict gracefully
