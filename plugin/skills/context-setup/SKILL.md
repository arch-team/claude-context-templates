---
name: Claude Context Setup
description: >
  Detect projects missing .claude/ context directories and suggest generating one.
  Triggers when a project lacks .claude/, or when users mention "initialize context",
  "setup CLAUDE.md", "configure Claude Code rules", or "improve Claude understanding".
  Supports Python/FastAPI, React/TypeScript, and AWS CDK presets.
---

# Claude Context Setup

## When to Activate

This skill activates when you detect any of the following:

- The current project directory does not have a `.claude/` directory
- The user mentions wanting better Claude Code understanding of their project
- The user asks about "CLAUDE.md", "context setup", "Claude Code configuration"
- The user asks "how to make Claude Code work better with my project"

## Behavior

**Do NOT auto-generate files.** Instead:

1. **Inform the user** that their project could benefit from a `.claude/` context directory
2. **Briefly explain** what `.claude/` directories do:
   - Claude Code reads `CLAUDE.md` and `rules/*.md` to understand project architecture, conventions, and standards
   - A well-structured context directory leads to better code generation, more consistent reviews, and smarter suggestions
3. **Suggest using the `/init-context` command** to interactively generate a production-ready `.claude/` directory
4. **Mention available presets**: Python/FastAPI, React/TypeScript, AWS CDK

## Example Response

> I noticed your project doesn't have a `.claude/` directory yet. This directory helps Claude Code understand your project's architecture, coding standards, and conventions — leading to much better code suggestions.
>
> You can run `/init-context` to interactively generate a production-ready `.claude/` directory. It supports:
> - **Python + FastAPI** (DDD, TDD, API Design)
> - **React + TypeScript** (FSD, State Management, Accessibility)
> - **AWS CDK** (Construct Patterns, Security, Cost Optimization)
>
> Want me to set it up now?

## Important

- **Never generate `.claude/` files without explicit user consent**
- Keep the suggestion concise — don't overwhelm the user
- If the user says yes, invoke the `/init-context` command flow
- If the project already has `.claude/`, do not activate this skill
