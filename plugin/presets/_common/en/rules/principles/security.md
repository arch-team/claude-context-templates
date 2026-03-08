# Security Principles

> Cross-stack security engineering principles. For stack-specific implementations, see the corresponding preset's rules/security.md.

---

## Secret Management

- ❌ Never hardcode secrets, API keys, or passwords
- ✅ Use environment variables or secret management services
- ✅ Ensure .gitignore covers all sensitive configuration files

---

## Input Validation

- All external input must be validated before use
- Validation should occur at system boundaries (API entry points, user input handlers)
- Prefer allowlist over denylist strategies

---

## Principle of Least Privilege

- Grant components/services only the minimum permissions needed
- Review permission configurations regularly
- Avoid wildcard permissions

---

## Sensitive Data Handling

- Never log passwords, tokens, or secrets
- Never expose internal implementation details in error responses
- PII (Personally Identifiable Information) must be encrypted or masked

---

## Dependency Security

- Keep dependencies up to date; patch security vulnerabilities promptly
- Use lock files to pin dependency versions
- Run dependency vulnerability scans regularly
