# Logging Standards

> **Purpose**: Log level standards, field naming, data masking rules, and concrete structlog configuration.

---

## Log Level Standards

| Level | Scenario | Example |
|-------|----------|---------|
| `DEBUG` | Development debugging | Request parameters, SQL statements |
| `INFO` | Key business events | User login, task creation |
| `WARNING` | Recoverable anomalies | Retries, degradation, approaching quota |
| `ERROR` | Business errors | Third-party API failures, data validation failures |
| `CRITICAL` | System-level failures | Database unreachable, missing configuration |

---

## Prohibited Practices

| Prohibited | Correct |
|-----------|---------|
| `print()` debug output | `logger.debug()` |
| `logger.info(f"password: {pwd}")` | `logger.info("login_attempt", user_id=user.id)` |
| String concatenation in logs | Structured key-value pairs |
| Exception logging with message only | Log full traceback |

---

## Standard Field Naming

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

## Data Masking Rules

| Field | Masking Method | Example |
|-------|---------------|---------|
| Password | Fully hidden | `"****"` |
| Token/API Key | Preserve first 4 chars | `"sk-1****"` |
| Email | Partially hidden | `"z***@example.com"` |
| Phone number | Middle digits hidden | `"138****5678"` |
| IP address | Context-dependent | Preserved for security audits, masked in regular logs |

---

## Environment Differences

| Configuration | Dev | Staging | Prod |
|--------------|-----|---------|------|
| Format | Colorized console | JSON | JSON |
| Level | DEBUG | INFO | INFO |
| Output | stdout | stdout | stdout -> Log collection service |

---

## 1. Structured Logging Configuration

**Library**: structlog | **Configuration**: `src/shared/infrastructure/logging.py`

```python
# Logger initialization and usage
logger = structlog.get_logger(__name__)
logger.info("task_created", task_id=task.id, owner=task.owner)
logger.error("api_call_failed", service="external", status_code=500, duration_ms=1200)
```

**Key Constraint**: Colorized console output in dev environment, JSON output in prod environment.

---

## 2. Correlation ID Implementation

**Middleware**: `src/presentation/api/middleware/correlation.py`

| Scenario | Propagation Method |
|----------|--------------------|
| HTTP requests | `X-Correlation-ID` Header |
| Event publishing | Event attribute `correlation_id` |
| Async tasks | Carried in task parameters |
| Log output | Auto-injected via structlog contextvars |

---

## 3. Data Masking Utility Functions

**Utility Functions**: `src/shared/infrastructure/logging_utils.py`

- `mask_token()` — Token/API Key preserve first 4 chars
- `mask_email()` — Email partially hidden
- `mask_phone()` — Phone number middle digits hidden

---

## Related Documentation

- [checklist.md](checklist.md) Section: Logging - PR Review Checklist
- [security.md](security.md) - Sensitive data masking requirements
- [observability.md](observability.md) - Observability (Metrics/Tracing)
