# Contributing to Claude Context Templates

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs or suggest features
- Include clear steps to reproduce for bug reports
- Check existing issues before creating a new one

### Contributing New Presets

New presets for additional tech stacks are highly welcome! For detailed preset development guidelines, directory structure, required files, and `preset.yaml` format, see [docs/customization-guide.md](docs/customization-guide.md).

**Quick checklist for new presets:**

- [ ] Create directory under `plugin/presets/your-preset-name/`
- [ ] Include both `zh-CN/` and `en/` language versions
- [ ] Include `preset.yaml` with metadata, defaults, and variable definitions
- [ ] Include all required files (CLAUDE.md, project-config.md, 7 core rules)
- [ ] Follow design principles: Section 0, SSoT, bidirectional links, kebab-case naming
- [ ] Use `{{VARIABLE}}` placeholders for project-specific content
- [ ] Run `./scripts/validate-presets.sh` to verify structure

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
4. Run validation scripts:
   - `./scripts/validate-presets.sh` — Preset structure verification
   - `./scripts/check-links.sh` — Documentation link check
   - `./scripts/test-init.sh` — init.sh functionality test
5. Submit a Pull Request with a clear description

### PR Checklist

- [ ] Files follow naming conventions (`kebab-case.md`)
- [ ] Both `zh-CN/` and `en/` versions are provided (for new presets)
- [ ] All validation scripts pass
- [ ] No project-specific content remains (proper abstraction)

## Code of Conduct

- Be respectful and constructive in discussions
- Focus on the technical merit of contributions
- Welcome contributors of all experience levels

## Questions?

Open a GitHub Issue with the "question" label.
