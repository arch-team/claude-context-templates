# Design Principles

This document explains the 6 core design principles behind the Claude Context Templates system.

## 1. Single Source of Truth (SSoT)

**Principle**: Each concept is defined in exactly one authoritative file. Other files reference it via links.

**Why**: Avoids information inconsistency. When a rule changes, you update it in one place.

**Example**:
- `tech-stack.md` is the SSoT for version requirements
- `architecture.md` is the SSoT for architecture patterns
- `common.md` is the SSoT for monorepo structure

**Pattern**:
```markdown
# In architecture.md
For version requirements, see [tech-stack.md](tech-stack.md)
```

## 2. Section 0 Quick Reference Card

**Principle**: Every rules file starts with a Section 0 (quick reference) containing tables, decision trees, and cheat sheets.

**Why**: Claude Code often only needs a quick lookup, not the full document. Section 0 provides high-density information with minimal token usage.

**Example structure**:
```markdown
# Architecture Standards

> **Responsibility**: Architecture patterns SSoT

---

## 0. Quick Reference Card

### Dependency Matrix
| From \ To | shared | entities | features |
|-----------|:------:|:--------:|:--------:|
| features  |   OK   |    OK    |    NO    |
| entities  |   OK   |    NO    |    NO    |

### Decision Tree
Need new module?
  -> Has domain logic? -> Yes -> Create domain module
  -> No domain logic? -> Add to shared/

### Common Pitfalls
| DO | DON'T |
|----|-------|
| Import from shared | Import across modules |

---

## 1. Detailed Standards
...
```

## 3. Layered Architecture

**Principle**: Context is organized in multiple layers with clear separation and one-way dependencies.

### Project Layers
```
Layer 1: Root .claude/                    -> Global settings (language, project overview)
Layer 2: Root .claude/rules/              -> Cross-project rules (Git, docs, structure)
Layer 2b: Root .claude/rules/principles/  -> Cross-preset engineering principles (from _common)
Layer 3: {subproject}/.claude/            -> Sub-project specific (tech stack, architecture)
```

### Cross-Preset Principles (_common)

`_common/rules/principles/` provides shared engineering principles (testing, security, architecture, code-quality) that apply across all presets. Each preset's rules files can reference these common principles.

**Dependency direction** (strictly one-way):
- `_common/` must NOT reference any specific preset
- Preset rules may reference `_common/` principles

**Why**: Claude Code automatically loads the appropriate layer based on the current directory. The _common principles layer ensures SSoT for universal engineering standards.

**How it works**:
- Working in project root -> Loads Layer 1 + 2 + 2b
- Working in `backend/` -> Loads Layer 1 + 2 + 2b + backend Layer 3
- Each layer can reference other layers via relative links

## 4. Dependency Matrix

**Principle**: Use tables (not prose) to express allowed/forbidden dependencies between architecture layers.

**Why**: A table is unambiguous, scannable, and token-efficient compared to paragraphs of text.

**Example** (Feature-Sliced Design):
```markdown
| From \ Import | shared | entities | features | widgets | pages |
|---------------|:------:|:--------:|:--------:|:-------:|:-----:|
| **pages**     |   OK   |    OK    |    OK    |   OK    |  NO   |
| **widgets**   |   OK   |    OK    |    OK    |   NO    |  NO   |
| **features**  |   OK   |    OK    |    NO    |   NO    |  NO   |
| **entities**  |   OK   |    NO    |    NO    |   NO    |  NO   |
| **shared**    |   NO   |    NO    |    NO    |   NO    |  NO   |
```

## 5. Bidirectional Linking

**Principle**: Documents reference each other with relative links, forming a navigable knowledge network.

**Why**: Enables Claude Code to follow references and understand relationships between rules.

**Pattern**:
```markdown
# In architecture.md
Testing requirements: see [testing.md](testing.md) Section 3

# In testing.md
Architecture patterns: see [architecture.md](architecture.md) Section 1
```

**Best practices**:
- Use section references (`Section 2` or `## Title`) for precise navigation
- Keep links relative to current directory
- Ensure links work in both directions

## 6. kebab-case Naming

**Principle**: All files use `kebab-case.md` naming, except for `CLAUDE.md` and `README.md`.

**Why**: Consistency in naming reduces cognitive load and prevents naming conflicts across platforms (case-sensitive vs case-insensitive filesystems).

**Examples**:
```
CLAUDE.md              # Exception: Claude Code convention
README.md              # Exception: GitHub convention
rules/
  principles/
    testing.md         # kebab-case
    architecture.md    # kebab-case
  practices/
    tech-stack.md      # kebab-case
    code-style.md      # kebab-case
project-config.md      # kebab-case
```
