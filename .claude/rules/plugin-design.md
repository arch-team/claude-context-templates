---
paths:
  - "**/plugin.json"
  - "**/.claude-plugin/**"
  - "**/contracts/**"
  - "**/knowledge/**"
---

# Agent Harness 插件结构参考

> 创建 Plugin 时的脚手架指南。选型时参考「组件选型」，建目录时参考「单插件规范结构」。

## 五层架构

```
L5 Entry          Commands（路由触发器）+ Hooks（质量门禁）
L4 Orchestration  Sub Agent（可选）：按需启用，仅当需要自动化流转/角色路由时创建
L3 Process        Skills（每个 Skill = 一个方法论阶段执行引擎，自包含）
L2 Knowledge      跨 Skill 共享知识：methodology / patterns / examples（+ 领域特定类目）
L1 Contract       跨 Skill 共享契约：roles.md / context-schema.md / schemas/（按需）
```

**L4 是可选层**：多数插件通过 L5 Command + L3 Skill 已能完整运作，仅在满足「L4 编排器启用判据」时才创建 `agents/`。

**Skill 最小自包含原则**：Skill 专属内容默认放在 `references/`，根目录 `contracts/` 和 `knowledge/` 仅存放 2+ Skill 共享内容。

**依赖方向**：L5 → L4 → L3 → L2 → L1，单向，禁止反向引用。

## Agent 质量模型

Agent 产出质量由四个维度约束，每个维度同时定义**正向优化方向**和**不可触碰的红线**。

| 维度 | 含义 | 正向优化方向 | 红线（P0 禁止） |
|------|------|-------------|---------------|
| Action Space | 工具定义的精确性和粒度 | Command、Hook、Script 的接口设计 | 删除工具选择分支、角色识别逻辑 |
| Observation | 工具返回结果的可操作性 | Hook 脚本输出格式、Skill 产出结构 | 删除产出 Schema、模板结构锚点 |
| Recovery | 错误路径的可恢复性 | Hook 异常降级、编排器跨会话恢复 | 删除 ANTI-RATIONALIZATION、错误恢复分支 |
| Context Budget | 上下文窗口的利用效率 | 知识按需加载、Skill 自包含、阶段边界压缩 | — 正向维度，精简的唯一合法目标 |

**使用场景**：

- **设计时**：按"正向优化方向"列评估插件组件是否完整覆盖四维
- **精简时**：按"红线"列判断优化动作是否合法（见 `token-optimization.md` 精简流程）

## 组件选型

**按职责选择**：

```
需要多步交互引导完成某个方法论阶段？       → Skill（L3）
仅是概念/模式/案例/模板等参考信息？       → Knowledge（L2）或 Contract（L1）
需要协调多个 Skill 的执行顺序？
  ├─ 用户可自行决策下一步？               → 不需编排，用 Command 串起 Skill
  ├─ 仅需聚合展示进度？                   → 一个 status Command 足够
  └─ 需自动流转 / 角色路由 / 跨会话角色记忆？ → Sub Agent（L4）
需要在产出前/后自动校验质量？             → Hook（L5）
只是简单触发某个 Skill 或 Agent？         → Command（L5）
需要维护持久化状态（上下文文件）？          → Script（辅助）
```

**按风险粒度选择**：

| 粒度 | 对应组件 |
|------|---------|
| 微粒度（高风险单次操作） | Hook Script、独立 Command |
| 中粒度（常见读写循环） | Skill |
| 宏粒度（完整流程编排） | Sub Agent |

## 首选：最小可行插件（MVP）

**先从这里开始**：单方法论阶段、无跨 Skill 状态同步、无多角色协作时使用下面的 4 文件结构即可运作。后续遇到升级触发条件再扩展（升级矩阵见 `compliance-checklist.md`）。

```
<domain>-<name>/
├── .claude-plugin/plugin.json
├── CLAUDE.md
├── skills/<first-stage>/
│   ├── SKILL.md
│   └── references/methodology.md
└── commands/<first-stage>.md
```

## 开发新插件顺序（L1 → L5）

**Step 0（设计驱动 eval，P1 推荐）**：在写任何规范文档前，先起草 **3 个 eval 场景**（最小必胜、最可能失败、边界/越权）。场景是黑盒输入/输出，先不关心实现。目的是**暴露 gap**：若场景写不出明确期望产出，说明方法论本身未想清，重新领域知识提炼。

1. 领域知识提炼 → 阶段划分、输入/输出定义、角色模型
2. 设计 L1 契约层 → roles.md + context-schema.md（共享 Schema 按需后续提取）
3. 构建 L2 知识层 → knowledge/ 分类文件（每文件 ≤150 行）+ _index.yml
4. 实现 L3 流程层 → 每阶段一个 SKILL.md（遵循 skill-writing.md 规范）
5. 评估 L4 编排层 → 对照「L4 编排器启用判据」判断是否需要；需要则创建轻量编排器（只做流转，不含方法论逻辑），不需要则跳过进入第 6 步
6. 实现 L5 入口层 → Commands + Hooks + Scripts
7. 评估与迭代（ops eval，P0 上线前）→ `evals/` 扩充为端到端场景：覆盖 Step 0 的 3 个设计 eval + 跨阶段集成 + 回归基线

