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
| Commands | `plugin/commands/` | 命令定义 |
| Skills | `plugin/skills/` | Skill 定义 |
| Presets | `plugin/presets/` | python-fastapi, react-typescript, aws-cdk |

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

### 完整组件参考

Agent / Hook / MCP 详细规格 → `.claude/references/component-reference.md`（按需加载）

## §1 Plugin 结构

```
plugin/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest（name + description + version）
│   └── marketplace.json     # Marketplace 配置
├── commands/                # 命令定义
├── skills/                  # Skill 定义（每 Skill 一个目录）
└── presets/                 # 预设模板
    ├── manifest.json        # 版本清单
    ├── _common/             # 公共模板 + 跨 preset 工程原则
    ├── python-fastapi/
    ├── react-typescript/
    └── aws-cdk/
```

### plugin.json

当前采用最小格式，仅含 `name`、`description`、`version`。`name` 是唯一必填字段（当 manifest 存在时），同时作为 Skill 的命名空间前缀。

可选字段（均为合法）：`homepage`、`repository`（字符串）、`license`、`keywords`、`commands`、`agents`、`skills`、`hooks`、`mcpServers`、`outputStyles`、`lspServers`。其中 `commands/skills/agents/hooks/mcpServers` 用于声明**额外**路径（补充默认目录的自动发现，不替代）。所有路径必须相对且以 `./` 开头。

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

### RED-GREEN-REFACTOR 质量验证法

Skill 开发/修改时，推荐使用以下验证方法：

1. **基线观测（RED）**：禁用目标 Skill → 观察 Claude 的默认行为 → 记录与期望行为的具体偏差
   - 记录格式："无 Skill 时 Claude 做了 [X]，期望行为是 [Y]"
   - 至少用 2 个不同复杂度的场景观测
2. **最小规则（GREEN）**：针对观测到的偏差写最小修正规则 → 启用 Skill → 确认偏差被修正
   - 原则：一条规则修正一个偏差，不做预防性规则
3. **漏洞补充（REFACTOR）**：用不同复杂度场景（S/M/L）压力测试 → 发现新偏差 → 补充合理化预防表
   - 重点关注：Claude 在长会话或复杂任务中是否"合理化"跳过规则

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

## §5 分发与版本管理

### 版本同步

`plugin/presets/manifest.json` 与 `plugin/.claude-plugin/plugin.json` 的版本号必须保持同步。修改版本时需同时更新两处。

### 分发架构

Plugin 分发的详细架构设计见 `docs/plugin-delivery-design.md`（SSoT），包含分发策略、工具链和 CI 流程。

## §6 规范查证方法

不确定 Claude Code 组件的 API、frontmatter 字段或行为时，按以下优先级查证：

1. **claude-code-guide agent**：`Agent(subagent_type="claude-code-guide", prompt="查询 [具体问题]")`——内置 agent，可访问官方文档
2. **官方文档**：`https://code.claude.com/docs/en/`（plugins、skills、hooks、mcp、sub-agents、agent-teams）
3. **调试模式**：`claude --debug` 查看加载日志排查问题

完整的 Agent、Hook、MCP Server 规格参考见 `.claude/references/component-reference.md`（按需加载）。

### 官方 plugin-dev 工具（推荐）

Anthropic 官方 plugin-dev Plugin 提供综合开发工具：

| 组件 | 用途 | 使用场景 |
|------|------|---------|
| **plugin-validator** Agent | 综合验证（Manifest/目录/Skills/Hooks/安全） | Plugin 结构变更后 |
| **skill-reviewer** Agent | Skill 质量审查（description/内容/渐进披露） | Skill 新增或修改后 |
| **agent-creator** Agent | AI 辅助 Agent 创建 | 新增 Agent 定义时 |
| `/plugin validate` | 内置命令，验证 plugin.json 基本结构 | 快速检查 |

安装：`/plugin install plugin-dev@claude-plugins-official`
