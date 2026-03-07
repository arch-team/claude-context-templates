> **Purpose**: Directory structure standards - Physical directory structure and configuration file quick reference

# Project Directory Structure Standards

---

## 0. Quick Reference Card

> For the monorepo structure overview, refer to the root-level common.md

### Frontend Directory Structure

```
{{SUBPROJECT_NAME}}/                       # Frontend project root
├── .claude/                    # Claude Code context (standards documents)
│   ├── CLAUDE.md               # Frontend entry point
│   ├── project-config*.md
│   └── rules/                  # Frontend-specific rules
├── public/                     # Static assets
│   └── favicon.ico
├── src/                        # Source code (FSD structure)
│   ├── app/                    # App layer
│   │   ├── App.tsx
│   │   ├── providers/
│   │   ├── routes/
│   │   └── styles/
│   ├── pages/                  # Pages layer
│   ├── widgets/                # Widgets layer
│   ├── features/               # Features layer
│   ├── entities/               # Entities layer
│   └── shared/                 # Shared layer
│       ├── api/
│       ├── config/
│       ├── hooks/
│       ├── lib/
│       ├── types/
│       └── ui/
├── tests/                      # E2E tests (Playwright)
│   ├── e2e/
│   └── fixtures/
├── .env.example                # Environment variable template
├── eslint.config.js               # ESLint configuration
├── .prettierrc                 # Prettier configuration
├── index.html                  # HTML entry point
├── package.json                # Project configuration
├── pnpm-lock.yaml              # Dependency lock file
├── postcss.config.js           # PostCSS configuration
├── tailwind.config.js          # TailwindCSS configuration
├── tsconfig.json               # TypeScript configuration
├── tsconfig.node.json          # Node TypeScript configuration
├── vite.config.ts              # Vite configuration
└── README.md                   # Frontend README
```

### Configuration File Quick Reference

| File | Purpose | Required |
|------|---------|:--------:|
| `package.json` | Project and scripts configuration | ✅ |
| `tsconfig.json` | TypeScript configuration | ✅ |
| `vite.config.ts` | Vite build configuration | ✅ |
| `.env.example` | Environment variable template | ✅ |
| `tailwind.config.js` | TailwindCSS configuration | ✅ |
| `eslint.config.js` | ESLint flat config (ESLint 9+) | ✅ |
| `.prettierrc` | Prettier configuration | ✅ |
| `README.md` | Project documentation | ✅ |
| `playwright.config.ts` | E2E test configuration | Recommended |

### Prohibited Practices

| Rule | Description |
|------|-------------|
| ❌ Components in root directory | All components must be in `src/` under the appropriate layer |
| ❌ Tests scattered in source directories | Unit tests co-locate with components, E2E in `tests/` |
| ❌ Config files scattered around | Configuration unified in root directory |
| ❌ Undeclared environment variables | All variables must be declared in `.env.example` |

---

## 1. New Project Initialization Checklist

### Directories
- [ ] `src/app/` contains App.tsx, providers/, routes/
- [ ] `src/shared/` contains api/, ui/, hooks/, lib/
- [ ] `src/features/` and `src/entities/` are created
- [ ] `.claude/CLAUDE.md` is configured

### Configuration Files
- [ ] `package.json` contains all necessary scripts
- [ ] `tsconfig.json` configures path aliases
- [ ] `vite.config.ts` configures path aliases
- [ ] `.env.example` lists all environment variables
- [ ] `tailwind.config.js` is configured
- [ ] `README.md` includes project description

### Code Quality
- [ ] `eslint.config.js` configures React + TypeScript rules
- [ ] `.prettierrc` configures formatting rules
- [ ] `vitest.config.ts` configures testing
