# 项目配置 - TaskFlow Backend

> **职责**: TaskFlow 后端项目的特定配置，包含模块列表和导入路径。

> **定位**: 本文件是 CLAUDE.md 的补充，包含**项目特定的业务配置**。
> **原则**: 通用规范放 `rules/`，项目特定信息放此处。
> 架构规范详见 [rules/architecture.md](rules/architecture.md)

---

## 项目信息

| 配置项 | 值 |
|--------|-----|
| **项目名称** | taskflow |
| **项目描述** | TaskFlow 后端服务 - 企业级任务管理 API |
| **架构模式** | DDD + Modular Monolith + Clean Architecture |
| **Python 版本** | >=3.11 |
| **源码根路径** | `src` |
| **模块路径** | `src/modules` |
| **共享路径** | `src/shared` |

---

## 技术栈补充

> **完整版本矩阵**: 见 [rules/tech-stack.md](rules/tech-stack.md) (单一真实源)
>
> 以下仅列出 tech-stack.md 未覆盖的**项目特有选型**。

| 类别 | 技术选型 | 说明 |
|------|---------|------|
| **数据库** | MySQL 8.0+ / Aurora MySQL 3.x | 主数据库 |
| **认证** | JWT + Amazon Cognito | 用户认证和授权 |
| **数据库迁移** | Alembic >=1.13.0 | 基于 SQLAlchemy |

---

## 业务模块

> **维护提示**: 新增模块时同步更新此表和 `src/modules/` 目录。

| 模块 | 职责 | 核心实体 |
|------|------|---------|
| `task` | 任务管理 | `Task`, `Subtask` |
| `project` | 项目管理 | `Project`, `Milestone` |
| `auth` | 用户认证与授权 | `User`, `Role` |
| `comment` | 评论系统 | `Comment`, `Mention` |
| `shared` | 共享内核 | `BaseEntity`, `DomainEvent` |

---

## 核心域事件

> **设计原则**: 事件用于模块间解耦通信，订阅者不应直接依赖发布者的实现。

| 模块 | 事件 | 触发场景 | 订阅者 |
|------|------|---------|--------|
| `task` | `TaskCreatedEvent` | 任务创建 | project, comment |
| `task` | `TaskStatusChangedEvent` | 任务状态变更 | project |
| `project` | `ProjectCreatedEvent` | 项目创建 | auth |
| `auth` | `UserRegisteredEvent` | 用户注册 | project |

---

## 导入路径配置

> **原则**: 参考 [rules/architecture.md](rules/architecture.md) §3 模块隔离规则。

### 共享内核导入

```python
# Domain 层共享
from src.shared.domain import (
    BaseEntity, PydanticEntity,
    IRepository,
    DomainError, EntityNotFoundError, ValidationError,
    DomainEvent, event_bus, event_handler,
)

# Infrastructure 层共享
from src.shared.infrastructure import get_db, get_settings, PydanticRepository

# API 层共享
from src.shared.api import domain_exception_handler
from src.shared.api.schemas import EntitySchema, PaginatedResponse
```

### 认证依赖 (唯一跨模块例外)

```python
# 仅允许在 API 层导入
from src.modules.auth.api.dependencies import (
    get_current_active_user,
    require_admin,
)
```

---

## 外部服务配置

> **位置约定**: 所有外部服务适配器放在 `infrastructure/external/` 下。

| 服务 | 用途 | 适配器位置 |
|------|------|-----------|
| AWS S3 | 附件存储 | `infrastructure/external/aws/s3/` |
| Amazon Cognito | 用户认证 | `infrastructure/external/aws/cognito/` |
| Redis | 缓存 | `infrastructure/external/cache/` |

---

## 架构合规

> 违规检测规则、依赖合法性矩阵、允许的例外、合规测试详见 [rules/architecture.md](rules/architecture.md) §0.1、§3、§9。
