# SDK-First

> **Purpose**: SDK-first principle defining the SDK decision process and exception handling patterns.

> Claude should consult this when generating code

**Core Principle**: Use SDKs whenever possible to simplify implementation and avoid reinventing the wheel.

---

## SDK Decision Flow

```
Need to implement a feature?
    ↓
Official SDK available? ──Yes──► 🟢 Use SDK directly
    │
   No
    ↓
Community library passes evaluation? ──Yes──► 🟡 Use community library
    │
   No
    ↓
🔴 Custom implementation (requires Tech Lead approval)
```

---

## Priority Levels

### 🟢 Priority 1: Use Official SDK Directly

No wrapping needed; call directly.

### 🟡 Priority 2: SDK + Thin Wrapper Layer

**Wrapper Principles**: < 100 lines | Does not alter SDK behavior | Exposes native types

### 🟡 Priority 3: Community Libraries

| Metric | Minimum Requirement |
|--------|-------------------|
| GitHub Stars | > 1,000 |
| Latest Commit | < 3 months |
| License | MIT / Apache 2.0 |

### 🔴 Priority 4: Custom Implementation

**Required Process**: Document in research.md → Provide justification → Tech Lead approval

---

## Project SDK Versions

See [tech-stack.md](tech-stack.md) for all SDK version requirements (Single Source of Truth).

---

## SDK Exception Handling

```python
# Pattern: SDK exception → Domain exception
try:
    self._client.operation(...)
except ClientError as e:
    raise DomainError(f"Operation failed: {e}") from e
```

| SDK | Original Exception | Domain Exception | HTTP |
|-----|-------------------|-----------------|------|
| boto3 | `ClientError (NoSuchKey)` | `EntityNotFoundError` | 404 |
| boto3 | `ClientError (AccessDenied)` | `PermissionError` | 403 |
| SQLAlchemy | `IntegrityError` | `DuplicateEntityError` | 409 |

---

## Anti-Patterns

```python
# ❌ Over-wrapping - Obscures the interface, hides SDK behavior
class SuperAwesomeS3Wrapper:
    def magic_upload(self, thing): ...

# ✅ Thin wrapper - Clear interface, delegates directly to SDK
class S3Adapter:
    def upload_file(self, local: Path, uri: S3Uri) -> None:
        self._client.upload_file(str(local), uri.bucket, uri.key)
```

---

## Detection Commands

```bash
# Detect over-wrapping (adapters > 100 lines)
find src/ -name "*adapter*.py" -exec wc -l {} \; | awk '$1 > 100 {print}'
```

---

## PR Review Checklist

See [checklist.md](checklist.md) Section: SDK Usage for the full checklist.
