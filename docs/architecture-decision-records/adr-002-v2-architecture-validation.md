# ADR-002: v2.0 架构验证

> 决策日期：2026-05-02
> 状态：已确认

## 背景

基于 v2.0 三大支柱的技术设计分析，确认当前架构适用性。

## 三大支柱架构需求

| 支柱 | 核心能力 | 实现方式 | 需要的架构层 |
|------|---------|---------|-------------|
| **A. 漂移检测** | `/audit-context` — 检查结构完整性、SSoT 违反、链接有效性 | Command + validation scripts | L5 (Command) + Scripts |
| **B. 升级路径** | `/update-context` — Preset 增量更新，三路合并 | Command + diff/merge 算法 | L5 (Command) + Scripts |
| **C. 质量门禁** | Hooks 模板库（建议/引导/强制三档） | Hook 脚本模板 | L5 (Hooks) |

## 架构验证结论

✅ **v2.0 MVP 确认不需要 L1/L2/L4 层**：
- 三大支柱均为**工具层面的增强**，不涉及方法论多阶段执行
- 继续使用 L3（Skill）+ L5（Command/Hook）两层架构

⚠️ **增强版本可能需要 L3 Skill**：
- 如引入"交互式漂移修复向导"（audit 后的引导式修复）
- 如引入"智能冲突解决"（update 时的语义分析）
- 如引入"Hook 推荐引擎"（根据项目特征推荐 Hook 组合）

## Phase 2A 触发条件（激进精简）

当以下条件**全部满足**时，执行 Phase 2A（进一步优化至 ~8,000 tokens）：
1. ✅ v2.0 三大支柱实现完成
2. ✅ 真实代码确认无 L3 Skill 需求
3. ✅ 连续 3 个月无架构扩展计划

**Phase 2A 内容**（如触发）：
- 创建 `skill-essentials.md`（MVP 必需部分，~1,500 tokens）
- 移动 `skill-writing.md` → `references/`（完整规范按需加载）
- 合并 `plugin-architecture.md`（统一讲完整架构故事）
- 预计节省：1,600 tokens（17% 进一步削减）
