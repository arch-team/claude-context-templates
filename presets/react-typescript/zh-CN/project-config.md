> **职责**: 项目特定配置 - 功能模块、路由、API 端点、环境变量（业务配置单一真实源）

# 项目配置 - {{PROJECT_NAME}} Frontend

> **原则**: 通用规范放 `rules/`，项目特定信息放此处。
> 架构规范详见 [rules/architecture.md](rules/architecture.md)

---

## 项目信息

| 配置项 | 值 |
|--------|-----|
| **项目名称** | <!-- TODO: 填写项目名称 --> |
| **项目描述** | <!-- TODO: 填写项目描述 --> |
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
| `auth` | 用户认证与授权 | `LoginForm`, `RegisterForm`, `AuthProvider` |
| `shared` | 共享组件和工具 | `Button`, `Modal`, `useApi` |
<!-- TODO: 根据项目需求添加功能模块，例如：
| `dashboard` | 仪表盘和数据可视化 | `DashboardLayout`, `MetricsCard` |
| `settings` | 系统设置 | `SettingsForm`, `ProfileEditor` |
-->

---

## 路由配置

> **设计原则**: 路由结构反映业务领域，使用嵌套路由组织相关页面。

| 路径 | 页面 | 功能模块 | 权限 |
|------|------|---------|------|
| `/` | 首页/仪表盘 | `dashboard` | 需登录 |
| `/login` | 登录页 | `auth` | 公开 |
| `/register` | 注册页 | `auth` | 公开 |
| `/settings` | 设置页 | `settings` | 需登录 |
<!-- TODO: 根据项目需求添加路由 -->

---

## API 端点配置

> **位置约定**: 所有 API 调用放在 `src/shared/api/` 下。

| 端点 | 用途 | 对应后端模块 |
|------|------|-------------|
| `/api/v1/auth/*` | 认证相关 | `auth` |
| `/api/v1/users/*` | 用户管理 | `auth` |
<!-- TODO: 根据项目需求添加 API 端点 -->

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
| `VITE_APP_TITLE` | 应用标题 | `{{PROJECT_NAME}}` |
<!-- TODO: 根据项目需求添加环境变量 -->
