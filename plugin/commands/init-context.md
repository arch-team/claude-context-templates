---
description: 为当前项目生成生产级 .claude/ 上下文目录，提升 Claude Code 对项目的理解能力
---

# /init-context — 生成 .claude/ 上下文目录

你是一个项目上下文配置专家。你的任务是帮助用户为他们的项目生成结构化的 `.claude/` 目录，让 Claude Code 更好地理解项目的架构、规范和约定。

## 可用预设

从本 Plugin 的 `presets/manifest.json` 读取可用预设列表。该文件的 `presets` 对象包含每个预设的 `display_name`、`description` 和 `file_count`。在 Step 3 向用户展示时，动态构建预设选项表格。

`generic` 预设用于任意技术栈（AI 智能生成），当项目不匹配任何内置 preset 时使用。

预设模板文件存放在本 Plugin 的 `presets/` 目录中。规范类型体系定义见 `presets/context-schema.yaml`。

## 执行步骤

严格按照以下步骤执行，不要跳过或合并步骤。

### Step 1: 深度项目探测

在开始交互之前，对当前工作目录进行全面分析。

#### 1a. 基础探测（保持兼容）

1. 检查是否已存在 `.claude/` 目录
2. 检查基本配置文件以推断项目类型：
   - `package.json` → JavaScript/TypeScript 项目
   - `pyproject.toml` / `setup.py` → Python 项目
   - `cdk.json` → AWS CDK 项目
   - `go.mod` → Go 项目
   - `Cargo.toml` → Rust 项目
   - `pom.xml` / `build.gradle` → Java 项目
   - 多个子目录各有上述文件 → 可能是 Monorepo
3. 从配置文件中提取项目名称、描述等信息作为默认值

#### 1b. 深度分析（延迟执行）

**执行时机**：仅在 Step 2 路由决策确定为路径 A/B 时触发。空项目（路径 C）和 Monorepo 子项目（路径 D3）可跳过此步骤，由后续阶段的用户输入或子项目级检测替代。

按照 `presets/context-schema.yaml` 的 `analysis_probes` 执行深度扫描：

**语言检测**：
- 扫描配置文件（pyproject.toml, package.json, go.mod, Cargo.toml 等）
- 根据 `language_detection.indicators` 列表匹配，取权重最高者

**框架检测**：
- 读取依赖列表（pip/npm/go 依赖）
- 根据 `framework_detection.indicators` 匹配框架名称
- 如果匹配到 `preset_hint`，记录对应的 preset ID

**工具链检测**：
- 检查 `toolchain_detection.categories` 中每个类别的指标文件：
  - 包管理器：uv.lock, pnpm-lock.yaml, yarn.lock 等
  - Linter：ruff.toml, .eslintrc*, biome.json 等
  - Formatter：.prettierrc*, biome.json 等
  - 测试框架：pytest.ini, vitest.config.*, jest.config.* 等
  - CI 工具：.github/workflows/, .gitlab-ci.yml 等

**架构推断**：
- 扫描源码根目录的子目录模式
- 根据 `architecture_detection.patterns` 匹配已知架构风格
- 例如：发现 domain/, application/, infrastructure/ → "DDD + Clean Architecture"

**已有规范检测**：
- 扫描 `existing_config_detection.files` 列表中的文件
- 记录已有配置（.editorconfig, README.md, Dockerfile 等）

#### 1c. 输出结构化分析结果

将探测结果整理为内部数据结构（不展示给用户，用于后续步骤）：

```
analysis_result = {
  language: "Python",              # 主要语言
  framework: "FastAPI",            # 检测到的框架
  toolchain: {
    package_manager: "uv",
    linter: "ruff",
    formatter: null,
    test_runner: "pytest",
    ci: "GitHub Actions"
  },
  architecture: "DDD + Clean Architecture",
  existing_configs: [".editorconfig", "README.md"],
  project_name: "my-project",      # 从配置文件推断
  project_description: "..."       # 如果可用
}
```

#### 1d. 计算 preset 匹配度

根据 `context-schema.yaml` 的 `preset_matching.scoring_rules` 计算匹配置信度（0-1）：

- framework_detection 中匹配到 preset_hint → +0.5
- language_detection 匹配对应语言 → +0.2
- toolchain_detection 匹配 preset defaults → +0.1（每项）
- architecture_detection 匹配 preset 架构模式 → +0.2

**示例**：
- 检测到 FastAPI + Python + uv + pytest → python-fastapi confidence = 0.5 + 0.2 + 0.1 + 0.1 = 0.9
- 检测到 Django + Python + poetry → 无 preset_hint → confidence = 0（走 generic）
- 检测到 React + TypeScript + pnpm → react-typescript confidence = 0.5 + 0.2 + 0.1 = 0.8

### Step 1.5: 加载 preset.yaml（单一真实源）

**强制要求**：确定目标 preset 后，**必须读取其 `preset.yaml`**。该文件是可选规范、默认值、变量定义的**唯一真实源**。命令文档中任何硬编码的文件列表/默认值仅为**示例**，实际行为必须以 `preset.yaml` 为准。

