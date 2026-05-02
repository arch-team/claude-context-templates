# 设计原则

> **职责**：Claude Context Templates 模板系统的核心设计原则。
> **与 agent-platform 关系**：本项目的 6 条原则是 `rules/core-constraints.md` IA 11 原则在"上下文模板工具"场景下的具体化。

## §0 速查卡片

| # | 原则 | 一句话描述 | IA 原则映射 | 详细定义 |
|---|------|-----------|-----------|---------|
| 1 | SSoT | 每个概念只在一个文件中定义 | IA-6 单一权威 | `rules/core-constraints.md` |
| 2 | Section 0 | 规范文件以速查卡片开头 | IA-8 可发现性优先 + IA-2 抽象分层 | `rules/core-constraints.md` |
| 3 | 分层架构 | 上下文按层级组织，单向依赖 | IA-1 单向依赖 + IA-10 契约隔离 | `rules/core-constraints.md` |
| 4 | 依赖矩阵 | 用表格（非散文）表达依赖关系 | IA-1 单向依赖 + IA-9 认知清晰 | `rules/project-structure.md` |
| 5 | 双向链接 | 文档形成可导航的知识网络 | IA-8 可发现性优先 | `rules/core-constraints.md` |
| 6 | kebab-case | 统一的文件命名约定 | IA-9 认知清晰 | `rules/conventions.md` |

> **IA 11 原则完整定义**：见 `rules/core-constraints.md` "IA 11 原则速查"章节。

---

## 1. 单一真实源 (SSoT)

**原则**: 每个概念只在一个权威文件中定义。其他文件通过链接引用它。

**本项目示例**:
- `rules/project-structure.md` §1 是目录树的 SSoT
- `docs/template-variables.md` 是模板变量占位符的 SSoT
- `docs/customization-guide.md` 是 Preset 创建流程的 SSoT

## 2. Section 0 速查卡片

**原则**: 每个规范文件以 Section 0（速查区）开头，包含表格、决策树和速查表。

**原因**: Claude Code 通常只需要快速查找，而非阅读全文。Section 0 以最少的 token 提供高密度信息。

## 3. 分层架构

**原则**: 上下文按多层组织，层次分明，单向依赖。

详细分层规则见 `rules/project-structure.md` §3。五层架构详细定义见 `rules/plugin-design.md`。

**Preset 中的 _common 原则**：`_common/` 提供跨 Preset 共享的工程原则，Preset 可引用 `_common/` 但 `_common/` 不得引用特定 Preset。

## 4. 依赖矩阵

**原则**: 使用表格（而非散文）来表达架构层间的允许/禁止依赖关系。

完整的层间依赖矩阵见 `rules/plugin-design.md` "层间依赖矩阵"章节。

## 5. 双向链接

**原则**: 文档通过相对链接互相引用，形成可导航的知识网络。

**最佳实践**:
- 使用 Section 引用（`§2` 或 `## 标题`）实现精确导航
- 保持链接相对于当前目录
- 确保链接双向可达

## 6. kebab-case 命名

**原则**: 文件命名统一使用 kebab-case，减少认知负担。

完整命名规则见 `rules/conventions.md`。例外：`SKILL.md` / `CLAUDE.md` / `README.md`（全大写）、`_index.yml`（下划线前缀）。
