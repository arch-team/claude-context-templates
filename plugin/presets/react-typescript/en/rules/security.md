# Security Standards

> **Purpose**: Security standards - Frontend security model, XSS protection code, CSRF configuration, CSP templates

---

## Frontend Security Model

### Core Security Rules

| Rule | Prohibited | Correct Approach |
|------|-----------|-----------------|
| XSS | Unsanitized `dangerouslySetInnerHTML` | React auto-escaping / DOMPurify |
| Sensitive storage | `localStorage.setItem('token')` | httpOnly Cookie / in-memory |
| API keys | Hardcoded in code | `VITE_` prefixed environment variables |
| URL parameters | Direct concatenation | `URLSearchParams` / validation |
| Third-party scripts | Direct inclusion | SRI validation / CSP |

---

## Client-Side Data Security

### Token Storage Strategy

| Storage Method | Security | Recommended Scenario |
|---------------|----------|---------------------|
| httpOnly Cookie | Most secure | Preferred (requires backend support) |
| In-memory (Zustand without persistence) | Secure | Short-term sessions |
| sessionStorage | Moderate | Tab-level sessions |
| localStorage | Insecure | **Prohibited for sensitive data** |

### Environment Variable Security

- Frontend only uses `VITE_` prefixed public configuration
- Sensitive information (API secrets, private keys) must never appear in frontend code
- All environment variables must be declared in `.env.example`

---

## Input Validation

| Input Type | Validation Method |
|-----------|------------------|
| Form input | Zod schema + React Hook Form |
| URL parameters | Regex validation + allowlist |
| API responses | Type validation |
| User-provided URLs | Protocol allowlist validation (http/https/mailto) |

---

## Content Security Policy (CSP)

- Enable CSP headers to restrict script and style sources
- External scripts must use SRI (Subresource Integrity) validation
- CORS configuration should be limited to known API domains

---

## 0. Quick Reference Card

### Detection Commands

```bash
# Dependency vulnerability check
{{PACKAGE_MANAGER}} audit

# Sensitive information detection
grep -rE "(password|secret|token|key)\s*[:=]" src/
```


---

## 2. XSS Protection

### 2.1 dangerouslySetInnerHTML (Only When Necessary)

```tsx
// ❌ Dangerous - Unsanitized
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ If you must use it, sanitize first
import DOMPurify from 'dompurify';

const cleanHtml = DOMPurify.sanitize(html, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
  ALLOWED_ATTR: ['href'],
});
<div dangerouslySetInnerHTML={{ __html: cleanHtml }} />
```

### 2.2 URL Safety

```tsx
// ❌ Dangerous - javascript: protocol
<a href={userProvidedUrl}>Link</a>

// ✅ Safe - Validate protocol
const isValidUrl = (url: string): boolean => {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
};

{isValidUrl(href) && <a href={href} rel="noopener noreferrer" target="_blank">Link</a>}
```

---

## 3. Sensitive Data Storage

> See [state-management.md](state-management.md) Section 2.1 for Zustand Store persistence implementation

---

## 4. Environment Variable Security

```bash
# .env.example

# ✅ Public configuration - VITE_ prefix
VITE_API_BASE_URL=https://api.example.com
VITE_APP_TITLE={{PROJECT_NAME}}

# ❌ Prohibited - Sensitive information should never be in the frontend
# API_SECRET_KEY=xxx  # Never do this
```

```typescript
// ✅ Access via import.meta.env
const apiUrl = import.meta.env.VITE_API_BASE_URL;
```

---

## 5. Input Validation Practices

| Input Type | Validation Method |
|-----------|------------------|
| Form input | Zod schema + React Hook Form (see state-management.md Section 3) |
| URL parameters | Regex validation + allowlist |
| API responses | Type validation |

```typescript
// URL parameter validation
const itemId = searchParams.get('id');
const isValidId = itemId && /^[a-zA-Z0-9-]+$/.test(itemId);
```

---

## 6. API Security

### CSRF Protection

```typescript
// When using cookie authentication, get CSRF Token from meta tag
const csrfToken = document.querySelector('meta[name="csrf-token"]')
  ?.getAttribute('content');

if (csrfToken) {
  config.headers['X-CSRF-Token'] = csrfToken;
}
```

---

## 7. Third-Party Dependency Security

### SRI Validation

```html
<!-- External scripts must use SRI -->
<script
  src="https://cdn.example.com/lib.js"
  integrity="sha384-..."
  crossorigin="anonymous"
></script>
```

### CSP Configuration

```html
<!-- index.html - Adjust based on project requirements -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https://api.example.com;
">
```
