# Skills 开发进阶指导手册：从中级到资深

> **定位**：面向已掌握 SKILL.md 基础语法的中级开发者，系统性提升至资深水平。
>
> **基于**：2,025 个真实 SKILL.md 文件的深度分析（覆盖 Anthropic 官方、ECC、AWS、社区生态），以及官方文档的系统研究。
>
> **互补关系**：本文档聚焦"设计哲学与进阶技术"。基础语法和 frontmatter 字段规格见 `../rules/plugin-dev-spec.md` §3，Agent/Hook/MCP 完整规格见 `../references/component-reference.md`。

---

## §0 速查卡片

### 能力矩阵：中级 vs 资深

| 维度 | 中级开发者 | 资深开发者 |
|------|-----------|-----------|
| **Description** | 能写出可用的 description | 精通 CSO 原则，description 是最重要的设计决策 |
| **结构设计** | 线性指令列表 | 选择合适的设计模式，渐进披露 |
| **上下文管理** | 把所有内容塞进 SKILL.md | 理解 2% 上下文预算，精准控制 token 开销 |
| **高级特性** | 基础 frontmatter 使用 | context fork、Skill-scoped Hooks、预处理器 |
| **质量保证** | 手动测试"能用就行" | RED-GREEN-REFACTOR + Eval-Driven Development |
| **防御性设计** | 信任 Claude 会遵循指令 | 设计合理化预防表，预判绕过行为 |
| **系统思维** | 关注单个 Skill | 考虑 Skill 间协作、与 Commands/Agents 的分工 |

### SKILL.md 完整 frontmatter 字段速查

| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `name` | string | 显示名称 | 目录名 |
| `description` | string | **触发条件描述**——Claude 据此判断是否自动调用 | — |
| `argument-hint` | string | 自动补全时的参数提示 | — |
| `allowed-tools` | string | 激活时免确认的工具，逗号分隔 | — |
| `model` | enum | `sonnet` / `opus` / `haiku` | 继承父级 |
| `disable-model-invocation` | bool | `true` = 仅用户可调用 | `false` |
| `user-invocable` | bool | `false` = 从 `/` 菜单隐藏 | `true` |
| `context` | enum | `fork` = 在子 agent 上下文中运行 | 主上下文 |
| `agent` | string | 当 `context: fork` 时使用的 agent 类型 | — |
| `hooks` | object | 作用域为此 Skill 的 Hook 配置 | — |

### 设计模式选择决策树

```
需要构建什么样的 Skill？
├─ 根据条件选择不同行为？ → Router/Decision Tree（§3.1）
├─ 验证某物是否符合标准？ → Checklist/Verification（§3.2）
├─ 按步骤完成复杂任务？ → Procedural Workflow（§3.3）
├─ 提供领域知识参考？ → Reference/Knowledge Base（§3.4）
├─ 协调外部工具执行？ → Tool Integration（§3.5）
├─ 生成创意内容？ → Creative/Generative（§3.6）
├─ 跨会话/多阶段编排？ → Orchestration（§3.7）
└─ 内容庞大需分层展示？ → Progressive Disclosure（§3.8）
```

---

## §1 Skills 核心机制深度解析

### 1.1 三级加载架构

Claude Code 对 Skill 的处理分为三个层级，理解这一点是资深开发者的基础：

```
Level 1: Metadata（始终加载）
  └─ frontmatter 中的 name + description
  └─ 用于路由决策：Claude 读取所有可用 Skill 的 description，决定是否激活

Level 2: SKILL.md 全文（按需加载）
  └─ Claude 决定激活后，读取完整 SKILL.md 内容
  └─ 包括指令、示例、流程定义

Level 3: 支撑资源（按引用加载）
  └─ SKILL.md 中引用的外部文件（procedures、templates、scripts）
  └─ 通过 ${CLAUDE_SKILL_DIR} 定位相对路径
```

**关键洞察**：Level 1 的 description 是**唯一**影响路由的信息。写得好不好直接决定 Skill 能否被正确触发。这就是为什么 §2 整节专门讲 Description 工程学。

### 1.2 上下文预算机制

Skill 内容被注入 Claude 的上下文窗口时，受到严格的预算限制：

- **预算上限**：上下文窗口的 **2%**，fallback 为 **16K tokens**
- **计算方式**：取 `min(context_window * 0.02, 16384)` tokens
- **超出处理**：内容被截断，尾部丢失

**资深开发者的做法**：

```
错误：把 500 行的完整编码规范塞进 SKILL.md
正确：SKILL.md 保留核心流程（~100 行），详细规范拆到 procedures 文件
```

**token 估算经验法则**：
- 英文约 4 字符 = 1 token
- 中文约 1.5 字符 = 1 token
- 一个结构化的 SKILL.md（含 frontmatter、流程、示例）通常在 200-400 行
- 超过 500 行时应考虑拆分

### 1.3 优先级层次

当多个来源提供了同名或冲突的 Skill 时，Claude Code 按以下优先级解析：

```
Enterprise Managed Settings（最高）
  ↓
Personal Skills（~/.claude/skills/）
  ↓
Project Skills（.claude/skills/）
  ↓
Plugin Skills（plugin/skills/）（最低）
```

**实战意义**：
- Plugin Skill 的 description 中不要包含过于通用的触发词，避免与用户个人/项目级 Skill 冲突
- 项目级 Skill 可以"覆盖" Plugin Skill 的行为

### 1.4 Skill vs Command vs Agent 的关系与分工

