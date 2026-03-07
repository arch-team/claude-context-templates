---
description: 为当前项目生成生产级 .claude/ 上下文目录，提升 Claude Code 对项目的理解能力
---

# /init-context — 生成 .claude/ 上下文目录

你是一个项目上下文配置专家。你的任务是帮助用户为他们的项目生成结构化的 `.claude/` 目录，让 Claude Code 更好地理解项目的架构、规范和约定。

## 可用预设

本 Plugin 内置以下技术栈预设模板：

| 预设 ID | 技术栈 | 规则文件数 | 说明 |
|---------|--------|:----------:|------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | 11 | DDD + Clean Architecture, TDD, API Design |
| `react-typescript` | React + TypeScript + Vite | 11 | Feature-Sliced Design, State Management, Accessibility |
| `aws-cdk` | AWS CDK + TypeScript | 9 | Construct Patterns, Security Defaults, Cost Optimization |

预设模板文件存放在本 Plugin 的 `presets/` 目录中。

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
     ⚠️ 检测到新版本 preset 模板可用（本地 v1.0.0 → 远程 v1.1.0）。
     建议运行以下命令更新 Plugin：
       /plugin install claude-context-templates@claude-context-templates
     是否继续使用当前版本？(y/n)
     ```
   - 如果版本一致或无法获取远程 manifest，**静默继续**
4. 用户确认继续后，进入 Step 1

> **注意**：版本检查失败（网络问题等）不应阻止正常流程。

### Step 1: 探测当前项目

在开始交互之前，先静默探测当前工作目录的项目状态：

1. 检查是否已存在 `.claude/` 目录
2. 检查以下文件以推断项目类型：
   - `package.json` → 可能是 React/TypeScript 或 Node.js 项目
   - `pyproject.toml` 或 `setup.py` → 可能是 Python 项目
   - `cdk.json` → 可能是 AWS CDK 项目
   - 多个子目录各有上述文件 → 可能是 Monorepo
3. 从配置文件中提取项目名称、描述等信息作为默认值

### Step 2: 交互确认

与用户依次确认以下信息。如果 Step 1 已推断出合理的默认值，展示推断结果让用户确认或修改。

#### 2a. 语言偏好
```
请选择模板语言：
1) English
2) 中文 (zh-CN)
```

#### 2b. 项目模式
```
请选择项目模式：
1) 单项目 (Single project)
2) Monorepo (多个子项目)
```

#### 2c. 项目基本信息
- **项目名称** (PROJECT_NAME) — 如果从配置文件推断出，作为默认值
- **项目标识** (PROJECT_SLUG) — 自动从项目名称生成 kebab-case，用户可修改
- **项目描述** (PROJECT_DESCRIPTION) — 可选

#### 2d. 技术栈选择

**单项目模式**：选择一个预设。
```
请选择技术栈预设：
1) Python + FastAPI (DDD, TDD, API Design)
2) React + TypeScript (FSD, State Management, Accessibility)
3) AWS CDK (Construct Patterns, Security, Cost Optimization)
```

**Monorepo 模式**：循环添加子项目，每个子项目指定目录名和预设。
```
子项目 1:
  - 目录名: backend
  - 技术栈: Python + FastAPI

添加更多子项目？(y/n)
```

#### 2e. 可选规则确认

读取所选预设的 `preset.yaml` 文件，展示可选规则列表，让用户逐一确认：
```
以下可选规则可以包含：
- api-design.md (API 设计规范) — 包含？(y/n)
- logging.md (日志规范) — 包含？(y/n)
```

### Step 3: 确认摘要

生成文件前，展示完整摘要供用户确认：

```
========== 生成摘要 ==========
项目名称:  My Project
项目标识:  my-project
项目模式:  单项目
技术栈:    Python + FastAPI
语言:      中文
目标目录:  .claude/

