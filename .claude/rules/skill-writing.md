---
paths:
  - "**/skills/**"
  - "**/SKILL.md"
---

# SKILL.md 编写规范

## Skill 模式

开发前先识别模式——决定工作流段与产出段的重心。

| 模式 | 重心 |
|------|------|
| Generator（产出结构化文档） | 模板逐节填充 |
| Reviewer（质量/合规校验） | 检查清单 + P0/P1/P2 分级，不生成新文档 |
| Inversion（信息采集） | 问题清单前置 → 填充模板 |
| Pipeline（多步门控） | 每步独立产出 + 显式继续条件 |
| Tool Wrapper（封装库/框架约定） | references/ 按需加载；无模板无脚本 |

**组合**：采集类 Skill → Inversion + Generator。

## 段落构成与必要性（P0/P1/P2）

完整 8 段（顺序固定）：frontmatter → 用途 → HARD RULES → ANTI-RATIONALIZATION → 启动协议 → 方法论工作流 → 产出生成 → 参考资料。

**默认**：`frontmatter` / `HARD RULES` / `方法论工作流` / `产出生成` 全模式 P0；`ANTI-RATIONALIZATION` 除 Tool Wrapper 外 P0；`启动协议` Inversion 为 P0，其余 P1；`参考资料` Tool Wrapper 为 P0，其余 P1。

**模式专属豁免**：

- **Inversion**（采集类）：`ANTI-RATIONALIZATION` 降为 P1（问题清单已强制信息完整性）
- **Reviewer**：`产出生成` 降为 P2（不生成新文档）
- **Tool Wrapper**：`用途` / `方法论工作流` 降为 P1；`ANTI-RATIONALIZATION` / `启动协议` / `产出生成` 降为 P2；`参考资料` 升为 P0（本模式重心在 references/）

**缺段说明（P1）**：不含某段时，在该段位置写一行说明为何省略，禁止直接跳过导致段落顺序错乱。

## frontmatter（P0）

```yaml
---
name: kebab-case-name
description: >
  Use this skill when the user asks to "<English trigger>",
  "<中文触发短语>", or when discussing <domain context>.
  SKIP when <排除条件>.
---
```

**硬限制**：`name` ≤64 字符；`description` ≤1024 字符；整个 frontmatter ≤1024 字符。

- `description`：措辞 pushy 对抗 undertrigger；**禁止摘要工作流步骤**；必须含排除条件（`SKIP when...`）防误触发；遮住测试（盖住 body 仅看 description，若 Agent 能完成任务 → 重写）
- 项目约定：用英文；含中英文触发短语

### 核心字段参考

| 字段 | 本规范推荐值 | 架构意义 |
|------|------------|---------|
| `name` | kebab-case 与目录同名（P0） | 稳定索引 |
| `description` | 英文 + 触发短语 + SKIP 条件；禁摘要（P0） | Agent 激活判据 |
| `allowed-tools` | 最小权限集（P0） | Reviewer 类只给 `["Read","Grep","Glob"]` |
| `model` | `inherit`（P0） | 禁止硬编码 opus/sonnet |
| `disable-model-invocation` | 方法论工作流类建议 `true`（P1） | 防 Agent 误激活长流程 |
| `context` | 编排器分派时设 `fork`（P1） | Skill 在独立 subagent 上下文执行 |
| `agent` | 与 fork 搭配：`Explore` / `Plan` / `general-purpose`（P1） | 决定 fork 后的工具集和权限 |
| `paths` | 按需限定触发路径 | 缩小无关激活的 token 开销 |

**反模式**：

- 省略 `allowed-tools` → 继承全部工具，违反最小权限
- 硬编码 `model: claude-opus-4-7` → 升级模型时需批量改
- 方法论 Skill 未设 `disable-model-invocation: true` → 误激活

## HARD RULES（P0）

- 祈使句（Do/Don't/Never/Always），禁"如果...则..."
- ≥2 条
- 示例：`ALWAYS read project-context.md before any action.`

## 扁平化指令（P0）

禁止嵌套条件结构（「如果 A 且 B 则...否则如果 C 则...」）。改写为条件枚举表：