| 维度 | Skill | Command | Agent |
|------|-------|---------|-------|
| **触发方式** | Claude 自动 + `/skill-name` | 仅 `/command-name` | `Agent()` 调用或 `context: fork` |
| **上下文** | 注入主对话 | 注入主对话 | 独立上下文（fork） |
| **适用场景** | 行为修改、知识注入 | 用户主动操作 | 隔离执行、长时任务 |
| **可自动触发** | 是（靠 description） | 否 | 否（除非 Skill 配 `context: fork`） |
| **frontmatter `name`** | 可选 | **无**（名称由文件名决定） | **必填** |
| **典型模式** | 编码规范、工作流指导 | 项目初始化、审计报告 | 代码审查、测试运行 |

**选择原则**：
- 需要 Claude 自动识别场景并激活 → **Skill**
- 需要用户明确主动触发 → **Command**
- 需要独立上下文或长时间运行 → **Agent**（或 Skill + `context: fork`）

---

## §2 Description 工程学（CSO 原则）

### 2.1 为什么 description 是最关键的设计决策

在 2,025 个分析的 Skill 中，**description 质量与 Skill 实际效果的相关性最高**。一个完美的 SKILL.md 正文配上糟糕的 description，等于一个从不被触发的死代码。

description 的消费者是 **Claude 的路由逻辑**，不是人类用户。它的唯一职责是帮助 Claude 回答："当前用户的请求，是否应该激活这个 Skill？"

### 2.2 CSO 原则详解

CSO（Condition-only Summary for Orchestration）是本项目提炼的 description 编写核心原则：

**只写"何时触发"，绝不写"做什么"。**

#### 为什么不能写"做什么"

当 description 中包含行为描述时，会导致两个问题：

**问题 1：Claude 跳过读完整 SKILL.md**

```yaml
# 错误示范
description: >
  Generates .claude/ directory structure, copies preset templates,
  runs validation scripts, and outputs a quality report.

# Claude 的反应：
# "我已经从 description 知道该做什么了，不需要读完整 SKILL.md"
# → 跳过了 SKILL.md 中的关键约束和边界条件
```

**问题 2：触发不精确**

```yaml
# 错误示范——过于模糊
description: "Handles project initialization tasks"
# → 任何提到"初始化"的请求都会触发，误报率高

# 错误示范——过于具体
description: "Use when user types exactly 'init my project'"
# → 只有精确匹配才触发，漏报率高
```

#### CSO 正确写法

```yaml
# 正确示范
description: >
  Activate when: the project has no .claude/ directory, the existing .claude/
  seems incomplete or low-quality, or the user expresses that Claude Code
  "doesn't understand" their project.

  Also activate for Chinese-speaking users who mention: 初始化上下文,
  配置 Claude, Claude 不理解项目.
```

**模式解析**：
1. 以 "Activate when" / "Use when" 开头
2. 列出具体的触发条件（环境状态 + 用户意图）
3. 包含多语言关键词（如适用）
4. 不描述 Skill 会做什么

### 2.3 三种 description 哲学对比

通过分析生态中的 Skill，可以归纳出三种 description 编写哲学：

| 哲学 | 特征 | 优点 | 缺点 | 适用场景 |
|------|------|------|------|---------|
| **Trigger-Phrase** | 列出具体的触发短语/关键词 | 精确触发，低误报 | 可能漏报近义表达 | 领域明确的 Skill |
| **Capability** | 描述 Skill 的能力和领域 | 触发范围广 | 易误触发，Claude 可能跳过正文 | 通用工具类 Skill |
| **Pushy** | 强制要求 Claude"必须使用" | 确保激活 | 破坏自然路由，与其他 Skill 冲突 | 极少数关键流程 |

**资深选择**：优先使用 **Trigger-Phrase**，在触发词列表中覆盖多种表达方式（包括多语言）。仅在工作流级 Skill 中谨慎使用 Pushy。

### 2.4 双语 description 设计模式

```yaml
# 模式 A：主语言 + 关键词补充（推荐）
description: >
  Use when user wants to initialize Claude context for a new project,
  set up .claude/ directory, or improve AI code generation quality.
  Also activate for: 初始化上下文, 配置 Claude, 提升 AI 代码质量.

# 模式 B：条件矩阵
description: >
  Activate when ANY of these conditions are met:
  - EN: "init context", "setup claude", "project doesn't understand"
  - ZH: "初始化上下文", "配置 Claude", "Claude 不理解项目"
  - Signal: no .claude/ directory exists in current project
```

### 2.5 description 调优方法论

**Step 1：写初稿**——列出 3-5 个最典型的触发场景

**Step 2：验证覆盖度**——用以下 prompt 模板测试：
```
假设你是 Claude Code 的路由逻辑。以下是一个 Skill 的 description：
[你的 description]

用户说了以下内容，你会激活这个 Skill 吗？（回答 Yes/No + 原因）
1. [应该触发的场景]
2. [不应该触发的场景]
3. [边界场景]
```

**Step 3：迭代**——根据测试结果调整触发词和条件表述

**Step 4：防冲突检查**——确保 description 与同一项目/Plugin 中其他 Skill 的触发条件不重叠

---

## §3 八大设计模式

### 3.1 Router/Decision Tree（路由决策型）

**适用场景**：根据环境状态或用户意图，选择不同的执行路径。

**结构模板**：

