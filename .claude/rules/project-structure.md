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

## §1 完整目录树

> 本节是项目结构的**单一真实源 (Single Source of Truth)**

```
claude-context-templates/            # 仓库根目录
├── .claude/                         # Claude Code 开发规范
│   ├── CLAUDE.md                    # 全局入口（速查卡片、分层架构、项目概述）
│   ├── settings.json                # Claude Code 设置
│   ├── rules/                       # 自动加载的开发规则
│   │   ├── compliance-checklist.md  # MVP → 正式插件升级矩阵（来源：agent-platform）
│   │   ├── conventions.md           # 语言约定 + Git 提交规范（来源：agent-platform，适配）
│   │   ├── core-constraints.md      # IA 11 原则铁律（来源：agent-platform）
│   │   ├── dev-workflow.md          # 会话协议、质量检查（本项目特化）
│   │   ├── hook-command-script.md   # Command/Hook/Script 规范（来源：agent-platform，适配）
│   │   ├── plugin-design.md         # Plugin 五层架构（来源：agent-platform）
│   │   ├── project-structure.md     # 项目结构 SSoT（本文件，本项目特化）
│   │   ├── skill-writing.md         # SKILL.md 8 段式规范（来源：agent-platform）
│   │   └── token-optimization.md    # Token 利用率优化（来源：agent-platform）
│   └── references/                  # 按需加载的参考文档（当前为空）
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

**常见绕过与反驳**：

| 借口 | 反驳 |
|------|------|
| "只是在 Plugin 中引用一下开发层路径" | 产品层必须独立可分发，任何运行时路径依赖都破坏此约束 |
| "Plugin README 描述 .claude/ 不算引用" | 功能描述合法（已在检测方法中说明），但 `source`/`import`/读取路径不合法 |
| "开发层工具对 Plugin 用户也有用" | 用户通过 `plugin/` 获取模板，开发工具属于贡献者而非用户 |

## §4 跨文档引用

| 内容 | 参见 |
|------|------|
| 分层架构概述 | `CLAUDE.md` "分层架构"章节 |
| 组件格式（SKILL.md frontmatter 等） | `rules/skill-writing.md`、`rules/hook-command-script.md` |
| 文件命名规范 | `rules/conventions.md` |
| 设计原则（6 条核心） | `rules/dev-workflow.md` §3 质量 checklist（内联） |
| Plugin 组件规格查证 | `claude-code-guide` agent 或官方文档 |