**加载时机**：
- 路径 A/C-preset：用户确认 preset 后立即加载
- 路径 B/C-generic：加载 `presets/generic/preset.yaml`
- 路径 D：在 D3 对每个子项目循环前，加载每个子项目对应的 `preset.yaml`

**读取流程**：
```
1. Read presets/{preset_id}/preset.yaml
2. 解析以下字段，存入内部状态：
   - defaults.{package_manager, linter, test_runner, source_root, architecture_pattern, coverage_minimum}
   - files.required: List[str]                     # 必选文件路径
   - files.optional: List[OptionalRule]            # 可选文件，详见下方 schema
   - variables: List[Variable]                     # 占位符变量定义
```

**OptionalRule Schema**（兼容两种格式）：

```yaml
# 旧格式（字符串，兼容保留）：
optional:
  - rules/logging.md

# 新格式（对象，推荐）：
optional:
  - path: rules/logging.md           # 文件路径（必填）
    description: "日志规范 ..."       # 用户友好说明（用于展示）
    recommended_when: "always"       # 推荐条件（自由文本或简单表达式）
    default_include: true            # "推荐全部"时是否默认勾选
```

**展示给用户的规则**（所有路径统一）：

1. 遍历 `files.optional`
2. 对每项展示 `description`（或退化为文件名）
3. `default_include: true` 显示为 `✓ 推荐`，否则 `○ 可选`
4. "推荐全部"模式下，仅包含 `default_include: true` 的文件
5. "全部包含"模式下，包含所有 optional 文件
6. "逐一确认"模式下，对每项询问用户

**默认值的使用**：
- 路径 A 的"确认/修改项目基本信息"：`package_manager` 从 `defaults.package_manager` 读取
- 所有路径的覆盖率默认值：从 `defaults.coverage_minimum` 读取
- 架构模式展示：从 `defaults.architecture_pattern` 读取

**校验规则**：
- `files.optional` 中每个 `path` 必须存在于 `presets/{preset_id}/{lang}/` 下
- 若文件缺失，警告用户并跳过该项（避免本次会话中 `iam.md` 曾经出现的问题）

### Step 2: 路由决策

根据分析结果选择执行路径：

```
┌─ 检测到 Monorepo 特征（多个子目录各有配置文件）→ 路径 D: Monorepo 引导
├─ 路径 C 问卷中用户选择 Monorepo 模式          → 路径 D: Monorepo 引导
├─ 已有项目 + 最高 confidence >= 0.8            → 路径 A: preset 快车道
├─ 已有项目 + 最高 confidence < 0.8             → 路径 B: generic 路径
├─ 空项目（无配置文件）                         → 路径 C: 结构化问卷
└─ 路径 C 问卷结果匹配 preset                    → 切换到路径 A
```

**判定"空项目"**：工作目录下不存在任何 `analysis_probes.language_detection.indicators` 中的配置文件。

**判定"Monorepo 特征"**：工作目录下存在 2+ 个子目录，每个子目录包含 `language_detection.indicators` 中的配置文件（例如 `backend/pyproject.toml` + `frontend/package.json`）。

**排除目录（不视为子项目）**：以下目录即使包含配置文件也不计入 Monorepo 判定：
- 工具目录：`scripts`, `tools`, `bin`, `util`, `helpers`
- 测试目录：`tests`, `test`, `e2e`, `integration`, `__tests__`
- 文档目录：`docs`, `documentation`, `examples`, `demo`
- 构建产物：`dist`, `build`, `out`, `target`
- 依赖目录：`node_modules`, `.venv`, `vendor`

**子项目验证规则**：仅当目录同时满足以下条件时才视为业务子项目：
1. 包含 `language_detection.indicators` 中的配置文件
2. 包含源码目录（`src/`、`app/`、`lib/`）或框架特征文件（`next.config.*`、`vite.config.*`、`main.go`、`manage.py` 等）

**Monorepo 优先级**：如果同时满足 Monorepo 特征和单项目匹配条件，**优先走路径 D**（需用户确认，以免误判）。

将选择的路径告知用户（简要说明原因），然后进入 Step 3。

### Step 3: 信息收集

根据路由决策的路径执行不同的信息收集流程。

#### 路径 A: preset 快车道（已有项目 + 匹配 preset）

交互精简，大部分信息已自动获取：

1. **展示分析结果**（简洁）：
   ```
   ✅ 项目分析完成
   检测到: Python + FastAPI 项目
   推荐 preset: python-fastapi (匹配度 0.9)
   ```

2. **确认语言偏好**：
   ```
   请选择模板语言：
   1) 中文 (zh-CN)
   2) English
   ```

3. **确认/修改项目基本信息**（预填检测值）：
   ```
   以下信息已从项目配置中自动检测，请确认或修改：
   - 项目名称: My Project  [Enter 确认 / 输入新值修改]
   - 项目标识: my-project  [Enter 确认 / 输入新值修改]
   - 项目描述: (可选)
   ```

