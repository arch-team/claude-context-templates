# Show HN: Claude Context Templates — Production-ready `.claude/` templates for Claude Code

I built **claude-context-templates**, an open-source collection of structured `.claude/` directory templates for Claude Code projects.

## The problem

Every Claude Code project needs a `.claude/` directory (CLAUDE.md + rules files) for Claude to understand your project well. But there's no standard way to set one up — most people write from scratch or copy from other projects.

## What this does

- **3 tech stack presets**: Python/FastAPI, React/TypeScript, AWS CDK
- **Interactive init script**: Run `./init.sh`, answer a few questions, get a complete `.claude/` directory
- **Monorepo + single-project** modes
- **English + Chinese** bilingual support

Each preset generates CLAUDE.md (entry point), project-config.md (fill-in template), and topic-specific rules (architecture, testing, security, code style, etc.).

## What makes it different

The templates follow 6 design principles extracted from production monorepo projects:
- **SSoT**: Each concept defined in one place, linked everywhere else
- **Section 0**: Every rules file starts with a quick reference card (tables, decision trees)
- **Layered architecture**: Root → sub-project → topic rules with clear separation
- **Bidirectional linking**: Documents cross-reference each other for Claude to navigate

## Try it

```bash
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates
./init.sh
```

Looking for feedback on the template structure and design principles. Also interested in contributors for new presets (Go, Java, Vue, etc.).

GitHub: https://github.com/arch-team/claude-context-templates
