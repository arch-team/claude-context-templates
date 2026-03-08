# Security Standards

> **Purpose**: Security standards - Secret management, input validation, security scanning, authentication guidelines

---

## 0. Quick Reference Card

> Claude should consult this section first when generating code

<!-- {{AI_GENERATED:security_quick_ref}}
  AI should generate a concise security quick-reference table for this project.
  Format:
  | Rule | Prohibited | Correct Approach |
  |------|-----------|-----------------|
  | Secret storage   | ... | ... |
  | Input handling   | ... | ... |
  | Authentication   | ... | ... |
  | Dependency safety| ... | ... |
-->

---

## Secret Management

> These rules are universal and apply regardless of tech stack.

### Absolute Prohibitions

| Practice | Why It's Dangerous |
|----------|--------------------|
| Hardcoded secrets in source code | Exposed in version control history forever |
| Secrets in client-side code | Visible to any user via browser dev tools |
| Committing `.env` files | Secrets leak to all repo collaborators |
| Logging secret values | Secrets appear in log aggregation systems |
| Sharing secrets via chat/email | Creates uncontrolled copies with no audit trail |

### Required Practices

- Store secrets in environment variables or a dedicated secrets manager
- Maintain `.env.example` with placeholder values (never real secrets)
- Add `.env*` (except `.env.example`) to `.gitignore`
- Rotate secrets on a regular schedule and after any suspected compromise
- Use different secrets for each environment (dev, staging, production)

### Detection

```bash
# Scan for potential hardcoded secrets
grep -rE "(password|secret|token|api_key|private_key)\s*[:=]" --include="*.{ts,js,py,go,java,rb,rs}" .
```

---

## Input Validation

> These principles are universal and apply regardless of tech stack.

### Validation Rules

| Principle | Description |
|-----------|-------------|
| **Validate early** | Validate at the entry point, before processing |
| **Allowlist over denylist** | Define what IS allowed, not what is forbidden |
| **Validate on the server** | Client-side validation is for UX only, never trust it |
| **Type + range + format** | Check data type, acceptable range, and expected format |
| **Sanitize output** | Escape/encode data before rendering or storing |

### Common Attack Vectors

| Vector | Prevention |
|--------|------------|
| SQL Injection | Parameterized queries, ORM usage |
| XSS (Cross-Site Scripting) | Output encoding, CSP headers |
| CSRF (Cross-Site Request Forgery) | CSRF tokens, SameSite cookies |
| Path Traversal | Canonicalize paths, restrict to allowed directories |
| Command Injection | Avoid shell execution, use parameterized APIs |

---

## Security Scanning

<!-- {{AI_GENERATED:security_scanning}}
  AI should generate security scanning commands based on the project's toolchain.
  Format:
  ```bash
  # Dependency vulnerability check
  <command>

  # Static analysis / security lint
  <command>

  # Secret detection
  <command>
  ```

  Examples by ecosystem:
  - Node.js: npm audit, eslint-plugin-security
  - Python: pip-audit, bandit, safety
  - Go: govulncheck, gosec
  - Rust: cargo audit
-->

---

## Authentication & Authorization Guidelines

<!-- {{AI_GENERATED:auth_guidelines}}
  AI should generate auth guidelines based on the project's authentication approach.
  Cover:
  - Authentication method (JWT, session, OAuth, API keys, etc.)
  - Token storage strategy (httpOnly cookies, in-memory, etc.)
  - Authorization model (RBAC, ABAC, ACL, etc.)
  - Session management rules
  - Password/credential handling rules

  If the project has no auth, state: "Not applicable - this project does not handle authentication directly."
-->

---

## Related Documents

- **Architecture**: [architecture.md](architecture.md)
- **PR Checklist**: [checklist.md](checklist.md)
- **Project Configuration**: [../project-config.md](../project-config.md)
