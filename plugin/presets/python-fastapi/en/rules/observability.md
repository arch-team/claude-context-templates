# Observability Standards

> **Purpose**: Observability standards defining Metrics, Distributed Tracing, and Health Check endpoints.

---

## Quick Reference Card

### Three Pillars

| Pillar | Purpose | Tool |
|--------|---------|------|
| **Logs** | Event recording | structlog (see [logging.md](logging.md)) |
| **Metrics** | Quantitative indicators | OpenTelemetry / Prometheus |
| **Traces** | Request chain tracing | OpenTelemetry / Jaeger |

### Health Check Endpoints

| Endpoint | Purpose | Response |
|----------|---------|----------|
| `GET /health` | Liveness check | `{"status": "ok"}` |
| `GET /health/ready` | Readiness check | `{"status": "ok", "checks": {...}}` |

---

## 1. Health Check

**Implementation Location**: `src/presentation/api/routes/health.py`

**Dependency Checks**:

| Dependency | Check Method | Timeout |
|------------|-------------|---------|
| Database | `SELECT 1` | 3s |
| Redis/Cache | `PING` | 2s |
| External API | HTTP HEAD or skip | 5s |

**Key Constraint**: Health checks should not contain business logic; they only verify connection availability. Readiness check failures return `503` with `status` set to `"degraded"`.

---

## 2. Metrics

### Key Business Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `http_requests_total` | Counter | Total HTTP requests (by method, path, status) |
| `http_request_duration_seconds` | Histogram | Request latency distribution |
| `db_query_duration_seconds` | Histogram | Database query latency |
| `task_execution_duration_seconds` | Histogram | Task execution duration |
| `active_tasks` | Gauge | Number of active async tasks |

### Naming Conventions

Format: `{namespace}_{subsystem}_{name}_{unit}`

| Rule | ✅ Correct | ❌ Wrong |
|------|-----------|---------|
| Use snake_case | `http_request_duration_seconds` | `httpRequestDuration` |
| Include unit suffix | `_seconds`, `_bytes`, `_total` | No unit |
| Counters use `_total` | `requests_total` | `request_count` |

---

## 3. Distributed Tracing

**Configuration Location**: `src/shared/infrastructure/tracing.py`

**Required Resource Attributes**: `service.name`, `deployment.environment`

### Span Standards

| Scenario | Span Name Pattern | Required Attributes |
|----------|------------------|---------------------|
| HTTP request | `{method} {path}` | `http.method`, `http.status_code` |
| Database query | `db.{operation}` | `db.system`, `db.statement` |
| External API call | `{service}.{operation}` | `peer.service`, `http.url` |
| Task execution | `task.execute` | `task.id`, `task.type` |

---

## 4. Environment Configuration

| Configuration | Dev | Staging | Prod |
|--------------|-----|---------|------|
| Tracing | Disabled or local Jaeger | Enabled | Enabled |
| Metrics | Console output | Enabled | Enabled |
| Health Check | Enabled | Enabled | Enabled + Load balancer integration |
| Sampling Rate | 100% | 10% | 1-5% |

---

## Related Documentation

- [checklist.md](checklist.md) Section: Observability - PR Review Checklist
- [logging.md](logging.md) - Structured logging standards
- [tech-stack.md](tech-stack.md) - Dependency versions
