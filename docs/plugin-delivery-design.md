# Claude Context Templates — Plugin 交付方案设计

> 将 claude-context-templates 作为 Claude Code Plugin 交付给最终用户的技术方案

---

## 1. 方案概述

### 1.1 核心思路

将 `claude-context-templates` 打包为 Claude Code Plugin，用户在 Claude Code 中通过 `/init-context` 命令（或自然语言触发）一键生成 `.claude/` 目录。

**本质变化**：从 "clone 仓库 + 运行 shell 脚本" 变为 "安装 plugin + 输入命令"。

### 1.2 用户体验对比

| 维度 | 当前 (init.sh) | Plugin 方案 |
|------|----------------|-------------|
| **安装** | `git clone` 整个仓库 | `/plugin install claude-context-templates` |
| **使用** | `./init.sh`（bash 交互提示） | `/init-context`（对话式交互） |
| **交互质量** | 固定选项、顺序提问 | 自然语言对话、可追问、可修改 |
| **智能程度** | 机械替换占位符 | Claude 可分析现有项目结构并给出建议 |
| **跨平台** | 依赖 bash/zsh（Windows 需 WSL） | Claude Code 支持的所有平台 |
| **更新** | 重新 clone | Plugin 版本更新 |
| **适用场景** | 通用（任何终端） | Claude Code 用户专属 |

### 1.3 与 init.sh 的关系

**互补，非替代。**

- Plugin 是面向 Claude Code 用户的**主要交付方式**
- init.sh 保留作为 CI/CD、非 Claude Code 环境的**备用方式**
- 两者共享同一套 preset 模板文件（Single Source of Truth）

---

## 2. Plugin 架构

### 2.1 目录结构

```
claude-context-templates-plugin/
├── .claude-plugin/
│   └── plugin.json                # Plugin 元数据
├── commands/
│   └── init-context.md            # /init-context 命令定义
├── skills/
│   └── context-setup/
│       └── SKILL.md               # 自动检测 skill（模型触发）
├── presets/                        # 所有 preset 模板（从主仓库同步）
│   ├── _common/
│   │   ├── en/
│   │   │   ├── root-CLAUDE.md
│   │   │   └── common-rules.md
│   │   └── zh-CN/
│   │       ├── root-CLAUDE.md
│   │       └── common-rules.md
│   ├── python-fastapi/
│   │   ├── preset.yaml
│   │   ├── en/
│   │   │   ├── CLAUDE.md
│   │   │   ├── project-config.md
│   │   │   └── rules/*.md
│   │   └── zh-CN/
│   │       └── ...
│   ├── react-typescript/
│   │   └── ...
│   └── aws-cdk/
│       └── ...
└── README.md
```

### 2.2 核心组件

#### A. Plugin Manifest (`.claude-plugin/plugin.json`)

```json
{
  "name": "claude-context-templates",
  "description": "为项目生成生产级 .claude/ 上下文目录。支持 Python/FastAPI、React/TypeScript、AWS CDK 等技术栈。",
  "version": "1.0.0",
  "author": {
    "name": "arch-team"
  }
}
```

#### B. Command (`commands/init-context.md`)

`/init-context` 是用户主动触发的入口。命令文件定义 Claude 执行此命令时的行为：

```yaml
---
description: 为当前项目生成 .claude/ 上下文目录（支持单项目和 Monorepo 模式）
---
```

命令正文包含完整的生成指令（见第 3 节详细设计）。

#### C. Skill (`skills/context-setup/SKILL.md`)

Skill 是模型自动触发的。当 Claude 检测到项目缺少 `.claude/` 目录时，可以主动建议使用此 Skill。

```yaml
---
name: Claude Context Setup
description: >
  检测并生成 .claude/ 上下文目录。当用户的项目缺少 .claude/ 目录，
  或者用户提到"初始化上下文"、"设置 CLAUDE.md"、"配置 Claude Code 规则"时自动触发。
---
```

---

## 3. `/init-context` 命令详细设计

### 3.1 交互流程

