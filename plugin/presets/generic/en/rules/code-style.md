# Code Style Standards

> **Purpose**: Code style standards - Naming conventions, type annotations, import ordering, DO/DON'T examples

---

## 0. Quick Reference Card

> Claude should consult this section first when generating code

<!-- {{AI_GENERATED:code_style_quick_ref}}
  AI should generate a concise quick-reference table summarizing the key code style rules.
  Format:
  | Rule | Standard | Example |
  |------|----------|---------|
  | File naming     | ...  | ... |
  | Function naming | ...  | ... |
  | Variable naming | ...  | ... |
  | Indentation     | ...  | ... |
  | Max line length | ...  | ... |
-->

---

## Naming Conventions

<!-- {{AI_GENERATED:naming_conventions}}
  AI should generate naming convention rules based on the project's language and framework.
  Format:
  | Element | Style | Example |
  |---------|-------|---------|
  | Files (modules)    | ...  | ... |
  | Classes / Types    | ...  | ... |
  | Functions / Methods| ...  | ... |
  | Variables          | ...  | ... |
  | Constants          | ...  | ... |
  | Directories        | ...  | ... |

  Include language-specific conventions:
  - Python: snake_case functions, PascalCase classes
  - JavaScript/TypeScript: camelCase functions, PascalCase components
  - Go: exported PascalCase, unexported camelCase
  - etc.
-->

---

## Import Ordering

<!-- {{AI_GENERATED:import_rules}}
  AI should generate import ordering rules for the project's language.
  Format as a numbered list with clear grouping rules.
  Example:
  1. Standard library imports
  2. Third-party library imports
  3. Internal/project imports
  4. Relative imports
  5. Type-only imports (if applicable)

  Include separator rules (blank lines between groups).
-->

---

## Type Annotations

<!-- {{AI_GENERATED:type_annotations}}
  AI should generate type annotation guidelines for the project's language.
  Cover:
  - When type annotations are required vs optional
  - Preferred annotation style (inline, separate file, etc.)
  - Rules for function signatures, return types, variable declarations
  - Any project-specific type conventions

  For dynamically typed languages, include docstring/type hint conventions.
  For statically typed languages, include interface vs type alias rules.
-->

---

## DO / DON'T Examples

<!-- {{AI_GENERATED:do_dont_examples}}
  AI should generate 4-6 DO/DON'T code examples specific to this project.
  Format:
  ```language
  // DO: Clear description
  good_example_code

  // DON'T: Clear description
  bad_example_code
  ```

  Cover common mistakes like:
  - Naming violations
  - Import anti-patterns
  - Type annotation omissions
  - Code organization issues
-->

---

## Related Documents

- **Architecture**: [architecture.md](architecture.md)
- **Tech Stack**: [tech-stack.md](tech-stack.md)
- **PR Checklist**: [checklist.md](checklist.md)
- **Project Structure**: [project-structure.md](project-structure.md)
