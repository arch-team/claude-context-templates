# Claude Context Templates — 项目战略

> 本文档定义项目的愿景、目标、核心指标与长期演进路线，作为迭代决策的基准参考。

---

## 1. 愿景 (Vision)

**成为 AI Coding 工具上下文规范协作治理的事实标准——从项目起点持续守护到生命周期终点。**

claude-context-templates 不仅是 Claude Code 的"模板起点"，更是**持续上下文守护者 (Continuous Context Guardian)**：在项目的每一次会话、每一次迭代、每一次结构变更中，保持 AI 行为与团队约定的对齐。

类比：
- `.editorconfig` / ESLint 解决了**代码层**的规范协作
- claude-context-templates 解决**上下文层**的规范协作——从 init 时的"结构铺设"，延伸到日常开发中的"漂移检测"、版本演进中的"升级路径"、团队协作中的"质量门禁"

---

## 2. 使命 (Mission)

**为 AI 辅助开发的全生命周期提供行为护栏，让"AI 按项目约定工作"从偶然变为必然。**

我们通过以下方式实现：
- **起点守护**：提供生产级 preset，让项目从第一天就有高质量上下文结构
- **过程守护**：通过审计、漂移检测、会话提醒，在日常开发中持续对齐
- **演进守护**：通过增量更新机制，让项目在 preset 迭代中保留自定义、获取改进
- **生态守护**：沉淀社区最佳实践，构建可扩展的 preset 与规范治理生态

---

## 3. 核心问题 (Problem Statement)

> **问题演进**：v1.x 聚焦"起点问题"（没有好的模板），v2.x 起扩展到"生命周期问题"（起点之后没有守护）。

### 3.1 起点问题（v1.x 已部分解决）

| 问题 | 影响 |
|------|------|
| Claude Code 的 `.claude/` 目录没有标准化的组织方式 | 每个项目从零开始，质量参差不齐 |
| 缺乏经过验证的上下文管理最佳实践 | 开发者凭直觉编写，效果不可预测 |
| 不同技术栈需要不同的规范，但共性模式未被抽取 | 重复劳动，无法复用 |
| 上下文管理的知识分散在个人经验中 | 团队间无法共享和协作 |

### 3.2 生命周期问题（v2.x+ 新增战略重点）

| 问题 | 影响 |
|------|------|
| init 后 `.claude/` 与项目实际演进脱节（结构漂移） | AI 按过时约定工作，规则形同虚设 |
| Preset 迭代改进无法下发到已存量用户 | 用户装完即走，无长期价值捕获 |
| 团队协作中 `.claude/` 质量退化（规则冲突、SSoT 被破坏）无感知 | 规范腐化速度超过维护速度 |
| 缺乏 AI 行为与项目约定对齐的质量门禁 | 约定成摆设，违规无提示 |

---

## 4. 价值主张 (Value Proposition)

```
对于：使用 Claude Code 进行 AI 辅助开发的开发者和团队
痛点：AI 辅助开发的上下文约定在起点、过程、演进中都缺乏守护手段
我们提供：项目全生命周期的 AI 行为护栏工具链
  = 生产级 Preset（起点）
  + 审计/漂移检测（过程）
  + 增量更新机制（演进）
  + 质量门禁组件（协作）
与众不同之处：
  1. 唯一覆盖"起点 → 过程 → 演进"全生命周期的上下文治理方案
  2. 基于真实 Monorepo 项目提炼的 6 大设计原则（SSoT、双向链接、Section 0 等）
  3. 多技术栈 preset 生态，通过 Plugin/init.sh 双通道分发
  4. 中英双语 + 可组合的护栏层级（建议/引导/强制）
```

---

## 5. 目标用户 (Target Users)

### 5.1 核心用户画像

| 用户类型 | 特征 | 核心需求 | 使用场景 |
|----------|------|----------|----------|
| **个人开发者**（首要） | 使用 Claude Code 开发个人/开源项目 | 快速搭建，即用即走 | 新项目初始化 |
| **技术团队 Lead**（次要） | 需要统一团队的 AI 开发规范 | 标准化、可定制、可推广 | 团队规范制定 |

