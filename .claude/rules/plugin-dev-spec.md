# Plugin/Preset 组件开发规范

> **职责**：开发 claude-context-templates Plugin 时 Claude 必须遵循的组件规范。基于官方文档。

## §0 速查卡片

### Plugin 目录规则

| 位置 | 内容 | 注意 |
|------|------|------|
| `plugin/.claude-plugin/` | 仅 `plugin.json` + `marketplace.json` | 组件不放这里 |
| `plugin/` 根目录 | `commands/`、`skills/`、`presets/` | 所有组件在此 |

### 组件清单

| 组件类型 | 目录 | 当前内容 |
|---------|------|---------|
| Commands | `plugin/commands/` | init-context, audit-context |
| Skills | `plugin/skills/` | context-setup |
| Presets | `plugin/presets/` | generic, python-fastapi, react-typescript, aws-cdk |
| Schema | `plugin/presets/` | context-schema.yaml |

### 常见陷阱

| 问题 | 原因 | 解决 |
|------|------|------|
| 组件放在 `.claude-plugin/` 内 | 只有 plugin.json 和 marketplace.json 在此目录 | 移到 Plugin 根目录 |
| Command frontmatter 含 `name` | Command 名由文件名决定 | 删除 `name`（SKILL.md 中合法） |
| Skill 不触发 | `description` 过于模糊 | 写明具体触发关键词 |
| Plugin 路径用绝对路径 | 必须相对且以 `./` 开头 | 改为相对路径 |
| Preset 缺少双语版本 | 新增 preset 必须包含 zh-CN 和 en | 补充缺失的语言版本 |

### 查证优先级

1. `claude-code-guide` agent → 2. 官方文档 `code.claude.com/docs/en/` → 3. `claude --debug`

### 参考文档

Agent / Hook / MCP 规格 + plugin.json 可选字段 + Skill 质量验证法 + plugin-dev 工具 → `references/component-reference.md`（按需加载）

## §1 Plugin 结构与版本管理

完整目录树见 `rules/project-structure.md` §1（SSoT），此处不重复。

### plugin.json

当前含 `name`、`description`、`version`、`author`。`name` 是唯一必填字段（当 manifest 存在时），同时作为 Skill 的命名空间前缀。可选字段完整列表见 `references/component-reference.md`。

### 版本同步

以下三处版本号必须保持同步，修改版本时需同时更新：

| 文件 | 版本字段 |
|------|---------|
| `plugin/.claude-plugin/plugin.json` | `version` |
| `plugin/.claude-plugin/marketplace.json` | `plugins[0].version` |
| `plugin/presets/manifest.json` | `plugin_version` |

### 分发架构

Plugin 分发的详细架构设计见 `docs/plugin-delivery-design.md`（SSoT），包含分发策略、工具链和 CI 流程。

## §2 命令开发 Commands

命令文件放在 `plugin/commands/` 目录，frontmatter 支持以下字段：

| 字段 | 说明 |
|------|------|
| `description` | 命令描述（显示在 `/` 菜单） |
| `allowed-tools` | 激活时免确认的工具，逗号分隔 |
| `model` | `sonnet` / `opus` / `haiku` |

**注意**：Command 的名称由文件名决定，frontmatter 中不应包含 `name` 字段。

## §3 Skill 开发 Skills

每个 Skill 是 `plugin/skills/<name>/SKILL.md`。目录名即 Skill 名称。

### SKILL.md Frontmatter

**合法 frontmatter 字段**：

| 字段 | 说明 |
|------|------|
| `name` | 显示名称（可选，省略则用目录名） |
| `description` | 触发条件描述——Claude 据此判断是否自动调用 |
| `argument-hint` | 自动补全时的参数提示 |
| `allowed-tools` | 激活时免确认的工具，逗号分隔 |
| `model` | `sonnet` / `opus` / `haiku` |
| `disable-model-invocation` | `true` = 仅用户可调用，Claude 不会自动调用 |
| `user-invocable` | `false` = 从 `/` 菜单隐藏，仅 Claude 可调用 |
| `context` | `fork` = 在子 agent 上下文中运行 |
| `agent` | 当 `context: fork` 时使用的 agent 类型 |
| `hooks` | 作用域为此 Skill 的 Hook 配置 |

### description 编写规则（CSO）

`description` 是 Claude 判断是否自动触发 Skill 的唯一依据。编写不当会导致两类问题：

**问题 1：Claude 跳过阅读完整 SKILL.md**——如果 description 中总结了工作流步骤，Claude 可能根据摘要直接行动而不加载完整 Skill 内容。

**问题 2：误触发或漏触发**——description 过于模糊或过于具体都会影响准确性。

**编写规则**：

| 规则 | 正确 | 错误 |
|------|------|------|
| 只写"何时触发"，不写"做什么" | `Use when user wants to initialize a new project` | `Generates .claude/ directory and copies preset templates` |
| 开头用 "Use when" 或触发条件列表 | `Use when setting up Claude context for a project` | `Project initialization skill for template management` |
| 包含具体触发关键词 | `Use when user says "初始化/init/setup"` | `Handles initialization tasks` |
| 避免描述内部步骤 | `Use when user needs a new preset template` | `Validates preset, copies files, runs init script` |

**字符串替换**：Skill 内容中可使用 `$ARGUMENTS`（全部参数）、`$0`/`$1`（按位参数）、`` !`command` ``（预处理器，执行 shell 命令并替换输出）。

### 分拆模式

SKILL.md 放"做什么"（输入/输出/路由），详细规则超 ~50 行拆出 `*-procedures.md`（"怎么做"）。

### 质量验证

Skill 开发/修改时的 RED-GREEN-REFACTOR 验证方法见 `references/component-reference.md`。

## §4 Preset 模板开发

Preset 是本项目的核心产出，每个 Preset 为特定技术栈提供完整的 `.claude/` 目录模板。

### 必需文件

每个 Preset 目录必须包含：
- `preset.yaml`——Preset 元数据和配置
- 模板文件——使用变量占位符（详见 `docs/template-variables.md`）
- zh-CN 和 en 两个语言版本

### 开发流程

Preset 创建的完整流程详见 `docs/customization-guide.md`（SSoT）。变量占位符规范详见 `docs/template-variables.md`（SSoT）。

### 双语要求

新增 Preset 必须同时提供中文（zh-CN）和英文（en）两个语言版本，确保国际化支持。
