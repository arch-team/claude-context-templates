# Claude Context Templates

This file provides guidance to Claude Code when working with code in this repository.

## §0 速查卡片

### 文件索引

**agent-platform 共享规范（自动加载）**：

| 文件 | 职责 | 来源 | 当前适用 |
|------|------|------|---------|
| `.claude/rules/core-constraints.md` | IA 11 原则铁律 | agent-platform | ✅ 适用 |
| `.claude/rules/skill-writing.md` | SKILL.md 8 段式规范 | agent-platform | ✅ 适用 |
| `.claude/rules/plugin-design.md` | Plugin 五层架构 | agent-platform | ⚠️ 部分适用 |
| `.claude/rules/compliance-checklist.md` | MVP → 正式插件升级矩阵 | agent-platform | ⚠️ 部分适用 |
| `.claude/rules/token-optimization.md` | Token 利用率优化 | agent-platform | ✅ 适用 |
| `.claude/rules/conventions.md` | 语言约定 + Git 提交规范 | agent-platform（适配） | ✅ 适用 |
| `.claude/rules/hook-command-script.md` | Command/Hook/Script 规范 | agent-platform（适配） | ✅ 适用 |

**claude-context-templates 特化规范（自动加载）**：

| 文件 | 职责 |
|------|------|
| `.claude/rules/dev-workflow.md` | 会话协议、质量检查、跨会话连续性 |
| `.claude/rules/project-structure.md` | 项目结构 SSoT、分层归属、新文件放置 |

**按需加载文档**：

| 文件 | 职责 | 加载时机 |
|------|------|---------|
| `.claude/references/orchestrator-writing.md` | 编排器编写规范 | **仅在创建 agents/ 时**（v2.0 可能需要） |
| `.claude/references/subagent-writing.md` | Sub Agent 编写规范 | **仅在创建 agents/ 时**（v2.0 可能需要） |
| `.claude/references/component-reference.md` | Plugin 组件规格补充 | 开发组件时 |
| `.claude/references/design-principles.md` | 6 条设计原则（IA 原则快速索引） | 创建规范时 |
| `docs/project-strategy.md` | 项目方向与路线图 | 按需 |
| `docs/customization-guide.md` | Preset 创建流程（SSoT） | 按需 |
| `docs/template-variables.md` | 模板变量占位符（SSoT） | 按需 |
| `docs/plugin-delivery-design.md` | Plugin 分发策略和工具链 | 按需 |
| `CONTRIBUTING.md` | 项目贡献指南 | 按需 |

---

## 规范适用性说明

**当前项目状态**：MVP 级别 Plugin（1 Skill + 2 Commands）

本项目实际使用五层架构中的 **L3（Skill）和 L5（Entry）两层**：
- L5: `plugin/commands/` — 命令触发
- L3: `plugin/skills/context-setup/` — 模板初始化逻辑

**暂未使用的架构层**（为未来扩展预留）：
- L1 (Contract): `contracts/` — 角色定义、状态 Schema（需要 ≥2 角色时引入）
- L2 (Knowledge): `knowledge/` — 跨 Skill 共享知识（需要 ≥2 Skill 共享内容时提取）
- L4 (Agent): `agents/` — 编排器（需要自动流转/角色路由时引入）

**开发指引**：
- **日常开发**：重点关注 `skill-writing.md`、`hook-command-script.md`、`conventions.md`、`dev-workflow.md`
- **v2.0 开发**：根据实际需求决定是否引入 L1/L2/L4 层
- **忽略内容**：`orchestrator-writing.md`、`subagent-writing.md`（仅在创建 agents/ 时阅读）

**何时升级到完整架构**（参考 `compliance-checklist.md` 升级矩阵）：
- 出现第 2 个 Skill → 考虑引入 L1 `contracts/`
- 2+ Skill 共享知识 → 提取到 L2 `knowledge/`
- Skill 数 ≥5 且需要自动流转 → 考虑引入 L4 `agents/`

---

## 分层架构

本项目分为**开发层**（`.claude/`、`docs/`、`scripts/`、`examples/`）和**产品层**（`plugin/`）。产品层不得依赖开发层，必须独立可分发。

详细分层规则、归属表和检测方法见 `rules/project-structure.md` §3。

---

## 开发守则

1. **Preset 是核心产出**：所有改进最终服务于 Preset 质量和技术栈覆盖
2. **规范优先不猜测**：组件开发通过 `claude-code-guide` agent 或官方文档查证，不凭记忆猜测 API
3. **双语同步交付**：新增 Preset/文档须双语同时完成
4. **plugin.json 必须实时同步**：新增/删除组件后立即更新 manifest
5. **分层不可违反**：产品层独立可分发，检测方法和常见绕过见 `project-structure.md` §3
6. **agent-platform 规范体系**：Plugin 开发遵循 `rules/plugin-design.md` 五层架构 + `rules/skill-writing.md` 8 段式规范

---

## 项目概述

Claude Context Templates — **AI Coding 工具上下文规范协作治理**的持续守护者。从项目 init 时的结构铺设，延伸到日常开发中的漂移检测、版本演进中的升级路径、团队协作中的质量门禁，为 AI 辅助开发的全生命周期提供行为护栏。

- **战略定位**: 项目全生命周期的 AI 行为护栏（详见 `docs/project-strategy.md` §1-§2）
- **三支柱能力**（v2.x 演进方向）: 漂移检测（支柱 A） / 升级路径（支柱 B，BR-003） / 质量门禁（支柱 C）
- **核心产出**: Plugin（预设模板 presets + 命令 commands + Skill + 可选 Hooks）
- **支持模式**: Monorepo 多子项目 | 单项目 | 双语 (zh-CN / en)

---

## 会话协议

详见 `rules/dev-workflow.md`（自动加载）。

---

## Git 分支

```
feat/{module-name} → main
```

功能分支直接从 main 创建，完成后合并回 main。提交规范见 `rules/conventions.md`。

---

## 常用命令

```bash
# 项目初始化（为目标项目生成 .claude/ 目录）
./init.sh
```

验证脚本（validate-presets / check-links / test-init）详见 `dev-workflow.md` §3 自动检查脚本。

---

## 项目模块

| 模块 | 路径 | 说明 |
|------|------|------|
| Plugin | `plugin/` | Claude Code Plugin（commands、skills、presets） |
| 预设模板 | `plugin/presets/` | generic, python-fastapi, react-typescript, aws-cdk |
| 完整示例 | `examples/` | monorepo-taskmanager, single-project-python |
| 脚本工具 | `scripts/` | CI/CD 和验证脚本 |
| 项目文档 | `docs/` | 设计原则、定制指南、模板变量、分发架构 |

> 完整目录树见 `rules/project-structure.md` §1（单一真实源）。

---

<!-- devpace-start -->
# Claude Context Templates

> 结构化、可复用的 Claude Code 上下文管理模板。为项目快速生成组织良好的 `.claude/` 目录。

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

（随开发自然生长 — 首次 `/pace-retro` 或讨论业务目标时引导定义）
<!-- devpace-end -->

---