> 其他潜在用户（开源项目维护者、企业 DevOps）留待有真实需求证据时再扩展。

### 5.2 用户旅程（全生命周期五步）

```
发现 → 初始化 → 定制 → 守护 → 演进
 │        │        │       │       │
 │        │        │       │       └─ preset 更新时增量合并，保留自定义、获取改进
 │        │        │       └─ 日常会话中 SessionStart 提示 + /audit-context 审计漂移
 │        │        └─ 修改模板适配项目/团队约定
 │        └─ 运行 init.sh 或 /init-context 生成 .claude/ 目录
 └─ 通过 GitHub 搜索 / 社区推荐 / 博客文章发现项目
```

> **注**：v1.x 只覆盖"发现 → 定制"三步，v2.x 起扩展"守护"和"演进"两步，形成完整生命周期闭环。

---

## 6. 北极星指标 (North Star Metric)

### 主指标（直接可测）

> **GitHub Stars + Forks 组合值** — 作为项目关注度和实际采用的代理指标

**选择理由**：在纯 GitHub 开源项目中，"活跃项目采用数"无法准确测量。Stars 反映关注度，Forks 反映实际使用意图，两者组合是个人维护者能持续追踪的最可靠信号。

### 验证指标（需主动收集）

> **确认使用报告数** — GitHub Issues / Discussions 中用户报告在真实项目中使用的数量

**选择理由**：这是唯一能证明模板真正创造价值的信号。需要通过 Issue 模板引导用户报告使用情况。

### 指标局限性

诚实对待开源项目的测量困境：
- Stars 和 Forks 是虚荣指标，不等于真实使用
- GitHub 不提供 clone 后的使用追踪
- Template "generated from" 计数是较好的信号，但仅适用于 GitHub Template 方式
- **核心判断标准**：是否有真实用户在 Issues/Discussions 中报告使用并提出改进建议

---

## 7. 目标体系 (Goals & OKR)

### 7.1 短期目标（v1.0 发布 — 验证价值）

**目标**：完成首次公开发布，获得真实用户反馈。

| 关键结果 | 指标 | 状态 |
|----------|------|------|
| KR1: 核心 preset 和文档体系完成 | 3 preset + 双语 + 文档 | ✅ 已完成 |
| KR2: init.sh 在 macOS / Linux 上通过端到端测试 | CI 自动化验证 | ✅ 已完成 |
| KR3: 成功发布到 GitHub 并启用 Template Repository | 发布完成 | ✅ 已完成 |
| KR4: 发布公告并获得首批外部反馈 | ≥ 5 条外部反馈 | ✅ 已完成 |

### 7.2 中期目标（v2.0 — 从"一次性生成器"升级为"生命周期护栏"）

**战略重定位**：v2.0 是本项目的战略分水岭——从"init 时的模板工具"升级为"项目全生命周期的 AI 行为护栏"。围绕三大支柱推进：

| 支柱 | 关键问题 | 核心能力 |
|------|---------|---------|
| **A. 漂移检测** | init 后结构与约定腐化 | 强化 `/audit-context` → 漂移检测、SessionStart 提示 |
| **B. 升级路径** | Preset 迭代无法下发 | Preset 增量更新机制（详见 BR-003） |
| **C. 质量门禁** | 违规约定无感知、无阻断 | hooks 模板（建议/引导/强制三档，默认 opt-in） |

| 关键结果 | 指标 |
|----------|------|
| KR1: 支柱 A — `/audit-context` 扩展为漂移检测，至少识别 3 类漂移模式 | 3 类漂移检测规则 + CI 验证 |
| KR2: 支柱 B — Preset 增量更新机制上线（BR-003） | update 命令可用且通过 CI 验证 |
| KR3: 支柱 C — 质量门禁 Hook 模板发布（opt-in） | 至少 2 个 hook 模板（pre-commit / SessionStart） |
| KR4: Preset 数量达到 5+（新增 Go 和 Next.js/Vue） | ≥ 5 个 presets |
| KR5: 社区贡献通道就绪（贡献指南 + PR 模板 + 验证流程） | 首个社区 preset PR |
| KR6: Preset 组合/继承机制实现 | _common 共享 + rule 级别继承 |

