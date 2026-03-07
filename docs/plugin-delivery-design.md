# Claude Context Templates — Plugin 交付方案设计

> 将 claude-context-templates 作为 Claude Code Plugin 交付给最终用户的技术方案

---

## 1. 方案概述

### 1.1 核心思路

将 `claude-context-templates` 打包为 Claude Code Plugin，用户在 Claude Code 中通过 `/init-context` 命令（或自然语言触发）一键生成 `.claude/` 目录。

**本质变化**：从 "clone 仓库 + 运行 shell 脚本" 变为 "安装 plugin + 输入命令"。

### 1.2 用户体验对比

| 维度 | init.sh 方式 | Plugin 方式 |
|------|-------------|-------------|
| **安装** | `git clone` 整个仓库 | `/plugin marketplace add` + `/plugin install` |
| **使用** | `./init.sh`（bash 交互提示） | `/init-context`（对话式交互） |
| **交互质量** | 固定选项、顺序提问 | 自然语言对话、可追问、可修改 |
| **智能程度** | 机械替换占位符 | Claude 可分析现有项目结构并给出建议 |
| **跨平台** | 依赖 bash/zsh（Windows 需 WSL） | Claude Code 支持的所有平台 |
| **更新** | 重新 clone | Plugin 版本更新 |
| **适用场景** | 通用（任何终端、CI/CD） | Claude Code 用户专属 |

### 1.3 与 init.sh 的关系

**互补，非替代。**

- Plugin 是面向 Claude Code 用户的**主要交付方式**
- init.sh 保留作为 CI/CD、非 Claude Code 环境的**备用方式**
- 两者共享同一套 preset 模板文件（`presets/` 为 Single Source of Truth）

---

## 2. Plugin 架构（当前实现）

### 2.1 目录结构

```
plugin/                              # Plugin 根目录（自包含）
├── .claude-plugin/
│   ├── plugin.json                  # Plugin 元数据
│   └── marketplace.json             # 内置 local-dev marketplace
├── commands/
│   └── init-context.md              # /init-context 命令定义
├── skills/
│   └── context-setup/
│       └── SKILL.md                 # 自动检测 Skill（模型触发）
├── presets/                         # Preset 模板（从 presets/ 同步）
│   ├── _common/{en,zh-CN}/          # 公共模板（root-CLAUDE.md, common-rules.md）
│   ├── python-fastapi/              # Python + FastAPI 预设（27 文件）
│   ├── react-typescript/            # React + TypeScript 预设（27 文件）
│   └── aws-cdk/                     # AWS CDK 预设（25 文件）
└── README.md                        # Plugin 使用说明
```

### 2.2 核心组件

| 组件 | 文件 | 说明 |
|------|------|------|
| **Plugin 元数据** | `.claude-plugin/plugin.json` | 名称、版本、描述、作者 |
| **内置 Marketplace** | `.claude-plugin/marketplace.json` | `local-dev` marketplace，简化本地测试 |
| **命令** | `commands/init-context.md` | `/init-context` 用户主动触发入口 |
| **Skill** | `skills/context-setup/SKILL.md` | 模型自动检测，项目缺少 `.claude/` 时建议 |
| **Preset 模板** | `presets/` | 83 个模板文件，构建时从主仓库同步 |

### 2.3 工具链

| 脚本 | 说明 |
|------|------|
| `scripts/build-plugin.sh` | 将 `presets/` 同步到 `plugin/presets/` + 结构验证 |
| `scripts/check-plugin-sync.sh` | CI 检查 plugin/presets/ 与 presets/ 的一致性 |
| `scripts/release-plugin.sh` | 版本发布流程（version bump → build → verify → 指引 commit/tag） |

### 2.4 CI 集成

`check-plugin-sync` job 已集成到 `.github/workflows/ci.yml`，每次 push/PR 自动检查 preset 同步状态。

---

## 3. Preset 同步策略（已实现）

```
presets/                    ← Single Source of Truth
    │
    ├── init.sh 直接读取
    │
    └── scripts/build-plugin.sh
            │
            ▼
        plugin/presets/     ← 构建时复制
            │
            └── CI: check-plugin-sync.sh 验证一致性
```

