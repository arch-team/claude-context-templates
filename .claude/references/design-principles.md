# 设计原则

> **职责**：Claude Context Templates 模板系统的核心设计原则。
>
> **理论基础**：实现自 [通用信息架构原则](ia-principles.md)。
>
> **跨文档引用**：被 `rules/dev-workflow.md` §2 引用。

## §0 速查卡片

### 原则概览

| # | 原则 | 一句话描述 | IA 映射 |
|---|------|-----------|---------|
| 1 | SSoT | 每个概念只在一个文件中定义 | [IA-6](ia-principles.md) |
| 2 | Section 0 | 规范文件以速查卡片开头 | [IA-8 + IA-5](ia-principles.md) |
| 3 | 分层架构 | 上下文按层级组织，单向依赖 | [IA-1 + IA-2](ia-principles.md) |
| 4 | 依赖矩阵 | 用表格（非散文）表达依赖关系 | [IA-9](ia-principles.md) |
| 5 | 双向链接 | 文档形成可导航的知识网络 | [IA-8](ia-principles.md) |
| 6 | kebab-case | 统一的文件命名约定 | --（项目约定） |

### 应用场景

| 场景 | 相关原则 |
|------|---------|
| 定义新概念 | 1 (SSoT), 5 (链接) |
| 创建规范文件 | 2 (Section 0), 6 (kebab-case) |
| 组织文件/层级 | 3 (分层), 4 (矩阵) |
| 引用其他文档 | 5 (链接), 1 (SSoT) |
| 命名文件 | 6 (kebab-case) |

### 未覆盖的 IA 原则

IA-3、IA-4、IA-7、IA-10、IA-11 未作为命名设计原则，但在项目中隐式应用——见 [第 7 节](#7-未覆盖的-ia-原则)。

---

## 1. 单一真实源 (SSoT)

> 实现 [IA-6 单一权威](ia-principles.md)

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

> 实现 [IA-8 可发现性优先](ia-principles.md) + [IA-5 按需加载](ia-principles.md)

**原则**: 每个规范文件以 Section 0（速查区）开头，包含表格、决策树和速查表。

**原因**: Claude Code 通常只需要快速查找，而非阅读全文。Section 0 以最少的 token 提供高密度信息。

**示例结构**:
```markdown
# 架构规范

> **职责**: 架构模式 SSoT

---

## §0 速查卡片

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

> 实现 [IA-1 单向依赖](ia-principles.md) + [IA-2 抽象分层](ia-principles.md)

**原则**: 上下文按多层组织，层次分明，单向依赖。

**原因**: Claude Code 根据当前目录自动加载对应层级。这避免了规则冲突，并保持上下文聚焦。

### 关键规则

- 层级从全局（抽象）到项目特定（具体）组织
- 依赖方向单向：具体层可引用全局层，反之不可
- 每层可通过相对链接引用其他层

### 跨 Preset 原则 (_common)

`_common/` 提供跨所有 Preset 共享的工程原则（测试、安全、架构、代码质量）。每个 Preset 的规则文件可引用这些公共原则。

**依赖方向**（严格单向）：
- `_common/` 不得引用任何特定 Preset
- Preset 规则可引用 `_common/` 原则

> 本项目的具体层级-目录映射，见 [project-structure.md §2](../rules/project-structure.md)。

## 4. 依赖矩阵

> 实现 [IA-9 认知清晰](ia-principles.md)

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

> 实现 [IA-8 可发现性优先](ia-principles.md)

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

> 项目约定（无 IA 映射）

**原则**: 除 `CLAUDE.md` 和 `README.md` 外，所有文件统一使用 `kebab-case.md` 命名。

**原因**: 命名一致性降低认知负担，避免跨平台（区分大小写 vs 不区分大小写文件系统）的命名冲突。

**示例**:
```
CLAUDE.md              # 例外：Claude Code 框架约定
README.md              # 例外：GitHub 约定
rules/
  principles/
    testing.md         # kebab-case
    architecture.md    # kebab-case
  practices/
    tech-stack.md      # kebab-case
    code-style.md      # kebab-case
project-config.md      # kebab-case
```

## 7. 未覆盖的 IA 原则

以下 [IA 原则](ia-principles.md) 未作为上述命名设计原则，但在项目中隐式应用：

| IA 原则 | 在本项目中的隐式应用 |
|---------|-------------------|
| IA-3 稳定-易变分离 | 规范文件将速查卡片（稳定）与详细内容（可能演变）分离 |
| IA-4 信息分类 | 不同信息类型放在不同目录（rules vs references vs docs） |
| IA-7 确定性分级 | 约束分级为 iron rule / required / recommended |
| IA-10 契约隔离 | 模板变量由独立契约定义（`docs/template-variables.md`） |
| IA-11 单一职责 | 每个文件在头部声明其唯一核心职责 |
