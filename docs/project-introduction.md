# Claude Context Templates — 项目详细介绍

> 为 Claude Code 提供结构化、可复用的上下文管理模板，让高质量的 AI 辅助开发体验对每个项目可及。

---

## 目录

- [1. 引言：为什么需要这个项目](#1-引言为什么需要这个项目)
- [2. 项目背景](#2-项目背景)
- [3. 设计理念与原则](#3-设计理念与原则)
- [4. 技术架构](#4-技术架构)
- [5. 使用与实践](#5-使用与实践)
- [6. 未来规划](#6-未来规划)
- [附录：项目文件索引](#附录项目文件索引)

---

## 1. 引言：为什么需要这个项目

### 场景

Claude Code 通过读取项目中的 `.claude/` 目录来理解你的代码库——包括架构约定、编码规范、测试策略和安全要求。一个组织良好的 `.claude/` 目录能显著提升 Claude 的代码生成质量、代码审查一致性和建议的准确性。

然而，`.claude/` 目录目前没有标准化的组织方式。每个开发者都在凭直觉从零开始搭建，质量参差不齐，效果不可预测。

### 核心痛点

| 痛点 | 影响 |
|------|------|
| `.claude/` 目录没有标准化的组织方式 | 每个项目从零开始，质量参差不齐 |
| 缺乏经过验证的上下文管理最佳实践 | 开发者凭直觉编写，效果不可预测 |
| 不同技术栈需要不同的规范，但共性模式未被抽取 | 重复劳动，无法复用 |
| 上下文管理的知识分散在个人经验中 | 团队间无法共享和协作 |

### 一句话定位

**正如 `.editorconfig` 标准化了编辑器配置、ESLint shared configs 标准化了代码风格，claude-context-templates 的目标是标准化 Claude Code 的上下文管理。**

### 项目愿景与使命

**愿景**：让每个 Claude Code 用户都能在几分钟内获得经过生产验证的上下文管理体系。

**使命**：降低 Claude Code 上下文管理的门槛，让高质量的 AI 辅助开发体验对每个项目可及。

---

## 2. 项目背景

### 2.1 核心问题

当开发者开始使用 Claude Code 时，通常会面对一个空白的 `.claude/` 目录。接下来会发生以下几件事：

1. **从零开始**：写一个 `CLAUDE.md`，把项目介绍、技术栈、编码规范等信息塞进去。没有结构化指导，每个人写出的东西截然不同。

2. **质量不可控**：有人写了一个 300 行的 CLAUDE.md 但 Claude 理解效果不佳——因为信息密度低、缺少可扫描的表格和速查卡片。有人写了精简的 5 行描述，但关键约束被遗漏。

3. **重复劳动**：Python + FastAPI 项目需要的架构规范、测试策略、安全检查清单，和 React + TypeScript 项目虽然技术栈不同，但在结构组织、设计原则上有大量共性。每个项目却都在重新发明这些模式。

4. **知识孤岛**：一位高级开发者花两天精心打磨出的 `.claude/` 目录，其中沉淀的经验无法被团队其他人复用，更无法被社区共享。

### 2.2 解决思路

Claude Context Templates 采用三管齐下的方式解决上述问题：

- **提供生产级模板**——不是示例代码或教学用的 "hello world"，而是基于真实 Monorepo 项目提炼的、可直接用于生产的上下文模板
- **沉淀社区最佳实践**——6 大设计原则（SSoT、Section 0 速查卡、分层架构等）确保模板结构化且可维护，而非某个人的个人偏好
- **构建可扩展的 preset 生态**——多技术栈预设模板，通过交互式工具一键适配，而非只适用于某一种技术栈的单一方案

### 2.3 目标用户

| 用户类型 | 特征 | 核心需求 | 使用场景 |
|----------|------|----------|----------|
| **个人开发者**（首要） | 使用 Claude Code 开发个人/开源项目 | 快速搭建，即用即走 | 新项目初始化 |
| **技术团队 Lead**（次要） | 需要统一团队的 AI 开发规范 | 标准化、可定制、可推广 | 团队规范制定 |

用户旅程简洁清晰：

```
发现 → 初始化 → 定制
 │        │        │
 │        │        └─ 修改模板适配项目/团队约定，日常开发中受益
 │        └─ 运行 /init-context 或 init.sh 生成 .claude/ 目录
 └─ 通过 GitHub / 社区推荐 / 博客文章发现项目
```

### 2.4 与现有方案的对比

| 方案 | 优势 | 劣势 | 本项目的差异化价值 |
|------|------|------|-------------------|
| **手动创建 CLAUDE.md** | 完全自由 | 无结构化指导，质量不稳定 | 生产级模板 + 6 大设计原则 |
| **复制他人的 .claude/ 目录** | 快速 | 技术栈不匹配，缺乏系统性 | 多 preset + 变量替换，精准适配 |
| **让 AI 直接生成** | 零成本 | 缺乏结构化，无法保证一致性 | 设计原则 + 双向链接 + SSoT + 质量自检 |
| **Claude Code 内置模板** | 官方支持 | 目前不存在此功能 | 先发优势 + 社区驱动 + Plugin 原生集成 |

本项目的核心差异化在于：**它不只是一堆模板文件，而是一套经过设计原则约束的、针对 AI 消费优化的上下文管理体系。**

---

## 3. 设计理念与原则

上下文模板与普通代码模板有本质区别：它的"读者"不仅是人类开发者，更是 AI。这意味着需要针对 AI 的上下文窗口、token 效率和信息检索方式做专门优化。以下 6 条设计原则正是为此而生。

### 3.1 Single Source of Truth (SSoT)

**原则**：每个概念只在一个权威文件中定义，其他文件通过链接引用。

**为什么重要**：当规则变更时，只需在一个地方更新。这不仅减少了人类的维护负担，也避免了 AI 因读到互相矛盾的信息而产生混乱。

**示例**：

- `tech-stack.md` 是版本矩阵的唯一权威源——所有其他文件提到版本号时都链接到它，而非重复定义
- `architecture.md` 是架构模式的唯一权威源——测试规范中提到"分层"时引用它，而非自行描述
- `common.md` 是 Monorepo 结构的唯一权威源

```markdown
# 在 architecture.md 中
版本要求请参见 [tech-stack.md](tech-stack.md)
```

### 3.2 Section 0 Quick Reference Card

**原则**：每个规则文件以 Section 0（速查卡片）开头，包含表格、决策树和备忘清单。

**为什么对 AI 重要**：Claude Code 读取规则文件时，往往只需要快速查阅关键约束，而非通读全文。Section 0 以最小的 token 消耗提供最高密度的信息。

**速查卡片示例**：

```markdown
# 架构规范

> **Responsibility**: 架构模式 SSoT

---

## 0. Quick Reference Card

### 依赖矩阵
| From \ To    | shared | entities | features |
|--------------|:------:|:--------:|:--------:|
| features     |   OK   |    OK    |    NO    |
| entities     |   OK   |    NO    |    NO    |

### 决策树
需要新模块？
  → 有领域逻辑？ → 是 → 创建 domain 模块
  → 无领域逻辑？ → 放入 shared/

---

## 1. 详细规范
...
```

### 3.3 Layered Architecture（分层架构）

**原则**：上下文按层级组织，层与层之间有明确的分离和单向依赖关系。

**四层结构**：

```
Layer 1:  根 .claude/                       → 全局设置（语言、项目概述）
Layer 2:  根 .claude/rules/                 → 跨项目规则（Git、文档、结构）
Layer 2b: 根 .claude/rules/principles/      → 跨 preset 工程原则（来自 _common）
Layer 3:  {子项目}/.claude/                 → 子项目特定规范（技术栈、架构）
```

**加载机制**：Claude Code 根据当前工作目录自动加载对应层级：

- 在项目根目录工作 → 加载 Layer 1 + 2 + 2b
- 在 `backend/` 子项目工作 → 加载 Layer 1 + 2 + 2b + backend Layer 3
- 每层可通过相对链接引用其他层

### 3.4 Dependency Matrix（依赖矩阵）

**原则**：使用表格（而非散文）来表达架构层之间的允许/禁止依赖关系。

**为什么用表格**：表格是无歧义的、可快速扫描的、token 效率高的表达方式——相比一段段的文字描述，Claude 能更准确地理解和执行依赖规则。

**示例**（Feature-Sliced Design）：

```markdown
| From \ Import | shared | entities | features | widgets | pages |
|---------------|:------:|:--------:|:--------:|:-------:|:-----:|
| **pages**     |   OK   |    OK    |    OK    |   OK    |  NO   |
| **widgets**   |   OK   |    OK    |    OK    |   NO    |  NO   |
| **features**  |   OK   |    OK    |    NO    |   NO    |  NO   |
| **entities**  |   OK   |    NO    |    NO    |   NO    |  NO   |
| **shared**    |   NO   |    NO    |    NO    |   NO    |  NO   |
```

### 3.5 Bidirectional Linking（双向链接）

**原则**：文档之间通过相对链接互相引用，形成可导航的知识网络。

**为什么重要**：Claude Code 可以沿着链接追踪引用，理解规则之间的关系。双向链接让任意文件都能成为探索知识网络的入口。

```markdown
# 在 architecture.md 中
测试要求请参见 [testing.md](testing.md) Section 3

# 在 testing.md 中
架构模式请参见 [architecture.md](architecture.md) Section 1
```

### 3.6 kebab-case Naming（命名规范）

**原则**：所有文件使用 `kebab-case.md` 命名，仅 `CLAUDE.md` 和 `README.md` 例外。

**为什么重要**：统一的命名降低认知负担，避免跨平台（大小写敏感 vs 不敏感文件系统）的兼容问题。

```
CLAUDE.md              # 例外：Claude Code 框架约定
README.md              # 例外：GitHub 约定
rules/
  architecture.md      # kebab-case
  tech-stack.md        # kebab-case
  code-style.md        # kebab-case
  project-structure.md # kebab-case
```

---

## 4. 技术架构

### 4.1 Preset 系统概览

**Preset（预设模板）** 是本项目的核心概念：一套针对特定技术栈的完整上下文模板集合。每个 preset 包含入口文件、配置模板和若干规则文件，覆盖架构、测试、安全等关键领域。

**三个内置 Preset**：

| Preset | 技术栈 | 架构模式 | 规则文件数 | 特色 |
|--------|--------|----------|:----------:|------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | DDD + Clean Architecture | 11 | SDK-First、uv + ruff + pytest |
| `react-typescript` | React + TypeScript + Vite | Feature-Sliced Design | 11 | React Query + Zustand、Accessibility |
| `aws-cdk` | AWS CDK + TypeScript | L1/L2/L3 Construct 分层 | 9 | CDK Nag、Cost Optimization |

**Generic Preset**：

除了三个内置 preset，项目还提供 `generic` preset——一个 AI 驱动的通用方案。当项目技术栈不匹配任何内置 preset 时（例如 Go + Gin、Django、Rust + Axum），generic preset 会基于项目分析结果，由 AI 动态生成规范内容。

### 4.2 Preset 内部结构

每个 preset 都遵循统一的文件结构：

```
plugin/presets/{preset-name}/
├── preset.yaml              # 元数据（名称、描述、默认值、变量定义）
├── zh-CN/                   # 中文版本
│   ├── CLAUDE.md            # 子项目入口（技术栈概述、开发命令、导航）
│   ├── project-config.md    # 项目特定配置（填写模板，含 TODO 标记）
│   └── rules/               # 专题规范
│       ├── architecture.md  # 架构规范
│       ├── tech-stack.md    # 技术栈版本矩阵（SSoT）
│       ├── code-style.md    # 编码规范
│       ├── testing.md       # 测试策略
│       ├── security.md      # 安全清单
│       ├── checklist.md     # PR 审查清单
│       ├── project-structure.md  # 目录结构
│       └── ...              # 可选规则（api-design, logging 等）
└── en/                      # 英文版本（相同结构）
```

`preset.yaml` 定义了 preset 的元数据：

```yaml
name: python-fastapi
display_name: "Python + FastAPI"
version: "1.0.0"

defaults:
  package_manager: uv
  linter: ruff
  test_runner: pytest
  source_root: src
  architecture_pattern: "DDD + Modular Monolith + Clean Architecture"
  coverage_minimum: 85

files:
  required:    # 必选文件（7 个核心 + 入口文件）
    - CLAUDE.md
    - project-config.md
    - rules/architecture.md
    - rules/tech-stack.md
    # ...
  optional:    # 可选文件（根据项目特征推荐）
    - rules/api-design.md
    - rules/logging.md
    # ...

variables:     # 占位符变量定义
  - name: PROJECT_NAME
    prompt: "项目名称"
    required: true
  # ...
```

### 4.3 _common 公共层

`_common` 目录提供**跨 preset 的通用内容**，包含两类文件：

**Monorepo 根级模板**：
- `root-CLAUDE.md` — Monorepo 根目录的全局入口文件
- `common-rules.md` — 跨子项目通用规则（Git 规范、文档规范）

**跨 preset 工程原则**（`rules/principles/`）：

| 原则文件 | 覆盖领域 |
|----------|----------|
| `architecture.md` | 依赖方向、模块隔离、显式导出 |
| `code-quality.md` | 命名一致性、避免副作用、错误处理 |
| `testing.md` | 测试金字塔、隔离原则、可重复性 |
| `security.md` | 最小权限、输入验证、密钥管理 |

**单向依赖原则**：`_common` 不引用任何特定 preset，但 preset 的规则文件可以引用 `_common` 的通用原则。这确保了 SSoT——通用工程标准只定义一次。

### 4.4 模板变量体系

模板文件中使用两类占位符，在初始化时被替换为实际内容：

**标准变量** `{{VARIABLE_NAME}}`：

由脚本或插件在初始化时自动替换。

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{PROJECT_NAME}}` | 项目显示名称 | My Awesome App |
| `{{PROJECT_SLUG}}` | 项目标识符 (kebab-case) | my-awesome-app |
| `{{PROJECT_DESCRIPTION}}` | 项目描述 | 一个现代 Web 应用 |
| `{{SUBPROJECT_NAME}}` | 子项目名称 | backend |
| `{{PACKAGE_MANAGER}}` | 包管理器 | uv |
| `{{COVERAGE_MIN}}` | 最低测试覆盖率 | 85 |
| `{{SUBPROJECT_TABLE}}` | Monorepo 子项目表格 | (自动生成) |
| `{{MONOREPO_STRUCTURE}}` | 目录结构树 | (自动生成) |

**AI 生成占位符** `{{AI_GENERATED:xxx}}`：

仅在 generic preset 中使用。`/init-context` 命令的 AI 引擎会根据项目分析结果动态生成内容来替换这些占位符。

共计 **36 个唯一占位符**分布在 9 个文件中，涵盖架构描述、版本矩阵、代码风格、测试策略等方面。例如：

| 占位符 | 所在文件 | 说明 |
|--------|----------|------|
| `{{AI_GENERATED:architecture_pattern}}` | rules/architecture.md | 架构模式描述 |
| `{{AI_GENERATED:version_matrix}}` | rules/tech-stack.md | 版本矩阵表格 |
| `{{AI_GENERATED:naming_conventions}}` | rules/code-style.md | 命名规范 |
| `{{AI_GENERATED:test_layering}}` | rules/testing.md | 测试分层表格 |
| `{{AI_GENERATED:security_quick_ref}}` | rules/security.md | 安全速查卡片 |

### 4.5 context-schema.yaml（规范类型体系）

`context-schema.yaml` 是 `/init-context` 命令决定"应该生成哪些文件"的核心依据，也是整个规范类型体系的 SSoT。

**规范类型分类**：

| 类别 | 类型数 | 说明 | 文件列表 |
|------|:------:|------|----------|
| **core**（必选） | 7 | 所有项目都应包含 | architecture, tech-stack, code-style, testing, security, checklist, project-structure |
| **optional**（按需） | 8 | 根据项目特征触发 | api-design, component-design, state-management, performance, accessibility, logging, observability, deployment, construct-design, cost-optimization, sdk-first |

**深度分析探针**：

`context-schema.yaml` 定义了 5 类分析探针，用于自动检测项目特征：

| 探针类型 | 检测内容 | 示例 |
|----------|----------|------|
| 语言检测 | 通过配置文件识别主要语言 | `pyproject.toml` → Python, `go.mod` → Go |
| 框架检测 | 通过依赖列表识别框架 | `fastapi` → FastAPI, `react` → React |
| 工具链检测 | 包管理器、Linter、测试框架等 | `uv.lock` → uv, `ruff.toml` → ruff |
| 架构推断 | 通过目录结构模式匹配 | `domain/ + application/` → DDD + Clean Architecture |
| 已有配置 | 扫描已存在的规范文件 | `.editorconfig`, `Dockerfile` |

**Preset 匹配规则与置信度**：

分析完成后，系统计算每个内置 preset 的匹配置信度（0-1）：

```
framework_detection 中匹配到 preset_hint  → +0.5
language_detection 匹配对应语言           → +0.2
toolchain_detection 匹配 preset defaults  → +0.1（每项）
architecture_detection 匹配架构模式       → +0.2
```

置信度阈值：

| 置信度 | 路径 |
|--------|------|
| >= 0.8 | Preset 快车道——直接使用匹配的 preset |
| 0.5 - 0.8 | 提示最接近的 preset，让用户确认 |
| < 0.5 | Generic 路径——AI 智能生成 |

### 4.6 双交付方式

项目提供两种交付方式，覆盖不同使用场景：

#### 方式一：Claude Code Plugin（推荐）

通过 Plugin 直接在 Claude Code 内使用，无需克隆仓库：

```bash
# 1. 添加 marketplace（一次性）
/plugin marketplace add arch-team/claude-context-templates

# 2. 安装 Plugin
/plugin install claude-context-templates@claude-context-templates

# 3. 交互式生成 .claude/ 目录
/init-context
```

**`/init-context` 命令的 8 步执行流程**：

| 步骤 | 内容 | 说明 |
|:----:|------|------|
| 0 | 版本检查 | 对比本地和远程 manifest.json 版本（静默失败不阻塞） |
| 1 | 深度项目探测 | 语言、框架、工具链、架构、已有配置的全面分析 |
| 2 | 路由决策 | 根据置信度选择 Preset 快车道 / Generic 路径 / 结构化问卷 |
| 3 | 信息收集 | 确认/修改分析结果，选择语言和可选规范 |
| 4 | 确认摘要 | 展示完整生成计划供用户确认 |
| 5 | 读取模板并生成 | Preset 模板复制或 Generic AI 智能生成 |
| 6 | 占位符替换 | 标准变量 + AI 生成占位符替换 |
| 7 | 冲突处理 | 已有 `.claude/` 目录时提供覆盖/跳过/取消选项 |
| 8 | 完成提示 | 列出生成文件，给出下一步建议 |

**`/audit-context` 命令**：

对已有的 `.claude/` 目录进行 5 维度审计：

| 审计维度 | 检查内容 | 评级标准 |
|----------|----------|----------|
| 结构完整性 | 关键文件是否齐全 | A: CLAUDE.md + rules/ + >=5 推荐文件 |
| 内容质量 | 实质内容 vs 空占位符 | A: 所有文件有内容，无未填写占位符 |
| 最佳实践 | 6 大设计原则合规度 | A: >=4 项合规 |
| 规范覆盖度 | 架构/代码/测试/安全/CI 领域覆盖 | A: 5/5 核心 + >=2 可选 |
| 可维护性 | 文件数量、长度、链接完整性 | A: 全部通过 |

#### 方式二：Shell 脚本

适用于 CI/CD 环境或偏好命令行工具的场景：

```bash
# 1. 克隆模板仓库
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates

# 2. 运行交互式初始化
./init.sh

# 3. 按提示选择 preset、语言和项目信息
```

`init.sh` 支持 macOS 和 Linux，通过交互式提示引导用户完成配置，使用 `sed` 进行占位符替换。

### 4.7 质量保障体系

项目通过多个验证脚本和 CI/CD 集成确保模板质量：

| 脚本 | 功能 | 运行方式 |
|------|------|----------|
| `validate-presets.sh` | 验证每个 preset 的必选文件完整性、双语一致性 | CI: push 时自动运行 |
| `validate-generated.sh` | 验证 init.sh 生成的 .claude/ 目录结构正确性 | CI: 烟雾测试 |
| `check-links.sh` | 检查所有 Markdown 文件的内部链接有效性 | CI: push 时自动运行 |
| `test-init.sh` | init.sh 端到端测试（单项目 + Monorepo 模式） | CI: push 时自动运行 |

**版本管理**：

`manifest.json` 记录每个 preset 的版本号和文件哈希，用于 Plugin 版本检查和完整性校验：

```json
{
  "plugin_version": "1.2.0",
  "presets": {
    "python-fastapi": { "version": "1.1.0", "file_count": 27 },
    "react-typescript": { "version": "1.1.0", "file_count": 27 },
    "aws-cdk": { "version": "1.1.0", "file_count": 25 },
    "generic": { "version": "1.0.0", "file_count": 19 }
  }
}
```

---

## 5. 使用与实践

### 5.1 快速开始

#### 方式一：Plugin 安装和使用（推荐）

```bash
# Step 1: 添加 marketplace 并安装 Plugin
/plugin marketplace add arch-team/claude-context-templates
/plugin install claude-context-templates@claude-context-templates

# Step 2: 在你的项目目录中运行
/init-context

# Step 3: 按交互提示完成配置，生成 .claude/ 目录
```

Plugin 会自动检测项目技术栈、推荐匹配的 preset、支持中英双语。

#### 方式二：Shell 脚本

```bash
# Step 1: 克隆仓库
git clone https://github.com/arch-team/claude-context-templates.git

# Step 2: 运行初始化脚本
cd claude-context-templates && ./init.sh

# Step 3: 将生成的 .claude/ 目录复制到你的项目中
```

### 5.2 生成结果展示

#### 单项目模式

```
your-project/
└── .claude/
    ├── CLAUDE.md              # 项目入口（技术栈、开发命令、规范导航）
    ├── project-config.md      # ← 填写项目特定信息（业务模块、核心实体）
    └── rules/
        ├── principles/        # 跨 preset 工程原则（自动包含）
        │   ├── architecture.md
        │   ├── code-quality.md
        │   ├── testing.md
        │   └── security.md
        ├── architecture.md    # 架构模式和依赖规则
        ├── tech-stack.md      # 版本矩阵（SSoT）
        ├── code-style.md      # 编码规范
        ├── testing.md         # 测试策略
        ├── security.md        # 安全检查清单
        ├── checklist.md       # PR 审查清单
        ├── project-structure.md  # 目录结构
        └── ...                # 可选规则（api-design, logging 等）
```

#### Monorepo 模式

```
your-project/
├── .claude/
│   ├── CLAUDE.md              # 全局入口（子项目导航、通用规范）
│   └── rules/
│       ├── common.md          # 跨项目通用规则（Git、文档、结构）
│       └── principles/        # 跨 preset 工程原则
├── backend/.claude/
│   ├── CLAUDE.md              # 后端入口
│   ├── project-config.md      # ← 填写后端项目配置
│   └── rules/
│       ├── architecture.md    # DDD + Clean Architecture
│       ├── api-design.md      # RESTful API 规范
│       └── ...
├── frontend/.claude/
│   ├── CLAUDE.md              # 前端入口
│   └── rules/
│       ├── architecture.md    # Feature-Sliced Design
│       ├── component-design.md
│       └── ...
└── infra/.claude/
    ├── CLAUDE.md              # 基础设施入口
    └── rules/
        ├── architecture.md    # Construct 分层
        ├── cost-optimization.md
        └── ...
```

### 5.3 各 Preset 实战亮点

#### python-fastapi

- **架构**：DDD + Modular Monolith + Clean Architecture，清晰的分层依赖矩阵
- **工具链**：uv (包管理) + ruff (lint + format) + pytest (测试)，现代 Python 最佳实践
- **特色规范**：SDK-First 原则（优先使用 SDK 简化实现）、结构化日志、API 版本策略
- **覆盖率目标**：85%

#### react-typescript

- **架构**：Feature-Sliced Design (FSD)，层级间依赖矩阵明确（pages > widgets > features > entities > shared）
- **工具链**：pnpm + ESLint + Vitest，TypeScript 严格模式
- **特色规范**：React Query 数据获取策略、Zustand 状态管理、Accessibility (WCAG) 合规
- **覆盖率目标**：80%

#### aws-cdk

- **架构**：L1/L2/L3 Construct 三层分级，每层职责清晰
- **安全**：CDK Nag 集成，安全默认值（加密、最小权限、日志审计）
- **特色规范**：Cost Optimization（资源标签、预算监控）、部署策略
- **覆盖率目标**：85%

#### generic（AI 智能生成）

- **适用场景**：任何不匹配内置 preset 的技术栈（Go + Gin、Django、Rust + Axum、Java + Spring Boot 等）
- **工作方式**：骨架模板 + AI 动态填充——先复制通用文件结构，再根据项目分析结果 AI 生成技术栈特定的内容
- **质量保障**：生成后通过 `context-schema.yaml` 中定义的质量标准自检

### 5.4 自定义和扩展

#### 生成后的自定义

所有生成的文件都归你所有，可以自由编辑：

1. **填写 `project-config.md`**：将 `<!-- TODO: ... -->` 标记替换为项目真实信息

   ```markdown
   <!-- 替换前 -->
   | <!-- TODO: 模块名 --> | <!-- TODO: 说明 --> | <!-- TODO: 核心实体 --> |

   <!-- 替换后 -->
   | `auth` | 用户认证与授权 | `User`, `Role`, `Permission` |
   ```

2. **添加自定义规则**：在 `rules/` 目录下创建新文件，遵循 Section 0 速查卡片格式，然后在 `CLAUDE.md` 中添加链接

3. **删除不需要的规则**：直接删除文件并移除 `CLAUDE.md` 中的链接

4. **运行 `/audit-context`**：获取质量报告和改进建议

#### 创建新 Preset 的基本流程

1. 在 `plugin/presets/` 下创建目录（含 `zh-CN/` 和 `en/` 子目录）
2. 编写 `preset.yaml` 定义元数据和变量
3. 创建所有必选文件（遵循 Section 0 + SSoT + 双向链接原则）
4. 在每个规则文件中使用 `{{VARIABLE}}` 占位符
5. 测试并提交 PR

详细步骤见仓库中的 `CONTRIBUTING.md` 和 `docs/customization-guide.md`。

### 5.5 最佳实践建议

1. **先生成后定制**：不要试图从零开始——先用 preset 生成完整结构，再根据项目实际情况修改

2. **保持 Section 0 速查卡片更新**：当规则变化时，优先更新速查卡片——这是 Claude Code 最频繁读取的部分

3. **定期审计**：使用 `/audit-context` 检查规范质量，特别是在项目技术栈或架构变更后

4. **善用 project-config.md**：这是模板中最需要你投入时间的文件——业务模块、核心实体、技术选型的补充信息能显著提升 Claude 的理解准确度

5. **保持文件精简**：每个规则文件建议 100-300 行。过长的文件既难以维护，也浪费 token

---

## 6. 未来规划

### 6.1 三阶段路线图

#### Phase 1: Foundation（基础）— v1.0 ✅ 已完成

发布 MVP，验证核心价值。

| 里程碑 | 内容 | 状态 |
|--------|------|:----:|
| M1.1 | 3 个核心 preset (Python/React/CDK) | ✅ |
| M1.2 | 中英双语支持 | ✅ |
| M1.3 | init.sh 交互式生成工具 | ✅ |
| M1.4 | 示例项目 (monorepo + single) | ✅ |
| M1.5 | 完整文档体系 | ✅ |
| M1.6 | GitHub Actions CI | ✅ |
| M1.7 | GitHub Template Repository | ✅ |
| M1.8 | 发布公告（英文博客 + Claude Code 社区） | ✅ |

#### Phase 1.5: Plugin 交付 — v1.1（进行中）

通过 Claude Code Plugin 降低使用门槛。

| 里程碑 | 内容 | 状态 |
|--------|------|:----:|
| M1.5.1 | Plugin MVP（/init-context 命令 + context-setup Skill） | ✅ |
| M1.5.2 | Plugin 工具链（build/sync-check/release + CI） | ✅ |
| M1.5.3 | GitHub marketplace 分发配置 | ✅ |
| M1.5.4 | 端到端外部用户安装测试 | 进行中 |

#### Phase 2: Ecosystem（生态）— v2.0

扩展 preset 覆盖，建立可组合架构和社区贡献通道。

| 里程碑 | 内容 |
|--------|------|
| M2.1 | Preset 组合机制（rule 级别继承，_common 共享） |
| M2.2 | 新增 2+ preset（Go + Next.js/Vue，总计 >= 5） |
| M2.3 | 社区贡献工作流（Issue/PR 模板、preset 审核标准） |
| M2.4 | Preset 版本追踪机制 |

#### Phase 3+: 探索性方向

以下方向不是承诺的路线图，是否执行取决于 Phase 1-2 的反馈和维护者资源：

- `/audit-context` 功能增强和远程 preset 热更新
- 社区驱动更多技术栈 preset
- CLI 分发进一步降低使用门槛
- 更多语言支持（依社区需求）

### 6.2 参与贡献

我们欢迎各种形式的贡献：

| 贡献方式 | 说明 |
|----------|------|
| **新增 Preset** | 为 Go、Java Spring Boot、Vue、Terraform 等技术栈创建 preset |
| **翻译** | 添加日文、韩文等语言支持 |
| **改进现有规范** | 增强规则文件的最佳实践内容 |
| **Bug 报告** | 报告模板或脚本中的问题 |
| **使用反馈** | 在 Issues/Discussions 中分享使用体验 |

**新 Preset 贡献流程概述**：

1. Fork 仓库，创建 feature 分支
2. 在 `plugin/presets/` 下创建 preset 目录（含 `preset.yaml` + `zh-CN/` + `en/`）
3. 包含所有必选文件，遵循设计原则
4. 提交 PR，确保 CI 验证通过

**社区链接**：

- GitHub 仓库：[arch-team/claude-context-templates](https://github.com/arch-team/claude-context-templates)
- Issue 提交：使用 GitHub Issues 报告 bug 或提出建议
- Discussions：分享使用案例和最佳实践

---

## 附录：项目文件索引

快速导航到项目中的核心文件。

### 文档

| 文件 | 用途 |
|------|------|
| `README.md` | 项目总说明和快速开始指南 |
| `CONTRIBUTING.md` | 贡献指南和 PR 流程 |
| `.claude/references/design-principles.md` | 6 大设计原则详解 |
| `docs/customization-guide.md` | 自定义和创建新 preset 指南 |
| `docs/template-variables.md` | 模板变量完整参考 |
| `docs/project-strategy.md` | 项目战略、愿景和路线图 |

### 预设模板

| 路径 | 说明 |
|------|------|
| `plugin/presets/manifest.json` | 版本清单和完整性校验 |
| `plugin/presets/context-schema.yaml` | 规范类型体系 SSoT |
| `plugin/presets/_common/` | 公共模板 + 跨 preset 工程原则 |
| `plugin/presets/python-fastapi/` | Python + FastAPI preset |
| `plugin/presets/react-typescript/` | React + TypeScript preset |
| `plugin/presets/aws-cdk/` | AWS CDK preset |
| `plugin/presets/generic/` | 通用 preset（AI 智能生成） |

### Plugin

| 路径 | 说明 |
|------|------|
| `plugin/commands/init-context.md` | /init-context 命令定义 |
| `plugin/commands/audit-context.md` | /audit-context 命令定义 |
| `plugin/skills/context-setup/` | context-setup Skill 定义 |

### 脚本工具

| 文件 | 功能 |
|------|------|
| `init.sh` | 项目初始化脚本（Shell 交付方式） |
| `scripts/validate-presets.sh` | preset 结构完整性验证 |
| `scripts/validate-generated.sh` | 生成结果验证 |
| `scripts/check-links.sh` | Markdown 链接有效性检查 |
| `scripts/test-init.sh` | init.sh 端到端测试 |

### 示例项目

| 路径 | 说明 |
|------|------|
| `examples/monorepo-taskmanager/` | 完整 Monorepo 示例（backend + frontend + infra） |
| `examples/single-project-python/` | 单项目 Python 示例 |