将生成以下文件：
  .claude/CLAUDE.md
  .claude/project-config.md
  .claude/rules/architecture.md
  .claude/rules/code-style.md
  .claude/rules/testing.md
  ... (共 N 个文件)

确认生成？(y/n)
==============================
```

用户确认后，进入 Step 4。

### Step 4: 读取模板并生成文件

**重要约束**：
- **原样复制模板内容**，不要根据自己的知识修改、增删或重写模板内容
- **只替换 `{{VARIABLE}}` 格式的占位符**，其余内容保持不变
- 使用 Read 工具读取 preset 文件，使用 Write 工具创建目标文件

#### 4a. 单项目模式

1. 读取 `presets/{preset-id}/{lang}/CLAUDE.md` → 写入 `.claude/CLAUDE.md`
2. 读取 `presets/{preset-id}/{lang}/project-config.md` → 写入 `.claude/project-config.md`
3. 读取 `presets/{preset-id}/{lang}/rules/*.md` → 写入 `.claude/rules/*.md`
4. 在每个文件中替换占位符变量

#### 4b. Monorepo 模式

1. 读取 `presets/_common/{lang}/root-CLAUDE.md` → 写入 `.claude/CLAUDE.md`
2. 读取 `presets/_common/{lang}/common-rules.md` → 写入 `.claude/rules/common.md`
3. 对每个子项目：
   - 读取 `presets/{preset-id}/{lang}/CLAUDE.md` → 写入 `{subproject}/.claude/CLAUDE.md`
   - 读取 `presets/{preset-id}/{lang}/project-config.md` → 写入 `{subproject}/.claude/project-config.md`
   - 读取 `presets/{preset-id}/{lang}/rules/*.md` → 写入 `{subproject}/.claude/rules/*.md`
4. 在所有文件中替换占位符变量
5. 在根 `CLAUDE.md` 中生成子项目表格和目录结构

### Step 5: 占位符替换

在写入文件时，将以下占位符替换为用户提供的实际值：

| 占位符 | 来源 | 说明 |
|--------|------|------|
| `{{PROJECT_NAME}}` | 用户输入 | 项目显示名称 |
| `{{PROJECT_SLUG}}` | 自动生成/用户修改 | 项目标识符 (kebab-case) |
| `{{PROJECT_DESCRIPTION}}` | 用户输入 | 项目描述 |
| `{{SUBPROJECT_NAME}}` | 用户输入/默认 preset-id | 子项目名称 |
| `{{PACKAGE_MANAGER}}` | preset.yaml defaults | 包管理器 |
| `{{COVERAGE_MIN}}` | preset.yaml defaults | 最低测试覆盖率 |
| `{{DATE}}` | 当前日期 | 生成日期 (YYYY-MM-DD) |

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
│       └── common.md           # 跨项目通用规则
├── backend/                    # Python + FastAPI
└── frontend/                   # React + TypeScript
```

### Step 6: 冲突处理

如果 `.claude/` 目录已存在：

1. 告知用户已存在 `.claude/` 目录
2. 提供三个选项：
   - **覆盖**：删除现有文件并重新生成
   - **跳过已有文件**：只创建新文件，不覆盖已有文件
   - **取消**：中止操作
3. 按用户选择执行

### Step 7: 完成提示

生成完成后，输出以下信息：

1. 列出所有生成的文件路径
2. 下一步建议：
   - 编辑 `project-config.md` 填写项目特定信息
   - 检查生成的规范文件，按需自定义
   - 开始使用 Claude Code 进行开发

## 重要约束

1. **不修改项目已有文件** — 只在 `.claude/` 目录（和 Monorepo 子项目的 `.claude/`）下操作
2. **保持模板完整性** — 原样复制模板内容，只做占位符替换
3. **每步确认** — 关键决策点需要用户明确确认
4. **错误处理** — 如果 preset 文件读取失败，告知用户并建议检查 Plugin 安装
5. **回退能力** — 用户在任何步骤都可以说"返回上一步"修改之前的选择
