# Claude Context Templates

This file provides guidance to Claude Code when working with code in this repository.

## §0 速查卡片

### 文件索引

**agent-platform 共享规范（自动加载）**：

| 文件 | 职责 |
|------|------|
| `.claude/rules/core-constraints.md` | IA 11 原则铁律 |
| `.claude/rules/skill-writing.md` | SKILL.md 8 段式规范 + Token 优化自检 |
| `.claude/rules/compliance-checklist.md` | 合规验收清单 |
| `.claude/rules/conventions.md` | 语言约定 + Git 提交规范 |
| `.claude/rules/hook-command-script.md` | Command/Hook/Script 规范 |

**claude-context-templates 特化规范（自动加载）**：

| 文件 | 职责 |
|------|------|
| `.claude/rules/dev-workflow.md` | 会话协议、质量检查、跨会话连续性 |
| `.claude/rules/project-structure.md` | 项目结构 SSoT、分层归属、新文件放置 |

**按需加载文档**：

| 文件 | 职责 | 加载时机 |
|------|------|---------|
| `docs/project-strategy.md` | 项目方向与路线图 | 按需 |
| `docs/customization-guide.md` | Preset 创建流程（SSoT） | 按需 |
| `docs/template-variables.md` | 模板变量占位符（SSoT） | 按需 |
| `docs/plugin-delivery-design.md` | Plugin 分发策略和工具链 | 按需 |
| `CONTRIBUTING.md` | 项目贡献指南 | 按需 |

---

## 项目概述

Claude Context Templates — **AI Coding 工具上下文规范协作治理**的持续守护者。从项目 init 时的结构铺设，延伸到日常开发中的漂移检测、版本演进中的升级路径、团队协作中的质量门禁，为 AI 辅助开发的全生命周期提供行为护栏。

- **战略定位**: 项目全生命周期的 AI 行为护栏（详见 `docs/project-strategy.md`）
- **三支柱能力**（v2.x 演进方向）: 漂移检测 / 升级路径 / 质量门禁
- **核心产出**: Plugin（预设模板 presets + 命令 commands + Skill + 可选 Hooks）
- **支持模式**: Monorepo 多子项目 | 单项目 | 双语 (zh-CN / en)

---

## 当前架构

本项目使用五层架构中的 **L3（Skill）和 L5（Entry）两层**：
- L5: `plugin/commands/` — 命令触发
- L3: `plugin/skills/context-setup/` — 模板初始化逻辑

其余架构层（L1 Contract、L2 Knowledge、L4 Agent）按需引入，触发条件见 `compliance-checklist.md`。

完整目录树和分层约束见 `rules/project-structure.md`。

---

## 开发守则

1. **Preset 是核心产出**：所有改进最终服务于 Preset 质量和技术栈覆盖
2. **规范优先不猜测**：组件开发通过 `claude-code-guide` agent 或官方文档查证，不凭记忆猜测 API
3. **双语同步交付**：新增 Preset/文档须双语同时完成
4. **plugin.json 必须实时同步**：新增/删除组件后立即更新 manifest
5. **分层不可违反**：产品层独立可分发，检测方法见 `project-structure.md` §3
6. **agent-platform 规范体系**：Skill 编写见 `rules/skill-writing.md`

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

<!-- devpace-start -->
## devpace 研发协作

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
