# Claude Context Templates

**TL;DR** Install the Plugin in Claude Code → run `/init-context` → get a production-ready `.claude/` directory with architecture, testing, and security rules for your tech stack. Supports Python/FastAPI, React/TypeScript, and AWS CDK.

> Structured, reusable context management templates for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Generate a well-organized `.claude/` directory for your project in seconds.

[中文文档](README.zh-CN.md)

## Why?

Claude Code reads `CLAUDE.md` files and `.claude/rules/` to understand your project. A well-structured context directory dramatically improves Claude's understanding of your codebase — leading to better code generation, more consistent reviews, and smarter suggestions.

**This project provides production-ready templates** based on proven patterns from real-world monorepo projects, so you don't have to build your context management from scratch.

## Quick Start

### Option 1: Claude Code Plugin (Recommended)

Install the plugin directly in Claude Code — no cloning required:

```bash
# 1. Add the marketplace (one-time setup)
/plugin marketplace add arch-team/claude-context-templates

# 2. Install the plugin
/plugin install claude-context-templates@claude-context-templates

# 3. Generate .claude/ directory interactively
/init-context
```

The plugin offers conversational interaction, auto-detects your project's tech stack, and supports all platforms.

### Option 2: Shell Script

For CI/CD environments or if you prefer command-line tools:

```bash
# 1. Clone the template repository
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates

# 2. Run the interactive initializer
./init.sh

# 3. Follow the prompts to generate your .claude/ directory
```

The script will ask you about your project and generate a complete `.claude/` directory structure tailored to your tech stack.

## Available Presets

| Preset | Tech Stack | Rules Files | Description |
|--------|-----------|:-----------:|-------------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | 11 | DDD + Clean Architecture, TDD, API Design |
| `react-typescript` | React + TypeScript + Vite | 11 | Feature-Sliced Design, State Management, Accessibility |
| `aws-cdk` | AWS CDK + TypeScript | 9 | Construct Patterns, Security Defaults, Cost Optimization |

Each preset includes:
- **CLAUDE.md** — Sub-project entry point (tech stack, dev commands, navigation)
- **project-config.md** — Project-specific configuration (fill-in template)
- **rules/*.md** — Topic-specific standards (architecture, testing, security, etc.)

## Generated Structure

### Monorepo Mode

```
your-project/
├── .claude/
│   ├── CLAUDE.md              # Global entry point
│   └── rules/
│       └── common.md          # Cross-project rules (Git, docs, structure)
├── backend/.claude/
│   ├── CLAUDE.md              # Backend entry point
│   ├── project-config.md      # <- Edit this with your project details
│   └── rules/
│       ├── architecture.md    # DDD + Clean Architecture
│       ├── api-design.md      # RESTful API standards
│       ├── code-style.md      # Python coding standards
│       ├── testing.md         # TDD methodology
│       ├── security.md        # Security checklist
│       └── ...                # More topic-specific rules
├── frontend/.claude/
│   └── ...                    # React + TypeScript rules
└── infra/.claude/
    └── ...                    # AWS CDK rules
```

### Single Project Mode

```
your-project/
└── .claude/
    ├── CLAUDE.md              # Project entry point
    ├── project-config.md      # <- Edit this with your project details
    └── rules/
        ├── architecture.md
        ├── code-style.md
        ├── testing.md
        └── ...
```

## Design Principles

This template system is built on 6 core design principles:

| Principle | Description |
|-----------|-------------|
| **Single Source of Truth (SSoT)** | Each concept is defined in exactly one file. Other files link to it. |
| **Section 0 Quick Reference Card** | Every rules file starts with a quick-lookup section (tables, decision trees, cheat sheets). |
| **Layered Architecture** | Root-level -> Sub-project -> Topic-specific rules, with clear separation. |
| **Dependency Matrix** | Table-based dependency rules for architecture layers. |
| **Bidirectional Linking** | Documents reference each other with relative links, forming a knowledge network. |
| **kebab-case Naming** | All files use `kebab-case.md` except `CLAUDE.md` and `README.md`. |

These principles are enforced through automated validation and quality checklists.

## Customization

### Adding Custom Rules

Create a new file in your `rules/` directory:

```bash
# Example: Add a custom i18n rule
touch backend/.claude/rules/i18n.md
```

Then add a link to it in your `CLAUDE.md`.

### Modifying Existing Rules

All generated files are yours to edit. The templates provide a starting point -- customize them to match your team's conventions.

### Creating a New Preset

See [docs/customization-guide.md](docs/customization-guide.md) for instructions on creating and contributing new presets.

## Bilingual Support

Templates are available in both **English** and **Chinese**. Select your preferred language during initialization.

## Examples

Check out the [examples/](examples/) directory for complete, ready-to-use configurations:

- **[monorepo-taskmanager](examples/monorepo-taskmanager/)** -- Full monorepo with backend + frontend + infra
- **[single-project-python](examples/single-project-python/)** -- Standalone Python project

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute

- **New Presets** -- Add templates for Go, Java Spring Boot, Vue, Terraform, etc.
- **Translations** -- Add support for more languages
- **Improvements** -- Enhance existing rules with better practices
- **Bug Reports** -- Report issues with templates or the init script

## Template Variables

When using the init script, the following placeholders are automatically replaced:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project display name | My Awesome App |
| `{{PROJECT_SLUG}}` | Project identifier (kebab-case) | my-awesome-app |
| `{{PROJECT_DESCRIPTION}}` | Project description | A modern web application |
| `{{SUBPROJECT_NAME}}` | Sub-project name | backend |
| `{{SUBPROJECT_TABLE}}` | Monorepo sub-project table | (auto-generated) |
| `{{MONOREPO_STRUCTURE}}` | Directory structure tree | (auto-generated) |

See [docs/template-variables.md](docs/template-variables.md) for the full reference.

## License

[MIT](LICENSE)