```markdown
# [Skill 名称]

## Core Logic

When activated, follow this decision flow:

1. Check [环境条件 A]
2. Check [环境条件 B]
3. Route to the appropriate path:
   - **条件 A 成立** → Path A
   - **条件 B 成立** → Path B
   - **其他** → Path C

## Path A: [路径名]
[具体行为指令]

## Path B: [路径名]
[具体行为指令]

## Path C: [路径名]
[具体行为指令]
```

**真实案例**：本项目的 `context-setup` Skill 就是典型的路由决策型——检测 `.claude/` 是否存在，路由到"创建"或"审计"路径。

**反模式**：把所有路径的行为混在一起，不明确标注条件分支。Claude 在长上下文中容易"混合"不同路径的指令。

### 3.2 Checklist/Verification（检查验证型）

**适用场景**：验证代码、配置或流程是否符合特定标准。

**结构模板**：

```markdown
# [验证 Skill 名称]

## Verification Checklist

Run through each check sequentially. Report findings.

### Check 1: [检查项名称]
- **What to check**: [具体检查内容]
- **Pass criteria**: [通过标准]
- **Fail action**: [不通过时的建议]

### Check 2: [检查项名称]
...

## Output Format
[报告模板]
```

**真实案例**：ECC 的 `verification-loop` Skill——在完成代码后自动运行 lint、typecheck、test，输出结构化报告。

**反模式**：检查项之间有隐式依赖但未标注。例如"先检查构建成功"应该在"检查测试通过"之前。

### 3.3 Procedural Workflow（流程工作流型）

**适用场景**：需要按严格顺序执行多个步骤的复杂任务。

**结构模板**：

```markdown
# [工作流 Skill 名称]

## Workflow

### Phase 1: [阶段名称]
**Gate**: [进入条件]
1. [步骤 1]
2. [步骤 2]
**Exit criteria**: [完成标准]

### Phase 2: [阶段名称]
**Gate**: Phase 1 完成
...

## Iron Rules（不可违反的铁律）
- [铁律 1]
- [铁律 2]
```

**真实案例**：ECC 的 `tdd-workflow` Skill——强制 RED → GREEN → REFACTOR 循环，每个阶段有明确的进入和退出条件。

**资深技巧**：用 "Iron Rules" 或 "Non-negotiable" 标记不可跳过的步骤。Claude 在压力下倾向于"合理化"跳过步骤，铁律标记能显著降低这种行为。

**反模式**：步骤过多（>15 步）。超过一定复杂度应拆分为多个 Skill 或使用 Orchestration 模式。

### 3.4 Reference/Knowledge Base（知识库参考型）

**适用场景**：提供领域知识、API 参考或编码规范，让 Claude 在生成代码时参照。

**结构模板**：

```markdown
# [知识库 Skill 名称]

## Core Principles
[3-5 条核心原则]

## Pattern Library

### Pattern: [模式名称]
**When to use**: [适用场景]
**Example**:
```[语言]
[代码示例]
```
**Anti-pattern**:
```[语言]
[错误示例]
```

### Pattern: [模式名称]
...
```

**真实案例**：ECC 的 `coding-standards` Skill——提供 TypeScript/React 编码标准，配以正确和错误的代码示例对比。

**资深技巧**：代码示例是知识库型 Skill 中最有效的部分。Claude 对"用示例展示"的响应远好于"用文字描述"。

**反模式**：知识库过大（>300 行）。应将不同领域的知识拆分为独立 Skill，或使用 Progressive Disclosure 模式。

### 3.5 Tool Integration（工具集成型）

**适用场景**：协调外部工具（MCP Server、shell 命令、API）完成任务。

**结构模板**：

```markdown
# [工具集成 Skill 名称]

## Available Tools
- [工具 1]: [用途说明]
- [工具 2]: [用途说明]

## Tool Selection Logic
If [条件 A] → use [工具 1]
If [条件 B] → use [工具 2]

## Integration Flow
1. [工具调用步骤]
2. [结果处理步骤]

## Error Handling
- [工具 1] fails → [降级策略]
```

**真实案例**：AWS Skills 中的 `bedrock-agent` Skill——协调 MCP Server 查询 AWS 文档，结合 context fork 在隔离环境中执行。

**反模式**：硬编码工具名而不提供降级策略。MCP Server 可能未安装或不可用。

### 3.6 Creative/Generative（创意生成型）

**适用场景**：生成文档、报告、代码框架等创意内容。

**结构模板**：

```markdown
# [生成型 Skill 名称]

## Output Specification
- **Format**: [输出格式]
- **Tone**: [风格基调]
- **Length**: [预期长度]

## Generation Template
[输出模板，用占位符标注可变部分]

## Quality Criteria
- [质量标准 1]
- [质量标准 2]

## Example Output
[一个完整的输出示例]
```

**真实案例**：Anthropic 官方的 `doc-coauthoring` Skill——根据代码变更自动生成文档草稿，有明确的格式和质量标准。

**反模式**：没有提供示例输出。Claude 对"照着模板生成"的一致性远好于"自行发挥"。

### 3.7 Orchestration/Multi-Session（编排调度型）

**适用场景**：跨多个工具、多个阶段、甚至多个会话的复杂编排。

**结构模板**：

```markdown
# [编排型 Skill 名称]

## Architecture
[阶段关系图]

## Session 1: [阶段名称]
**Input**: [输入]
**Process**: [处理逻辑]
**Output**: [输出，传递给下一阶段]
**Persistence**: [持久化到哪里]

## Session 2: [阶段名称]
**Resume from**: [从哪里恢复]
...

## State Management
[状态存储和恢复机制]
```

