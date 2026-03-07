# Claude Context Templates Plugin

Claude Code Plugin — 在 Claude Code 中一键生成生产级 `.claude/` 上下文目录。

## 安装

```bash
# 添加 marketplace（一次性）
/plugin marketplace add arch-team/claude-plugins

# 安装 Plugin
/plugin install claude-context-templates@arch-team
```

## 使用

### 命令方式

在 Claude Code 中输入：

```
/init-context
```

按提示选择语言、项目模式、技术栈，即可生成完整的 `.claude/` 目录。

### 自动检测

Plugin 会在检测到项目缺少 `.claude/` 目录时自动建议生成。

## 支持的预设

| 预设 | 技术栈 | 说明 |
|------|--------|------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | DDD + Clean Architecture, TDD, API Design |
| `react-typescript` | React + TypeScript + Vite | Feature-Sliced Design, State Management |
| `aws-cdk` | AWS CDK + TypeScript | Construct Patterns, Security, Cost Optimization |

## 功能特性

- **对话式交互**：自然语言对话，非固定菜单
- **项目探测**：自动检测 `package.json`/`pyproject.toml` 推断技术栈
- **双语支持**：English / 中文模板
- **Monorepo 支持**：多子项目独立配置
- **可选规则**：按需选择可选规范文件

## 本地开发

```bash
# 构建 Plugin（同步 presets）
./scripts/build-plugin.sh

# 本地测试
/plugin marketplace add ./plugin
/plugin install claude-context-templates@local-test
```

## 许可证

[MIT](../LICENSE)
