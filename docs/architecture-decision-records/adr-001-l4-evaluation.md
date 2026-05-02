# ADR 001: L4 编排器引入评估

## Status

**Proposed** (v2.0 三支柱实现前)

## Context

claude-context-templates v2.0 三支柱（漂移检测 / 升级路径 / 质量门禁）是否需要引入 L4 编排器？

**评估依据**: `rules/plugin-design.md` "L4 编排器启用判据"章节

## Decision

**不引入 L4，除非 v2.0 实现时满足 `plugin-design.md` 的阶段 A + 阶段 B 判据**

### 三支柱逐项分析

| v2.0 支柱 | 实现方式 | 是否需要 L4 | 理由 |
|----------|---------|------------|------|
| A. 漂移检测 | `/audit-context` 命令 + SessionStart Hook | ❌ 不需要 | 单命令足够，无需跨 Skill 状态同步 |
| B. 升级路径 | `/update-context` 命令 + `.preset-meta.yml` 三向合并 | ⚠️ 取决于复杂度 | 简单 diff+merge 用 Command 足够；跨大版本迁移可能需要 |
| C. 质量门禁 | Hook 模板库 | ❌ 不需要 | Hook 独立运行，无编排需求 |

### 当前判据对照（阶段 A 必要条件）

| 判据 | 量化标准 | 当前状态 | 满足 |
|------|---------|---------|------|
| 多角色路由 | 角色数 ≥3 | 当前无角色定义 | ❌ |
| Skill 数量规模 | Skill 数 ≥5 | 当前 1 个（context-setup） | ❌ |
| 跨会话刚需 | 跨 ≥3 个会话 + 持久化角色状态 | 无跨会话状态需求 | ❌ |
| 单 Skill 负荷 | 任一 Skill ≥40K tokens | context-setup 约 10K | ❌ |

**阶段 A 判据无一满足 → 不引入 L4**

### 关键决策点

支柱 B 的 `/update-context` 是唯一可能触发 L4 的场景：

- **简单场景**（文件 diff + merge）：Command 路由到 Skill 足够
- **复杂场景**（跨大版本迁移 + 用户分批确认 + 回滚）：可能需要编排器

## 重新评估触发条件

满足以下**任一**条件时重新评估本 ADR：

1. Skill 总数达到 5 个（setup / audit / update / migrate / rollback）
2. 单个 Skill token 消耗 ≥40K
3. `/update-context` 需要多步门控 + 跨会话状态持久化
4. 出现 3+ 角色且需根据状态路由

## Consequences

完整的后果分析见 `rules/plugin-design.md` "L4 编排器启用判据"章节的"代价衡量"。

**不引入 L4 的影响**：
- ✅ 保持架构简洁，调试透明
- ✅ 无 5-10K tokens 固定激活开销
- ❌ 若 v2.0 后期 Skill 数激增，可能需要返工

## Review Timeline

| 时间点 | 动作 |
|--------|------|
| 本 ADR | 初次评估，决定不引入 |
| v2.0 M2.B.1 实现完成后 | 基于 `/update-context` 实际复杂度重新评估 |
| v2.0 RC 版本前 | 最终决策 |