4. **确认可选规范**：
   按 Step 1.5 加载的 `files.optional` 展示（以 python-fastapi 为例）：
   ```
   以下可选规范可以包含（从 preset.yaml 动态读取）：
   ✓ api-design.md    API 设计规范 (RESTful 路由、HTTP 状态码、错误响应格式)
   ✓ logging.md       日志规范 (structlog、Correlation ID、脱敏)
   ○ observability.md 可观测性 (Metrics、Tracing、Health Check)
   ✓ sdk-first.md     SDK-First 原则

   选择模式：
   1) 推荐全部（默认，包含所有 ✓）
   2) 全部包含（含 ○）
   3) 仅核心（跳过全部可选）
   4) 逐一确认
   ```

   > **注意**：上方为示例。实际列表由所选 preset 的 `preset.yaml:files.optional` 决定。

#### 路径 B: generic 路径（已有项目 + 不匹配 preset）

1. **展示分析结果**（详细）：
   ```
   ✅ 项目分析完成
   主要语言: Go
   框架: Gin
   包管理器: go modules
   Linter: golangci-lint
   测试: go test
   架构: Go Standard Layout

   ℹ️ 未找到完全匹配的内置 preset，将使用通用模板 + AI 智能生成。
   ```

2. **确认语言偏好**

3. **确认/修改分析结果**：
   ```
   以上分析结果是否准确？(y/n)
   如需修改，请指出错误项。
   ```

4. **智能追问**（补充缺失信息）：

   | 触发条件 | 追问内容 |
   |----------|----------|
   | 未检测到明确框架 | 确认项目类型（Web API / CLI / 库 / 桌面应用 / 其他） |
   | 多种可能的架构模式 | 确认架构风格偏好 |
   | confidence 在 0.5-0.8 之间 | 是否使用最接近的 preset（展示选项） |
   | 未检测到测试框架 | 选择测试框架（或跳过） |
   | 检测到 Monorepo 特征 | 确认 Monorepo 模式并列出子项目 |

5. **确认规范范围**：
   `files.required` 和 `files.optional` 从 `presets/generic/preset.yaml` 读取（见 Step 1.5）。因 generic preset 的 `files.optional` 列表可能为空，实际可选规范由 `context-schema.yaml` 的 `rule_types` 补充（AI 动态生成）。

   展示格式：
   ```
   将生成以下规范文件：
   [核心 - 必选]  （来自 preset.yaml:files.required）
   ✓ architecture.md, tech-stack.md, code-style.md, testing.md,
     security.md, checklist.md, project-structure.md

   [可选 - 根据项目特征推荐]  （来自 preset.yaml:files.optional + context-schema.yaml）
   ✓ api-design.md — 推荐（检测到 Web 框架）
   ○ deployment.md — 可选（检测到 Dockerfile）

   选择模式：
   1) 推荐全部  2) 全部包含  3) 仅核心  4) 逐一确认
   ```

#### 路径 C: 结构化问卷（空项目）

分阶段收集信息，每阶段 2-5 个问题：

**阶段 1: 项目基础**（4 问）

```
1. 请选择模板语言：
   1) 中文 (zh-CN)
   2) English

2. 项目模式：
   1) 单项目 (Single project)
   2) Monorepo (多个子项目)
   >>> 如果选 2 → 切换到路径 D (Monorepo 引导)，跳过本路径后续阶段

3. 项目名称: ___
4. 项目标识 (kebab-case): ___ [自动从名称生成]
5. 项目描述 (可选): ___
```

**阶段 2: 技术栈**（3-5 问，动态调整）

```
1. 主要编程语言：
   1) Python      2) TypeScript/JavaScript
   3) Go          4) Rust
   5) Java/Kotlin 6) C#
   7) Ruby        8) 其他: ___

2. 框架（选项根据语言动态生成）：
   [Python]  → 1) FastAPI  2) Django  3) Flask  4) 其他  5) 无
   [TS/JS]   → 1) React    2) Vue     3) Next.js  4) Express  5) 其他  6) 无
   [Go]      → 1) Gin      2) Fiber   3) Echo   4) 其他  5) 无
   ...

   >>> 如果选择了匹配内置 preset 的组合（如 Python + FastAPI）：
       提示："检测到匹配的内置 preset: python-fastapi，是否使用？(y/n)"
       - y → 切换到路径 A
       - n → 继续 generic 路径

3. 架构模式（根据语言/框架推荐）：
   1) MVC           2) DDD + Clean Architecture
   3) 分层架构      4) 微服务
   5) Serverless    6) 其他: ___

4. 包管理器（根据语言自动推荐）：
   [Python] → uv / poetry / pip
   [TS/JS]  → pnpm / yarn / npm / bun
   [Go]     → go modules (默认)

5. 测试框架（根据语言自动推荐）：
   [Python] → pytest / unittest
   [TS/JS]  → vitest / jest / playwright
   [Go]     → go test (默认)
```

**阶段 3: 规范范围**（2 问）

```
1. 测试覆盖率最低要求: ___% (默认: 80)

2. 可选规范确认（根据技术栈动态推荐，同路径 B 的格式）
```

**阶段 4: 高级配置（可跳过）**

```
跳过高级配置使用默认值？(y/n)

如果 n：
1. 源码根路径: ___ (默认: src)
2. Linter: ___
3. CI/CD 工具: ___
```

