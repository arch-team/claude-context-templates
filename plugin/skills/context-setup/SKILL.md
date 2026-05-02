---
name: context-setup
description: >
  Use when user wants to: set up Claude Code context for their project, initialize
  .claude/ directory, create CLAUDE.md or project rules, improve Claude's understanding
  of project architecture, or expresses that Claude repeatedly produces incorrect code
  across multiple files.

  Also activate for Chinese-speaking users who mention: 初始化 Claude 上下文, 创建 .claude 目录,
  生成 CLAUDE.md, 配置 Claude 项目规范, Claude 持续不理解项目架构, 提升 AI 代码生成质量,
  上下文管理, 让 Claude 更懂项目, Claude 总是写错代码需要重复修改.
---

# Claude Context Setup

> **Skill 模式**: Inversion + Generator（信息采集 → 路由 → 产出引导）
> **方法论阶段**: 项目上下文初始化与质量提升

## HARD RULES

1. ALWAYS verify project structure before selecting initialization mode (Monorepo vs Single).
2. NEVER skip deep project scan when files exist in target directory — empty check is NOT sufficient.
3. ALWAYS read `presets/manifest.json` to get available preset list. DO NOT hardcode preset names.
4. NEVER write to `.claude/` directory without explicit user consent.
5. ALWAYS attempt existing project detection (language/framework/toolchain) before falling back to interactive selection.
6. NEVER recommend a preset that does not exist in `manifest.json`.
7. ALWAYS prefer built-in preset over generic when framework matches (e.g., FastAPI → python-fastapi, NOT generic).
8. ALWAYS use `scripts/render-template.sh` for variable substitution. DO NOT implement custom replacement logic.
9. NEVER leave `{{VARIABLE}}` or `<!-- TODO -->` placeholders unprocessed in final output.
10. ALWAYS validate rendered output against `context-schema.yaml` before declaring success.
11. ALWAYS suggest `/audit-context` after initialization to verify structure integrity.
12. NEVER report "initialization complete" without confirming target directory structure matches expected schema.

## ANTI-RATIONALIZATION

**Do not rationalize skipping project scan by claiming the directory is empty.** A directory with hidden files (like `.git/`) is NOT empty and requires deep scan to detect Monorepo structure. ALWAYS execute full project structure analysis.

**Do not rationalize using generic preset by claiming "it's more flexible".** When the user's project clearly matches a built-in preset (e.g., has `requirements.txt` with `fastapi` → python-fastapi), generic is a DOWNGRADE in quality. ALWAYS prefer specificity over generality.

**Do not rationalize skipping `manifest.json` read by claiming you "know" the preset list.** Your training data may be outdated. The preset list is dynamic (users can add custom presets). ALWAYS read the current manifest.

**Do not rationalize skipping variable validation by claiming the user will "fix it later".** Unprocessed placeholders (`{{VAR}}` or `<!-- TODO -->`) break AI context parsing. ALWAYS ensure complete rendering before handoff.

**Do not rationalize reporting success without running `/audit-context` by claiming "the files were created so it's done".** File existence ≠ structure correctness. Schema violations (missing sections, broken links, empty values) are common. ALWAYS verify with audit before declaring complete.

**It is NOT acceptable to emit partial initialization output (e.g., only CLAUDE.md without rules/) and claim it as "MVP".** Partial output violates `context-schema.yaml` required files contract. If mandatory sections are missing, HALT and ask the user for missing information.

## 启动协议

**在开始任何操作前，依次执行以下验证**:

1. **读取 preset 清单**:
   ```
   Read plugin/presets/manifest.json
   ```
   获取当前可用 preset 列表和版本信息。

2. **读取 context schema**:
   ```
   Read plugin/presets/context-schema.yaml
   ```
   了解产出必须满足的结构要求。

3. **项目结构扫描**:
   - 检查 `.claude/` 目录是否存在及其内容
   - 检测项目类型指标: `package.json`, `pyproject.toml`, `setup.py`, `cdk.json`, `go.mod`, `Cargo.toml`, `pom.xml` 等
   - 判定 Monorepo 结构: 多个子目录各有独立配置文件

**在继续执行方法论工作流之前，必须完成：上述 3 步验证全部执行完毕。**

## 方法论工作流

基于启动协议的扫描结果，路由到对应路径：

### 路由决策

| 条件 | 路径 |
|------|------|
| 无 `.claude/` 目录 | Path A: 初始化引导 |
| `.claude/` 存在但为空或无 `rules/` | Path A（带警告） |
| `.claude/` 存在且结构完整 | Path B: 优化审计 |
| 用户明确要求重新初始化 | Path A（带覆盖选项） |
| 用户询问如何优化 | Path C: 优化路由 |

### Path A: 初始化引导

1. **解释价值**: `.claude/` 目录教会 Claude Code 项目的架构、约定和标准，显著提升代码生成和审查质量
2. **推荐匹配 preset**（基于检测结果）:
   - `package.json` + React/Next.js → React + TypeScript preset
   - `pyproject.toml` / `setup.py` + FastAPI → Python + FastAPI preset
   - `cdk.json` → AWS CDK preset
   - 多子目录各有配置 → 建议 Monorepo 模式
   - 无匹配 → 告知 `/init-context` 支持 `generic` preset（AI 驱动生成）
3. **建议 `/init-context`**: 执行深度分析并自动路由到最佳路径
4. **参数预填**: 利用检测结果减少用户交互（preset 名称、Monorepo 结构）

### Path B: 优化审计

1. **确认**现有配置
2. **建议 `/audit-context`** 从 5 个维度检查质量:
   - 结构完整性（必需文件 + 推荐文件）
   - 内容质量（占位符填充率、实质内容）
   - 最佳实践合规（SSoT、链接、命名）
   - 覆盖度（架构、测试、安全、代码风格、CI/CD）
   - 可维护性（文件数、长度、断链）
3. 告知 `/audit-context` 产出 A/B/C/D 评级和优先改进建议

### Path C: 优化路由

- `.claude/` 存在 → Path B
- `.claude/` 不存在 → Path A
- Monorepo → 提示 `/init-context` 支持 Monorepo 模式

## 产出生成

本 Skill 不直接生成 `.claude/` 文件，而是**引导用户到 `/init-context` 或 `/audit-context` 命令**。

**响应模板**:

- **无 .claude/，检测到匹配 preset**: 告知检测结果 + 推荐具体 preset + 建议 `/init-context`
- **无 .claude/，无匹配**: 告知支持任意技术栈 + 建议 `/init-context`（generic 路径）
- **有 .claude/，用户抱怨质量**: 确认配置存在 + 建议 `/audit-context` + 简述审计维度
- **Monorepo**: 告知支持 Monorepo 模式 + 每子项目独立 preset + 共享根配置

**语言规则**: 匹配用户语言（中文用户用中文回复，英文用户用英文回复）。

**用户拒绝时**: "No problem. If you change your mind, just ask me to 'initialize Claude context'."

## 参考资料

| 资源 | 路径 | 用途 |
|------|------|------|
| Preset 清单 | `presets/manifest.json` | 可用 preset 列表 + 版本 |
| 结构 Schema | `presets/context-schema.yaml` | 产出必须满足的结构要求 |
| 工程原则 | `presets/_common/rules/principles/*.md` | 跨 preset 共享原则 |
| 模板变量 | `docs/template-variables.md` | 占位符格式参考 |
| 定制指南 | `docs/customization-guide.md` | Preset 创建流程 |
