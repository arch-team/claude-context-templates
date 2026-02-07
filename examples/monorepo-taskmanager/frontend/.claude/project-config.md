> **职责**: 项目特定配置 - 功能模块、路由、API 端点、环境变量（业务配置单一真实源）

# 项目配置 - TaskFlow Frontend

> **原则**: 通用规范放 `rules/`，项目特定信息放此处。
> 架构规范详见 [rules/architecture.md](rules/architecture.md)

---

## 项目信息

| 配置项 | 值 |
|--------|-----|
| **项目名称** | taskflow-frontend |
| **项目描述** | TaskFlow 前端应用 - 企业级任务管理界面 |
| **架构模式** | Feature-Sliced Design (FSD) |
| **Node 版本** | >=18.0.0 |
| **源码根路径** | `src` |

---

## 技术栈版本要求

> **技术栈版本**: 详见 [rules/tech-stack.md](rules/tech-stack.md) (单一真实源)
>
> 如需项目特定的版本约束，请在 `package.json` 的 `engines` 或 `peerDependencies` 中定义。

---

## 功能模块

> **维护提示**: 新增功能时同步更新此表和 `src/features/` 目录。

| 功能 (Feature) | 职责 | 核心组件 |
|----------------|------|---------|
| `task` | 任务列表、看板视图、任务详情 | `TaskCard`, `TaskBoard`, `TaskDetailModal` |
| `project` | 项目仪表板、项目设置 | `ProjectSidebar`, `ProjectDashboard`, `MilestoneTimeline` |
| `auth` | 用户登录、注册、权限管理 | `LoginForm`, `RegisterForm`, `AuthProvider` |
| `comment` | 评论、@提及、实时通知 | `CommentThread`, `MentionInput`, `NotificationBell` |
| `label` | 标签管理、筛选 | `LabelBadge`, `LabelSelector`, `LabelManager` |
| `shared` | 共享组件和工具 | `Button`, `Modal`, `useApi` |

---

## 状态管理

| 状态类型 | 方案 | 用途 |
|---------|------|------|
| 服务端状态 | React Query | `useTasks`, `useProjects`, `useComments` |
| 客户端状态 | Zustand | `useAppStore`（主题、侧边栏、用户偏好） |
| 认证状态 | React Query + Context | `useAuth`（登录状态、Token 管理） |

---

## 路由配置

> **设计原则**: 路由结构反映业务领域，使用嵌套路由组织相关页面。

| 路径 | 页面 | 功能模块 | 权限 |
|------|------|---------|------|
| `/` | 项目仪表板 | `project` | 需登录 |
| `/login` | 登录页 | `auth` | 公开 |
| `/register` | 注册页 | `auth` | 公开 |
| `/projects/:id` | 项目详情 | `project` | 需登录 |
| `/projects/:id/board` | 看板视图 | `task` | 需登录 |
| `/projects/:id/list` | 列表视图 | `task` | 需登录 |
| `/tasks/:id` | 任务详情 | `task` | 需登录 |
| `/settings` | 设置页 | `settings` | 需登录 |

---

## API 端点配置

> **位置约定**: 所有 API 调用放在 `src/shared/api/` 下。

| 端点 | 用途 | 对应后端模块 |
|------|------|-------------|
| `/api/v1/auth/*` | 认证相关 | `auth` |
| `/api/v1/users/*` | 用户管理 | `auth` |
| `/api/v1/projects/*` | 项目管理 | `project` |
| `/api/v1/tasks/*` | 任务管理 | `task` |
| `/api/v1/comments/*` | 评论管理 | `comment` |
| `/api/v1/labels/*` | 标签管理 | `label` |

### API 客户端配置

```typescript
// src/shared/api/client.ts
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});
```

---

## 环境变量配置

> **位置**: `.env.example` 模板，`.env.local` 本地配置

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `VITE_API_BASE_URL` | 后端 API 基础 URL | `http://localhost:8000` |
| `VITE_APP_TITLE` | 应用标题 | `TaskFlow` |
| `VITE_COGNITO_USER_POOL_ID` | Cognito 用户池 ID | `us-east-1_xxxxxxxx` |
| `VITE_COGNITO_CLIENT_ID` | Cognito 客户端 ID | `xxxxxxxxxxxxxxxxxxxxxxxxxx` |
