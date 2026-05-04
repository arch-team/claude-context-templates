# 架构规范

> **职责**: 架构规范 - FSD 分层原则、依赖规则、Slice 结构模板、导出示例、跨层通信代码
>
> **相关规范**: [component-design.md](component-design.md) (组件类型与位置) | [state-management.md](state-management.md) (跨层状态管理) | [checklist.md](checklist.md) (PR Review 检查清单)

> **架构模式**: Feature-Sliced Design (FSD)
> **适用范围**: React + TypeScript 前端项目

<!-- CLAUDE 占位符说明:
  {Feature}    → 功能名称 PascalCase，如 Auth, Tasks, Dashboard
  {feature}    → 功能名称 kebab-case，如 auth, tasks, dashboard
  {Entity}     → 实体名称 PascalCase，如 User, Task
  {entity}     → 实体名称 kebab-case，如 user, task
  {Component}  → 组件名称 PascalCase，如 LoginForm, TaskCard
  {Widget}     → 组件组合 PascalCase，如 Header, Sidebar
-->

---

## Feature-Sliced Design (FSD) 分层原则

### 分层依赖矩阵

| 从 ↓ 导入 → | shared | entities | features | widgets | pages | app |
|-------------|:------:|:--------:|:--------:|:-------:|:-----:|:---:|
| **app** | ✅ | ✅ | ✅ | ✅ | ✅ | - |
| **pages** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **widgets** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **features** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **entities** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **shared** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**核心规则**: 只能向下依赖，不能向上或平级依赖

---

## 层级职责

| 层级 | 职责 | ✅ 可以 | ❌ 禁止 |
|------|------|--------|--------|
| **app** | 应用初始化、路由、全局 Provider | Provider、路由、全局样式 | 具体业务实现 |
| **pages** | 页面组件，组装 widgets/features | 组合 widgets/features、页面布局 | 业务逻辑 |
| **widgets** | 独立 UI 块，组合多个 features | 组合下层组件、简单状态 | 直接业务逻辑、API 调用 |
| **features** | 业务功能，包含业务逻辑 | 业务逻辑、API 调用、状态管理 | 跨 feature 依赖 |
| **entities** | 业务实体，数据模型和基础 UI | 数据模型、基础 UI、类型定义 | 复杂业务逻辑、跨实体依赖 |
| **shared** | 共享工具，无业务逻辑 | 工具函数、基础 UI、API 客户端 | 任何业务逻辑、业务实体 |

---

## 组件抽象层级

### Public API 原则

- 每个 slice 必须有 `index.ts` 定义公开 API
- 禁止导出内部工具函数、私有组件、实现细节
- 外部只能通过 `index.ts` 导入 slice 的功能

### 模块通信原则

| 场景 | 推荐方案 |
|------|---------|
| 组件间数据传递 | Props drilling / Context |
| 全局状态 | Zustand store |
| 服务端数据 | React Query |
| 事件通信 | Custom Events / Zustand |

---

## 0. 速查卡片

> Claude 生成代码时优先查阅此章节

### 0.1 Slice 结构模板

```
{layer}/{slice}/
├── index.ts              # 公开 API 导出
├── api/                  # API 调用 (features/entities 专用)
│   └── queries.ts
├── model/                # 状态管理
│   ├── store.ts          # Zustand store
│   └── types.ts          # 类型定义
├── ui/                   # UI 组件
│   ├── {Component}.tsx
│   └── {Component}.test.tsx
└── lib/                  # 工具函数
    └── utils.ts
```


---

## 1. 模块导出规则

### 1.1 Public API 原则

每个 slice 必须有 `index.ts` 定义公开 API：

```typescript
// features/auth/index.ts
// UI 组件
export { LoginForm } from './ui/LoginForm';
export { RegisterForm } from './ui/RegisterForm';

// Hooks
export { useAuth } from './model/store';
export { useLogin, useLogout } from './api/queries';

// 类型
export type { LoginCredentials, AuthState } from './model/types';
```

### 1.2 禁止导出

- 内部工具函数
- 私有组件
- 实现细节

```typescript
// ❌ 错误 - 不应导出内部实现
export { validateEmail } from './lib/validation';
export { useInternalState } from './model/internal';
```

---

## 2. 跨层通信

### 2.1 推荐模式

| 场景 | 推荐方案 | 详细规范 |
|------|---------|---------|
| 组件间数据传递 | Props drilling / Context | - |
| 全局状态 | Zustand store | [state-management.md](state-management.md) §2 |
| 服务端数据 | React Query | [state-management.md](state-management.md) §1 |
| 事件通信 | Custom Events / Zustand | - |
