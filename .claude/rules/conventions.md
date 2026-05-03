---
paths:
  - "**"
---

# 项目约定

> 本仓库内所有操作遵守以下约定。

## 语言约定

- 对话和文档使用**中文**
- 保持英文：CLI 命令、技术术语（Harness Engineering、SKILL.md、Hook）、代码标识符、文件名路径、HARD RULES 段落、ANTI-RATIONALIZATION 段落、frontmatter `description` 字段

## Git 提交规范

格式：`<类型>(<范围>): <简短描述>` — Conventional Commits 三段式。

**类型**：

| 类型 | 说明 |
|------|------|
| `feat` | 新 Skill、新 Command、新 Schema |
| `fix` | Schema 缺陷、脚本错误、Prompt 逻辑修复 |
| `docs` | 文档变更 |
| `refactor` | 不改变行为的结构调整 |
| `test` | 新增或修改评估用例 |
| `chore` | 配置、依赖 |

**范围**：`presets` / `plugin` / `skills` / `commands` / `hooks` / `scripts` / `docs` / `.claude` / `devpace` / `config` / `*`

## 优先级分级

| 级别 | 语义 | 偏离处理 |
|------|------|---------|
| P0 | 必须遵守 | 违反即不合规 |
| P1 | 推荐遵守 | 偏离需说明理由 |
| P2 | 可选 | 按需采纳 |
