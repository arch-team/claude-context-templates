# CLAUDE.md - {{PROJECT_NAME}} 项目规范

> **职责**: 项目入口规范，定义技术栈、开发命令和核心原则。

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **注意**: 通用规范（响应语言、项目概述）请参考根目录 [../.claude/CLAUDE.md](../../.claude/CLAUDE.md)

---

## 技术栈

<!-- {{AI_GENERATED:tech_stack_summary}}
  根据项目实际技术栈生成摘要，格式示例:
  **核心**: 语言 | 框架 | 数据库
  **工具**: 包管理 | Linter | 类型检查 | 测试框架
-->

版本矩阵和约束详见 [rules/tech-stack.md](rules/tech-stack.md)

---

## 开发命令

<!-- {{AI_GENERATED:dev_commands}}
  根据项目实际工具链生成常用命令，应包含:
  - 代码质量检查（lint、格式化、类型检查）
  - 测试（运行全部、覆盖率、指定模块）
  - 服务运行（开发模式、生产模式）
  - 一键运行所有检查
-->

---

## 核心原则

<!-- {{AI_GENERATED:core_principles}}
  根据项目特点生成 2-4 条核心原则，格式示例:
  ### 原则名称
  **核心要点**: 一句话概括
  详细说明请参考 [rules/xxx.md](rules/xxx.md)
-->

### TDD 工作流

本项目采用测试驱动开发 (TDD)。详见 [rules/testing.md](rules/testing.md)

---

## 代码风格快速参考

类型提示、命名规范、导入排序详见 [rules/code-style.md](rules/code-style.md)

---

## 项目结构

**项目级目录**: 详见 [rules/project-structure.md](rules/project-structure.md) - 完整目录结构规范

**架构模式**: 详见 [rules/architecture.md](rules/architecture.md) - 架构设计与分层原则

---

## 安全规范快速参考

速查表和检测命令详见 [rules/security.md](rules/security.md)。

---

## 覆盖率要求

<!-- {{AI_GENERATED:coverage_table}}
  根据项目架构分层生成覆盖率表格，格式示例:
  | 层级 | 最低覆盖率 | 目标覆盖率 |
  |------|-----------|-----------|
  | 核心业务 | 95% | 100% |
  | 应用层 | 90% | 95% |
  | 基础设施 | 80% | 85% |
  | **整体** | **80%** | **90%** |
-->

---

## PR Review 检查清单

完整检查清单见 [rules/checklist.md](rules/checklist.md)

**预提交一键验证**:

<!-- {{AI_GENERATED:pre_commit_one_liner}}
  生成一行可执行的预提交命令，串联 lint + 格式化检查 + 类型检查 + 测试，示例:
  ```bash
  npm run lint && npm run typecheck && npm run test -- --coverage
  ```
-->

---

## 注意事项 (Gotchas)

<!-- {{AI_GENERATED:gotchas}}
  列出项目特有的易错点和注意事项，格式示例:
  | 项目 | 说明 |
  |------|------|
  | **数据库** | 使用 xxx，注意 yyy |
  | **包管理** | 仅使用 xxx，禁止 yyy |
-->
