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
mkdir -p plugin/presets/your-preset/zh-CN/rules
mkdir -p plugin/presets/your-preset/en/rules
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

### Step 5: Register Your Preset

There are two initialization paths, and each has a different registration method:

> **`init.sh` (shell script path)**
>
> Edit `init.sh` lines 17-18 to add your preset to the two arrays:
> ```bash
> PRESET_IDS=("python-fastapi" "react-typescript" "aws-cdk" "your-preset")
> PRESET_DISPLAY_NAMES=("Python + FastAPI" "React + TypeScript" "AWS CDK (TypeScript)" "Your Tech Stack")
> ```
>
> **`/init-context` (Plugin command path)**
>
> No registration needed. The command auto-discovers all presets under `plugin/presets/` by reading each `preset.yaml`.

### Step 6: Test

```bash
# Test single project mode
./init.sh
# Select your preset and verify output

# Test monorepo mode
./init.sh
# Add a sub-project with your preset and verify
```

## Using the Generic Preset

The `generic` preset supports **any tech stack** through AI-powered content generation. It's automatically selected when `/init-context` detects a project that doesn't match any built-in preset.

### When Generic is Used

| Scenario | Path |
|----------|------|
| Existing project with FastAPI → matches `python-fastapi` | Built-in preset (fast track) |
| Existing project with Django → no match | Generic (AI generation) |
| Existing project with Go + Gin → no match | Generic (AI generation) |
| Empty project, user picks Python + FastAPI | Built-in preset (fast track) |
| Empty project, user picks Rust + Axum | Generic (AI generation) |

### How It Works

1. `/init-context` performs deep project analysis (language, framework, toolchain, architecture)
2. Skeleton template files are copied from `presets/generic/{lang}/`
3. `{{AI_GENERATED:xxx}}` placeholders are replaced with AI-generated content based on analysis
4. Quality self-check ensures generated content meets `context-schema.yaml` criteria

### Customizing After Generation

AI-generated content is a **starting point**. After generation:

1. **Review `rules/architecture.md`** — Verify the architecture description matches your actual design
2. **Review `rules/tech-stack.md`** — Confirm version numbers and constraints
3. **Fill in `project-config.md`** — Add business modules, import paths, etc.
4. **Run `/audit-context`** — Get a quality report and improvement suggestions
5. **Add optional rules** — Use `context-schema.yaml` as reference for what rules to add

### Template Structure

Generic templates use two types of placeholders:

- `{{VARIABLE}}` — Simple text replacement (project name, slug, etc.)
- `{{AI_GENERATED:xxx}}` — AI fills these based on project analysis results

See [template-variables.md](template-variables.md) for the complete placeholder reference.

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