**真实案例**：ECC 的 `continuous-learning` Skill——跨会话学习用户编码模式，通过 Hook 在会话结束时持久化学习结果。

**注意**：这是最复杂的模式，通常需要结合 `context: fork`、Hooks 和外部状态存储。中级开发者应先掌握前六种模式。

### 3.8 Progressive Disclosure（渐进披露型）

**适用场景**：Skill 内容庞大，需要按需分层展示以节省上下文预算。

**结构模板**：

```markdown
# [Skill 名称]

## Quick Reference（始终加载）
[最高频使用的核心信息，<50 行]

## Detailed Procedures
For the full procedure, read `${CLAUDE_SKILL_DIR}/procedures.md`

## Reference Tables
For the complete reference, read `${CLAUDE_SKILL_DIR}/reference-tables.md`
```

**核心思想**：SKILL.md 正文只放"做什么"（路由和决策），详细的"怎么做"拆分到支撑文件。

**文件组织**：

```
skills/
  my-skill/
    SKILL.md                 # 核心路由逻辑（<200 行）
    procedures.md            # 详细步骤（按需读取）
    reference-tables.md      # 参考表格（按需读取）
    scripts/                 # 辅助脚本
    templates/               # 输出模板
```

**拆分阈值**：SKILL.md 超过约 200 行时，应考虑拆分。超过 500 行时**必须**拆分——否则会触及上下文预算限制。

**反模式**：把所有内容放在 SKILL.md 中不拆分，导致内容被截断且关键指令丢失。

---

## §4 高级技术

### 4.1 Context Forking 与 Agent 委派

`context: fork` 是 Skill 的高级特性，让 Skill 在独立的子 agent 上下文中运行，而不是注入主对话。

```yaml
---
name: Code Review
description: Use when user asks for a code review of recent changes
context: fork
agent: code-reviewer
allowed-tools: Read, Grep, Glob, Bash
---
```

**适用场景**：
- Skill 会产生大量中间输出（搜索结果、分析报告），不想污染主对话
- 需要特定工具权限集，不同于主对话
- 长时间运行的任务

**不适用场景**：
- 需要与用户频繁交互的 Skill
- 简单的知识注入或行为修改

**关键限制**：fork 的子 agent 不能再嵌套调用 Agent 工具。

### 4.2 Skill-Scoped Hooks

Hooks 可以限定在特定 Skill 的作用域内，只在该 Skill 激活时生效：

```yaml
---
name: Safe Deployment
description: Use when deploying to production environments
hooks:
  PreToolUse:
    - matcher:
        tool_name: "Bash"
      hooks:
        - type: prompt
          prompt: >
            The user is deploying to production. Verify this bash command
            is safe and does not contain destructive operations like
            rm -rf, DROP TABLE, or force push.
          timeout: 15
  Stop:
    - hooks:
        - type: command
          command: "echo 'Deployment skill session ended' >> deploy.log"
---
```

**应用场景**：
- **安全门**：在 Skill 执行期间拦截危险操作
- **审计日志**：记录 Skill 执行过程中的关键动作
- **格式校验**：确保 Write/Edit 输出符合特定格式

**与全局 Hooks 的关系**：Skill-scoped Hooks 与全局 `settings.json` 中的 Hooks 互补执行——全局做通用检查，Skill 级做精细控制。

### 4.3 预处理器动态上下文注入

SKILL.md 中的 `` !`command` `` 语法会在 Skill 加载时执行 shell 命令，并将输出替换到内容中：

```markdown
## Current Project Context

The project uses the following dependencies:
!`cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('\n'.join(f'- {k}: {v}' for k,v in d.get('dependencies',{}).items()))"`

Current git branch: !`git branch --show-current`
Last commit: !`git log -1 --oneline`
```

**适用场景**：
- 注入动态的项目状态（依赖版本、git 分支、环境变量）
- 读取外部配置文件的关键字段
- 获取运行时信息

**注意**：
- 命令在 Skill **加载时**执行，不是在后续对话中
- 命令失败时输出为空字符串，不会阻断 Skill 加载
- 避免执行耗时长的命令（会延迟 Skill 加载）

### 4.4 字符串替换系统

| 变量 | 说明 | 示例 |
|------|------|------|
| `$ARGUMENTS` | 用户在 `/skill-name` 后输入的全部参数 | `/review src/` → `$ARGUMENTS` = `"src/"` |
| `$0` | 第一个参数 | `/deploy staging` → `$0` = `"staging"` |
| `$1` | 第二个参数 | `/deploy staging v2` → `$1` = `"v2"` |
| `${CLAUDE_SKILL_DIR}` | Skill 目录的绝对路径 | 引用支撑文件 |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin 根目录的绝对路径 | 引用 Plugin 级资源 |

**实战用法**：

```markdown
## Task

Review the code in: $ARGUMENTS

If no path is specified, review all staged changes.

For the detailed review checklist, read `${CLAUDE_SKILL_DIR}/review-checklist.md`.
```

### 4.5 权限控制三层体系

```
Layer 1: allowed-tools（Skill frontmatter）
  → 白名单：列出的工具免确认执行
  → 示例：allowed-tools: Read, Grep, Glob

Layer 2: Hook PreToolUse（Skill-scoped 或全局）
  → 拦截层：对允许的工具做更细粒度的检查
  → 示例：允许 Bash 但拦截 rm -rf

Layer 3: User Permission Mode
  → 最终裁决：用户的全局权限设置始终优先
  → 即使 Skill 允许 Write，用户设了只读也会被拦截
