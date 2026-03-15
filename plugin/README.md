# Claude Context Templates Plugin

Claude Code Plugin — 生成和审计 `.claude/` 上下文目录，提升 Claude Code 对项目的理解能力。

## 安装

```bash
# 添加 marketplace（一次性）
/plugin marketplace add arch-team/claude-context-templates

# 安装 Plugin
/plugin install claude-context-templates@claude-context-templates
```

## 命令

### /init-context — 生成上下文目录

```
/init-context
```

对话式交互生成 `.claude/` 目录。自动探测项目技术栈，支持单项目和 Monorepo 模式。

### /audit-context — 审计上下文目录

```
/audit-context
```

审计现有 `.claude/` 目录的质量，从 5 个维度评估并给出改进建议：

| 维度 | 检查内容 |
|------|----------|
| 结构完整性 | 关键文件是否齐全 |
| 内容质量 | 是否有实质内容、未填写的占位符 |
| 最佳实践 | Section 0 速查卡片、双向链接、SSoT |
| 规范覆盖度 | 架构、测试、安全、代码风格、CI/CD |
| 可维护性 | 文件数量、长度、断链、冗余 |

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
# 本地测试（使用内置的 local-dev marketplace）
/plugin marketplace add ./plugin
/plugin install claude-context-templates@local-dev
```

> Plugin 内置了 `marketplace.json`（marketplace 名称为 `local-dev`），简化本地开发测试流程。

> 构建和发布脚本说明见仓库根目录 `CONTRIBUTING.md`。

## 许可证

[MIT](../LICENSE)