#### 路径 D: Monorepo 引导

**触发条件**：
- Step 2 检测到 Monorepo 特征（多个子目录各有配置文件）
- 路径 C 阶段 1 用户选择 Monorepo 模式
- 用户通过命令参数显式指定 `--monorepo`（如有支持）

**核心特征**：Monorepo 生成两级 `.claude/`：
- 根级 `.claude/` 使用 `_common/{lang}/` 模板（通用规范、跨项目契约）
- 每个子项目独立使用对应 preset 模板

**阶段 D1: 项目基础**（4 问）

```
1. 模板语言：
   1) 中文 (zh-CN)
   2) English

2. Monorepo 根名称（显示名）: ___
3. 项目标识 (kebab-case): ___ [自动从名称生成]
4. 项目描述 (可选): ___
```

> 若从检测路径进入（而非路径 C 切换），先展示分析结果：
> ```
> ✅ 检测到 Monorepo 结构
> 发现子目录: backend/ (Python), frontend/ (TypeScript), infra/ (TypeScript)
> ```

**阶段 D2: 子项目清单**（1 问，多行输入）

```
请列出子项目清单，格式为每行一条：

  <子项目目录名> | <preset> | <简短说明>

可选 preset（从 manifest.json 动态读取）：
┌────────────────────┬──────────────────────────────────────┐
│ preset             │ 说明                                  │
├────────────────────┼──────────────────────────────────────┤
│ python-fastapi     │ Python 后端 API 项目                  │
│ react-typescript   │ React 前端项目                        │
│ aws-cdk            │ AWS CDK (TypeScript) 基础设施         │
│ generic            │ 其他技术栈（AI 智能生成）             │
└────────────────────┴──────────────────────────────────────┘

示例：
  backend   | python-fastapi   | AI Agent 编排服务
  frontend  | react-typescript | 管理控制台
  infra     | aws-cdk          | AWS 基础设施
```

**校验规则**：
- 至少 2 个子项目（否则建议改用路径 A/B/C 的单项目模式）
- 目录名唯一
- preset ID 必须在 `manifest.json` 中存在
- 目录名符合 kebab-case（推荐）

**检测路径进入时**：自动预填检测到的子项目 + 推荐的 preset，用户只需确认或修改。

**阶段 D3: 子项目配置（智能推荐 + 一键确认）**

加载每个子项目的 `preset.yaml`（按 Step 1.5 流程），生成**统一推荐表格**展示给用户：

```
===== 子项目配置推荐 =====

基于各 preset 的推荐默认值，为每个子项目生成以下配置：

┌────────────┬────────────────┬────────────────────────────────────────────────┐
│ 子项目     │ 包管理器       │ 可选规范                                        │
├────────────┼────────────────┼────────────────────────────────────────────────┤
│ backend    │ uv             │ ✓ api-design ✓ logging ✓ sdk-first ○ observ.    │
│ frontend   │ pnpm           │ ✓ component ✓ state-mgmt ✓ perf ○ a11y         │
│ infra      │ npm            │ ✓ construct ✓ deployment ○ cost ○ iam           │
└────────────┴────────────────┴────────────────────────────────────────────────┘

✓ = 推荐包含 (default_include: true)    ○ = 可选

选择：
1) 全部采用推荐（默认，含所有 ✓）
2) 全部包含（含所有 ○）
3) 仅核心（跳过全部可选）
4) 部分自定义（选择子项目编号单独配置）
```

> 上方表格为示例展示。实际内容由各 preset 的 `preset.yaml:files.optional` 和 `defaults.package_manager` 决定。

**推荐策略生成规则**：
- `✓`（推荐）= `files.optional` 中 `default_include: true` 的项
- `○`（可选）= `default_include: false` 或未设置 `default_include` 的项
- 包管理器 = `preset.yaml:defaults.package_manager`

**用户选择 "4) 部分自定义" 时**：
1. 用户输入子项目编号（如 "2" 表示 frontend）
2. 仅对该子项目展示完整可选规范列表（格式同路径 A 第 4 步）
3. 配置完成后返回推荐表格，用户可继续选择其他子项目或确认

> **关键**：必须完整读取对应 preset 的 `preset.yaml`，**禁止硬编码任何文件名或默认值**。

**阶段 D4: 全局规范范围**（2 问）

```
1. 测试覆盖率最低要求: ___% (默认: 80)

2. 根级跨项目规范（生成到 .claude/rules/）：
   ┌──────────────────────┬──────────┬──────────────────────────────┐
   │ 规范文件              │ 推荐状态  │ 说明                          │
   ├──────────────────────┼──────────┼──────────────────────────────┤
   │ common.md             │ ✓ 必选    │ Git 提交规范、代码审查标准    │
   │ principles/*.md       │ ✓ 必选    │ 跨 preset 工程原则 (4 个文件) │
   │ api-contracts.md      │ ○ 可选    │ 跨项目 API 契约（依赖 #13）   │
   │ shared-types.md       │ ○ 可选    │ 共享类型生成策略（依赖 #13）  │
   │ env-matrix.md         │ ○ 可选    │ 环境变量矩阵（依赖 #13）      │
   │ local-dev.md          │ ○ 可选    │ 本地开发启动（依赖 #13）      │
   └──────────────────────┴──────────┴──────────────────────────────┘

   包含哪些可选规范？(all / none / 手动选择)
```