### 7.3 长期方向（v3.0+ — 探索性）

> 以下不是承诺的 OKR，而是在 Phase 1-2 成功的前提下可能追求的方向。

- 覆盖更多技术栈（依赖社区贡献或维护者精力）
- Cursor Rules / AGENTS.md 跨工具兼容
- 模板浏览网站或 Awesome List 社区聚合
- 被 Claude Code 生态中的其他项目/文章引用

---

## 8. 核心指标体系 (Metrics Framework)

> **设计原则**：只追踪有可靠数据源的指标。宁可指标少但真实，不要指标多但虚假。

### 8.1 可量化指标（GitHub 原生提供）

| 指标 | 数据源 | 检查频率 | 说明 |
|------|--------|----------|------|
| Stars | GitHub | 月度 | 关注度信号 |
| Forks | GitHub | 月度 | 使用意图信号 |
| Open Issues | GitHub | 周度 | 社区互动健康度 |
| 外部 PR 数 | GitHub Pull Requests | 月度 | 社区贡献活跃度 |
| Template "generated from" 计数 | GitHub（启用 Template Repository 后） | 月度 | 最接近真实采用的指标 |
| 贡献者数（非维护者） | GitHub Contributors | 月度 | 社区参与广度 |

### 8.2 定性信号（需人工观察）

| 信号 | 在哪里看 | 说明 |
|------|----------|------|
| 用户成功案例 | Issues, Discussions | 最有价值的反馈 |
| 功能请求 | Issues | 需求信号 |
| 社区 preset PR | Pull Requests | 生态扩展信号 |
| 外部提及 | GitHub 搜索, Google Alerts | 传播范围信号 |

### 8.3 质量指标

| 指标 | 衡量方式 | 目标 |
|------|----------|------|
| Preset 完整度 | 每个 preset 的 required files 覆盖率 | 100% |
| 双语一致性 | zh-CN / en 文件数量和结构对比 | 100% 一致 |
| init.sh 成功率 | CI 自动化测试（多平台） | 100% |
| 模板变量替换准确率 | 自动化测试 | 100% |
| 文档链接有效性 | CI 链接检查 | 0 个断链 |

---

## 9. 竞争分析 (Competitive Landscape)

### 9.1 现有替代方案

> 基于 2026-03-16 GitHub 竞品调研（详见 `.devpace/research/github-competitor-analysis-2026-03-16.md`）

| 方案 | 代表项目 | Stars | 优势 | 劣势 | 我们的差异化 |
|------|---------|-------|------|------|-------------|
| **手动创建 CLAUDE.md** | — | — | 完全自由 | 无结构化指导，质量不稳定 | 生产级模板 + 6 条设计原则 |
| **Claude Code 配置展示** | ChrisWiles/claude-code-showcase | 5.5K | 完整参考 | 展示非工具，无法自动化 | Plugin 自动化分发 + 多技术栈 |
| **安全导向配置模板** | trailofbits/claude-code-config | 1.6K | 安全加固 | 单一场景，无多栈支持 | 安全作为可选层 + 多 preset |
| **Context Engineering 模板** | coleam00/context-engineering-intro | 12.7K | PRP 工作流 | 无 preset 系统，无自动初始化 | 结构化 preset + init.sh/Plugin |
| **Claude Code CLI 工具** | davila7/claude-code-templates | 23K | npx 一键启动，Analytics | 偏监控，模板生成非核心 | 专注模板质量 + 设计原则 |
| **通用模板生成器** | cookiecutter, copier, plop | 3K-25K | 成熟生态，Copier 支持更新 | 不针对 AI 编码场景 | AI 上下文专用 + Plugin 原生 |
| **Awesome List** | awesome-claude-skills | 44.6K | 社区聚合效应 | 列表非工具，无法直接使用 | 可执行模板 vs 参考列表 |
| **AI 生成 CLAUDE.md** | — | — | 零成本 | 缺乏结构化，不可复现 | 设计原则 + SSoT + Schema 验证 |