```
用户输入 /init-context
    │
    ▼
[Step 1] 语言偏好
    Claude: "请选择模板语言：1) English  2) 中文"
    │
    ▼
[Step 2] 项目模式
    Claude: "请选择项目模式：1) 单项目  2) Monorepo"
    │
    ▼
[Step 3] 项目基本信息
    Claude: "请告诉我项目名称、简短描述"
    （Claude 可尝试从 package.json/pyproject.toml 等推断）
    │
    ▼
[Step 4] 技术栈选择
    Claude: "请选择技术栈预设：
     1) Python + FastAPI (DDD, TDD, API Design)
     2) React + TypeScript (FSD, State Management)
     3) AWS CDK (Construct Patterns, Security)"
    │
    ▼
[Step 5] 可选规则确认
    Claude: "以下可选规则可以包含：
     - api-design.md (API 设计规范)
     - logging.md (日志规范)
     要包含哪些？"
    │
    ▼
[Step 6] 确认摘要
    Claude: "即将生成以下文件：
     .claude/CLAUDE.md
     .claude/rules/architecture.md
     ...共 N 个文件
     确认生成？"
    │
    ▼
[Step 7] 生成文件
    Claude 读取 preset 模板 → 替换占位符 → 使用 Write 工具创建文件
    │
    ▼
[Step 8] 完成提示
    Claude: "已生成 .claude/ 目录。
     下一步：编辑 project-config.md 填写项目特定信息"
```

### 3.2 智能增强（相比 init.sh 的优势）

Plugin 方案中 Claude 可以做到 init.sh 无法实现的事：

| 能力 | 说明 |
|------|------|
| **项目结构探测** | 自动检测 `package.json`、`pyproject.toml`、`cdk.json` 推断技术栈 |
| **智能默认值** | 从现有配置文件提取项目名称、包管理器等信息 |
| **冲突处理** | 发现已有 `.claude/` 时，对话式协商（合并/覆盖/跳过） |
| **定制建议** | 根据项目特点推荐可选规则（如检测到 API 路由则推荐 api-design.md） |
| **后续指导** | 生成后主动解释每个文件的作用，指导用户定制 |

### 3.3 命令文件内容设计

`commands/init-context.md` 核心结构：

```markdown
---
description: 为当前项目生成 .claude/ 上下文目录（支持单项目和 Monorepo 模式）
---

# Init Context 命令

## 你的角色
你是一个项目上下文配置专家。你的任务是帮助用户为他们的项目生成
结构化的 .claude/ 目录，以提升 Claude Code 的理解能力。

## 可用预设
读取 presets/ 目录下的 preset.yaml 文件获取可用预设列表。
每个预设包含该技术栈的最佳实践规则文件。

## 执行步骤
1. **探测项目**：检查当前目录的项目类型和现有配置
2. **交互确认**：依次确认语言、模式、项目信息、技术栈
3. **读取模板**：从 presets/{preset-id}/{lang}/ 读取模板文件
4. **替换变量**：将 {{VARIABLE}} 占位符替换为用户提供的值
5. **生成文件**：使用 Write 工具在目标目录创建所有文件
6. **后续指导**：告知用户下一步操作

## 变量替换规则
[详细的变量列表和替换规则]

## 重要约束
- 不修改项目已有文件（只创建 .claude/ 目录下的文件）
- 如果 .claude/ 已存在，必须先询问用户如何处理
- 保持模板内容的完整性，不要自行修改模板内容
- 只替换 {{}} 格式的占位符
```

---

## 4. Skill 自动检测设计

### 4.1 触发条件

`skills/context-setup/SKILL.md` 在以下情况自动激活：

- 用户提到"初始化上下文"、"setup CLAUDE.md"、"配置 Claude Code"
- Claude 发现项目没有 `.claude/` 目录（在其他任务中偶然检测到）
- 用户问"如何让 Claude Code 更好地理解我的项目"

### 4.2 Skill 行为

与 `/init-context` 命令共享相同的生成逻辑，但入口更轻量：

```markdown
---
name: Claude Context Setup
description: >
  检测并生成 .claude/ 上下文目录。当用户的项目缺少 .claude/ 目录，
  或提到"初始化上下文"、"设置 CLAUDE.md"、"配置规则"时自动触发。
  支持 Python/FastAPI、React/TypeScript、AWS CDK 预设模板。
---

# Context Setup Skill

当你检测到当前项目可能需要 .claude/ 上下文配置时：

1. **轻量提示**：告知用户可以使用 /init-context 命令生成上下文目录
2. **简要说明**：解释 .claude/ 目录的作用和价值
3. **不要自动执行**：不要在未经用户确认的情况下生成文件

如果用户明确要求设置，则执行与 /init-context 相同的流程。
参考 [命令定义](../commands/init-context.md) 获取完整生成逻辑。
```

