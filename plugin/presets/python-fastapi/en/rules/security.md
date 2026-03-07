# Security Standards

> **Purpose**: Security standards defining prohibited practices, mandatory requirements, and security detection commands.

---

## 0. Quick Reference Card

> Claude should consult this section first when generating code

### Security Rules Cheat Sheet

| Rule | ❌ Prohibited | ✅ Correct |
|------|-------------|-----------|
| Hardcoded secrets | `API_KEY = "sk-xxx"` | `settings.api_key` (environment variable) |
| SQL injection | `f"SELECT * WHERE id='{x}'"` | `session.query().filter()` |
| Command injection | `os.system(user_input)` | Parameterized commands or allowlist |
| Path traversal | `open(f"/uploads/{name}")` | `Path(name).name` validation |
| Sensitive logs | `logger.info(f"password: {pwd}")` | Log only non-sensitive information |
| Dangerous functions | `eval(user_input)` | `json.loads()` / Pydantic |

### Security Detection Commands

```bash
# Full security check
uv run bandit -r src/ && uv run safety check && uv run pip-audit

# Category-specific detection
grep -rE "(password|secret|key|token)\s*=\s*['\"][^'\"]+['\"]" src/  # Hardcoded secrets
grep -rE "f['\"].*SELECT|os\.system|subprocess\.call.*shell=True" src/  # Injection attacks
grep -rE "\beval\s*\(|\bexec\s*\(|pickle\.loads" src/                  # Dangerous functions
grep -rE "logger\.(info|debug|error).*password" src/                    # Sensitive logs
```

---

## 1. Common Mistake Corrections

> The cheat sheet above lists core prohibited/correct comparisons. Below are supplementary correct patterns for common mistakes.

```python
# SQL parameter binding - Use SQLAlchemy text() instead of f-strings
stmt = text("SELECT * FROM users WHERE id = :user_id")
session.execute(stmt, {"user_id": user_id})

# Path traversal protection - Use Path.name to remove ../ components
safe_name = Path(filename).name
file_path = Path("/uploads") / safe_name
```

---

## 2. Mandatory Requirements

| Requirement | Standard | Key Constraint |
|-------------|----------|---------------|
| **Environment Variables** | `pydantic_settings.BaseSettings` | Use `SecretStr` type for sensitive fields |
| **Input Validation** | Pydantic `Field` + `field_validator` | Password: 8-128 chars, must include upper/lowercase + digits |
| **Password Storage** | `passlib` bcrypt | `bcrypt__rounds=12` |
| **Login Throttling** | Login failure lockout | 5 failures → locked for 30 minutes |
| **Error Responses** | Generic error messages | ❌ Never return `str(e)` or traceback; see [architecture.md](architecture.md) Section 8 |
| **Access Control** | OAuth2 + RBAC | `get_current_user` → `require_role` dependency chain |

---

## Related Documentation

- [checklist.md](checklist.md) Section: Security - PR Review Checklist
- [logging.md](logging.md) - Log data masking rules