> **注意**：api-contracts / shared-types / env-matrix / local-dev 依赖 **#13** 完成后才可启用。如果对应模板文件不存在于 `_common/{lang}/rules/`，**静默跳过**不报错。

**阶段 D5: 确认与生成策略**

展示完整生成计划后进入 Step 4。

```
===== Monorepo 生成计划 =====

根目录:
  .claude/CLAUDE.md               [_common/{lang}/root-CLAUDE.md]
  .claude/rules/common.md         [_common/{lang}/common-rules.md]
  .claude/rules/principles/*.md   [_common/{lang}/rules/principles/ × 4]
  {可选: api-contracts.md / shared-types.md / env-matrix.md / local-dev.md}

子项目:
  backend/.claude/      [python-fastapi/{lang}/ 全量]
  frontend/.claude/     [react-typescript/{lang}/ 全量]
  infra/.claude/        [aws-cdk/{lang}/ 全量]

特殊占位符替换:
  {{SUBPROJECT_TABLE}}     → 子项目表格
  {{MONOREPO_STRUCTURE}}   → 目录结构树
  {{PARENT_CLAUDE_REF}}    → 指向根 .claude/CLAUDE.md 的引用（子项目专用）
```

### Step 4: 确认摘要

生成文件前，展示完整摘要供用户确认：

**单项目模式摘要**（路径 A / B / C 单项目）：

```
========== 生成摘要 ==========
路径:      {A: preset 快车道 / B: generic 智能生成 / C: 结构化问卷}
项目名称:  My Project
项目标识:  my-project
项目模式:  单项目
技术栈:    {分析结果或用户输入}
语言:      中文
目标目录:  .claude/

将生成以下文件：
  [核心]
  .claude/CLAUDE.md
  .claude/project-config.md
  .claude/rules/architecture.md
  .claude/rules/tech-stack.md
  .claude/rules/code-style.md
  .claude/rules/testing.md
  .claude/rules/security.md
  .claude/rules/checklist.md
  .claude/rules/project-structure.md

  [可选]
  .claude/rules/api-design.md
  .claude/rules/logging.md

  [通用原则]
  .claude/rules/principles/architecture.md
  .claude/rules/principles/code-quality.md
  .claude/rules/principles/testing.md
  .claude/rules/principles/security.md

  共 N 个文件

{路径 B/C-generic 特有提示}
ℹ️ AI 将根据项目分析结果智能生成规范内容，生成后建议人工审查。

确认生成？(y/n)
==============================
```

**Monorepo 模式摘要**（路径 D）：

```
========== 生成摘要 (Monorepo) ==========
路径:        D - Monorepo 引导
Monorepo 名: claude-context-templates-test
项目标识:    claude-context-templates-test
描述:        ai agent 平台项目
模板语言:    中文
测试覆盖率:  80%

子项目清单:
  backend  → python-fastapi   (AI Agent 编排服务)
  frontend → react-typescript (管理控制台)
  infra    → aws-cdk          (AWS 基础设施)

将生成的文件结构:
  .claude/CLAUDE.md                       # 根级入口（含子项目表格）
  .claude/rules/common.md                 # 跨项目通用规则
  .claude/rules/principles/*.md           # 通用工程原则 (4 files)
  {路径 D4 选中的可选文件}

  backend/.claude/
    CLAUDE.md
    project-config.md
    rules/ (N 核心 + M 可选)

  frontend/.claude/
    CLAUDE.md
    project-config.md
    rules/ (N 核心 + M 可选)

  infra/.claude/
    CLAUDE.md
    project-config.md
    rules/ (N 核心 + M 可选)

  预计共 N 个文件

ℹ️ Monorepo 模式：子项目间共享根级规范，避免重复。

确认生成？(y/n)
==========================================
```

用户确认后，进入 Step 5。

### Step 5: 读取模板并生成文件

根据路径选择不同的文件生成策略。

#### 统一渲染工具（所有路径共用）

**强烈推荐**使用 Plugin 提供的标准化渲染脚本 `scripts/render-template.sh`，它保证：
- 占位符正则严格匹配 `{{UPPER_SNAKE_CASE}}`，**不会误替换 JSX 的 `{{ foo }}` 或 YAML 的 `{{ expr }}`**
- 支持多行占位符（如 `PARENT_CLAUDE_REF`），通过 JSON 字符串传入
- 未提供值的占位符自动替换为空字符串并警告
- 未使用的变量产生警告（便于发现模板遗漏）
- 有完整单元测试（`scripts/tests/test-render.sh`）

**调用方式**：

```bash
bash scripts/render-template.sh \
  --preset python-fastapi \
  --lang zh-CN \
  --target backend/.claude \
  --vars '{
    "PROJECT_NAME": "my-app",
    "PROJECT_SLUG": "my-app",
    "PROJECT_DESCRIPTION": "...",
    "SUBPROJECT_NAME": "backend",
    "PACKAGE_MANAGER": "uv",
    "COVERAGE_MIN": "80",
    "PARENT_CLAUDE_REF": "> **父级 Monorepo 规范**: ..."
  }'
```

