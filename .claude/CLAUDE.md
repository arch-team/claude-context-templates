# Claude Context Templates

This file provides guidance to Claude Code when working with code in this repository.

## §0 速查卡片

### 权威文件索引

| 概念 | 权威文件 | 说明 |
|------|---------|------|
| 项目方向与路线图 | `docs/project-strategy.md` | 项目战略规划 |
| 6 条核心设计原则 | `docs/design-principles.md` | SSoT、Section 0、分层等 |
| Preset 创建流程 | `docs/customization-guide.md` | 定制指南（SSoT） |
| 模板变量占位符 | `docs/template-variables.md` | 变量规范（SSoT） |
| Plugin 分发架构 | `docs/plugin-delivery-design.md` | 分发策略和工具链 |
| 项目目录结构 | `.claude/rules/project-structure.md` | 结构 SSoT + 分层归属 |

### 开发规范索引

| 规范文件（`.claude/rules/`，自动加载） | 职责 |
|--------------------------------------|------|
| `common.md` | 语言、Git 提交、命名、审查 |
| `dev-workflow.md` | 会话协议、质量检查、跨会话连续性 |
| `plugin-dev-spec.md` | Plugin/Preset 组件开发规范（Skill/Command/Preset） |
| `project-structure.md` | 项目结构 SSoT、分层归属、新文件放置 |

### 参考文档索引

| 参考文件（`.claude/references/`，按需加载） | 何时读 |
|--------------------------------------------|--------|
| `component-reference.md` | 开发/修改 Agent、Hook、MCP 组件时 |
| `ia-principles.md` | 审视信息架构、创建新 Preset、审计文档结构时 |

---

## 响应语言

**所有对话和文档必须使用中文。** 详细语言规则见 `rules/common.md` §0。

---

## 分层架构

本项目分为两个独立层次，**产品层不得依赖开发层**：

| 层次 | 目录 | 职责 | 分发 |
|------|------|------|------|
| **开发层** | `.claude/`、`docs/`、`scripts/`、`examples/` | 开发本项目的规范和文档 | 不分发 |
| **产品层** | `plugin/` | Plugin 运行时资产，分发给用户 | 随 Plugin 分发 |

**硬性约束**：

1. **产品层独立可分发**：`plugin/` 必须作为独立整体分发，不依赖开发层文件
2. **禁止产品->开发引用**：`plugin/` 内的文件不得引用 `.claude/`、`docs/`、`scripts/`
3. **开发->产品引用允许**：开发层文件可以引用产品层文件

详细分层规则和检测方法见 `rules/project-structure.md` §3。

---

## 项目概述

Claude Context Templates — 为 Claude Code 提供结构化、可复用的上下文管理模板。通过 Claude Code Plugin 分发预设模板，为项目快速生成 `.claude/` 目录。

- **核心产出**: Plugin（预设模板 presets + 命令 commands + Skill）
- **支持模式**: Monorepo 多子项目 | 单项目 | 双语 (zh-CN / en)

---

## 会话协议

详见 `rules/dev-workflow.md`（自动加载）。

---

## Git 分支

```
feat/{module-name} → main
```

功能分支直接从 main 创建，完成后合并回 main。提交规范见 `rules/common.md`。

---

## 常用命令

```bash
# 运行初始化脚本（为目标项目生成 .claude/ 目录）
./init.sh

# 验证预设模板结构完整性
./scripts/validate-presets.sh

# 检查文档链接有效性
./scripts/check-links.sh

# 测试 init.sh 脚本功能
./scripts/test-init.sh
```

---

## 项目模块

| 模块 | 路径 | 说明 |
|------|------|------|
| Plugin | `plugin/` | Claude Code Plugin（commands、skills、presets） |
| 预设模板 | `plugin/presets/` | python-fastapi, react-typescript, aws-cdk |
| 完整示例 | `examples/` | monorepo-taskmanager, single-project-python |
| 脚本工具 | `scripts/` | CI/CD 和验证脚本 |
| 项目文档 | `docs/` | 设计原则、定制指南、模板变量、分发架构 |

> 完整目录树见 `rules/project-structure.md` §1（单一真实源）。

---

## 相关文档

| 文档 | 说明 |
|------|------|
| [通用规则](rules/common.md) | 语言、Git 提交、命名、审查 |
| [开发工作流](rules/dev-workflow.md) | 会话协议、质量检查 |
| [Plugin 开发规范](rules/plugin-dev-spec.md) | Plugin/Preset 组件规范 |
| [项目结构](rules/project-structure.md) | 目录结构 SSoT、分层归属 |
| [设计原则](../docs/design-principles.md) | 模板系统的 6 条核心设计原则 |
| [定制指南](../docs/customization-guide.md) | 创建和贡献新预设模板 |
| [项目战略](../docs/project-strategy.md) | 项目方向和发展规划 |
| [贡献指南](../CONTRIBUTING.md) | 项目贡献流程和规范 |

---

<!-- devpace-start -->
# Claude Context Templates

> 为 Claude Code 提供结构化、可复用的上下文管理模板

## 研发协作

本项目使用 `.devpace/` 管理迭代研发。行为规则由 devpace Plugin 的 `rules/devpace-rules.md` 自动注入，此处不重复。

### .devpace/ 文件参考

| 文件 | 何时读 |
|------|--------|
| `state.md` | 每次会话开始（必读） |
| `backlog/CR-*.md` | 推进模式 |
| `project.md` | 变更分析 或 用户要求看全景 |
| `rules/workflow.md` | 推进模式（状态机定义） |
| `rules/checks.md` | 推进模式（质量检查定义） |
| `iterations/current.md` | 查进度 或 变更分析 |
| `metrics/dashboard.md` | /pace-retro 或 /pace-status metrics |

## 业务目标

（首次 `/pace-retro` 或讨论业务目标时引导定义）
<!-- devpace-end -->
