# Claude Context Templates: Production-Ready `.claude/` Management for Every Project

Every Claude Code project starts with the same problem: you need a well-structured `.claude/` directory to get the best AI-assisted development experience, but there's no standard way to set one up. Most developers either copy snippets from other projects or write everything from scratch — both approaches lead to inconsistent quality and wasted effort.

**claude-context-templates** solves this by providing production-ready, reusable templates for your `.claude/` directory. Think of it as `.editorconfig` for Claude Code — a shared starting point that encodes best practices so you can focus on building.

## What's Inside

The project ships with **3 tech stack presets**, each covering a complete context management setup:

| Preset | Stack | What You Get |
|--------|-------|-------------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | DDD architecture, TDD methodology, API design standards |
| `react-typescript` | React + TypeScript + Vite | Feature-Sliced Design, state management, accessibility rules |
| `aws-cdk` | AWS CDK + TypeScript | Construct patterns, security defaults, cost optimization |

Each preset generates:
- **CLAUDE.md** — Entry point with tech stack overview and dev commands
- **project-config.md** — Fill-in template for project-specific details
- **rules/*.md** — Topic-specific standards (architecture, testing, security, code style, etc.)

Everything works in both **monorepo** and **single-project** modes, in **English** and **Chinese**.

## Design Principles That Matter

What makes this different from "just a collection of markdown files" is the structural design:

1. **Single Source of Truth (SSoT)** — Each concept is defined in exactly one file. Other files link to it. No duplication, no drift.

2. **Section 0 Quick Reference Card** — Every rules file starts with a quick-lookup section (tables, decision trees, cheat sheets) so Claude gets the critical info first.

3. **Layered Architecture** — Root-level rules → sub-project rules → topic-specific rules, with clear separation and inheritance.

4. **Bidirectional Linking** — Documents reference each other with relative links, forming a navigable knowledge graph that Claude can traverse.

5. **Dependency Matrix** — Table-based dependency rules for architecture layers, giving Claude clear boundaries.

6. **kebab-case Naming** — Consistent file naming convention across all templates.

These principles were extracted from real production monorepo projects, not designed in theory.

## Getting Started

```bash
# Clone the repository
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates

# Run the interactive initializer
./init.sh

# Follow the prompts — select preset, language, project mode
# Copy the generated .claude/ directory to your project
```

The `init.sh` script handles variable substitution (`{{PROJECT_NAME}}`, `{{PROJECT_SLUG}}`, etc.), language selection, and monorepo/single-project setup.

## What This Is (and Isn't)

**This is**: A starting point. The generated files are yours to edit and customize. The templates provide structure and best practices — adapt them to match your team's conventions.

**This isn't**: A rigid framework. You can add rules, remove rules, modify anything. The templates give you a well-organized foundation; you build on top of it.

## What's Next

We're looking for feedback from real usage. If you try the templates in your project:

- **Star the repo** if you find it useful: [github.com/arch-team/claude-context-templates](https://github.com/arch-team/claude-context-templates)
- **Report your experience** using the Usage Report issue template — this is the most valuable feedback we can get
- **Contribute a preset** for your tech stack (Go, Java, Vue, etc.)
- **File issues** for anything that doesn't work or could be improved

The project is MIT-licensed and open to contributions.
