# Contributing to Claude Context Templates

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs or suggest features
- Include clear steps to reproduce for bug reports
- Check existing issues before creating a new one

### Contributing New Presets

New presets for additional tech stacks are highly welcome! Here's how:

#### 1. Directory Structure

Create a new preset directory following this structure:

```
plugin/presets/your-preset-name/
├── preset.yaml           # Preset metadata and configuration
├── zh-CN/                # Chinese version
│   ├── CLAUDE.md         # Sub-project entry point
│   ├── project-config.md # Project config (fill-in template)
│   └── rules/            # Topic-specific rules
│       ├── architecture.md
│       ├── tech-stack.md
│       ├── code-style.md
│       ├── testing.md
│       ├── security.md
│       ├── checklist.md
│       ├── project-structure.md
│       └── ...           # Additional rules
└── en/                   # English version (same structure)
```

#### 2. Required Files

Every preset MUST include:
- `preset.yaml` — Metadata, defaults, variable definitions
- `CLAUDE.md` — Sub-project entry point with tech stack overview
- `project-config.md` — Fill-in template for project-specific config
- `rules/architecture.md` — Architecture patterns
- `rules/tech-stack.md` — Version requirements (SSoT)
- `rules/code-style.md` — Coding standards
- `rules/testing.md` — Testing methodology
- `rules/security.md` — Security checklist
- `rules/checklist.md` — PR review checklist
- `rules/project-structure.md` — Directory structure

#### 3. Design Guidelines

Follow these patterns from existing presets:

- **Section 0 Quick Reference Card** at the top of each rules file
- **Single Source of Truth** — don't duplicate information
- **Bidirectional links** between related documents
- **kebab-case** file naming
- **Tables over prose** for quick reference
- **TODO markers** in project-config.md for user-fillable fields
- Use `{{VARIABLE}}` placeholders for project-specific content

#### 4. preset.yaml Format

```yaml
name: your-preset-name
display_name: "Your Tech Stack"
description: "Brief description of what this preset covers"
version: "1.0.0"

defaults:
  package_manager: npm
  linter: eslint
  test_runner: jest
  source_root: src
  architecture_pattern: "Your Architecture Pattern"
  coverage_minimum: 80

files:
  required:
    - CLAUDE.md
    - project-config.md
    - rules/architecture.md
    - rules/tech-stack.md
    # ... more required files
  optional:
    - rules/optional-topic.md
    # ... optional files

variables:
  - name: PROJECT_NAME
    prompt: "Project name"
    required: true
  # ... more variables
```

### Contributing Translations

To add a new language:

1. Create a new language directory in each preset (e.g., `ja/` for Japanese)
2. Translate all files from the `en/` directory
3. Keep all code examples, table structures, and placeholders unchanged
4. Update `init.sh` to support the new language option

### Improving Existing Rules

When improving existing rules:

1. Keep changes focused and backward-compatible
2. Maintain the Section 0 Quick Reference Card format
3. Don't break existing links or references
4. Test that the init.sh script still works correctly

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-preset-go`)
3. Make your changes
4. Test the init.sh script with your changes
5. Submit a Pull Request with a clear description

### PR Checklist

- [ ] Files follow the naming conventions (`kebab-case.md`)
- [ ] All required files are included (for new presets)
- [ ] Both `zh-CN/` and `en/` versions are provided
- [ ] `preset.yaml` is complete and valid
- [ ] Templates use `{{VARIABLE}}` placeholders correctly
- [ ] No project-specific content remains (proper abstraction)
- [ ] `init.sh` updated if new preset added

## Code of Conduct

- Be respectful and constructive in discussions
- Focus on the technical merit of contributions
- Welcome contributors of all experience levels

## Questions?

Open a GitHub Issue with the "question" label.