```

**设计原则**：**最小权限**。只在 `allowed-tools` 中列出 Skill 真正需要的工具。不要图方便写 `allowed-tools: *`。

### 4.6 支撑文件架构

当 Skill 复杂到需要拆分时，推荐以下目录结构：

```
skills/
  my-complex-skill/
    SKILL.md                    # 入口：路由逻辑 + 核心流程
    procedures.md               # 详细步骤文档
    reference.md                # 参考表格和规范
    scripts/
      validate.sh               # 辅助脚本
      generate.py               # 生成脚本
    templates/
      output-template.md        # 输出模板
```

**引用方式**：

```markdown
# 在 SKILL.md 中
For the detailed validation procedure, read `${CLAUDE_SKILL_DIR}/procedures.md`.
Run the validation script: `${CLAUDE_SKILL_DIR}/scripts/validate.sh`
```

**脚本黑箱哲学**：辅助脚本应该是"黑箱"——SKILL.md 告诉 Claude 何时运行、传什么参数、如何解读输出，但不需要解释脚本内部逻辑。这节省了上下文预算，也减少了 Claude 试图"改进"脚本的风险。

### 4.7 Extended Thinking 激活

通过在 SKILL.md 中使用特定关键词，可以引导 Claude 使用更深层的推理：

```markdown
## Analysis Phase

Think deeply about the architecture implications before proceeding.

Analyze the codebase structure thoroughly — consider all dependencies,
potential side effects, and edge cases before making changes.
```

提示 Claude 进行深度思考的关键词（非官方但实践验证有效）：`think deeply`、`think step by step`、`analyze thoroughly`、`consider carefully`。但请注意，这些是引导性的，不是确定性的 API。

---

## §5 指令编写艺术

### 5.1 祈使句 vs 第二人称

```markdown
# 祈使句（推荐）——简洁、直接
Run the linter before committing.
Check for breaking changes in the API.

# 第二人称——解释性更强，适合复杂逻辑
You should first verify that all tests pass. If any test fails,
you must fix the issue before proceeding to the next step.
```

**选择原则**：简单指令用祈使句，需要条件说明的复杂逻辑用第二人称。

### 5.2 决策树优于线性指令

```markdown
# 线性指令（脆弱）
1. Read the config file
2. If it's JSON, parse it with jq
3. If it's YAML, parse it with yq
4. If it's TOML, parse it with tomlq
5. Extract the version field
6. Compare with the expected version

# 决策树（健壮）
1. Detect config format:
   - `*.json` → parse with jq
   - `*.yaml` / `*.yml` → parse with yq
   - `*.toml` → parse with tomlq
   - Other → report unsupported format and stop
2. Extract the `version` field from parsed output
3. Compare: actual vs expected
```

**为什么**：Claude 处理分支逻辑时，决策树格式比线性列表更不容易"跳步"或"混淆路径"。

### 5.3 "解释 Why 而非仅说 What"原则

```markdown
# 仅说 What（Claude 可能"合理化"跳过）
Never use console.log in production code.

# 解释 Why（Claude 理解原因后更可能遵守）
Never use console.log in production code — it leaks internal state
to browser DevTools, may contain PII, and degrades performance
through synchronous I/O.
```

当 Claude 理解规则的**原因**时，它在边界场景中的判断力显著提升。

### 5.4 负面约束的有效表达

```markdown
# 弱约束（Claude 倾向于忽略）
Try not to modify files outside the src/ directory.

# 中等约束
Do not modify files outside the src/ directory.

# 强约束（资深做法）
## Non-negotiable Rules
- **NEVER** modify files outside `src/`. If a change seems necessary
  outside this boundary, STOP and ask the user for explicit permission.
- Justification: Files outside src/ are managed by CI/CD pipeline
  and manual changes will be overwritten on next deploy.
```

**约束强度工具箱**：

| 强度 | 标记方式 | 适用场景 |
|------|---------|---------|
| 建议 | "Prefer...", "Consider..." | 风格偏好 |
| 规则 | "Do not...", "Always..." | 常规约束 |
| 铁律 | "NEVER", "Non-negotiable", "## Iron Rules" | 不可违反的安全/架构约束 |

### 5.5 示例响应的模板设计

```markdown
## Example Responses

**Scenario 1 — [场景描述]:**

> [完整的预期响应]

**Scenario 2 — [场景描述]:**

> [完整的预期响应]
```

**为什么重要**：示例响应是 Skill 中**最有效的行为校准工具**。Claude 会非常精确地模仿示例的格式、语气和内容结构。提供 2-3 个覆盖不同场景的示例即可。

### 5.6 多环境适配

Skill 在以下环境中的表现可能不同：
- **Claude Code CLI**：完整工具访问
- **Claude.ai Web**：无文件系统访问
- **Claude Cowork / IDE 集成**：部分工具限制

如果 Skill 需要跨环境工作，使用条件检测：

```markdown
## Environment Adaptation

If file system tools (Read, Write, Bash) are available:
  → Execute the full workflow with file operations

If file system tools are NOT available:
  → Provide the instructions as text output for the user to execute manually
```

---

## §6 反模式与陷阱

### 6.1 七大反模式

#### 反模式 1：Description 泄露行为（Leaky Description）

```yaml
# 错误
description: >
  Validates code quality by running ESLint, checking TypeScript types,
  running unit tests, and generating a coverage report.

