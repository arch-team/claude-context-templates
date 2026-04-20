# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.3.1] - 2026-04-20

### 用户体验 Patch 修复

v1.3.0 发布后通过手工端到端测试发现 3 个影响首次使用体验的 UX bug，均已修复。

### Fixed

- **B2 项目名称被错误 lowercase**：所有 preset 的 `project-config.md` 中"项目名称"字段误用 `{{PROJECT_SLUG}}`（kebab-case 标识符），导致用户输入 `MyAwesomeApp` 显示为 `myawesomeapp`。修正为 `{{PROJECT_NAME}}`（用户原文）。
- **B3 项目描述未填充**：`python-fastapi` / `react-typescript` / `aws-cdk` 三个 preset 的 `project-config.md` 中"项目描述"字段硬编码为 TODO 占位符，用户在交互流程中输入的描述被丢弃。现改为 `{{PROJECT_DESCRIPTION}}` 占位符，init.sh 自动填充。
- **B4 单项目模式生成 Monorepo 引用路径**：所有 preset 的 `CLAUDE.md` 硬编码"参考根目录 `../.claude/CLAUDE.md`"，在单项目模式下指向不存在的父目录。引入 `{{PARENT_CLAUDE_REF}}` 占位符，init.sh 按模式动态填充（Monorepo=实际引用，单项目=空串）。

### Improved

- `init.sh`：用户未输入项目描述时，自动填充为 `<!-- TODO: 填写项目描述 -->` 占位符，方便用户后续编辑
- `scripts/test-init.sh`：新增 `assert_file_contains` / `assert_file_not_contains` 辅助函数，并为 B2/B3/B4 三个 bug 加入专门回归断言（共 4 个新断言），防止未来再次引入类似问题

### Housekeeping

- 四处版本号（plugin.json / plugin 内 marketplace.json / 根 marketplace.json / manifest.json）同步升至 1.3.1

### 发现过程

发布 v1.3.0 数分钟后在一个 fresh 项目中手工运行完整 `init.sh` 流程，发现上述 3 个 bug。此前自动化测试全部绿，但因断言只覆盖"通用文件存在"未检测到变量替换错误。本次修复同时加强了断言覆盖面。

教训：**手工端到端体验测试 > 自动化断言覆盖率**——战略文档"evidence-based > assumption"在工程实践中的体现。

---

## [1.3.0] - 2026-04-20

### 清理与规范收尾版

本版本聚焦自 v1.0.0 以来累积变更的正式发布，重点是代码清理、规范体系完善和项目状态归档。

### Added

- 新增 `CHANGELOG.md`，正式建立版本变更追踪
- 新增 Skills 开发进阶指导手册（`docs/skills-development-guide.md`）
- `.claude/rules/` 新增分层架构规范（产品层 / 开发层分离）
- `.claude/references/` 新增设计原则与 IA 原则参考文档
- 新增 `generic` preset，提供无特定技术栈的通用模板

### Changed

- **Plugin Skill 双 ID 重构**：`context-setup` skill 的触发和内容结构优化（见 v1.2 内部迭代）
- `init-context` / `audit-context` 命令增强，支持 `generic` preset 和 `context-schema.yaml`
- Preset 统一存储至 `plugin/presets/`，引入轻量版本感知机制
- Preset 模板格式统一，新增 `_common` 跨 preset 工程原则
- 规范体系精简：消除跨文件重复，强化 SSoT 合规
- 融合 devpace 成熟设计实践到项目规范

### Fixed

- 对齐 `plugin.json` 与 `manifest.json` 版本号
- 修复 `context-setup` skill 的 scenario 编号和缺失引用
- 工程质量审计修复（H1-H6, M1-M5, L1-L5 共 16 项问题）

### Housekeeping

- 归档项目初始需求草稿至 `.devpace/requirements/archive/initial-drafts.md`
- `.devpace/state.md` 版本信息与实际产物同步
- `.gitignore` 增加 skill eval workspace 目录

### 版本号说明

**v1.1.0 / v1.2.0 未作为正式 release 发布**：这两个版本号在演进过程中先出现在 `manifest.json`，后由 commit `3a27d29` 同步到 `plugin.json`，属于内部版本号对齐操作，未打 git tag、未对外发布。v1.3.0 是 v1.0.0 之后的首次正式 release，累计包含上述所有变更。

---

## [1.0.0] - 2026-03（首发）

### 🎉 首次公开发布

**MVP 范围**：
- 3 个核心 preset：`python-fastapi`、`react-typescript`、`aws-cdk`
- 双语支持：zh-CN / en 完整覆盖
- `init.sh` 交互式生成工具（macOS / Linux）
- 完整示例项目：`examples/monorepo-taskmanager`、`examples/single-project-python`
- GitHub Template Repository 配置
- CI 体系：preset 结构验证 + init.sh 烟雾测试（macOS + Ubuntu 矩阵）
- 6 大设计原则：SSoT、Section 0、分层架构、依赖矩阵、双向链接、kebab-case

### Added

- Claude Code Plugin 交付方式（`/init-context` 命令、`context-setup` Skill）
- `/audit-context` 命令：`.claude/` 目录质量审计（ABCD 五维评级）
- marketplace.json 分发配置

---

[1.3.1]: https://github.com/arch-team/claude-context-templates/releases/tag/v1.3.1
[1.3.0]: https://github.com/arch-team/claude-context-templates/releases/tag/v1.3.0
[1.0.0]: https://github.com/arch-team/claude-context-templates/releases/tag/v1.0.0
