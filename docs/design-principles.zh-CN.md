[English](design-principles.md)

# 设计原则

本文档阐述 Claude Context Templates 模板系统背后的 6 大核心设计原则。

## 1. 单一真实源 (SSoT)

**原则**: 每个概念只在一个权威文件中定义。其他文件通过链接引用它。

**原因**: 避免信息不一致。当规则变更时，只需在一处更新。

**示例**:
- `tech-stack.md` 是版本要求的 SSoT
- `architecture.md` 是架构模式的 SSoT
- `common.md` 是 Monorepo 结构的 SSoT

**模式**:
```markdown
# 在 architecture.md 中
版本要求请参见 [tech-stack.md](tech-stack.md)
```

## 2. Section 0 速查卡片

**原则**: 每个规范文件以 Section 0（速查区）开头，包含表格、决策树和速查表。

**原因**: Claude Code 通常只需要快速查找，而非阅读全文。Section 0 以最少的 token 提供高密度信息。

**示例结构**:
```markdown
# 架构规范

> **职责**: 架构模式 SSoT

---

## 0. 速查卡片

### 依赖矩阵
| From \ To | shared | entities | features |
|-----------|:------:|:--------:|:--------:|
| features  |   OK   |    OK    |    NO    |
| entities  |   OK   |    NO    |    NO    |

### 决策树
需要新模块？
  -> 有领域逻辑？-> 是 -> 创建领域模块
  -> 无领域逻辑？-> 添加到 shared/

### 常见陷阱
| 正确做法 | 错误做法 |
|---------|---------|
| 从 shared 导入 | 跨模块导入 |

---

## 1. 详细规范
...
```

## 3. 分层架构

**原则**: 上下文按 3 层组织，层次分明。

```
第 1 层: 根 .claude/           -> 全局设置（语言、项目概述）
第 2 层: 根 .claude/rules/     -> 跨项目规则（Git、文档、结构）
第 3 层: {子项目}/.claude/     -> 子项目专属（技术栈、架构）
```

**原因**: Claude Code 根据当前目录自动加载对应层级。这避免了规则冲突，并保持上下文聚焦。

**工作方式**:
- 在项目根目录工作 -> 加载第 1 层 + 第 2 层
- 在 `backend/` 中工作 -> 加载第 1 层 + 第 2 层 + backend 第 3 层
- 每层可通过相对链接引用其他层

## 4. 依赖矩阵

**原则**: 使用表格（而非散文）来表达架构层间的允许/禁止依赖关系。

**原因**: 表格比文字段落更明确、更易扫描、更节省 token。

**示例** (Feature-Sliced Design):
```markdown
| From \ Import | shared | entities | features | widgets | pages |
|---------------|:------:|:--------:|:--------:|:-------:|:-----:|
| **pages**     |   OK   |    OK    |    OK    |   OK    |  NO   |
| **widgets**   |   OK   |    OK    |    OK    |   NO    |  NO   |
| **features**  |   OK   |    OK    |    NO    |   NO    |  NO   |
| **entities**  |   OK   |    NO    |    NO    |   NO    |  NO   |
| **shared**    |   NO   |    NO    |    NO    |   NO    |  NO   |
```

## 5. 双向链接

**原则**: 文档通过相对链接互相引用，形成可导航的知识网络。

**原因**: 使 Claude Code 能够追踪引用关系，理解规则间的关联。

**模式**:
```markdown
# 在 architecture.md 中
测试要求：参见 [testing.md](testing.md) Section 3

# 在 testing.md 中
架构模式：参见 [architecture.md](architecture.md) Section 1
```

**最佳实践**:
- 使用 Section 引用（`Section 2` 或 `## 标题`）实现精确导航
- 保持链接相对于当前目录
- 确保链接双向可达

## 6. kebab-case 命名

**原则**: 除 `CLAUDE.md` 和 `README.md` 外，所有文件统一使用 `kebab-case.md` 命名。

**原因**: 命名一致性降低认知负担，避免跨平台（区分大小写 vs 不区分大小写文件系统）的命名冲突。

**示例**:
```
CLAUDE.md              # 例外：Claude Code 框架约定
README.md              # 例外：GitHub 约定
rules/
  api-design.md        # kebab-case
  code-style.md        # kebab-case
  project-structure.md # kebab-case
  tech-stack.md        # kebab-case
project-config.md      # kebab-case
```