### 9.2 护城河策略

```
短期（v1.x）：模板质量 + 先发优势 + 双语支持 + Plugin 原生集成
  → 唯一通过 Plugin 直接在 Claude Code 内交付的模板工具
  → 唯一提供 zh-CN/en 双语的 Claude Code 模板项目

中期（v2.x）：从"一次性生成器"升级为"持续上下文守护者"
  → 漂移检测（支柱 A）：init 后持续对齐,竞品的"一次性模板"无法复制此能力
  → 增量更新（支柱 B）:Preset 更新机制(借鉴 Copier)建立用户长期关系
  → 质量门禁(支柱 C):opt-in 的 hook 层,形成团队级标准协作
  → 社区 preset 贡献形成网络效应

长期：承认不确定性
  → 如果 Anthropic 原生实现类似功能,项目可能转为社区扩展层
  → 保持架构灵活性,以便快速适配官方变更
  → 持续上下文守护的能力边界可能延伸到 Cursor/AGENTS.md 等其他 AI Coding 工具
```

---

## 10. 产品路线图 (Roadmap)

### Phase 1: Foundation（基础）— v1.0

**主题**：发布 MVP，验证核心价值

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M1.1 | 3 个核心 preset (Python/React/CDK) | ✅ 完成 |
| M1.2 | 中英双语支持 | ✅ 完成 |
| M1.3 | init.sh 交互式生成工具 | ✅ 完成 |
| M1.4 | 示例项目 (monorepo + single) | ✅ 完成 |
| M1.5 | 完整文档体系 | ✅ 完成 |
| M1.6 | GitHub Actions CI（init.sh 烟雾测试 + preset 结构验证） | ✅ 完成 |
| M1.7 | 启用 GitHub Template Repository + README URL 更新 | ✅ 完成 |
| M1.8 | 发布公告（英文博客 + Claude Code 社区） | ✅ 完成 |

### 10.5 Phase 1 完成清单

- [x] 所有 preset 通过结构验证（required files 完整、无断链）
- [x] init.sh 在 macOS 和 Linux (Ubuntu) 上测试通过
- [x] GitHub Actions CI: push 时运行 init.sh 烟雾测试
- [x] GitHub Actions CI: push 时运行 preset 结构验证
- [x] README 中的仓库 URL 更新为实际地址
- [x] 仓库配置为 GitHub Template Repository
- [x] 发布博客文章
- [x] 在 Claude Code 社区发布首次公告

### Phase 1.5: Plugin 交付 — v1.1

**主题**：通过 Claude Code Plugin 降低使用门槛

| 里程碑 | 内容 | 状态 |
|--------|------|------|
| M1.5.1 | Plugin MVP（/init-context 命令 + context-setup Skill） | ✅ 完成 |
| M1.5.2 | Plugin 工具链（build/sync-check/release 脚本 + CI 集成） | ✅ 完成 |
| M1.5.3 | GitHub marketplace 分发配置 + README 更新 | ✅ 完成 |
| M1.5.5 | /audit-context 命令（.claude/ 目录质量审计） | ✅ 完成 |
| M1.5.4 | 端到端外部用户安装测试 | 进行中 |

### Phase 2: Lifecycle Guardian（生命周期护栏）— v2.0

**主题**：从"一次性生成器"升级为"持续上下文守护者"——围绕三大支柱（漂移检测 / 升级路径 / 质量门禁）建立生命周期治理能力，同时扩展 preset 生态。

> 以下里程碑按三支柱分组。基础能力建设（支柱 A/B/C）优先级高于生态扩展（M2.E.x）。

#### 支柱 A：漂移检测（Drift Detection）

| 里程碑 | 内容 | 优先级 |
|--------|------|--------|
| M2.A.1 | **`/audit-context` 漂移检测升级** — 识别至少 3 类漂移：SSoT 被破坏、双向链接失效、Section 0 速查卡片与实际内容脱节 | 高 |
| M2.A.2 | **SessionStart Hook 模板** — Plugin 可选注入到生成的 `.claude/settings.json`,会话启动时 <1s 内完成结构完整性提示（建议层,默认开启） | 中 |

