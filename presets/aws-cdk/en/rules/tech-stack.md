# Tech Stack Standards

> **Purpose**: The **Single Source of Truth (SSoT)** for tech stack version requirements, including AWS CDK, TypeScript, Node.js, and other core dependency versions.

---

## §0 Quick Reference Card

### Version Requirements Matrix

| Category | Technology | Minimum Version | Recommended Version |
|----------|-----------|----------------|---------------------|
| **Core** | AWS CDK | >=2.130.0 | 2.170.0+ |
| **Core** | TypeScript | >=5.0.0 | 5.4+ |
| **Core** | Node.js | >=18.0.0 | 22 LTS |
| **Package Manager** | pnpm | >=8.0.0 | 9.x |
| **Testing** | Jest | >=29.0.0 | 29.7+ |
| **Security** | cdk-nag | >=2.28.0 | 2.30+ |
| **Code Quality** | ESLint | >=8.0.0 | 9.x |
| **Code Quality** | Prettier | >=3.0.0 | 3.x |

### Key Constraints

- **Package manager**: Use pnpm only; npm/yarn are prohibited
- **Lambda runtime**: nodejs22.x (Node.js 22 LTS)
- **TypeScript**: `strict: true` must be enabled

### Quick Verification Commands

```bash
# Check core versions
node -v && pnpm -v && pnpm exec tsc --version && pnpm exec cdk --version

# Check dependency versions
pnpm list aws-cdk-lib jest cdk-nag
```

---

## Related Documents

| Document | Description |
|----------|-------------|
| [CLAUDE.md](../CLAUDE.md) | Tech stack overview |
| [testing.md](testing.md) | Testing standards |
