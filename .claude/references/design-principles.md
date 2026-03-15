# 设计原则

> **职责**：Claude Context Templates 模板系统的核心设计原则。
>
> **跨文档引用**：被 `rules/dev-workflow.md` §2 引用。

## §0 速查卡片

| # | 原则 | 一句话描述 | 适用场景 | IA 映射 |
|---|------|-----------|---------|---------|
| 1 | SSoT | 每个概念只在一个文件中定义 | A B | IA-6 |
| 2 | Section 0 | 规范文件以速查卡片开头 | A B | IA-8, IA-5 |
| 3 | 分层架构 | 上下文按层级组织，单向依赖 | A B | IA-1, IA-2 |
| 4 | 依赖矩阵 | 用表格（非散文）表达依赖关系 | A B | IA-9 |
| 5 | 双向链接 | 文档形成可导航的知识网络 | A B | IA-8 |
| 6 | kebab-case | 统一的文件命名约定 | A B | — |

> **场景 A** = 开发本项目（组织 `.claude/`、`docs/` 等）；**场景 B** = 开发 Preset 模板内容。IA 映射详见 [ia-principles.md](ia-principles.md)。

---

## 1. 单一真实源 (SSoT)

**原则**: 每个概念只在一个权威文件中定义。其他文件通过链接引用它。

**原因**: 避免信息不一致。当规则变更时，只需在一处更新。

**本项目示例**:
- `rules/project-structure.md` §1 是目录树的 SSoT
- `docs/template-variables.md` 是模板变量占位符的 SSoT
- `docs/customization-guide.md` 是 Preset 创建流程的 SSoT

**模式**:
```markdown
# 在 plugin-dev-spec.md 中
Preset 创建的完整流程详见 `docs/customization-guide.md`（SSoT）。
```

## 2. Section 0 速查卡片

**原则**: 每个规范文件以 Section 0（速查区）开头，包含表格、决策树和速查表。

**原因**: Claude Code 通常只需要快速查找，而非阅读全文。Section 0 以最少的 token 提供高密度信息。

**本项目示例** (`project-structure.md` §0):
```markdown
# 项目目录结构

> **职责**: 文件放置规则与分层归属

## §0 速查卡片

### 新文件放置决策树
新文件
├─ Plugin 运行时需要？→ plugin/
├─ 开发规范？→ .claude/rules/ 或 references/
├─ 项目文档？→ docs/
└─ 不确定 → 先问

### 常见陷阱
| 正确做法 | 错误做法 |
|---------|---------|
| 查决策树后放置 | 直接放项目根目录 |

---

## §1 详细规范
...
```

## 3. 分层架构

**原则**: 上下文按多层组织，层次分明，单向依赖。

详细分层规则、归属表和约束见 [`project-structure.md` §3](../rules/project-structure.md)。

**Preset 中的 _common 原则**：`_common/` 提供跨 Preset 共享的工程原则，Preset 可引用 `_common/` 但 `_common/` 不得引用特定 Preset。

## 4. 依赖矩阵

**原则**: 使用表格（而非散文）来表达架构层间的允许/禁止依赖关系。

**原因**: 表格比文字段落更明确、更易扫描、更节省 token。

**本项目示例** (`project-structure.md` §3 分层约束):

| 方向 | 允许 | 示例 |
|------|------|------|
| 开发层 → 产品层 | OK | `.claude/rules/` 引用 `plugin/` 结构 |
| 产品层 → 开发层 | NO | `plugin/` 不得引用 `.claude/` |

**Preset 模板示例** (Feature-Sliced Design):

| From \ Import | shared | entities | features |
|---------------|:------:|:--------:|:--------:|
| **features**  |   OK   |    OK    |    NO    |
| **entities**  |   OK   |    NO    |    NO    |
| **shared**    |   NO   |    NO    |    NO    |

## 5. 双向链接

**原则**: 文档通过相对链接互相引用，形成可导航的知识网络。

**原因**: 使 Claude Code 能够追踪引用关系，理解规则间的关联。

**本项目示例**:
```markdown
# 在 plugin-dev-spec.md 中
完整目录树见 `rules/project-structure.md` §1（SSoT），此处不重复。

# 在 project-structure.md §4 中
组件格式见 `rules/plugin-dev-spec.md`。
```

**最佳实践**:
- 使用 Section 引用（`§2` 或 `## 标题`）实现精确导航
- 保持链接相对于当前目录
- 确保链接双向可达

## 6. kebab-case 命名

**原则**: 除框架/GitHub 约定文件（`CLAUDE.md`、`README.md`、`CONTRIBUTING.md`、`LICENSE`、`SKILL.md`）外，所有文档统一使用 `kebab-case.md`。

完整命名规则和例外列表见 [`common.md` §0](../rules/common.md)。