#### 支柱 B：升级路径（Evolution Path）

| 里程碑 | 内容 | 优先级 | 灵感来源 |
|--------|------|--------|---------|
| M2.B.1 | **Preset 增量更新机制** — 详见 BR-003。生成 `.claude/` 时记录 `.preset-meta.yml`,`/update-context` 命令执行三向合并 | 高 | Copier (`copier update`) |
| M2.B.2 | **跨大版本迁移脚本框架** — Preset 结构破坏性变更时提供迁移脚本模板 | 中 | — |

#### 支柱 C:质量门禁(Quality Gates)

| 里程碑 | 内容 | 优先级 | 灵感来源 |
|--------|------|--------|---------|
| M2.C.1 | **Hook 模板库(opt-in)** — pre-commit / pre-push hook 模板,检查 CLAUDE.md 与项目约定一致性 | 中 | trailofbits/claude-code-config |
| M2.C.2 | **安全加固 Preset 组件** — 可选安全层:settings.json 安全默认值、Read/Edit deny rules、防敏感文件泄露 Hook | 中 | trailofbits/claude-code-config |
| M2.C.3 | **GitHub Actions 集成模板** — 为每个 preset 提供可选 CI(PR Claude Code 审查、文档同步检查、代码质量审计) | 中 | ChrisWiles/claude-code-showcase |

#### 生态扩展(E - Ecosystem)

| 里程碑 | 内容 | 优先级 |
|--------|------|--------|
| M2.E.1 | 新增 2+ preset(Go + Next.js/Vue,总计 ≥ 5 个) | 高 |
| M2.E.2 | Preset 组合机制(rule 级别继承,_common 共享) | 高 |
| M2.E.3 | **社区 Preset 生态** — 建立贡献流程和质量标准;维护 Awesome List 扩大传播 | 高 |
| M2.E.4 | **交互式 Preset 配置向导** — 升级 init.sh 为交互式向导,支持 preset 选择 → 变量填写 → 可选组件组合 | 中低 |

### Phase 3+: 未来可能方向（探索性）

> 以下方向不是承诺的路线图，而是基于当前认知和竞品调研的探索性选项。是否执行取决于 Phase 2 的反馈和维护者资源。

- **Plugin preset 远程热更新**（无需重新安装即可获取最新模板）
- **Cursor Rules / AGENTS.md 兼容**（借鉴 StackOneHQ/cursor-rules-to-claude 的跨工具迁移思路）
- **模板浏览网站**（借鉴 davila7/claude-code-templates 的 aitmpl.com 模式）
- **会话级上下文管理**（借鉴 carveragents/flux 的 session-based 学习机制）
- 社区驱动更多 preset（依赖外部贡献者出现）
- 更多语言支持（依社区需求）

---

## 11. 成功标准与风险 (Success Criteria & Risks)

### 11.1 各阶段成功标准

| 阶段 | 成功标准 | 失败信号 |
|------|----------|----------|
| Phase 1 | ≥ 1 个确认的外部用户；init.sh 无关键 bug；CI 通过 | 公开 3 个月后零外部互动 |
| Phase 2 | 收到社区贡献的 preset PR；preset 组合机制可用 | 仅维护者活跃，无社区参与；架构无法扩展 |

### 11.2 风险矩阵

| 风险 | 概率 | 影响 | 应对策略 |
|------|------|------|----------|
| Anthropic 推出官方模板方案 | 中 | 高 | 快速适配，转为社区扩展层 |
| Claude Code 架构大幅变更 | 低 | 高 | 关注官方 changelog，快速适配 |
| 社区参与度低 | 中 | 中 | 主动推广，降低贡献门槛，维护者持续输出高质量内容 |
| preset 质量不一致 | 中 | 中 | 建立 preset 审核标准和自动化验证 |
| **维护者倦怠** | 中 | 高 | 保持最小范围，自动化重复任务，避免过度承诺 |
| **模板过时** | 中 | 中 | 定期更新节奏（跟随 Claude Code 官方变更），CI 验证断链 |

