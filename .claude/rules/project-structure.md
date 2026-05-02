---
paths:
  - "**/plugin.json"
  - "**/.claude-plugin/**"
---

# 项目结构与组件设计

> **职责**：文件放置规则、分层归属、新组件选型。新建文件或添加组件时查此文件。

## §0 速查卡片

### 新文件放置决策树

```
新文件
├─ Plugin 运行时需要？（随 Plugin 分发）
│  ├─ Plugin 元数据 → plugin/.claude-plugin/
│  ├─ 命令 → plugin/commands/
│  ├─ Skill → plugin/skills/<name>/
│  └─ Preset 模板 → plugin/presets/<preset-name>/
├─ 开发规范？
│  └─ 自动加载规则 → .claude/rules/
├─ 项目文档？ → docs/
├─ 完整示例？ → examples/
├─ 脚本工具？ → scripts/
└─ 不确定 → 先问，不要放项目根目录
```

### 组件选型速查

```
需要多步交互引导完成某个方法论阶段？       → Skill（L3）
仅是概念/模式/案例/模板等参考信息？       → Knowledge（L2）或 references/
需要在产出前/后自动校验质量？             → Hook（L5）
只是简单触发某个 Skill？                 → Command（L5）
需要维护持久化状态（上下文文件）？          → Script（辅助）
```

| 粒度 | 对应组件 |
|------|---------|
| 微粒度（高风险单次操作） | Hook Script、独立 Command |
| 中粒度（常见读写循环） | Skill |
| 宏粒度（完整流程编排） | Sub Agent（通过 `claude-code-guide` agent 查证） |

## §1 完整目录树

> 本节是项目结构的**单一真实源 (Single Source of Truth)**

```
claude-context-templates/            # 仓库根目录
├── .claude/                         # Claude Code 开发规范
│   ├── CLAUDE.md                    # 全局入口（速查卡片、分层架构、项目概述）
│   ├── settings.json                # Claude Code 设置
│   └── rules/                       # 自动加载的开发规则
│       ├── compliance-checklist.md  # MVP → 正式插件升级矩阵（来源：agent-platform）
│       ├── conventions.md           # 语言约定 + Git 提交规范（来源：agent-platform，适配）
│       ├── core-constraints.md      # IA 11 原则铁律（来源：agent-platform）
│       ├── dev-workflow.md          # 会话协议、质量检查（本项目特化）
│       ├── hook-command-script.md   # Command/Hook/Script 规范（来源：agent-platform，适配）
│       ├── project-structure.md     # 项目结构与组件设计 SSoT（本文件）
│       ├── skill-writing.md         # SKILL.md 8 段式规范（来源：agent-platform）
│       └── token-optimization.md    # Token 利用率优化（来源：agent-platform）
├── .claude-plugin/                  # 根目录 marketplace（本地开发用）
│   └── marketplace.json
├── .github/                         # GitHub 配置
│   ├── ISSUE_TEMPLATE/              # Issue 模板
│   │   ├── bug-report.yml
│   │   ├── config.yml
│   │   ├── feature-request.yml
│   │   └── usage-report.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── ci.yml
├── plugin/                          # Claude Code Plugin（产品层）
│   ├── .claude-plugin/              # Plugin 元数据
│   │   ├── plugin.json              # Plugin manifest
│   │   └── marketplace.json         # Marketplace 配置（本地开发）
│   ├── hooks/                       # Hook 质量门禁（v2.0）
│   │   ├── README.md                # Hook 体系说明与检查维度
│   │   └── scripts/                 # Hook 脚本（v2.0 实现）
│   ├── commands/                    # 命令定义
│   │   ├── init-context.md          # /init-context 命令
│   │   └── audit-context.md         # /audit-context 命令
│   ├── skills/                      # Skill 定义
│   │   └── context-setup/           # 自动检测 Skill
│   │       └── SKILL.md
│   ├── presets/                     # 预设模板（唯一 SSoT）
│   │   ├── manifest.json            # 版本清单
│   │   ├── context-schema.yaml      # Preset 结构 schema
│   │   ├── _common/                 # 公共模板 + 跨 preset 工程原则
│   │   ├── generic/                 # 通用预设（无特定技术栈）
│   │   ├── python-fastapi/          # Python + FastAPI 预设
│   │   ├── react-typescript/        # React + TypeScript 预设
│   │   └── aws-cdk/                 # AWS CDK 预设
│   └── README.md                    # Plugin 使用说明
├── examples/                        # 完整示例项目
│   ├── monorepo-taskmanager/        # Monorepo 示例
│   └── single-project-python/       # 单项目示例
├── scripts/                         # CI/CD 和验证脚本
│   ├── lib-yaml.sh                  # 公共 YAML 解析函数（被 validate 脚本 source）
│   ├── build-plugin.sh              # Plugin 构建（manifest 生成 + 结构验证）
│   ├── check-links.sh               # 文档链接有效性检查
│   ├── generate-manifest.sh         # Preset manifest 生成
│   ├── release-plugin.sh            # Plugin 版本发布
│   ├── test-init.sh                 # init.sh 功能测试
│   ├── validate-generated.sh        # 生成结果验证
│   └── validate-presets.sh          # Preset 结构完整性验证
├── docs/                            # 项目文档
│   ├── architecture-decision-records/ # 架构决策记录
│   │   └── adr-001-l4-evaluation.md # L4 编排器引入评估
│   ├── customization-guide.md       # Preset 定制指南
│   ├── customization-guide.zh-CN.md # Preset 定制指南（中文）
│   ├── plugin-delivery-design.md    # Plugin 分发架构
│   ├── project-strategy.md          # 项目战略与路线图
│   ├── template-variables.md        # 模板变量说明
│   └── template-variables.zh-CN.md  # 模板变量说明（中文）
├── init.sh                          # 项目初始化脚本
├── install.sh                       # 安装脚本
├── CONTRIBUTING.md                  # 贡献指南
├── LICENSE                          # 许可证
├── .gitignore
├── README.md                        # 项目总说明（英文）
└── README.zh-CN.md                  # 项目总说明（中文）
```

