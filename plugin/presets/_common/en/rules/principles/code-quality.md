# Code Quality Principles

> Cross-stack code quality principles. For stack-specific implementations, see the corresponding preset's rules/code-style.md.

---

## Type Safety

- ❌ Never use escape types such as any/Any/Object
- ✅ All variables and function parameters should have explicit types
- ✅ Enable strict type checking

---

## Naming Conventions

- Prefix booleans with is/has/can/should
- Function names should express actions (start with a verb)
- Variable names should express meaning (nouns/adjectives)
- Use plural forms for collections

---

## Import Ordering

- Group and sort imports: standard library/framework core → third-party → local modules
- Separate groups with blank lines
- Wildcard imports are forbidden

---

## Self-Documenting Code

- Prefer clear naming and structure to express intent
- Comments explain WHY, not WHAT
- Avoid outdated or misleading comments
- Types are documentation: good type annotations + good naming = self-explanatory code