**两种 eval 区别**：Step 0 的 **design-time eval** 是找 gap 的思考工具（可只存在文档草稿中）；Step 7 的 **ops eval** 是上线验收的自动化脚本（存 `evals/` 目录，纳入 CI）。

## L4 编排器启用判据

**默认不启用**。启用需满足**两阶门槛**。启用后编排器的行为铁律见 `core-constraints.md` 的「编排器（Sub Agent）铁律」节。

**阶段 A（必要条件，至少命中 1 项）**：

| 判据 | 量化标准 |
|------|---------|
| 多角色路由 | 角色数 ≥3 且同一 Command 需根据状态路由到不同角色 |
| Skill 数量规模 | Skill 数 ≥5，主会话上下文污染成本 > 编排器固定开销 |
| 跨会话刚需 | 流程预期跨 ≥3 个会话（跨天），需要持久化"我在哪一步"之外的角色状态 |
| 单 Skill 负荷 | 任一 Skill 执行 ≥40K tokens |

**阶段 B（充分条件，P0 必须全部满足，P1 推荐满足）**：

- [ ] （P0）用户无法通过 Command + 状态仪表板自主决定下一步
- [ ] （P0）Sub Agent 固定代价可接受（激活开销 + 调试透明度下降）
- [ ] （P1）已评估过"用 Command 串起 Skill"的方案并写入 CLAUDE.md 拒绝理由

**不满足两阶门槛 → 用 Command + Skill 组合，L4 纯冗余**。

**代价衡量**：激活开销典型值 5-10K tokens（实际用 `anthropic.count_tokens()` 或 `tiktoken` 实测）；Sub Agent 内部工具调用不在主会话 transcript 可见；中断 Sub Agent 比中断主会话复杂。

---

## 附录

### 单插件完整结构

```
<domain>-<name>/
├── .claude-plugin/plugin.json          # name, version, description, keywords
├── CLAUDE.md                           # 面向 Agent 的指令和约束
├── contracts/                          # L1：跨 Skill 共享契约（2+ Skill 引用时才放这里）
│   ├── roles.md                        # 角色定义与权限矩阵
│   ├── context-schema.md               # 上下文状态结构
│   └── schemas/                        # 2+ Skill 共用的 Schema
├── knowledge/                          # L2：跨 Skill 共享知识（2+ Skill 引用时才放这里）
│   ├── _index.yml                      # 顶层知识索引
│   ├── <category>/
│   │   ├── _index.yml
│   │   └── <item>.md                   # ≤150 行
│   └── templates/                      # 2+ Skill 共用的模板
├── skills/                             # L3
│   ├── <stage-name>/
│   │   ├── SKILL.md
│   │   ├── references/                 # 参考文档（平铺）
│   │   │   ├── _index.yml
│   │   │   ├── methodology.md
│   │   │   └── template-<output>.md
│   │   ├── examples/                   # 可选：完整示例
│   │   └── scripts/                    # 按需：执行脚本（Python 优先）
│   └── <cross-cutting-name>/           # 贯穿 Skill（结构同上）
├── commands/                           # L5
│   ├── <stage>.md
│   ├── <domain>.md                     # 全流程入口
│   └── status.md
├── hooks/                              # L5
│   ├── hooks.json
│   └── scripts/
│       └── validate-<维度>.py
├── scripts/
│   ├── update-context.py               # 独占写入 project-context.md
│   └── init-project.py                 # 可选
├── tests/
│   └── test-<script-name>.py
└── evals/                              # 端到端评估
    ├── <stage>-evals.json
    └── chain-integration-evals.json
```

### 层间依赖矩阵

| 引用方 ↓ / 被引用方 → | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| **L5** Entry | 可以 | — | 可以 | 可以 | — |
| **L4** Orchestration | 可以 | — | 可以 | — | 禁止 |
| **L3** Process | 必须 | 存在时必须 | 同层可读产出文件 | 禁止 | 禁止 |
| **L2** Knowledge | 可以 | 同层可引用 | 禁止 | 禁止 | 禁止 |
| **L1** Contract | 同层可引用 | 禁止 | 禁止 | 禁止 | 禁止 |

**图例**：`可以`=允许引用 | `必须`=强制引用 | `存在时必须`=该层存在时强制引用，不存在时（如 MVP）由 `references/` 替代 | `禁止`=不得引用 | `—`=不适用 | `同层可引用`/`同层可读产出文件`=同层内有限互操作

### 命名规范（P0）

**文件与目录**：全部使用 **kebab-case**（如 `stage-1-analysis/`、`event-driven.md`、`update-context.py`）。
例外：`SKILL.md` / `CLAUDE.md` / `README.md`（全大写）、`_index.yml`（下划线前缀）。

**组件命名**：

- Sub Agent `name`：`<domain>-orchestrator`（编排器固定后缀）
- Hook 脚本：`validate-<维度>.py` 或 `<维度>-check.py`

### 多插件工作空间（P1）

**跨插件独立性原则（P0）**：每个 Plugin 必须能独立运行，不依赖其他 Plugin。若多插件共享资源，置于顶层 `shared/`（含 `knowledge/` / `contracts/` / `scripts/`），并通过复制或符号链接整合到各 Plugin 内部使用。设计方法论文档（人读）建议放 `method/`。
