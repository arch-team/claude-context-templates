# 项目配置 - {{PROJECT_NAME}}

> **职责**: {{PROJECT_NAME}} 项目的特定配置，包含模块列表和导入路径。

> **定位**: 本文件是 CLAUDE.md 的补充，包含**项目特定的业务配置**。
> **原则**: 通用规范放 `rules/`，项目特定信息放此处。
> 架构规范详见 [rules/architecture.md](rules/architecture.md)

---

## 项目信息

| 配置项 | 值 |
|--------|-----|
| **项目名称** | {{PROJECT_SLUG}} |
| **项目描述** | {{PROJECT_DESCRIPTION}} |
| **源码根路径** | <!-- TODO: 填写源码根路径，如 src/ --> |

---

## 技术栈补充

> **完整版本矩阵**: 见 [rules/tech-stack.md](rules/tech-stack.md) (单一真实源)
>
> 以下仅列出 tech-stack.md 未覆盖的**项目特有选型**。

| 类别 | 技术选型 | 说明 |
|------|---------|------|
| <!-- TODO: 类别 --> | <!-- TODO: 技术选型 --> | <!-- TODO: 说明 --> |
<!-- 示例：
| **数据库** | PostgreSQL 15 | 主数据库 |
| **缓存** | Redis 7.x | 会话和数据缓存 |
| **认证** | JWT + OAuth2 | 用户认证方案 |
-->

---

## 业务模块

> **维护提示**: 新增模块时同步更新此表和源码目录。

| 模块 | 职责 | 核心实体 |
|------|------|---------|
| <!-- TODO: 模块名 --> | <!-- TODO: 说明 --> | <!-- TODO: 核心实体 --> |
<!-- 示例：
| `auth` | 用户认证与授权 | `User` |
| `orders` | 订单管理 | `Order`, `OrderItem` |
| `products` | 商品管理 | `Product`, `Category` |
-->

---

## 导入路径约定

> **原则**: 参考 [rules/architecture.md](rules/architecture.md) 模块隔离规则。

<!-- TODO: 根据项目实际技术栈填写导入路径示例
示例 (Python):
```python
from src.modules.auth import AuthService
from src.shared.domain import BaseEntity
```

示例 (TypeScript):
```typescript
import { AuthService } from '@/modules/auth';
import { BaseEntity } from '@/shared/domain';
```
-->

---

## 外部服务配置

> **位置约定**: 所有外部服务适配器应集中管理。

| 服务 | 用途 | 适配器位置 |
|------|------|-----------|
| <!-- TODO: 服务名 --> | <!-- TODO: 用途 --> | <!-- TODO: 适配器位置 --> |
<!-- 示例：
| AWS S3 | 文件存储 | infrastructure/external/s3/ |
| Redis | 缓存 | infrastructure/external/cache/ |
-->

---

## 架构合规

> 违规检测规则和依赖方向详见 [rules/architecture.md](rules/architecture.md)。