```
| 条件              | 动作       | 跳转        |
|-------------------|-----------|-------------|
| Schema 校验通过    | 继续步骤 3 | → §3        |
| Schema 校验失败    | 修复循环   | → §错误恢复  |
```

## 语言精确性（P1）

**禁用词**：视情况、酌情、一般来说、通常、大多数、按惯例、显然、自然地

**用词替换**：

| 禁用 | 改为 |
|------|------|
| 视情况调用 X | 当 `<条件>` 满足时调用 X |
| 大概需要 | 需要 ≥N |
| 尽量保持 | 必须 ≤N / 应 ≤N |

## ANTI-RATIONALIZATION（P0）

- 句式：`Do not rationalize...` / `It is NOT acceptable to...`
- ≥2 条，**每条必须对应一种具体可观察的逃避行为**（非泛泛禁令）

**有效示例**：

- `Do not rationalize skipping prerequisite verification by claiming the user already confirmed. ALWAYS verify by reading files.`
- `It is NOT acceptable to emit a partial output and claim it as complete. If any mandatory section is empty, HALT and ask the user.`

**反面示例**（无效，不计入 ≥2 条）：

| 无效条目 | 为什么无效 |
|---------|----------|
| `Do not rationalize bad code.` | "bad" 无观察锚点，Agent 无法自检 |
| `Always follow best practices.` | 正向陈述，不对应逃避行为；属 HARD RULES |
| `Do not lie to the user.` | 非 Skill 执行语境；归模型基础准则 |
| `Do not rationalize skipping tests.`（本 Skill 不涉及测试） | 与本 Skill 无关——凑数 |

**判别口诀**：合格条目必须能回答"Agent 何时、如何、因何理由会逃避"（三问齐全）。

**降级条件（P1）**：若梳理不出 ≥2 条三问齐全的真实逃避场景，本节降为 P1，需一句话说明"本 Skill 目前未识别出具体逃避模式，待首轮 eval 后补入"。禁止凑数。

## 开篇声明（P0）

SKILL.md body 开篇必须显式声明四要素：

| 要素 | 说明 | 示例 |
|------|------|------|
| 角色 | 本 Skill 执行时"我是谁" | "作为架构审查员..." |
| 环境 | 触发条件 / 前置依赖 | "当 project-context.md 存在时..." |
| 目标 | 可验证的成功标准 | "产出通过 Schema 校验" |
| 反向边界 | 禁止项（不可省略） | "不修改源代码，只输出报告" |

## 工具调用规范（P1）

SKILL.md 中每个 Bash / MCP / Agent 调用必须写明：

| 要素 | 说明 |
|------|------|
| 何时用 | 可判定触发条件（非"视情况"） |
| 失败降级 | fallback 路径 |
| 数据传递 | 输入来源 + 输出去向 |

多种可用工具时须说明选择理由；涉及不可逆操作时须写明回退路径。

## 方法论工作流

含关键验证节点（产出写入前、阶段跳转前）须用显式继续条件：

```
**在继续执行步骤 3 之前，必须完成：用户确认分析结论无误。**
```

继续条件用中文；仅对产出写入/不可逆操作节点加，非每步强制。

## 产出生成

### Annotated Template 模式（P1）

**解决**：template/example 双文件漂移 → HTML 注释内嵌示例。

**实施**：
```markdown
| 风险类别 | 影响 | 缓解 |
|---------|-----|------|
<!-- FILL EXAMPLE:
| 技术 | 核心功能 | PoC 验证 |
-->
```

**优势**：单一真实源、示例可见、原子更新

**适用**：Generator/Inversion 结构化产出

## 语言一致性（P0）

同一段落不混用两种自然语言；若采用中英混合策略（如 HARD RULES 用英文、工作流用中文），应在 CLAUDE.md 中声明。

## context: fork 使用指南（P1）

编排器分派 Skill 时，`context: fork` 使 Skill 在独立上下文运行，避免编排器 token 溢出。

```yaml
---
name: analysis-skill
description: >
  Use when the user asks to run stage-1 analysis...
context: fork
agent: general-purpose
allowed-tools: ["Read", "Write", "Edit"]
---
```

