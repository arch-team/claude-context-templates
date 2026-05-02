---
paths:
  - "**/contracts/**"
  - "**/plugin.json"
  - "**/evals/**"
---

# Agent Harness 合规清单

> 开发完成后的验收工具。P0 清单必须全部通过；P1 清单偏离需说明理由。
>
> **适用范围**：P0/P1 清单适用于**正式插件**（2+ Skill）。MVP 插件（单 Skill）仅需满足标注 `[MVP]` 的项，其余项在升级为正式插件时补齐。

## 验收方式标注

| 标注 | 含义 |
|------|------|
| `[Hook]` | 自动化脚本验收 |
| `[Script]` | 可脚本化验收 |
| `[人工]` | 需人工判断 |
| `[人工+留痕]` | 需人工判断且记录（格式：`## 审查记录\n- YYYY-MM-DD <审查项>：<结论>`） |

P0 项优先 Hook/Script 验收。

## MVP → 正式插件升级矩阵（单一权威）

> 本表是 MVP 升级触发条件的唯一权威定义。`project-structure.md` 和 `core-constraints.md` 中与升级相关的描述均以本表为准。

| 触发条件 | 需补齐的组件 | 依据 |
|---------|------------|------|
| 出现第 2 个 Skill | `hooks/` + 聚合 Command | 多 Skill 间需质量门禁 |
| 2+ Skill 共享同一知识内容 | 提取到 `knowledge/<category>/` | IA-3 稳定-易变分离 |
| 2+ Skill 共享同一 Schema | 提取到 `contracts/schemas/` | IA-10 契约隔离 |
| 角色数 ≥2 | `contracts/roles.md`（P1） | IA-6 单一权威 |
| 角色数 ≥3 | `contracts/roles.md`（P0） | IA-6 强制 |
| Skill 数 ≥5 | 审查是否存在共享知识，有则提取 | 阈值：2+ Skill 共享内容即提取到 `knowledge/` 或 `contracts/` |
| 满足「L4 编排器启用判据」任一项 | `agents/<domain>-orchestrator.md` | 见 `project-structure.md` §4 架构现状 |
| 上线前 | `evals/` 端到端评估 | 见下方 Step 6 评估指标 |

**升级时机**：触发条件满足时**即时升级**，不要攒到一起重构（避免大规模返工）。

**回退**：若某 Skill 被删除导致共享条件不再满足，可反向合并知识回 `references/`，但 `contracts/roles.md` 和 `context-schema.md` 一旦创建不删除（稳定接口）。

## 各步骤退出标准

| 步骤 | 完成标准 |
|------|---------|
| Step 1 L1 | roles.md 和 context-schema.md 已定义；context-schema 含 progress + resume_hint；各 Skill 专属 schema 在 Step 3 中随 Skill 创建 |
| Step 2 L2 | 每文件 ≤150 行；被 2+ Skill 引用的知识已提取；L2 共享模板 + L3 `references/templates/` 专属模板合计覆盖所有必须产出 |
| Step 3 L3 | 每个 SKILL.md 8 段式；≥2 条 HARD RULES + ANTI-RATIONALIZATION（英文）；知识通过路径引用（内嵌 ≤10 行，见 `core-constraints.md` IA-3） |
| Step 4 L4 | **仅适用于有 agents/ 目录的插件**。如需引入，通过 `claude-code-guide` agent 查证规范 |
| Step 5 L5 | 每个 Command ≤5 行执行流（本架构约束，非官方限制）；Hook 注册完整；update-context.py 是唯一写入者；plugin.json 含 name/version/description/keywords |
| Step 6 Eval | 端到端走通一个完整流程；跨会话恢复测试通过；关键指标已度量（见评估指标） |

**Step 6 评估指标（P1）**：

| 指标 | 说明 | 基线 |
|------|------|------|
| 完成率 | 端到端流程成功完成的比例 | ≥ 80% |
| 每任务重试次数 | Agent 因错误/歧义而重试的平均次数 | ≤ 2 |
| pass@1 | 首次尝试即通过的比例 | ≥ 60% |
| 单次成功成本 | 完成一次完整流程的 token 消耗 | 记录基线，逐版优化 |

## P0 合规清单（开发新插件或审查时必须全部通过）

> **执行原则**：发现 P0 违反时，修复范围 ≤3 文件直接修复；>3 文件或需架构级重构则先向用户说明再执行。

### 架构级 P0（本文件独有验收）

跨组件一致性、层间依赖、核心文件存在性等只能在架构层面判定的项：

```
层间依赖
□ [MVP] 层间依赖单向（L5→L4→L3→L2→L1），无反向引用 [Script]
□ [MVP] L1/L2 文件不引用 L3-L5 [Script]
□ [MVP] Skill 间信息流通过文件系统，禁止直接调用 [Script]

核心文件存在性
□ contracts/ 目录存在（含 roles.md + context-schema.md）[Script]
□ 5+ Skill 时已审查是否存在 2+ Skill 共享知识（有则提取到 knowledge/）；无共享时须在插件根 `CLAUDE.md` 的「## 审查记录」节留一行：`YYYY-MM-DD 共享知识审查：无共享`[人工+留痕]

知识层约束（IA-5）
□ knowledge/ 下每个文件 ≤ 150 行 [Script]

状态管理（单一写入者）
□ project-context.md 由专用脚本独占写入（见 `hook-command-script.md`）[Script]

跨插件独立性
□ [MVP] 每个 Plugin 能独立运行，不依赖其他 Plugin [人工]
```

### 组件级 P0（详见对应组件规范）

组件内部验收细节由各组件规范维护（DRY），本文件不重述。审查时对照：

| 组件 | 权威文件 |
|------|---------|
| SKILL.md | `skill-writing.md` |
| Orchestrator / Sub Agent | 通过 `claude-code-guide` agent 查证（本项目暂不适用） |
| Hook / Command | `hook-command-script.md` |
| Knowledge 调用 | `skill-writing.md`（Skill 侧调用约束） |

## P1 推荐清单（审查时识别，偏离需说明理由）

```
□ 知识目录 3+ 文件时有 _index.yml [Script]
□ 3-4 Skill 时审查并按需提取 contracts/ 和 knowledge/；审查结论须在插件 `CLAUDE.md` 的「## 审查记录」节留一行 [人工+留痕]
□ 2 角色时定义 contracts/roles.md [Script]
□ 各阶段产出有 Schema 定义 [人工]
□ 编排器实现 3 个标准流程 [人工]
□ SKILL.md 正文 ≤ 2500 词 [Script]
□ 被 2+ Skill 引用的知识提取到 knowledge/ [人工]
□ 编排器 frontmatter 含至少 2 个 example [Script]
□ 编排器 frontmatter description 含 example 块（仅限 Agent，Skill 禁止摘要工作流）[Script]
□ references/ 下单个文件 ≤ 250 行；超过 150 行时文件顶部须加目录 [Script]
□ [MVP] 一个 Skill 只负责一个方法论阶段；SKILL.md 顶部引用块声明"本 Skill 阶段 = <阶段名>" [人工+留痕]
□ [MVP] description 含中英文触发短语，禁止摘要工作流步骤 [人工]
```

