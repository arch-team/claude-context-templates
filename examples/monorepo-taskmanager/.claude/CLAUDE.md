# TaskFlow - Monorepo

## 响应语言
**所有对话和文档必须（Must）使用中文。**

### 强制要求

- 所有对话必须使用中文
- 代码注释使用中文
- 文档内容使用中文
- Git 提交信息使用中文

### 例外情况

以下内容保持英文:
- 代码变量名、函数名、类名
- 技术术语 (如 API, SDK, TDD)
- 第三方库/框架名称
- 错误信息和日志 (可选)

---

## 项目概述

TaskFlow - 企业级任务管理平台，支持项目管理、任务跟踪和团队协作。

## Monorepo 结构

| 子项目 | 路径 | 说明 |
|--------|------|------|
| 后端服务 | `backend/` | Python + FastAPI |
| 前端应用 | `frontend/` | React + TypeScript |
| 基础设施 | `infra/` | AWS CDK |

## 开发指南

进入对应子目录后，Claude Code 会自动加载该子项目的规范：

```bash
cd backend/   # 加载后端规范
cd frontend/  # 加载前端规范
cd infra/     # 加载基础设施规范
```

## 相关文档

| 子项目 | 规范文档 |
|--------|---------|
| 后端 | [backend/.claude/CLAUDE.md](backend/.claude/CLAUDE.md) |
| 前端 | [frontend/.claude/CLAUDE.md](frontend/.claude/CLAUDE.md) |
| 基础设施 | [infra/.claude/CLAUDE.md](infra/.claude/CLAUDE.md) |
| 通用规则 | [.claude/rules/common.md](.claude/rules/common.md) |
