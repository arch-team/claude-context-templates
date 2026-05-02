---
paths:
  - "**/agents/**"
---

# Sub Agent 编写规范（通用）

> 本文件覆盖所有 Sub Agent 模式共享的规则，写编排器时额外参考 `orchestrator-writing.md`。

## frontmatter 规则（P0）

```yaml
---
name: kebab-case-name          # 与文件名一致
description: >
  Use when <English trigger phrase>.
  当用户 <中文触发短语> 时使用。
model: inherit                 # 禁止硬编码模型名
tools: ["Read", "Grep", "Glob"]  # 最小权限集，显式声明
---
```

**工具权限原则（P0）**：

| Sub Agent 类型 | 推荐工具集 | 理由 |
|---------------|-----------|------|
| Reviewer / Parallel Worker（只读） | `Read`, `Grep`, `Glob`, `WebFetch` | 不需写权限 |
| Orchestrator / Generator（读写） | 按需追加 `Write`, `Edit`, `Bash` | 最小权限 |

省略 `tools` 字段 = 继承全部工具 = 违反最小权限。

## Sub Agent 模式分类

| 模式 | 职责 | 专属约束 |
|------|------|---------|
| **Orchestrator** | 流程编排 / 角色路由 / 跨会话恢复 | 不含方法论逻辑（见 `orchestrator-writing.md`） |
| **Reviewer** | 质量审查 / 合规校验 | 只读工具；产出为评审报告 |
| **Specialist** | 专家人格（安全/架构） | 可写入；聚焦单一领域 |
| **Parallel Worker** | 并行调查 / 独立验证 | 只读；互不依赖 |

## 上下文隔离（P0）

- Sub Agent 拥有独立上下文窗口
- 产出通过文件系统或最终消息回传主 Agent
- 禁止持续作为主 Agent 的父代理运行——Skill 执行消耗大量 token，Sub Agent 持续运行会导致上下文溢出
- 编排器分派方法论 Skill 时使用 `context: fork`

## 契约层规则（P0/P1）

- 3+ 角色 → 必须定义 `contracts/roles.md`（P0）
- 2 角色 → 推荐定义 `contracts/roles.md`（P1）
- Sub Agent 通过读取 roles.md 获取角色信息，禁止内联硬编码
- `project-context.md` 由 `update-context.py` 独占写入，Sub Agent 只读

## 与 Skill 的关系

- Sub Agent 可路由到 Skill，但不执行方法论步骤
- Skill 产出通过文件系统传递，Sub Agent 读取后决策下一步
- Sub Agent 的 description 禁止摘要 Skill 工作流步骤

