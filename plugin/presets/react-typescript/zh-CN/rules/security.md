# 安全规范

> **职责**: 安全规范 - 前端安全模型、XSS 防护代码、CSRF 配置、CSP 模板

---

## 前端安全模型

### 核心安全规则

| 规则 | 禁止 | 正确做法 |
|------|------|---------|
| XSS | `dangerouslySetInnerHTML` 未清洗 | React 自动转义 / DOMPurify |
| 敏感存储 | `localStorage.setItem('token')` | httpOnly Cookie / 内存存储 |
| API 密钥 | 硬编码在代码中 | `VITE_` 前缀环境变量 |
| URL 参数 | 直接拼接 | `URLSearchParams` / 验证 |
| 第三方脚本 | 直接引入 | SRI 校验 / CSP |

---

## 客户端数据安全

### Token 存储策略

| 存储方式 | 安全性 | 推荐场景 |
|---------|-------|---------|
| httpOnly Cookie | 最安全 | 首选（需后端配合） |
| 内存 (Zustand 不持久化) | 安全 | 短期会话 |
| sessionStorage | 中等 | 标签页级别会话 |
| localStorage | 不安全 | **禁止存储敏感数据** |

### 环境变量安全

- 前端只使用 `VITE_` 前缀的公开配置
- 敏感信息（API Secret、私钥）永远不出现在前端代码中
- 所有环境变量必须在 `.env.example` 中声明

---

## 输入验证

| 输入类型 | 验证方式 |
|---------|---------|
| 表单输入 | Zod schema + React Hook Form |
| URL 参数 | 正则验证 + 白名单 |
| API 响应 | 类型校验 |
| 用户提供的 URL | 协议白名单验证（http/https/mailto） |

---

## 内容安全策略 (CSP)

- 启用 CSP 头限制脚本和样式来源
- 外部脚本必须使用 SRI (Subresource Integrity) 校验
- CORS 配置应限制为已知的 API 域名

---

## 0. 速查卡片

### 检测命令

```bash
# 依赖漏洞检查
{{PACKAGE_MANAGER}} audit

# 敏感信息检测
grep -rE "(password|secret|token|key)\s*[:=]" src/
```


---

## 2. XSS 防护

### 2.1 dangerouslySetInnerHTML（仅在必要时）

```tsx
// ❌ 危险 - 未经清洗
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ 如果必须使用，先清洗
import DOMPurify from 'dompurify';

const cleanHtml = DOMPurify.sanitize(html, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
  ALLOWED_ATTR: ['href'],
});
<div dangerouslySetInnerHTML={{ __html: cleanHtml }} />
```

### 2.2 URL 安全

```tsx
// ❌ 危险 - javascript: 协议
<a href={userProvidedUrl}>链接</a>

// ✅ 安全 - 验证协议
const isValidUrl = (url: string): boolean => {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
};

{isValidUrl(href) && <a href={href} rel="noopener noreferrer" target="_blank">链接</a>}
```

---

## 3. 敏感数据存储

> Zustand Store 持久化实现详见 [state-management.md](state-management.md) §2.1

---

## 4. 环境变量安全

```bash
# .env.example

# ✅ 公开配置 - VITE_ 前缀
VITE_API_BASE_URL=https://api.example.com
VITE_APP_TITLE={{PROJECT_NAME}}

# ❌ 禁止 - 敏感信息不应出现在前端
# API_SECRET_KEY=xxx  # 永远不要这样做
```

```typescript
// ✅ 通过 import.meta.env 访问
const apiUrl = import.meta.env.VITE_API_BASE_URL;
```

---

## 5. 输入验证实践

| 输入类型 | 验证方式 |
|---------|---------|
| 表单输入 | Zod schema + React Hook Form（详见 state-management.md §3） |
| URL 参数 | 正则验证 + 白名单 |
| API 响应 | 类型校验 |

```typescript
// URL 参数验证
const itemId = searchParams.get('id');
const isValidId = itemId && /^[a-zA-Z0-9-]+$/.test(itemId);
```

---

## 6. API 安全

### CSRF 防护

```typescript
// Cookie 认证时，从 meta 标签获取 CSRF Token
const csrfToken = document.querySelector('meta[name="csrf-token"]')
  ?.getAttribute('content');

if (csrfToken) {
  config.headers['X-CSRF-Token'] = csrfToken;
}
```

---

## 7. 第三方依赖安全

### SRI 校验

```html
<!-- 外部脚本必须使用 SRI -->
<script
  src="https://cdn.example.com/lib.js"
  integrity="sha384-..."
  crossorigin="anonymous"
></script>
```

### CSP 配置

```html
<!-- index.html - 根据项目需求调整 -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https://api.example.com;
">
```