# 正确
description: >
  Use when code changes are complete and ready for quality verification,
  or when the user asks to check code quality, run tests, or validate changes.
```

**危害**：Claude 根据 description 直接行动，跳过 SKILL.md 中的详细流程和约束条件。

#### 反模式 2：内容膨胀（Context Bloat）

```markdown
# 错误：500+ 行的 SKILL.md，包含完整的编码规范、API 参考、示例代码库
# → 触及 2% 上下文预算限制，尾部内容被截断

# 正确：SKILL.md ~150 行核心流程，详细内容拆分到支撑文件
```

**危害**：关键指令可能在截断点之后，导致 Skill 行为不完整。

#### 反模式 3：万能 Skill（God Skill）

```yaml
# 错误
description: >
  Use for all coding tasks including writing, reviewing, testing,
  deploying, documenting, and debugging code.
```

**危害**：触发条件过宽导致不该激活时激活，且单个 Skill 无法高质量处理所有场景。

**修复**：拆分为多个职责单一的 Skill。

#### 反模式 4：无示例的抽象指令（Abstract Without Examples）

```markdown
# 错误
Write code that follows best practices and is well-structured.

# 正确
## Code Standards

### Naming
- Functions: camelCase, verb prefix (`getUserData`, `validateInput`)
- Constants: UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`)

### Example
```typescript
// Good
function getUserById(id: string): Promise<User> { ... }

// Bad
function get(id: string): Promise<any> { ... }
```
```

**危害**：抽象指令的可解释空间太大，Claude 会按自己的"理解"执行，不一定符合你的预期。

#### 反模式 5：指令冗余与矛盾（Redundancy & Contradiction）

```markdown
# 错误：同一 Skill 中重复且矛盾的指令
Always use async/await for asynchronous operations.
...
（200 行后）
Use Promises with .then() for better readability.
```

**危害**：Claude 可能选择任一指令执行，行为不可预测。

**修复**：SSoT 原则——每条规则只出现一次。

#### 反模式 6：过度工程化（Over-Engineering）

```yaml
# 错误：一个简单的 greeting Skill 配了 context: fork + hooks + 3 个支撑文件
---
context: fork
agent: greeting-agent
hooks:
  PreToolUse:
    - matcher:
        tool_name: "Write"
      hooks:
        - type: prompt
          prompt: "Verify greeting is appropriate"
---
```

**信号**：如果你的 Skill 的复杂度超过了它要解决的问题的复杂度，那就是过度工程化。

**修复**：从最简单的实现开始，只在遇到实际问题时增加复杂度。

#### 反模式 7：忽视合理化风险（Rationalization Blindness）

```markdown
# 脆弱的规则——Claude 容易"合理化"绕过
Run all tests before committing.

# 防御性规则——包含合理化预防
## Iron Rule: Pre-Commit Testing
Run ALL tests before committing. No exceptions.

Common rationalizations to reject:
- "The change is too small to need tests" → Run tests anyway.
- "Only docs changed" → Run tests anyway. Docs may contain code examples.
- "Tests are slow, I'll run them later" → Run tests NOW. Slow tests
  are a separate problem to solve, not a reason to skip.
```

**为什么关键**：Claude 是一个语言模型，它会寻找"合理"的理由来简化任务。资深开发者会预判这些绕过路径并提前封堵。

### 6.2 常见 frontmatter 错误

| 错误 | 原因 | 修复 |
|------|------|------|
| Command 中写了 `name` 字段 | Command 名由文件名决定 | 删除 `name` |
| `allowed-tools` 写成数组 | 应为逗号分隔的字符串 | `"Read, Write, Bash"` |
| `disable-model-invocation` 拼错 | frontmatter 解析器不报错 | 注意拼写 |
| `context: "fork"` 加了引号 | YAML enum 不需要引号 | `context: fork` |
| Hooks 配置格式错误 | 嵌套结构容易出错 | 参照 `component-reference.md` |

---

## §7 质量保证方法论

### 7.1 RED-GREEN-REFACTOR 验证法

这是本项目推荐的 Skill 质量验证方法（详见 `../references/component-reference.md` "Skill RED-GREEN-REFACTOR 质量验证法"）：

**Step 1: RED（基线观测）**

禁用目标 Skill，观察 Claude 的默认行为：

```
1. 在不启用 Skill 的环境中提交请求
2. 记录 Claude 的行为与期望行为的偏差
3. 格式："无 Skill 时 Claude 做了 [X]，期望行为是 [Y]"
4. 至少用 2 个不同复杂度的场景观测
```

**Step 2: GREEN（最小修正）**

针对观测到的偏差写最小 Skill：

```
1. 一条规则修正一个偏差
2. 不做预防性规则——只解决已观测到的问题
3. 启用 Skill 后确认偏差被修正
```

**Step 3: REFACTOR（漏洞补充）**

用不同复杂度的场景压力测试：

```
1. Small：简单、明确的请求
2. Medium：有边界条件的请求
3. Large：复杂、多步骤的请求
4. 发现新偏差 → 补充规则或合理化预防表
```

### 7.2 Eval-Driven Development（评估驱动开发）

比 RED-GREEN-REFACTOR 更系统化的方法，适合高频使用的关键 Skill：

**Step 1：定义评估用例集**

```yaml
eval_cases:
  - name: "basic_trigger"
    input: "帮我初始化项目上下文"
    expected:
      - skill_activated: true
      - path: "A"  # 无 .claude/ 目录时走 Path A

  - name: "should_not_trigger"
    input: "帮我写一个排序算法"
    expected:
      - skill_activated: false

  - name: "chinese_trigger"
    input: "Claude 老是写错代码，怎么办"
    expected:
      - skill_activated: true
      - path: "B" or "C"
```

