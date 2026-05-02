---
paths:
  - "**/agents/**-orchestrator.md"
---

# Orchestrator（编排器 Sub Agent）编写规范

> Orchestrator 模式的特殊约束。通用 Sub Agent 规则见 `subagent-writing.md`。

## 命名（P0）

- `name` 固定后缀：`<domain>-orchestrator`
- 文件路径：`agents/<domain>-orchestrator.md`

## frontmatter 专属要求（P0）

```yaml
---
name: <domain>-orchestrator
description: >
  Use this agent when user invokes /<domain> or expresses intent to start
  <domain> workflow. Guides users through the complete methodology chain.

  <example>
  Context: User starting a new project from scratch
  user: "/<domain>"
  assistant: "Checks for existing project-context.md. If not found, initializes
  the project step by step, then begins the first methodology stage."
  </example>

  <example>
  Context: User returning to continue an in-progress project
  user: "继续上次的工作"
  assistant: "Reads project-context.md, identifies the last completed stage,
  displays the progress dashboard, and asks whether to resume from the
  interruption point."
  </example>

model: inherit
color: <color>
tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash"]
---
```

- `description` 必须含 2 个 example（P1）：命令触发 + 跨会话恢复

## 编排器与 Skill 的协作模型（P0）

编排器**禁止**作为 Skill 的父代理持续运行。正确流转：

`编排器激活 → 读 project-context.md → 路由 Skill → 编排器退出 → Skill 独立执行 → update-context.py → 编排器再次激活 → 展示流转选项 → 路由下一 Skill`

## context: fork 落地（P1）

编排器分派 Skill 时推荐使用 `context: fork` 实现"编排器非父代理"理念。

## 3 个标准流程（P1）

1. **项目初始化**：逐步收集信息（每次一个问题），创建产出目录
2. **阶段流转**：展示进度仪表板 + 角色适配的流转选项
3. **跨会话恢复**：读取 `resume_hint`，展示恢复点与选项

## 方法论泄漏检测（P0）

> "若删除编排器某段文字后，某个方法论步骤无法执行 → 该段为泄漏，必须移至对应 Skill。"

常见泄漏模式：

- 解释领域方法论核心概念 → 移至 Skill 用途说明或 `knowledge/`
- 特定阶段详细提示话术 → 移至贯穿 Skill
- 阶段具体执行步骤 → 移至对应 Skill

## 编排策略（P2）

**推荐 Hybrid**：固定阶段顺序 + 阶段内 Skill 自主探索。

