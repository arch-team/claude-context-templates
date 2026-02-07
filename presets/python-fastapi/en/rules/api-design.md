# API Design Standards

> **Purpose**: API design standards defining RESTful routing, HTTP status codes, and error response format.

> Claude should consult this document first when generating API code

---

## RESTful Route Naming

```python
# ✅ Correct - Use plural nouns
GET    /api/v1/users          # List users
GET    /api/v1/users/{id}     # Get a single user
POST   /api/v1/users          # Create a user
PUT    /api/v1/users/{id}     # Update a user
DELETE /api/v1/users/{id}     # Delete a user

# ❌ Wrong - Using verbs
POST   /api/v1/createUser
GET    /api/v1/getUserById
```

---

## HTTP Status Codes

| Status Code | Scenario |
|-------------|----------|
| 200 | Success (GET, PUT) |
| 201 | Created (POST) |
| 204 | Deleted (DELETE) |
| 400 | Bad request parameters |
| 401 | Unauthenticated |
| 403 | Forbidden |
| 404 | Resource not found |
| 409 | Resource conflict |
| 422 | Validation error |
| 500 | Internal server error |

---

## Error Response Format

```python
class ErrorResponse(BaseModel):
    code: str           # Prefix: INVALID_, NOT_FOUND_, DUPLICATE_, FORBIDDEN_, INTERNAL_
    message: str        # Human-readable error message
    details: dict | None = None
```

---

## Pagination Standards

| Parameter/Field | Type | Description |
|----------------|------|-------------|
| `page` | int | Page number, starting from 1, default 1 |
| `page_size` | int | Items per page, default 20, max 100 |
| `total` | int | Total record count (response) |
| `total_pages` | int | Total page count (response) |
| `items` | list[T] | Data list (response) |

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Route paths | `kebab-case` | `/training-jobs` |
| Query parameters | `snake_case` | `?page_size=20` |
| Request/Response fields | `snake_case` | `{"created_at": "..."}` |

---

## Versioning

- URL path versioning: `/api/v1/`, `/api/v2/`
- Maintain at least 2 major versions

---

## PR Review Checklist

See [checklist.md](checklist.md) Section: API Design for the full checklist.