**Step 2：运行评估**

```
1. 对每个 eval case 运行 Claude
2. 对比实际行为与预期行为
3. 计算通过率：通过数 / 总数
4. 目标：关键 Skill 通过率 ≥ 90%
```

**Step 3：迭代优化**

```
失败用例分析 → 调整 description 或 SKILL.md → 重新运行评估 → 循环
```

### 7.3 基准对比方法

对于行为修改类 Skill，最直观的评估方式是 with-skill vs baseline 对比：

```
1. 准备 3 个代表性任务
2. 分别在启用/禁用 Skill 的环境中执行
3. 对比输出的质量维度：
   - 格式一致性（0-5 分）
   - 规范遵守率（0-5 分）
   - 输出完整性（0-5 分）
4. 总分差异 ≥ 3 分 = Skill 有效
```

### 7.4 Description 质量评估清单

| # | 检查项 | 通过标准 |
|---|--------|---------|
| 1 | 是否以 "Use when" / "Activate when" 开头？ | 是 |
| 2 | 是否只描述触发条件，不描述行为？ | 是 |
| 3 | 是否包含具体的触发关键词？ | 至少 3 个 |
| 4 | 是否覆盖多种表达方式？ | 至少 2 种 |
| 5 | 是否与其他 Skill 的 description 不冲突？ | 是 |
| 6 | 是否包含多语言关键词（如适用）？ | 是 |
| 7 | 长度是否适中（50-200 词）？ | 是 |

---

## §8 架构决策指南

### 8.1 何时用 Skill vs Command vs Agent

```
需要做的事情
├─ Claude 能自动判断何时需要？
│  ├─ 是 → Skill
│  └─ 否 → 用户必须主动触发？
│     ├─ 是 → Command
│     └─ 需要独立运行环境？ → Agent
├─ 需要工具权限控制？
│  ├─ 简单白名单就够 → Skill (allowed-tools)
│  └─ 需要自定义工具集 → Agent (tools)
└─ 执行时间长？
   ├─ <30 秒 → Skill 或 Command
   └─ >30 秒 → Agent（独立上下文不占主对话）
```

### 8.2 何时启用 context: fork

```
你的 Skill 是否：
├─ 产生大量中间搜索/分析输出？ → 考虑 fork
├─ 需要限制工具集（不同于主对话）？ → 考虑 fork
├─ 运行时间超过 30 秒？ → 考虑 fork
├─ 需要与用户频繁交互？ → 不要 fork
├─ 只是注入知识/修改行为？ → 不要 fork
└─ 是简单的检查/验证？ → 不要 fork
```

**经验法则**：如果 Skill 的主要价值在于"修改 Claude 的行为"（如编码规范），不要 fork。如果主要价值在于"执行独立任务"（如代码审查），考虑 fork。

### 8.3 何时需要 Hooks

```
你需要保证的约束：
├─ 绝对不可违反（安全/合规）？ → Hook (command, exit 2)
├─ 需要语义理解来判断？ → Hook (prompt/agent)
├─ Claude "合理化"跳过的风险高？ → Hook 补强
├─ 只是建议性的最佳实践？ → Skill 指令即可
└─ 需要审计日志？ → Hook (command, async)
```

### 8.4 单文件 vs 多文件决策

```
你的 SKILL.md 行数：
├─ <100 行 → 单文件即可
├─ 100-200 行 → 单文件，但考虑是否有拆分空间
├─ 200-500 行 → 应该拆分（procedures + reference）
└─ >500 行 → 必须拆分（会触及上下文预算限制）
```

### 8.5 Plugin 内 vs 项目级 vs 个人级选择

| 放置位置 | 路径 | 适用场景 | 分享范围 |
|---------|------|---------|---------|
| Plugin 内 | `plugin/skills/` | 通用能力，随 Plugin 分发 | 所有安装者 |
| 项目级 | `.claude/skills/` | 项目特定的工作流和规范 | 项目团队 |
| 个人级 | `~/.claude/skills/` | 个人偏好和工作习惯 | 仅自己 |

**选择原则**：
- 能通用化的 → Plugin
- 与项目架构紧耦合的 → 项目级
- 个人工作习惯的 → 个人级

---

## §9 资深开发者思维模型

### 9.1 从"写指令"到"设计系统"的思维转变

中级开发者把 Skill 视为"一组指令"。资深开发者把 Skill 视为"一个系统设计问题"。

| 中级思维 | 资深思维 |
|---------|---------|
| "我要告诉 Claude 做什么" | "我要设计一个让 Claude 可靠地做出正确决策的系统" |
| "description 是描述功能" | "description 是路由策略" |
| "规则越多越好" | "规则越少越精准越好——每条规则都有维护成本" |
| "Skill 写完就行了" | "Skill 需要持续评估和迭代" |
| "合理化是 Claude 的 bug" | "合理化是语言模型的固有特性，需要设计来应对" |

### 9.2 上下文经济学

**核心认知**：token 是稀缺资源。每一行注入上下文的内容都有成本。

```
成本 = 占用的 token 数 × 使用频率 × 会话数
价值 = 行为改善的程度 × 影响范围
ROI  = 价值 / 成本
```