**参数说明**：
- `--preset` + `--lang`：自动定位 `plugin/presets/{preset}/{lang}/`
- `--source`（替代 --preset/--lang）：直接指定源目录（用于 `_common/`）
- `--target`：目标目录（会自动创建）
- `--vars`：JSON 字符串或 `@/path/to/vars.json`
- `--dry-run`：仅打印操作，不写文件
- `--verbose`：显示每处替换详情

**环境要求**：
- bash ≥ 4.0
- jq ≥ 1.5
- awk（任意版本）

如果环境检测缺少 jq：
- macOS: 提示用户 `brew install jq`
- Linux: 提示用户 `sudo apt-get install jq` 或 `sudo yum install jq`
- Windows: 提示用户安装 Git Bash 或 WSL

环境不满足时报错中止命令，不执行低效的替代流程。

#### 路径 A / 路径 C-preset: preset 模板复制

**推荐**：直接调用 `render-template.sh`（见上方统一渲染工具）。

**原样复制约束**：
- **不要**根据自己的知识修改、增删或重写模板内容
- **只替换 `{{VARIABLE}}` 格式的占位符**

**生成流程（使用 render-template.sh）**：

```bash
# 1. 渲染 preset 本体
bash scripts/render-template.sh \
  --preset <preset_id> --lang <lang> \
  --target .claude \
  --vars '{...}'

# 2. 复制 principles (不需要替换)
cp -r plugin/presets/_common/<lang>/rules/principles .claude/rules/
```

**注意**：单项目模式下，`{{PARENT_CLAUDE_REF}}` 会被 render-template.sh 自动替换为空字符串（合法行为，单项目无父级引用）。

#### 路径 D: Monorepo 模板组合

**重要约束**：
- 根级 `.claude/` 使用 `_common/{lang}/` 模板
- 每个子项目 `.claude/` 使用对应 preset 模板（与路径 A 相同）
- **占位符替换分层**：根级用 Monorepo 级变量，子项目级用自己的变量

**推荐流程（两步 render-template）**：

```bash
# 步骤 1: 渲染根级 _common/
bash scripts/render-template.sh \
  --source plugin/presets/_common/<lang> \
  --target .claude \
  --vars '{
    "PROJECT_NAME": "monorepo-root-name",
    "PROJECT_DESCRIPTION": "...",
    "SUBPROJECT_TABLE": "| 子项目 | 路径 | 说明 |\n|...|...|...|\n| backend | `backend/` | ... |",
    "MONOREPO_STRUCTURE": "```\nroot/\n├── .claude/\n└── backend/\n```"
  }'

# 步骤 2: 对每个子项目单独渲染
for subproject in backend frontend infra; do
  bash scripts/render-template.sh \
    --preset <preset_id> --lang <lang> \
    --target "${subproject}/.claude" \
    --vars "{... 含 PARENT_CLAUDE_REF ...}"
done
```

**生成流程（详细步骤）**：

1. **根目录生成**：
   - 渲染 `_common/{lang}/root-CLAUDE.md` → `.claude/CLAUDE.md`
   - 渲染 `_common/{lang}/common-rules.md` → `.claude/rules/common.md`
   - 复制 `_common/{lang}/rules/principles/*.md` → `.claude/rules/principles/*.md`（原样，不渲染）
   - D4 中用户选中的可选规范（api-contracts/shared-types/env-matrix/local-dev）：
     - 若对应模板存在于 `_common/{lang}/rules/`，则渲染
     - 若不存在（#13 未完成），则**静默跳过**

2. **根级占位符（Monorepo 特有）**：由 agent **预生成字符串** 传给 `render-template.sh`：

   - `{{SUBPROJECT_TABLE}}` — `## Monorepo 结构` 下的主表格
     - 格式（中文）：
       ```markdown
       | 子项目 | 路径 | 说明 |
       |--------|------|------|
       | backend | `backend/` | AI Agent 编排服务 (Python + FastAPI) |
       | frontend | `frontend/` | 管理控制台 (React + TypeScript) |
       ```

   - `{{MONOREPO_STRUCTURE}}` — `common.md` 中的目录结构树代码块
     - 格式：Markdown 代码块（\`\`\`...\`\`\`）

   - `{{SUBPROJECT_LINK_TABLE}}` — `## 相关文档` 表格中的子项目导航行（追加在"通用规则"行之后）
     - **路径约定**：`.claude/CLAUDE.md` → `../{子项目}/.claude/CLAUDE.md`（相对本文件所在目录）
     - 格式：每个子项目一行 Markdown 表格行（无表头，直接拼在"通用规则"行下）：
       ```markdown
       | backend | [backend/.claude/CLAUDE.md](../backend/.claude/CLAUDE.md) |
       | frontend | [frontend/.claude/CLAUDE.md](../frontend/.claude/CLAUDE.md) |
       | infra | [infra/.claude/CLAUDE.md](../infra/.claude/CLAUDE.md) |
       ```
     - **禁止**写成 `[backend/.claude/CLAUDE.md](backend/.claude/CLAUDE.md)`（少 `../`，错误路径）