## §2 分层归属表

| 目录/文件 | 归属层 | 自动加载 | 随 Plugin 分发 | 说明 |
|-----------|--------|---------|---------------|------|
| `plugin/.claude-plugin/` | 产品 | — | 是 | 仅 plugin.json + marketplace.json |
| `plugin/commands/` | 产品 | 按调用 | 是 | 命令定义 |
| `plugin/skills/` | 产品 | 按触发 | 是 | Skill 定义 |
| `plugin/presets/` | 产品 | 否 | 是 | 预设模板（init.sh 读取） |
| `.claude/CLAUDE.md` | 开发 | 是 | 否 | 项目入口 |
| `.claude/rules/` | 开发 | 是（Rules） | 否 | 开发规范 |
| `docs/` | 开发 | 否 | 否 | 设计文档、指南 |
| `scripts/` | 开发 | 否 | 否 | 验证和 CI 脚本 |
| `examples/` | 开发 | 否 | 否 | 完整示例项目 |
| `.devpace/` | 研发管理 | 按 Plugin | 否 | devpace 迭代管理 |

## §3 分层约束

本项目分为两个独立层次，**产品层不得依赖开发层**：

| 层次 | 目录 | 职责 | 分发 |
|------|------|------|------|
| **开发层** | `.claude/`、`docs/`、`scripts/`、`examples/` | 开发本项目的规范和文档 | 不分发 |
| **产品层** | `plugin/` | Plugin 运行时资产，分发给用户 | 随 Plugin 分发 |

**硬性约束**：

1. **产品层独立可分发**：`plugin/` 必须作为独立整体分发，不依赖 `.claude/`、`docs/`、`scripts/` 中的任何文件
2. **禁止产品->开发引用**：`plugin/` 内的文件不得出现指向 `.claude/`、`docs/`、`scripts/` 的路径引用
3. **开发->产品引用允许**：开发层文件可以引用产品层文件

**检测方法**：`plugin/` 内的文件不应有对本仓库 `.claude/`、`docs/`、`scripts/` 的运行时依赖（如 `import`、`source`、文件读取路径）。Plugin 命令和文档中提及 `.claude/` 作为功能描述（Plugin 为用户生成 `.claude/` 目录）是正常的，不算违反此约束。

## §4 组件设计

### Agent 质量模型

Agent 产出质量由四个维度约束：

| 维度 | 含义 | 正向优化方向 | 红线（P0 禁止） |
|------|------|-------------|---------------|
| Action Space | 工具定义的精确性和粒度 | Command、Hook、Script 的接口设计 | 删除工具选择分支、角色识别逻辑 |
| Observation | 工具返回结果的可操作性 | Hook 脚本输出格式、Skill 产出结构 | 删除产出 Schema、模板结构锚点 |
| Recovery | 错误路径的可恢复性 | Hook 异常降级、跨会话恢复 | 删除 ANTI-RATIONALIZATION、错误恢复分支 |
| Context Budget | 上下文窗口的利用效率 | 知识按需加载、Skill 自包含 | — 正向维度，精简的唯一合法目标 |

**使用场景**：
- **设计时**：按"正向优化方向"评估组件是否完整覆盖四维
- **精简时**：按"红线"判断优化动作是否合法（见 `token-optimization.md`）

### 本项目架构现状

使用 MVP 结构（L3 + L5 两层）：
- L5: `plugin/commands/`（init-context、audit-context）
- L3: `plugin/skills/context-setup/`
- L5: `plugin/hooks/`（v2.0 计划）
- 资产: `plugin/presets/`（核心模板，非标准 Plugin 组件）

升级触发条件见 `compliance-checklist.md` 升级矩阵。
五层架构完整定义和编排器规范通过 `claude-code-guide` agent 查证。

## §5 跨文档引用

| 内容 | 参见 |
|------|------|
| 分层架构概述 | `CLAUDE.md` "分层架构"章节 |
| 组件格式（SKILL.md frontmatter 等） | `rules/skill-writing.md`、`rules/hook-command-script.md` |
| 文件命名规范 | `rules/conventions.md` |
| 设计原则（6 条核心） | `rules/dev-workflow.md` §3 质量 checklist（内联） |
| Plugin 组件规格查证 | `claude-code-guide` agent 或官方文档 |
