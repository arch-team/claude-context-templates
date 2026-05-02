# Claude Code 组件参考

> **职责**：Agent、Hook、MCP Server 的完整规格参考。按需加载，仅在开发/修改对应组件时使用。
>
> **核心规范引用**：Plugin 开发遵循 agent-platform 规范体系：
> - 五层架构：`rules/plugin-design.md`
> - SKILL.md 8 段式：`rules/skill-writing.md`
> - Command/Hook/Script：`rules/hook-command-script.md`
> - 合规清单：`rules/compliance-checklist.md`

**章节索引**：[Agent 定义](#agent-定义) | [Hooks](#hooks) | [MCP Server 配置](#mcp-server-配置) | [Plugin 开发辅助参考](#plugin-开发辅助参考) | [规范查证方法](#规范查证方法)

## Agent 定义

Agent 文件放在 `agents/` 目录，frontmatter 必须包含 `name` 和 `description`。

**合法 frontmatter 字段**：

| 字段 | 说明 |
|------|------|
| `name` | **必填**，Agent 名称 |
| `description` | **必填**，Agent 描述 |
| `tools` | 允许的工具列表 |
| `disallowedTools` | 禁止的工具列表 |
| `model` | `sonnet` / `opus` / `haiku` |
| `color` | UI 背景色（`blue`/`cyan`/`green`/`yellow`/`red`/`magenta`） |
| `permissionMode` | 权限模式 |
| `maxTurns` | 最大轮次 |
| `skills` | 可用 Skill 列表 |
| `mcpServers` | 可用 MCP Server |
| `memory` | 记忆持久化级别（见下方备注） |
| `hooks` | Agent 级 Hook 配置 |
| `isolation` | `worktree` = 独立 git worktree 运行 |

`memory` 持久化路径：`user` -> `~/.claude/agent-memory/<name>/`，`project` -> `.claude/agent-memory/<name>/`，`local` -> 仅当前会话。下次 fork 时自动加载。`isolation: worktree` 时无变更自动清理。

通过 Agent 工具调用：`Agent(subagent_type="agent-name", prompt="...", description="...")`。子 agent 不能再嵌套调用 Agent。

## Hooks

Hook 事件名称区分大小写。可用事件：

| 事件 | 触发时机 | 可阻断? |
|------|---------|---------|
| `PreToolUse` | 工具执行前 | 是（exit 2） |
| `PostToolUse` | 工具执行成功后 | 否 |
| `PostToolUseFailure` | 工具执行失败后 | 否 |
| `UserPromptSubmit` | 用户提交 prompt | 是 |
| `PreCompact` | 上下文压缩前（manual/auto） | 否 |
| `Stop` | Claude 完成响应 | 是 |
| `SessionStart` / `SessionEnd` | 会话开始/结束 | 否 |
| `SubagentStart` / `SubagentStop` | 子 agent 启停 | 部分 |
| `TeammateIdle` / `TaskCompleted` | 团队协作事件 | 是（exit 2） |

配置位置（优先级从高到低）：

1. managed settings
2. `.claude/settings.json`（项目共享）
3. `.claude/settings.local.json`（项目本地）
4. `~/.claude/settings.json`（全局）
5. Plugin `hooks/hooks.json`

Hook 脚本中使用 `${CLAUDE_PLUGIN_ROOT}` 引用 Plugin 根目录。exit 0 = 成功，exit 2 = 阻断，其他 = 非阻断错误。

### Hook 类型

| 类型 | 说明 | 超时默认 |
|------|------|---------|
| `command` | 执行 shell 命令，通过 stdin 接收 JSON 输入 | 无默认 |
| `prompt` | LLM 评估 prompt 内容，决定是否放行 | 30s |
| `agent` | LLM agent 执行（有工具访问权限），决定是否放行 | 60s |

`command` 类型额外支持 `"async": true`（后台执行，不阻塞主流程）。`prompt`/`agent` 类型具有语义理解能力，适合替代简单的正则匹配做复杂判断。

### Skill 级 Hooks

SKILL.md 的 `hooks` frontmatter 字段支持定义仅在该 Skill 激活时生效的 Hook：

```yaml
hooks:
  PreToolUse:
    - matcher:
        tool_name: "Write|Edit"
      hooks:
        - type: prompt
          prompt: "验证此写入是否合法..."
          timeout: 15
```

Skill 级 Hook 与全局 hooks.json 互补——全局做通用检查，Skill 级做精细控制。

### 约束执行分级

选择约束的执行保障级别时参考：

| 可靠性 | 机制 | 适用场景 |
|--------|------|---------|
| 最高 | Hook command + exit 2 | 不可逆操作阻断、模式保护 |
| 高 | Hook prompt/agent | 需语义理解的检查 |
| 中 | Skill 指令 + 铁律标记 | 工作流约束 |
| 基线 | Rules 文本建议 | 行为规范、风格指引 |

## MCP Server 配置

项目级配置放在根目录 `.mcp.json`，格式：

```json
{
  "mcpServers": {
    "server-name": {
      "command": "path/to/server",
      "args": ["--flag"],
      "env": { "KEY": "${ENV_VAR}", "KEY2": "${VAR:-default}" }
    }
  }
}
```

Plugin 内部引用路径时使用 `${CLAUDE_PLUGIN_ROOT}`。也可在 `plugin.json` 的 `mcpServers` 字段内联定义。

## Plugin 开发辅助参考

> 低频使用的 Plugin 开发参考信息。高频规范见 `rules/plugin-dev-spec.md`（始终加载）。

### plugin.json 可选字段

当前采用最小格式（`name` + `description` + `version`）。以下为合法可选字段：

`homepage`、`repository`（字符串）、`license`、`keywords`、`commands`、`agents`、`skills`、`hooks`、`mcpServers`、`outputStyles`、`lspServers`。其中 `commands/skills/agents/hooks/mcpServers` 用于声明**额外**路径（补充默认目录的自动发现，不替代）。所有路径必须相对且以 `./` 开头。

### Skill RED-GREEN-REFACTOR 质量验证法

Skill 开发/修改时，推荐使用以下验证方法：

1. **基线观测（RED）**：禁用目标 Skill → 观察 Claude 的默认行为 → 记录与期望行为的具体偏差
   - 记录格式："无 Skill 时 Claude 做了 [X]，期望行为是 [Y]"
   - 至少用 2 个不同复杂度的场景观测
2. **最小规则（GREEN）**：针对观测到的偏差写最小修正规则 → 启用 Skill → 确认偏差被修正
   - 原则：一条规则修正一个偏差，不做预防性规则
3. **漏洞补充（REFACTOR）**：用不同复杂度场景（S/M/L）压力测试 → 发现新偏差 → 补充合理化预防表
   - 重点关注：Claude 在长会话或复杂任务中是否"合理化"跳过规则

### 官方 plugin-dev 工具（推荐）

Anthropic 官方 plugin-dev Plugin 提供综合开发工具：

| 组件 | 用途 | 使用场景 |
|------|------|---------|
| **plugin-validator** Agent | 综合验证（Manifest/目录/Skills/Hooks/安全） | Plugin 结构变更后 |
| **skill-reviewer** Agent | Skill 质量审查（description/内容/渐进披露） | Skill 新增或修改后 |
| **agent-creator** Agent | AI 辅助 Agent 创建 | 新增 Agent 定义时 |
| `/plugin validate` | 内置命令，验证 plugin.json 基本结构 | 快速检查 |

安装：`/plugin install plugin-dev@claude-plugins-official`

## 规范查证方法

不确定 Claude Code 组件的 API、frontmatter 字段或行为时，按以下优先级查证：

1. **claude-code-guide agent**：`Agent(subagent_type="claude-code-guide", prompt="查询 [具体问题]")`——内置 agent，可访问官方文档
2. **官方文档**：`https://code.claude.com/docs/en/`（plugins、skills、hooks、mcp、sub-agents、agent-teams）
3. **调试模式**：`claude --debug` 查看加载日志排查问题
