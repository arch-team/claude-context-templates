# Customization Guide

This guide explains how to customize the generated templates and create new presets.

## Customizing Generated Files

After running `init.sh`, all generated files are yours to edit. Here are common customization scenarios:

### Adding a Custom Rules File

1. Create the file in your `rules/` directory:
   ```bash
   touch backend/.claude/rules/i18n.md
   ```

2. Follow the standard structure:
   ```markdown
   # Internationalization Standards (i18n)

   > **Responsibility**: i18n and localization standards SSoT

   ---

   ## 0. Quick Reference Card

   ### Key Rules
   | Rule | Description |
   |------|-------------|
   | ... | ... |

   ---

   ## 1. Detailed Standards
   ...
   ```

3. Add a link in your `CLAUDE.md`:
   ```markdown
   | i18n | [rules/i18n.md](rules/i18n.md) |
   ```

### Modifying project-config.md

The `project-config.md` file is designed to be filled in with your project's specific information. Replace all `<!-- TODO: ... -->` markers with actual content:

```markdown
<!-- Before -->
| <!-- TODO: Module name --> | <!-- TODO: Description --> | <!-- TODO: Core entities --> |

<!-- After -->
| `auth` | User authentication and authorization | `User`, `Role`, `Permission` |
```

### Removing Optional Rules

Simply delete any rules file you don't need and remove its link from `CLAUDE.md`.

## Creating a New Preset

### Step 1: Create Directory Structure

```bash
mkdir -p presets/your-preset/zh-CN/rules
mkdir -p presets/your-preset/en/rules
```

### Step 2: Create preset.yaml

```yaml
name: your-preset
display_name: "Your Tech Stack Name"
description: "Brief description"
version: "1.0.0"

defaults:
  package_manager: your-pkg-manager
  linter: your-linter
  test_runner: your-test-framework
  source_root: src
  architecture_pattern: "Your Architecture"
  coverage_minimum: 80

files:
  required:
    - CLAUDE.md
    - project-config.md
    - rules/architecture.md
    - rules/tech-stack.md
    - rules/code-style.md
    - rules/testing.md
    - rules/security.md
    - rules/checklist.md
    - rules/project-structure.md
  optional:
    - rules/your-optional-topic.md

variables:
  - name: PROJECT_NAME
    prompt: "Project name"
    required: true
  - name: YOUR_CUSTOM_VAR
    prompt: "Your custom variable"
    default: "default-value"
```

### Step 3: Write Template Files

Start with these required files:

1. **CLAUDE.md** -- Sub-project entry point
2. **project-config.md** -- Fill-in template with TODO markers
3. **rules/architecture.md** -- Architecture patterns for your tech stack
4. **rules/tech-stack.md** -- Version requirements matrix
5. **rules/code-style.md** -- Coding standards
6. **rules/testing.md** -- Testing methodology
7. **rules/security.md** -- Security checklist
8. **rules/checklist.md** -- PR review checklist
9. **rules/project-structure.md** -- Directory structure

### Step 4: Follow Design Patterns

- Start each rules file with a **Section 0 Quick Reference Card**
- Use **tables over prose** for quick reference
- Add **bidirectional links** between related files
- Mark SSoT documents clearly
- Use `{{VARIABLE}}` for project-specific content
- Use `<!-- TODO: ... -->` for user-fillable sections in project-config.md

### Step 5: Update init.sh

Add your preset to the selection menu in `init.sh`:

1. Add it to the preset list in the `select_preset()` function
2. Define the `TECH_STACK_SUMMARY` for your preset
3. Add optional rules handling

### Step 6: Test

```bash
# Test single project mode
./init.sh
# Select your preset and verify output

# Test monorepo mode
./init.sh
# Add a sub-project with your preset and verify
```

## Preset Design Tips

### Use Real-World Patterns

Base your rules on actual production experience, not theoretical ideals. Include:
- Common pitfalls (with DO / DON'T comparisons)
- Decision trees for common choices
- Code examples that developers can copy
- Coverage requirements with realistic targets

### Keep Files Focused

Each rules file should have a single, clear responsibility. If a file covers too many topics, split it.

### Balance Detail with Brevity

- Section 0: Dense, scannable (tables, matrices)
- Later sections: Detailed with examples
- Total file length: 100-300 lines is the sweet spot

### Think About Token Efficiency

Claude Code reads these files into its context window. Optimize for:
- Tables over paragraphs
- Code examples over descriptions
- Decision trees over complex prose
- Bullet points over narrative text