---

## 5. 分发策略

### 5.1 Marketplace 发布

创建独立的 marketplace 或加入现有社区 marketplace：

```json
{
  "name": "arch-team-marketplace",
  "owner": {
    "name": "arch-team"
  },
  "plugins": [
    {
      "name": "claude-context-templates",
      "source": "./claude-context-templates-plugin",
      "description": "生产级 .claude/ 上下文模板生成器"
    }
  ]
}
```

### 5.2 用户安装流程

```bash
# 1. 添加 marketplace（一次性）
/plugin marketplace add arch-team/claude-plugins

# 2. 安装 plugin
/plugin install claude-context-templates@arch-team

# 3. 使用
/init-context
```

### 5.3 团队分发

团队可在仓库的 `.claude/settings.json` 中配置自动安装：

```json
{
  "plugins": {
    "marketplaces": ["arch-team/claude-plugins"],
    "installed": {
      "claude-context-templates@arch-team": { "enabled": true }
    }
  }
}
```

---

## 6. Preset 同步策略

### 6.1 单一源问题

主仓库 `claude-context-templates` 和 plugin 都包含 preset 文件。需要确保一致性。

### 6.2 推荐方案：构建时同步

```
claude-context-templates/         # 主仓库（源）
├── presets/                      # 模板源文件
├── init.sh                      # Shell 交付方式
└── plugin/                      # Plugin 目录
    ├── .claude-plugin/
    ├── commands/
    ├── skills/
    └── presets/ → 构建时从 ../presets/ 复制
```

使用简单的构建脚本：

```bash
#!/bin/bash
# scripts/build-plugin.sh
rsync -av --delete presets/ plugin/presets/
echo "Plugin presets synced from main repository"
```

### 6.3 CI 验证

GitHub Actions 检查 plugin/presets/ 与 presets/ 的一致性，防止漂移。

---

## 7. 实施路径

### Phase 1: MVP Plugin（最小可用版本）

**目标**：可安装、可使用的基础版本

| 任务 | 说明 |
|------|------|
| 创建 plugin 目录结构 | `.claude-plugin/plugin.json` + `commands/` + `presets/` |
| 编写 `/init-context` 命令 | 支持单项目模式 + 3 个预设 |
| 同步 preset 文件 | 从主仓库复制到 plugin 目录 |
| 本地测试 | 使用本地 marketplace 验证 |

### Phase 2: 智能增强

| 任务 | 说明 |
|------|------|
| 添加项目探测能力 | 自动识别技术栈和项目配置 |
| 添加 Monorepo 支持 | 多子项目生成流程 |
| 添加 Skill 自动检测 | `skills/context-setup/SKILL.md` |
| 发布到 marketplace | 创建 arch-team marketplace |

### Phase 3: 生态扩展

| 任务 | 说明 |
|------|------|
| preset 热更新 | Plugin 从远程获取最新 preset |
| 社区 preset | 支持第三方 preset 来源 |
| 上下文审计 | `/audit-context` 命令检查现有 .claude/ 质量 |

---

## 8. 技术风险与应对

| 风险 | 影响 | 应对 |
|------|------|------|
| Preset 内容太大，超出上下文窗口 | 中 | Claude 按需读取单个 preset，不一次性加载所有内容 |
| Claude 生成的文件与 init.sh 不一致 | 中 | 命令明确指示"原样复制模板内容，只替换占位符" |
| Plugin 机制未来可能变化 | 低 | 关注 Claude Code changelog，plugin 结构已相对稳定 |
| 用户 Claude Code 版本不支持 plugin | 低 | README 标注最低版本要求，保留 init.sh 作为 fallback |

---

## 9. 成功指标

| 指标 | 目标 | 衡量方式 |
|------|------|----------|
| Plugin 安装数 | v1.0 后 3 个月内 ≥ 20 | Marketplace 统计 |
| 命令使用成功率 | ≥ 95% | 用户反馈 |
| 生成文件一致性 | 与 init.sh 输出 100% 一致 | 自动化对比测试 |
| 用户满意度 | 正面反馈 > 负面 | GitHub Issues/Discussions |
