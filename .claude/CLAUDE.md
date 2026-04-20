# Claude Context Templates

This file provides guidance to Claude Code when working with code in this repository.

## §0 速查卡片

### 文件索引

| 文件 | 职责 | 加载方式 |
|------|------|---------|
| `docs/project-strategy.md` | 项目方向与路线图 | 按需 |
| `docs/customization-guide.md` | Preset 创建流程（SSoT） | 按需 |
| `docs/template-variables.md` | 模板变量占位符（SSoT） | 按需 |
| `docs/plugin-delivery-design.md` | Plugin 分发策略和工具链 | 按需 |
| `CONTRIBUTING.md` | 项目贡献指南 | 按需 |
| `.claude/rules/common.md` | 语言、Git 提交、命名、审查 | 自动加载 |
| `.claude/rules/dev-workflow.md` | 会话协议、质量检查、跨会话连续性 | 自动加载 |
| `.claude/rules/plugin-dev-spec.md` | Plugin/Preset 组件开发规范 | 自动加载 |
| `.claude/rules/project-structure.md` | 项目结构 SSoT、分层归属、新文件放置 | 自动加载 |
| `.claude/references/component-reference.md` | Agent/Hook/MCP 组件规格 | 按需（开发组件时） |
| `.claude/references/design-principles.md` | 6 条核心设计原则 | 按需（创建规范时） |
| `.claude/references/ia-principles.md` | 11 条信息架构原则 | 按需（审计结构时） |

---

## 响应语言

**所有对话和文档必须使用中文。** 详细语言规则见 `rules/common.md` §0。

---

## 分层架构

本项目分为**开发层**（`.claude/`、`docs/`、`scripts/`、`examples/`）和**产品层**（`plugin/`）。产品层不得依赖开发层，必须独立可分发。

详细分层规则、归属表和检测方法见 `rules/project-structure.md` §3。

---

## 开发守则

1. **Preset 是核心产出**：所有改进最终服务于 Preset 质量和技术栈覆盖
2. **规范优先不猜测**：组件开发通过 `claude-code-guide` agent 或官方文档查证，不凭记忆猜测 API
3. **双语同步交付**：新增 Preset/文档须双语同时完成，规则详见 `plugin-dev-spec.md` §4
4. **plugin.json 必须实时同步**：新增/删除组件后立即更新 manifest，完整清单见 `rules/plugin-dev-spec.md` §1 扩展同步清单
5. **分层不可违反**：产品层独立可分发，检测方法和常见绕过见 `project-structure.md` §3

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

功能分支直接从 main 创建，完成后合并回 main。提交规范见 `rules/common.md`。

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
# claude-context-templates

> Structured, reusable context management templates for Claude Code

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
| `context.md` | 查进度 或 变更分析 |
| `metrics/dashboard.md` | /pace-retro 或 /pace-status metrics |

## 业务目标

详见 `.devpace/project.md`。核心目标：提升用户采用率、代码生成质量、建立生态标准。
<!-- devpace-end -->
