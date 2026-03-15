# 项目目录结构

> **职责**：文件放置规则与分层归属。新建文件时查此文件确定目标位置。

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
│  ├─ 自动加载规则 → .claude/rules/
│  └─ 按需参考 → .claude/references/
├─ 项目文档？ → docs/
├─ 完整示例？ → examples/
├─ 脚本工具？ → scripts/
└─ 不确定 → 先问，不要放项目根目录
```

### 分层归属速查表

| 目录 | 归属层 | 自动加载 | 随 Plugin 分发 |
|------|--------|---------|---------------|
| `plugin/` | 产品层 | 按组件类型 | 是 |
| `.claude/rules/` | 开发层 | 是 | 否 |
| `.claude/references/` | 开发层 | 否（按需） | 否 |
| `docs/` | 开发层 | 否 | 否 |
| `scripts/` | 开发层 | 否 | 否 |
| `examples/` | 开发层 | 否 | 否 |

## §1 完整目录树

> 本节是项目结构的**单一真实源 (Single Source of Truth)**

```
claude-context-templates/            # 仓库根目录
├── .claude/                         # Claude Code 开发规范
│   ├── CLAUDE.md                    # 全局入口（速查卡片、分层架构、项目概述）
│   ├── settings.json                # Claude Code 设置
│   ├── rules/                       # 自动加载的开发规则
│   │   ├── common.md                # 语言、Git 提交、命名、审查
│   │   ├── dev-workflow.md          # 会话协议、质量检查
│   │   ├── plugin-dev-spec.md       # Plugin/Preset 组件开发规范
│   │   └── project-structure.md     # 项目结构 SSoT（本文件）
│   └── references/                  # 按需加载的参考文档
│       ├── component-reference.md   # Agent/Hook/MCP 完整规格参考
│       ├── design-principles.md     # 设计原则（6 条核心）
│       └── ia-principles.md         # 11 条通用信息架构原则
├── plugin/                          # Claude Code Plugin（产品层）
│   ├── .claude-plugin/              # Plugin 元数据
│   │   ├── plugin.json              # Plugin manifest
│   │   └── marketplace.json         # Marketplace 配置
│   ├── commands/                    # 命令定义
│   ├── skills/                      # Skill 定义
│   └── presets/                     # 预设模板（唯一 SSoT）
│       ├── manifest.json            # 版本清单
│       ├── _common/                 # 公共模板 + 跨 preset 工程原则
│       ├── python-fastapi/          # Python + FastAPI 预设
│       ├── react-typescript/        # React + TypeScript 预设
│       └── aws-cdk/                 # AWS CDK 预设
├── examples/                        # 完整示例项目
│   ├── monorepo-taskmanager/        # Monorepo 示例
│   └── single-project-python/       # 单项目示例
├── scripts/                         # CI/CD 和验证脚本
├── docs/                            # 项目文档
│   ├── customization-guide.md       # Preset 定制指南
│   ├── template-variables.md        # 模板变量说明
│   ├── plugin-delivery-design.md    # Plugin 分发架构
│   └── project-strategy.md          # 项目战略与路线图
├── init.sh                          # 项目初始化脚本
├── CONTRIBUTING.md                  # 贡献指南
├── .gitignore
└── README.md                        # 项目总说明
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
| `.claude/references/` | 开发 | 按需读取 | 否 | 参考文档 |
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
3. **开发->产品引用允许**：开发层文件可以引用产品层文件（如 `.claude/rules/plugin-dev-spec.md` 引用 `plugin/` 结构）

**检测方法**：`plugin/` 内的文件不应有对本仓库 `.claude/`、`docs/`、`scripts/` 的运行时依赖（如 `import`、`source`、文件读取路径）。注意：Plugin 命令和文档中提及 `.claude/` 作为功能描述（Plugin 为用户生成 `.claude/` 目录）是正常的，不算违反此约束。

## §4 跨文档引用

| 内容 | 参见 |
|------|------|
| 分层架构概述 | CLAUDE.md "分层架构"章节 |
| 组件格式（SKILL.md frontmatter 等） | `plugin-dev-spec.md` |
| 文件命名规范 | `common.md` |
| 设计原则（6 条核心） | `references/design-principles.md` |
| 信息架构原则 | `references/ia-principles.md`（按需加载） |