3. **子项目生成**（对 D2 清单中每个子项目）：
   - 调用 `render-template.sh --preset <id> --lang <lang> --target <sub>/.claude`
   - `PARENT_CLAUDE_REF` 值为 `"> **父级 Monorepo 规范**: 请参考根目录 [../../.claude/CLAUDE.md](../../.claude/CLAUDE.md) 获取跨项目通用规则和 Monorepo 结构概览。"`
   - **Monorepo 模式下不在子项目内重复放置 `principles/*.md`**（仅在根级存在，避免重复）

4. **路径 D 专属校验**（生成前）：
   - 子项目目录名必须唯一
   - 每个子项目的 preset ID 必须在 `manifest.json` 中存在
   - `_common/{lang}/` 必须存在 `root-CLAUDE.md` 和 `common-rules.md`

#### 路径 B / 路径 C-generic: generic 智能生成

分三个阶段生成文件：

**阶段 1: 骨架复制 + 简单占位符替换**

1. 读取 `presets/generic/{lang}/CLAUDE.md` → 写入 `.claude/CLAUDE.md`
2. 读取 `presets/generic/{lang}/project-config.md` → 写入 `.claude/project-config.md`
3. 读取 `presets/generic/{lang}/rules/*.md` → 写入 `.claude/rules/*.md`
4. 替换 `{{VARIABLE}}` 占位符（PROJECT_NAME, PROJECT_SLUG 等）

**阶段 2: AI 动态填充 `{{AI_GENERATED:xxx}}` 区域**

对每个包含 `{{AI_GENERATED:xxx}}` 的文件：

1. 读取 `context-schema.yaml` 中对应 rule_type 的 `ai_generation_hints`
2. 将收集到的信息（language, framework, toolchain, architecture 等）注入提示模板
3. AI 生成内容替换 `{{AI_GENERATED:xxx}}` 区域
4. 生成要求：
   - 遵循现有 preset 的格式风格（表格、代码块、速查卡片）
   - 内容基于检测到的实际技术栈
   - 每个规范文件 100-300 行
   - 包含 Section 0 速查卡片（表格或决策树开头）
   - 包含双向链接（引用相关 rules 文件）

**阶段 3: 可选规范文件生成**

对用户确认的可选规范（context-schema.yaml 中 `category: optional` 的类型）：

1. 读取 `ai_generation_hints` 获取生成提示
2. AI 直接生成完整文件内容（无骨架模板）
3. 格式要求同阶段 2

**阶段 4: 通用原则文件复制**

1. 读取 `presets/_common/{lang}/rules/principles/*.md`
2. 写入 `.claude/rules/principles/*.md`
3. 这些文件原样复制，不做 AI 生成

**质量自检**（生成后、写入前）：

1. 检查 `context-schema.yaml` 中对应类型的 `quality_criteria` 列表
2. 验证所有 `{{AI_GENERATED:xxx}}` 已被替换（无残留占位符）
3. 检查文件间 Markdown 链接对称性（A 链接到 B，B 应能找到）
4. 确认每个文件长度在 100-300 行之间
5. 确认包含 Section 0 速查卡片

> **自动化兜底**：以上自检在 Step 7.5 由 `audit-context.sh` 程序化执行，不依赖 agent 自觉。

### Step 6: 占位符替换

在写入文件时，将以下占位符替换为用户提供的实际值：

| 占位符 | 来源 | 说明 |
|--------|------|------|
| `{{PROJECT_NAME}}` | 用户输入 | 项目显示名称 |
| `{{PROJECT_SLUG}}` | 自动生成/用户修改 | 项目标识符 (kebab-case) |
| `{{PROJECT_DESCRIPTION}}` | 用户输入 | 项目描述 |
| `{{SUBPROJECT_NAME}}` | 用户输入/默认 preset-id | 子项目名称 |
| `{{PACKAGE_MANAGER}}` | preset.yaml defaults / 分析结果 | 包管理器 |
| `{{COVERAGE_MIN}}` | preset.yaml defaults / 用户输入 | 最低测试覆盖率 |
| `{{DATE}}` | 当前日期 | 生成日期 (YYYY-MM-DD) |

