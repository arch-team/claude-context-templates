---
paths:
  - "**/skills/**"
  - "**/SKILL.md"
---

# Token 利用率优化规范

> 核心铁律：优化 = 删除冗余 + 重组载体，**仅**当精简仅影响 Context Budget 且不触碰 Agent 质量模型前三维红线时方可执行。

## 违规检测模式表（机械化扫描）

| 检测模式 | 违规类型 | 修复动作 |
|---------|---------|---------|
| SKILL.md 中连续 >10 行知识/原理描述 | 方法论泄漏（IA-3） | 提取到 `references/methodology.md` |
| SKILL.md 内嵌完整产出示例 | Example 泄漏 | 移至 `examples/` 或 Annotated Template |
| description 含流程步骤描述 | 触发器膨胀（IA-8） | 仅保留触发短语 + 领域上下文 |
| 同一步骤主干多处重复 | 冗余叙述 | 保留一处权威表述 |
| 角色 / Schema 在 SKILL.md 重述 | 违反单一权威（IA-6） | 引用 `contracts/` |
| HARD RULES 使用"如果...则..."条件句 | 违反认知清晰（IA-9） | 改 MUST / NEVER / ALWAYS 祈使句 |
| references/ 单文件 >150 行 | 违反按需加载（IA-5） | 按子主题拆分 |
| references/ ≥3 文件无 `_index.yml` | 违反可发现性（IA-8） | 创建顶层索引 |
| template / example 同义双份维护 | 双文件漂移 | 合并为 Annotated Template |

## Token 消耗优先级

| 消耗来源 | 典型占比 | 允许动作 |
|---------|---------|---------|
| SKILL.md 主干 | 30-40% | 移除方法论泄漏、内嵌示例、重复描述 |
| references/ 按需加载 | 取决于引用频率 | 拆分 ≤150 行、建 `_index.yml` |
| templates + examples | 10-20% | 采用 Annotated Template |
| HARD RULES / ANTI-RATIONALIZATION | 5-15% | 仅合并同质，禁止削弱约束 |
