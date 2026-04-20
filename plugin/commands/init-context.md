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

### Step 0: 版本检查（轻量）

在开始之前，尝试检查本 Plugin 的 preset 是否为最新版本：

1. 读取本 Plugin 内的 `presets/manifest.json`，获取 `plugin_version`
2. 尝试从远程获取最新 manifest（静默失败，不阻塞流程）：
   ```
   https://raw.githubusercontent.com/arch-team/claude-context-templates/main/plugin/presets/manifest.json
   ```
3. 对比版本号：
   - 如果远程版本 > 本地版本，**提示用户**（但不强制）：
     ```
     ⚠️ 检测到新版本 preset 模板可用（本地 v1.2.0 → 远程 vX.Y.Z）。
     建议运行以下命令更新 Plugin：
       /plugin install claude-context-templates@claude-context-templates
     是否继续使用当前版本？(y/n)
     ```
   - 如果版本一致或无法获取远程 manifest，**静默继续**
4. 用户确认继续后，进入 Step 1

> **注意**：版本检查失败（网络问题等）不应阻止正常流程。

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

#### 1b. 深度分析（新增）

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

### Step 2: 路由决策

根据分析结果选择执行路径：

```
┌─ 已有项目 + 最高 confidence >= 0.8  → 路径 A: preset 快车道
├─ 已有项目 + 最高 confidence < 0.8   → 路径 B: generic 路径
├─ 空项目（无配置文件）               → 路径 C: 结构化问卷
└─ 路径 C 问卷结果匹配 preset          → 切换到路径 A
```

**判定"空项目"**：工作目录下不存在任何 `analysis_probes.language_detection.indicators` 中的配置文件。

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
   读取所选 preset 的 `preset.yaml`，展示可选规则列表：
   ```
   以下可选规范可以包含（根据项目特征推荐）：
   ✓ api-design.md (API 设计规范) — 推荐，检测到 Web 框架
   ✓ logging.md (日志规范) — 推荐，后端服务项目
   ○ observability.md (可观测性) — 可选
   包含推荐项？(y/n) 或逐一确认？(l)
   ```

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
   基于 `context-schema.yaml` 的 rule_types，展示推荐列表：
   ```
   将生成以下规范文件：
   [核心 - 必选]
   ✓ architecture.md, tech-stack.md, code-style.md, testing.md,
     security.md, checklist.md, project-structure.md

   [可选 - 根据项目特征推荐]
   ✓ api-design.md — 推荐（检测到 Web 框架）
   ○ deployment.md — 可选（检测到 Dockerfile）

   包含推荐项？(y/n) 或逐一确认？(l)
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

### Step 4: 确认摘要

生成文件前，展示完整摘要供用户确认：

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

用户确认后，进入 Step 5。

### Step 5: 读取模板并生成文件

根据路径选择不同的文件生成策略。

#### 路径 A / 路径 C-preset: preset 模板复制

与现有逻辑一致，原样复制模板内容，只做占位符替换。

**重要约束**：
- **原样复制模板内容**，不要根据自己的知识修改、增删或重写模板内容
- **只替换 `{{VARIABLE}}` 格式的占位符**，其余内容保持不变
- 使用 Read 工具读取 preset 文件，使用 Write 工具创建目标文件

**单项目模式**：
1. 读取 `presets/{preset-id}/{lang}/CLAUDE.md` → 写入 `.claude/CLAUDE.md`
2. 读取 `presets/{preset-id}/{lang}/project-config.md` → 写入 `.claude/project-config.md`
3. 读取 `presets/{preset-id}/{lang}/rules/*.md` → 写入 `.claude/rules/*.md`
4. 在每个文件中替换占位符变量

**Monorepo 模式**：
1. 读取 `presets/_common/{lang}/root-CLAUDE.md` → 写入 `.claude/CLAUDE.md`
2. 读取 `presets/_common/{lang}/common-rules.md` → 写入 `.claude/rules/common.md`
3. 对每个子项目：
   - 读取对应 preset 模板 → 写入 `{subproject}/.claude/` 下
4. 在所有文件中替换占位符变量
5. 在根 `CLAUDE.md` 中生成子项目表格和目录结构

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

### Step 8: 完成提示

生成完成后，输出以下信息：

1. 列出所有生成的文件路径
2. 下一步建议：
   - 编辑 `project-config.md` 填写项目特定信息
   - 检查生成的规范文件，按需自定义
   - 推荐运行 `/audit-context` 检查生成质量
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
