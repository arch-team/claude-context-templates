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

## §1 完整目录树

> 本节是项目结构的**单一真实源 (Single Source of Truth)**

```
claude-context-templates/
├── .claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   └── rules/
│       ├── compliance-checklist.md
│       ├── conventions.md
│       ├── core-constraints.md
│       ├── dev-workflow.md
│       ├── hook-command-script.md
│       ├── project-structure.md
│       └── skill-writing.md
├── .claude-plugin/
│   └── marketplace.json
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug-report.yml
│   │   ├── config.yml
│   │   ├── feature-request.yml
│   │   └── usage-report.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── ci.yml
├── plugin/
│   ├── .claude-plugin/
│   │   ├── plugin.json
│   │   └── marketplace.json
│   ├── hooks/
│   │   ├── README.md
│   │   └── scripts/
│   ├── commands/
│   │   ├── init-context.md
│   │   └── audit-context.md
│   ├── skills/
│   │   └── context-setup/
│   │       └── SKILL.md
│   ├── presets/
│   │   ├── manifest.json
│   │   ├── context-schema.yaml
│   │   ├── _common/
│   │   ├── generic/
│   │   ├── python-fastapi/
│   │   ├── react-typescript/
│   │   └── aws-cdk/
│   └── README.md
├── examples/
│   ├── monorepo-taskmanager/
│   └── single-project-python/
├── scripts/
│   ├── lib-yaml.sh
│   ├── build-plugin.sh
│   ├── check-links.sh
│   ├── generate-manifest.sh
│   ├── release-plugin.sh
│   ├── test-init.sh
│   ├── validate-generated.sh
│   └── validate-presets.sh
├── docs/
│   ├── architecture-decision-records/
│   │   └── adr-001-l4-evaluation.md
│   ├── customization-guide.md
│   ├── customization-guide.zh-CN.md
│   ├── plugin-delivery-design.md
│   ├── project-strategy.md
│   ├── template-variables.md
│   └── template-variables.zh-CN.md
├── init.sh
├── install.sh
├── CONTRIBUTING.md
├── LICENSE
├── .gitignore
├── README.md
└── README.zh-CN.md
```

## §2 分层归属表

| 目录/文件 | 归属层 | 自动加载 | 随 Plugin 分发 | 说明 |
|-----------|--------|---------|---------------|------|
| `plugin/.claude-plugin/` | 产品 | — | 是 | 仅 plugin.json + marketplace.json |
| `plugin/commands/` | 产品 | 按调用 | 是 | 命令定义 |
| `plugin/skills/` | 产品 | 按触发 | 是 | Skill 定义 |
| `plugin/presets/` | 产品 | 否 | 是 | 预设模板（init.sh 读取） |
| `CLAUDE.md`（根目录） | 开发 | 是 | 否 | 项目入口 |
| `.claude/CLAUDE.md` | 开发 | 是 | 否 | 通用编码行为准则 |
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

**检测**：`plugin/` 内不应有对 `.claude/`、`docs/`、`scripts/` 的路径引用（功能描述中提及 `.claude/` 不算违反）。

## §4 组件设计

### 本项目架构现状

使用 MVP 结构（L3 + L5 两层）：
- L5: `plugin/commands/`（init-context、audit-context）
- L3: `plugin/skills/context-setup/`
- L5: `plugin/hooks/`（v2.0 计划）
- 资产: `plugin/presets/`（核心模板，非标准 Plugin 组件）

各层引入时机见 `compliance-checklist.md` 各步骤退出标准。
五层架构完整定义和编排器规范通过 `claude-code-guide` agent 查证。

### 入口层与脚本现状

**Command 路由**：
- `plugin/commands/init-context.md` 仅做路由触发
- 实际初始化逻辑在 `plugin/skills/context-setup/SKILL.md` 中
- 模板渲染通过 `scripts/render-template.sh` 执行

**Hook 校验 Preset 结构（v2.0 计划）**：

| 检查维度 | 脚本名 | 说明 |
|---------|--------|------|
| 版本同步 | `validate-version-sync.py` | 校验 plugin.json / marketplace.json / manifest.json 版本一致性 |
| Preset 结构 | `validate-preset-structure.py` | 校验 zh-CN/ 和 en/ 双语对称性 + required files |
| 分层约束 | `validate-layer-dependency.py` | 检测产品层（plugin/）引用开发层（.claude/、docs/）|

**Script 场景**（本项目使用 bash 脚本替代 Python 的 `update-context.py`）：

| 脚本 | 职责 |
|------|------|
| `scripts/render-template.sh` | 模板变量替换（`{{VAR}}` 占位符） |
| `scripts/validate-presets.sh` | Preset 结构完整性校验 |
| `scripts/generate-manifest.sh` | 生成 preset manifest.json |
| `scripts/audit-context.sh` | .claude/ 目录质量审计 |
