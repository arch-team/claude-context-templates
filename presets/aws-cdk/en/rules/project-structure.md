# Project Directory Structure Standards

> **Purpose**: Define the infra project directory structure, configuration file purposes, and new project initialization checklist.

> Consult this document first when Claude initializes or reviews project structure

---

## 0. Quick Reference Card

> For the monorepo structure overview, refer to the root-level common.md

### Infra Directory Structure

```
infra/                          # CDK project root
├── .claude/                    # Claude Code context (standards documents)
│   ├── CLAUDE.md               # Infrastructure entry point
│   ├── project-config*.md
│   └── rules/                  # Infra-specific rules
├── bin/                        # CDK application entry
│   └── app.ts
├── lib/                        # Source code
│   ├── constructs/             # Custom L3 Constructs
│   │   ├── vpc/
│   │   │   ├── index.ts
│   │   │   ├── vpc.construct.ts
│   │   │   └── vpc.construct.test.ts
│   │   ├── aurora/
│   │   └── api-gateway/
│   ├── stacks/                 # Stack definitions
│   │   ├── network-stack.ts
│   │   ├── compute-stack.ts
│   │   └── api-stack.ts
│   └── config/                 # Configuration and constants
│       ├── environments.ts
│       └── constants.ts
├── test/                       # Integration tests
│   ├── snapshot/               # Snapshot tests
│   └── compliance/             # CDK Nag compliance tests
├── cdk.json                    # CDK configuration
├── cdk.context.json            # CDK context cache (git ignore)
├── jest.config.js              # Jest configuration
├── package.json                # Project configuration
├── pnpm-lock.yaml              # Dependency lock file
├── tsconfig.json               # TypeScript configuration
└── README.md                   # Infrastructure documentation
```

### Configuration File Quick Reference

| File | Purpose | Required |
|------|---------|:--------:|
| `cdk.json` | CDK application configuration | ✅ |
| `package.json` | Project and scripts configuration | ✅ |
| `tsconfig.json` | TypeScript configuration | ✅ |
| `jest.config.js` | Jest testing configuration | ✅ |
| `.eslintrc.cjs` | ESLint configuration | Recommended |
| `README.md` | Project documentation | ✅ |

### Naming Conventions

| Type | Naming | Example |
|------|--------|---------|
| Construct directory | `kebab-case` | `api-gateway/` |
| Construct file | `{name}.construct.ts` | `vpc.construct.ts` |
| Construct test | `{name}.construct.test.ts` | `vpc.construct.test.ts` |
| Stack file | `{name}-stack.ts` | `network-stack.ts` |
| Construct class name | `PascalCase` + `Construct` | `VpcConstruct` |
| Stack class name | `PascalCase` + `Stack` | `NetworkStack` |

### Prohibited Practices

| Rule | Description |
|------|-------------|
| Business logic in bin/ | bin/app.ts should only handle Stack assembly |
| Resources directly in Stacks | Complex resources should be encapsulated as Constructs |
| Hardcoded accounts/regions | Use CDK Context for management |
| cdk.context.json in version control | Should be in .gitignore |

---

## 1. cdk.json Key Configuration

```json
{
  "app": "npx ts-node --prefer-ts-exts bin/app.ts",
  "context": {
    "@aws-cdk/core:newStyleStackSynthesis": true,
    "@aws-cdk/aws-rds:lowercaseDbIdentifier": true,
    "environments": {
      "dev": { "account": "<YOUR_DEV_ACCOUNT_ID>", "region": "ap-northeast-1" },
      "prod": { "account": "<YOUR_PROD_ACCOUNT_ID>", "region": "ap-northeast-1" }
    }
  }
}
```

> **Note**: `<YOUR_*_ACCOUNT_ID>` are placeholders; for actual values, refer to [project-config.md](../project-config.md) environment configuration. Never commit real account IDs to public repositories.

**Key point**: `environments` is defined in context and read via `app.node.tryGetContext('env')`

---

## 2. New Project Initialization Checklist

### Directories
- [ ] `bin/app.ts` exists and is executable
- [ ] `lib/constructs/` and `lib/stacks/` are created
- [ ] `lib/config/environments.ts` is configured
- [ ] `.claude/CLAUDE.md` is configured

### Configuration Files
- [ ] `cdk.json` contains application entry and context
- [ ] `package.json` contains all necessary scripts
- [ ] `tsconfig.json` is correctly configured
- [ ] `jest.config.js` configures testing
- [ ] `README.md` includes project description

### Git Configuration
- [ ] `.gitignore` includes `cdk.context.json`
- [ ] `.gitignore` includes `cdk.out/`
- [ ] `.gitignore` includes `node_modules/`
