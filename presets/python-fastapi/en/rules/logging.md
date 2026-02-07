# Logging Standards

> **Purpose**: Structured logging standards defining log format, levels, Correlation ID, and data masking rules.

---

## Quick Reference Card

### Log Levels

| Level | Scenario | Example |
|-------|----------|---------|
| `DEBUG` | Development debugging | Request parameters, SQL statements |
| `INFO` | Key business events | User login, task creation |
| `WARNING` | Recoverable anomalies | Retries, degradation, approaching quota |
| `ERROR` | Business errors | Third-party API failures, data validation failures |
| `CRITICAL` | System-level failures | Database unreachable, missing configuration |

### Prohibited Practices

| ❌ Prohibited | ✅ Correct |
|--------------|-----------|
| `print()` debug output | `logger.debug()` |
| `logger.info(f"password: {pwd}")` | `logger.info("login_attempt", user_id=user.id)` |
| String concatenation in logs | Structured key-value pairs |
| Exception logging with message only | Log full traceback |

---

## 1. Structured Logging

**Library**: structlog | **Configuration**: `src/shared/infrastructure/logging.py`

```python
# Logger initialization and usage
logger = structlog.get_logger(__name__)
logger.info("task_created", task_id=task.id, owner=task.owner)
logger.error("api_call_failed", service="external", status_code=500, duration_ms=1200)
```

**Key Constraint**: Colorized console output in dev environment, JSON output in prod environment.

### Standard Field Naming

| Field | Name | Type |
|-------|------|------|
| Request method | `method` | str |
| Request path | `path` | str |
| Status code | `status_code` | int |
| Duration | `duration_ms` | float |
| User ID | `user_id` | str |
| Correlation ID | `correlation_id` | str (auto-injected) |
| Error code | `error_code` | str |
| Service name | `service` | str |

---

## 2. Correlation ID

**Middleware**: `src/presentation/api/middleware/correlation.py`

| Scenario | Propagation Method |
|----------|--------------------|
| HTTP requests | `X-Correlation-ID` Header |
| Event publishing | Event attribute `correlation_id` |
| Async tasks | Carried in task parameters |
| Log output | Auto-injected via structlog contextvars |

---

## 3. Data Masking Rules

**Utility Functions**: `src/shared/infrastructure/logging_utils.py`

| Field | Masking Method | Example |
|-------|---------------|---------|
| Password | Fully hidden | `"****"` |
| Token/API Key | `mask_token()` preserve first 4 chars | `"sk-1****"` |
| Email | `mask_email()` partially hidden | `"z***@example.com"` |
| Phone number | `mask_phone()` middle digits hidden | `"138****5678"` |
| IP address | Context-dependent | Preserved for security audits, masked in regular logs |

---

## 4. Environment Differences

| Configuration | Dev | Staging | Prod |
|--------------|-----|---------|------|
| Format | Colorized console | JSON | JSON |
| Level | DEBUG | INFO | INFO |
| Output | stdout | stdout | stdout → Log collection service |

---

## Related Documentation

- [checklist.md](checklist.md) Section: Logging - PR Review Checklist
- [security.md](security.md) - Sensitive data masking requirements
- [observability.md](observability.md) - Observability (Metrics/Tracing)