**Generic 路径专用占位符**：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:xxx}}` | AI 根据收集信息动态生成内容替换的区域。详见 Step 5 阶段 2 |

**Monorepo 专用占位符**（需要生成内容替换）：

| 占位符 | 说明 |
|--------|------|
| `{{SUBPROJECT_TABLE}}` | 子项目表格（Markdown 格式） |
| `{{MONOREPO_STRUCTURE}}` | 目录结构树（代码块格式） |

**SUBPROJECT_TABLE 格式**（中文）：
```markdown
| 子项目 | 路径 | 说明 |
|--------|------|------|
| backend | `backend/` | Python + FastAPI |
| frontend | `frontend/` | React + TypeScript |
```

**MONOREPO_STRUCTURE 格式**（中文）：
```
{project-slug}/                    # Monorepo 根目录
├── .claude/                    # 根级：通用规范
│   ├── CLAUDE.md               # 全局入口
│   └── rules/
│       ├── common.md           # 跨项目通用规则
│       └── principles/         # 跨 preset 工程原则
├── backend/                    # Python + FastAPI
└── frontend/                   # React + TypeScript
```

### Step 7: 冲突处理

如果 `.claude/` 目录已存在：

1. 告知用户已存在 `.claude/` 目录
2. 提供三个选项：
   - **覆盖**：删除现有文件并重新生成
   - **跳过已有文件**：只创建新文件，不覆盖已有文件
   - **取消**：中止操作
3. 按用户选择执行

### Step 7.5: 强制审计（所有路径必经）

**目的**：程序化兜底 Step 5 中列出的质量自检项，防止残留占位符、断链、过短/过长文件流入用户项目。

**执行**：

```bash
bash <plugin_root>/scripts/audit-context.sh \
  --target <project_root> \
  --json <project_root>/.claude/audit-report.json
```

**严重度策略**：

| 严重度 | 触发条件 | 处理 |
|--------|---------|------|
| ERROR  | 残留 `{{AI_GENERATED:...}}` 或其他 `{{UPPER_CASE}}` 占位符；核心必选文件缺失 | **阻断**：告知用户具体问题, 询问是否仍要继续（修复/忽略/取消） |
| WARN   | 断链、文件过短 (<30 行) 或过长 (>500 行) | 列出警告, 不阻断, 建议用户后续处理 |
| INFO   | 缺少 Section 0 速查卡片、`<!-- TODO -->` 标记数量 | 仅提示, 不阻断 |

**对路径 A/C-preset（preset 快车道）**：
- 仅残留占位符和文件缺失是 ERROR（理论上 preset 已预先验证过）
- WARN/INFO 多数为正常（preset 模板里本就有 TODO）

**对路径 B/C-generic（AI 生成）**：
- **推荐追加 `--strict`**：所有 WARN 提升为 ERROR
- AI 生成的内容必须通过质量自检才能交付

**用户可视化输出**：
- 终端彩色报告（ERROR/WARN/INFO）
- `.claude/audit-report.json` 供后续 `/audit-context` 二次查阅

**失败处理**：
- 若 ERROR ≥1, 列出问题清单后问用户：
  - 1) 现在修复（返回 Step 5 对应路径重新生成）
  - 2) 保留已生成文件，手工修复（继续 Step 8）
  - 3) 取消并回滚（删除已写入文件）

### Step 7.6: 错误恢复机制

**AI 生成失败处理**（仅路径 B/C-generic）：

当 AI 生成的内容不符合 `context-schema.yaml:quality_criteria`（如文件过短、缺少必需结构）时：
1. 报告具体失败原因（哪个文件、哪个 quality_criteria 不满足）
2. 提供 3 个选项：
   - 1) 重试生成（重新执行 Step 5 阶段 2/3）
   - 2) 使用 generic 骨架保留，用户手工补充（继续 Step 8）
   - 3) 取消并回滚已生成文件

**占位符残留修复**（Step 7.5 审计发现 ERROR 后的自动修复流程）：
- 对每个残留的 `{{AI_GENERATED:xxx}}`：重新触发对应区域的 AI 生成
- 对每个残留的 `{{USER_VAR}}`（如 `{{PROJECT_NAME}}`）：询问用户提供值
- 修复后自动重跑 `audit-context.sh` 验证

### Step 8: 完成提示

生成完成后，输出以下信息：

1. 列出所有生成的文件路径
2. 下一步建议：
   - 编辑 `project-config.md` 填写项目特定信息
   - 检查生成的规范文件，按需自定义
   - 推荐运行 `/audit-context` 检查生成质量
   - 若长期未更新 Plugin，可运行 `/plugin update` 获取最新 preset 模板
   - 开始使用 Claude Code 进行开发

3. **路径 B/C-generic 特有提示**：
   ```
   ℹ️ 提示：本次使用了 AI 智能生成模式。建议：
   1. 审查 AI 生成的规范内容是否符合项目实际情况
   2. 特别检查 rules/architecture.md 和 rules/tech-stack.md
   3. 运行 /audit-context 获取详细质量报告
   ```

4. **使用反馈邀请**（所有路径均输出）：
   ```
   👋 如果这对你有用，请提交使用报告（1 分钟填写）：
      https://github.com/arch-team/claude-context-templates/issues/new?template=usage-report.yml
      真实使用反馈是项目继续的唯一依据。
   ```

## 重要约束

1. **不修改项目已有文件** — 只在 `.claude/` 目录（和 Monorepo 子项目的 `.claude/`）下操作
2. **Preset 路径保持模板完整性** — 原样复制模板内容，只做占位符替换
3. **Generic 路径保证生成质量** — AI 生成内容必须通过质量自检
4. **每步确认** — 关键决策点需要用户明确确认
5. **错误处理** — 如果 preset 文件读取失败，告知用户并建议检查 Plugin 安装
6. **回退能力** — 用户在任何步骤都可以说"返回上一步"修改之前的选择
7. **向后兼容** — 所有现有 preset 的流程不受影响