---

## 12. 推广策略 (Go-to-Market)

> 推广活动绑定到具体 Phase，而非独立浮动的策略。个人维护者的精力有限，聚焦高 ROI 渠道。

### 12.1 Phase 1 推广

| 渠道 | 具体行动 |
|------|----------|
| **GitHub** | 启用 Template Repo、添加话题标签、提交 awesome-list |
| **英文博客** | 发布 1 篇发布公告 + 设计原则解读 |
| **Claude Code 社区** | Anthropic Discord/Forum 发布公告 |
| **Hacker News** | Show HN 帖子 |

### 12.2 Phase 2 推广

| 渠道 | 具体行动 |
|------|----------|
| **中文社区** | 掘金、知乎发布中文使用教程 |
| **贡献教程** | 发布"如何为你的技术栈创建 preset"指南 |
| **案例收集** | 在 Discussions 中收集用户成功案例 |

---

## 13. 迭代决策框架 (Decision Framework)

### 新功能优先级评估

对于每个新功能/改进提案，使用以下评分矩阵决策：

| 维度 | 权重 | 评分标准 (1-5) |
|------|------|----------------|
| **用户影响** | 35% | 影响多少用户？解决多大痛点？ |
| **北极星贡献** | 25% | 是否直接推动真实用户采用？ |
| **实现成本** | 20% | 需要多少开发和维护投入？(反向：成本低得分高) |
| **生态价值** | 20% | 是否增强社区贡献或 preset 生态？ |

**决策阈值**：
- **≥ 4.0 分**：立即排入当前迭代
- **3.0 - 3.9 分**：排入下一迭代
- **< 3.0 分**：暂不考虑，记录到 backlog

### 示例评估

```
提案：新增 Go + Gin preset
├─ 用户影响: 4  (Go 社区大，需求明确)
├─ 北极星贡献: 4  (直接增加潜在用户群)
├─ 实现成本: 3  (需要 Go 专业知识，中等工作量)
├─ 生态价值: 5  (证明 preset 可扩展，吸引更多贡献者)
└─ 综合得分: 4 × 0.35 + 4 × 0.25 + 3 × 0.20 + 5 × 0.20 = 4.0 → 立即排入
```

---

## 14. 版本管理策略 (Versioning)

### 语义化版本

```
MAJOR.MINOR.PATCH

MAJOR: preset 结构不兼容变更（如 rules 文件重组）
MINOR: 新增 preset、新功能、新语言支持
PATCH: Bug 修复、文案改进、小优化
```

### 版本里程碑对应

| 版本 | 对应阶段 | 核心变更 |
|------|----------|----------|
| v1.0 | Phase 1 | 首次稳定发布（init.sh + preset 模板） |
| v1.1 | Phase 1.5 | Claude Code Plugin 交付方式 |
| v1.x | Phase 1 | 修复和小改进 |
| v2.0 | Phase 2 | 生命周期护栏三支柱（漂移检测 / 升级路径 / 质量门禁）+ 新 presets + 组合机制 + 社区生态 |
| v3.0+ | Phase 3+ | 跨工具兼容 + 模板浏览站 + 视社区反馈决定 |

---

## 附录: 关键假设

本战略基于以下假设，需持续验证：

| 假设 | 验证方式 | 失效时的应对 |
|------|----------|-------------|
| Claude Code 的 .claude/ 机制会持续存在 | 关注 Anthropic 官方动态 | 快速适配新机制 |
| 开发者愿意为 AI 辅助开发投入上下文管理 | 用户反馈和使用数据 | 降低使用门槛，强化即用体验 |
| 社区有为不同技术栈贡献 preset 的动力 | PR 和 Issue 数据 | 维护者主动覆盖主流栈 |
| 结构化上下文管理确实能提升 Claude Code 效果 | A/B 对比实验 | 调整模板策略 |
| 中英双语能覆盖目标用户的主要需求 | 用户反馈 | 增加更多语言 |
| 个人维护者能长期持续维护此项目 | 每季度诚实自评 | 简化范围、寻找联合维护者、或标记为 stable/unmaintained |