**高 ROI 内容**：
- 精准的 description（几十 token 决定整个 Skill 是否被正确触发）
- 代码示例（Claude 对示例的响应远好于文字描述）
- 铁律标记（几个词的标记显著降低合理化风险）

**低 ROI 内容**：
- 冗长的背景解释
- 可以通过支撑文件按需加载的参考表
- Claude 本来就会做对的事情的指令

### 9.3 可组合性设计

资深开发者设计的 Skill 可以与其他 Skill、Commands、Agents 协同工作：

```markdown
## Integration Points

This skill works well with:
- `/audit-context` command → runs after this skill completes
- `coding-standards` skill → provides the standards this skill verifies
- `code-reviewer` agent → can be used for deep review (context: fork)
```

**设计原则**：
- 每个 Skill 做好一件事（Unix 哲学）
- 定义清晰的输入/输出接口
- 通过 Skill 间的引用关系建立工作流

### 9.4 防御性编程

**合理化预防（Rationalization Prevention）**是资深 Skill 开发者的核心能力：

```markdown
## Rationalization Prevention Table

| Claude 可能的合理化 | 预设回应 |
|-------------------|---------|
| "这个改动太小，不需要测试" | 任何改动都需要测试。小改动可能有大影响。 |
| "用户说了要快，所以跳过审查" | 速度不是跳过质量检查的理由。快速地做错比慢速做对更浪费时间。 |
| "这个文件不在范围内，但改一下更好" | 不要修改范围外的文件。如果觉得需要，先请求用户许可。 |
```

**关键洞察**：你不是在与一个"故意偷懒"的系统对抗，而是在为一个"总是寻找最合理路径"的系统设置正确的护栏。理解这一点，防御性设计就不再是对抗，而是协作。

### 9.5 社区贡献与生态意识

资深开发者不只是写好自己的 Skill，还关注生态健康：

- **复用优先**：检查社区是否已有类似 Skill，避免重复造轮子
- **质量标杆**：遵循社区规范（如本项目的 CSO 原则），让自己的 Skill 成为他人的参考
- **反馈循环**：使用他人的 Skill 时提供建设性反馈
- **生态意识**：理解 Skill 优先级层次，避免与其他层级的 Skill 产生冲突

---

## 附录

### 附录 A：完整 frontmatter 字段参考表

| 字段 | 类型 | 必填 | 说明 | 谁能用 |
|------|------|------|------|--------|
| `name` | string | 否 | 显示名称（省略则用目录名） | Skill |
| `description` | string | 强烈推荐 | 触发条件描述（CSO 原则） | Skill |
| `argument-hint` | string | 否 | 参数提示文本 | Skill |
| `allowed-tools` | string | 否 | 免确认工具白名单，逗号分隔 | Skill, Command |
| `model` | enum | 否 | `sonnet` / `opus` / `haiku` | Skill, Command |
| `disable-model-invocation` | bool | 否 | 禁止 Claude 自动调用 | Skill |
| `user-invocable` | bool | 否 | 是否在 `/` 菜单显示 | Skill |
| `context` | enum | 否 | `fork` = 子 agent 上下文 | Skill |
| `agent` | string | 否 | fork 时使用的 agent 类型 | Skill |
| `hooks` | object | 否 | Skill 级 Hook 配置 | Skill |

> Command frontmatter 中**不应包含 `name` 字段**——Command 名由文件名决定。

### 附录 B：Exemplar Skills 推荐列表

按学习阶段组织的优秀 Skill 参考：

**入门级（掌握基础模式）**：

| Skill | 来源 | 模式 | 学习要点 |
|-------|------|------|---------|
| `context-setup` | 本项目 | Router | CSO description + 三路径路由 + 示例响应 |
| `coding-standards` | ECC | Reference | 代码示例对比 + 多语言覆盖 |

**进阶级（掌握高级技术）**：

| Skill | 来源 | 模式 | 学习要点 |
|-------|------|------|---------|
| `tdd-workflow` | ECC | Procedural | 铁律标记 + 阶段门控 + 合理化预防 |
| `verification-loop` | ECC | Checklist | 多维度检查 + 结构化报告输出 |
| `skill-creator` | Anthropic 官方 | Creative | Meta-skill 设计 + 输出模板 |
| `doc-coauthoring` | Anthropic 官方 | Creative | 协作式生成 + 质量标准 |

**资深级（掌握系统设计）**：

| Skill | 来源 | 模式 | 学习要点 |
|-------|------|------|---------|
| `mcp-builder` | Anthropic 官方 | Tool Integration | MCP Server 集成 + 多工具协调 |
| AWS Skills | AWS 官方 | Orchestration | context fork + Hooks + MCP + 隔离执行 |
| `continuous-learning` | ECC | Orchestration | 跨会话状态 + Hook 持久化 + 模式提取 |

### 附录 C：设计模式速查对照表

| 模式 | 核心结构 | 适用信号 | 复杂度 |
|------|---------|---------|--------|
| Router | if/else 路径 | 需要条件分支 | 低 |
| Checklist | 检查项列表 | 需要验证合规 | 低 |
| Procedural | 阶段 + 门控 | 需要严格顺序 | 中 |
| Reference | 模式库 + 示例 | 需要知识注入 | 低-中 |
| Tool Integration | 工具选择 + 调用 | 需要外部工具 | 中 |
| Creative | 模板 + 质量标准 | 需要内容生成 | 中 |
| Orchestration | 状态 + 多阶段 | 需要跨会话协调 | 高 |
| Progressive Disclosure | 分层 + 按需加载 | 内容量大 | 中 |