- `build-plugin.sh`：使用 `rsync --delete` 确保完全一致
- `check-plugin-sync.sh`：使用 `diff -rq` 检测漂移，CI 中自动运行
- `release-plugin.sh`：发布前自动调用两者

---

## 4. 分发策略

### 4.1 本地开发测试（已实现）

Plugin 内置了 `local-dev` marketplace，开发者可直接测试：

```bash
/plugin marketplace add ./plugin
/plugin install claude-context-templates@local-dev
```

### 4.2 正式发布（待实施）

两种方案：

**方案 A：主仓库直接作为 marketplace**

用户添加 GitHub 仓库作为 marketplace 源：

```bash
/plugin marketplace add arch-team/claude-context-templates
/plugin install claude-context-templates@claude-context-templates
```

**方案 B：独立 marketplace 仓库**

创建 `arch-team/claude-plugins` 作为 marketplace，托管多个 plugin：

```bash
/plugin marketplace add arch-team/claude-plugins
/plugin install claude-context-templates@claude-plugins
```

> 推荐方案 A（简单直接），除非未来有多个 Plugin 需要统一管理。

### 4.3 团队分发

团队可在项目 `.claude/settings.json` 中配置自动安装：

```json
{
  "plugins": {
    "marketplaces": ["arch-team/claude-context-templates"],
    "installed": {
      "claude-context-templates@claude-context-templates": { "enabled": true }
    }
  }
}
```

---

## 5. 实施路径与当前进度

### Phase 1: MVP Plugin — ✅ 已完成

| 任务 | 状态 |
|------|------|
| Plugin 目录结构 + `plugin.json` | ✅ |
| `/init-context` 命令（单项目 + Monorepo + 3 preset） | ✅ |
| `context-setup` Skill（自动检测） | ✅ |
| `build-plugin.sh`（preset 同步 + 结构验证） | ✅ |
| 内置 `marketplace.json`（local-dev） | ✅ |
| `check-plugin-sync.sh`（CI 一致性检查） | ✅ |
| `release-plugin.sh`（版本发布流程） | ✅ |
| CI workflow 集成 | ✅ |
| Plugin README | ✅ |

### Phase 2: 正式发布 + 主仓库整合

**目标**：让外部用户可以安装使用，并更新主仓库文档推荐 Plugin 方式。

| 任务 | 说明 |
|------|------|
| 确定 marketplace 分发方案 | 方案 A（主仓库）或方案 B（独立仓库） |
| 配置 marketplace 正式发布 | 根据所选方案配置 GitHub 仓库 |
| 更新主仓库 README | 添加 Plugin 安装方式作为推荐使用方法 |
| 更新 project-strategy.md | 将 Plugin 交付纳入路线图 |
| 端到端发布测试 | 模拟外部用户完整安装流程验证 |

### Phase 3: 增强与生态

| 任务 | 说明 |
|------|------|
| `/audit-context` 命令 | 检查现有 `.claude/` 目录质量并给出改进建议 |
| Preset 远程更新 | Plugin 从 GitHub 获取最新 preset，无需重新安装 |
| 社区 preset 支持 | 允许第三方 preset 来源 |
| 新增 preset（Go, Next.js 等） | 随主仓库 Phase 2 同步扩展 |

---

## 6. 技术风险与应对

| 风险 | 影响 | 应对 |
|------|------|------|
| Preset 内容大，超出上下文窗口 | 中 | Claude 按需读取单个 preset，不一次性加载 |
| Claude 生成文件与 init.sh 不一致 | 中 | 命令明确指示"原样复制模板内容，只替换占位符" |
| Plugin 机制未来变化 | 低 | 关注 Claude Code changelog，结构已相对稳定 |
| 用户 Claude Code 版本不支持 plugin | 低 | README 标注最低版本要求，保留 init.sh |
| preset 同步遗忘 | 低 | CI `check-plugin-sync` 自动拦截 |

---

## 7. 成功指标

| 指标 | 目标 | 衡量方式 |
|------|------|----------|
| Plugin 安装数 | 发布后 3 个月内 ≥ 20 | Marketplace 统计 |
| 命令使用成功率 | ≥ 95% | 用户反馈 |
| 生成文件一致性 | 与 init.sh 输出 100% 一致 | 自动化对比测试 |
| 用户满意度 | 正面反馈 > 负面 | GitHub Issues/Discussions |