**陷阱：fork 后 Skill 看不到主对话状态**。状态传递必须通过文件系统桥接：
1. 编排器先调用 `update-context.py` 写状态到 `project-context.md`
2. Skill 启动协议第一步：读取 `project-context.md`
3. Skill 产出通过 `update-context.py` 回写

**不使用 fork**：贯穿关注点 Skill（需读主对话历史）、简单 Tool Wrapper（产出小无需独立上下文）。

## 尺寸约束

- SKILL.md 正文 ≤ 2500 词，推荐 1000-2000
- references/ 单文件 ≤ 250 行；>150 行须加目录

## Skill 间信息流

- 只能通过文件系统传递（读上游产出目录）
- 禁止直接调用
- 一个 Skill 只负责一个方法论阶段

## 引用与知识层规则

### 引用深度（P0）

`references/*.md` 和 `knowledge/*.md` 只能从 SKILL.md 直接引用；被引用文件内部禁止再引用其他 references 或 knowledge 文件（仅一层深度）。

### 知识层约束

仅适用于 `knowledge/`；`references/` 由工作流步骤直接引用。

- 单文件 ≤ 150 行（P0），超限拆分
- 3+ 文件须提供 `_index.yml`
- 启动只读 `_index.yml`，按需加载（P0）

**L2 类目**：`methodology/`（如何做）/ `patterns/`（选什么）/ `examples/`（做过什么）；领域特定按需扩展。

**Skill 自包含**：专属内容默认放 `skills/<name>/references/`；被 2+ Skill 引用才提取。

| 内容类型 | 默认位置 | 提取目标 | 合规 |
|---------|---------|---------|------|
| 专属 schema | `skills/<name>/references/schema.md` | `contracts/schemas/` | P0 |
| 专属 templates | `skills/<name>/references/template-*.md` | `knowledge/templates/` | P1 |
| 专属方法论/案例 | `skills/<name>/references/` | `knowledge/<category>/` | P1 |
| 角色定义 | `contracts/roles.md` | — 不下放 | P0 |
| 状态结构 | `contracts/context-schema.md` | — 不下放 | P0 |

### references/ 自治性原则（P0）

**约束**：目录内容自包含，禁止向上层泄漏引用。

**边界**：

| 文件 | 职责 | 禁止项 |
|------|------|--------|
| methodology/ | 理论（如何做） | 不含产出模板 |
| templates/ | 产出（做什么） | 不含方法论步骤 |
| checklist.md | 门禁（够不够） | 不含实施细节 |

**合规**：
- ✅ templates.md 内嵌示例（无需外部 examples/）
- ✅ methodology 不引用外部 templates
- ❌ checklist 写"参见 methodology § 3.2"
- ❌ templates 含"按 methodology 步骤 2 填写"

**适用**：Generator/Reviewer/Inversion 模式

## 贯穿关注点 Skill（Cross-Cutting）

- 任意阶段可调用
- 产出增量追加，禁覆盖
- 每条记录标注当前阶段
- 前置条件仅依赖 project-context.md 存在

## Token 优化自检

> 铁律：优化 = 删除冗余 + 重组载体。禁止删除：工具选择分支、产出 Schema、错误恢复逻辑、HARD RULES / ANTI-RATIONALIZATION 约束。

**违规扫描清单**：

| 检测模式 | 修复动作 |
|---------|---------|
| SKILL.md 连续 >10 行知识/原理描述 | 提取到 `references/methodology.md` |
| SKILL.md 内嵌完整产出示例 | 移至 Annotated Template 或 `examples/` |
| description 含流程步骤描述 | 仅保留触发短语 + 领域上下文 |
| template / example 同义双份维护 | 合并为 Annotated Template |

**Token 消耗优先级**：

| 消耗来源 | 允许动作 |
|---------|---------|
| SKILL.md 主干 | 移除方法论泄漏、内嵌示例、重复描述 |
| references/ 按需加载 | 拆分超限文件、建 `_index.yml` |
| templates + examples | 采用 Annotated Template |
| HARD RULES / ANTI-RATIONALIZATION | 仅合并同质，禁止削弱约束 |
