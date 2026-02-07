# CLAUDE.md - TaskAPI 项目规范

> **职责**: 项目入口规范，定义技术栈、开发命令和核心原则。

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

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

---

## 项目概述

TaskAPI - 轻量级任务管理 API，提供任务的 CRUD 操作和基本用户认证功能。

---

## 技术栈

**核心**: Python 3.11+ | FastAPI | SQLAlchemy 2.0+ | Pydantic v2 | MySQL 8.0+

**工具**: uv (包管理) | Ruff (lint) | MyPy (类型检查) | pytest 8.0+

---

## 开发命令

### 代码质量

```bash
# 代码检查 (lint)
uv run ruff check src/

# 代码检查并自动修复
uv run ruff check src/ --fix

# 代码格式化
uv run ruff format src/

# 类型检查
uv run mypy src/

# 一键运行所有检查
uv run ruff check src/ && uv run ruff format --check src/ && uv run mypy src/
```

### 测试

```bash
# 运行所有测试
uv run pytest

# 运行测试 + 覆盖率报告
uv run pytest --cov=src --cov-report=term-missing

# 运行特定模块的测试
uv run pytest tests/modules/task/

# 运行标记的测试
uv run pytest -m "unit"
uv run pytest -m "integration"
```

### 服务运行

```bash
# 开发模式运行 API 服务
uv run uvicorn src.presentation.api.main:app --reload --port 8000

# 生产模式运行
uv run uvicorn src.presentation.api.main:app --host 0.0.0.0 --port 8000 --workers 4
```

---

## 核心原则

### SDK-First 原则

**核心原则**：尽可能使用 SDK 简化代码实现，避免重复造轮子。

### TDD 工作流

本项目全面采用测试驱动开发 (TDD)。

**核心循环**:
```
1. Red: 先写失败的测试
2. Green: 编写最少代码使测试通过
3. Refactor: 重构代码，保持测试通过
```

**测试分层策略**:

| 层级 | 说明 |
|------|------|
| **Unit** | 实体、值对象、域逻辑 |
| **Integration** | API 端点、仓库实现 |
| **E2E** | 完整流程、外部服务集成 |

**测试诚信原则**: 切勿为让测试通过而伪造结果。测试失败 = 代码有问题，必须修复代码。

---

## 项目结构

**架构模式**: DDD + Clean Architecture

**核心分层**: Domain -> Application -> Infrastructure -> Presentation (依赖方向从外向内)

---

## 覆盖率要求

| 层级 | 最低覆盖率 | 目标覆盖率 |
|------|-----------|-----------|
| Domain | 95% | 100% |
| Application | 90% | 95% |
| Infrastructure | 80% | 85% |
| Presentation | 80% | 85% |
| **整体** | **85%** | **90%** |

---

## 注意事项 (Gotchas)

| 项目 | 说明 |
|------|------|
| **数据库** | MySQL 8.0+，非 PostgreSQL。SQLAlchemy 方言注意差异 |
| **异步驱动** | 需要 asyncmy 作为异步 MySQL 驱动 |
| **包管理** | 仅使用 uv，禁止 pip/poetry |

---

## PR Review 检查清单

**预提交一键验证**:
```bash
uv run ruff check src/ && uv run ruff format --check src/ && uv run mypy src/ && uv run pytest --cov=src --cov-fail-under=85
```

---

## 相关文档

| 文档 | 说明 |
|------|------|
| [rules/common.md](rules/common.md) | Git 提交规范、代码审查标准 |
