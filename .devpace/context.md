# 开发上下文

> **职责**：记录项目技术栈、编码约定和架构约束。

## 技术栈

- **语言**: Shell (Bash)
- **主要工具**: Git, Claude Code Plugin系统
- **CI/CD**: GitHub Actions（触发方式：push to main, PR to main）

## 开发流程

- **分支策略**: Trunk-based（main + feature 分支）
- **提交规范**: 见 `.claude/rules/common.md`
- **PR 流程**: 所有变更通过 PR 合并到 main

## 编码约定

### 文件命名

- 框架约定文件：UPPERCASE.md（如 CLAUDE.md、README.md、CONTRIBUTING.md）
- 项目文档：kebab-case.md（如 dev-workflow.md、plugin-dev-spec.md）
- 脚本：kebab-case.sh（如 validate-presets.sh）

### 项目结构

- **产品层** (`plugin/`)：随 Plugin 分发，不依赖开发层
- **开发层** (`.claude/`, `docs/`, `scripts/`)：仅用于开发本项目

详见 `.claude/rules/project-structure.md`

## 架构约束

- **分层隔离**: plugin/ 不得引用 .claude/、docs/、scripts/
- **SSoT 原则**: 每个概念仅在一处定义（如目录结构在 project-structure.md）
- **模板系统**: plugin/presets/ 是唯一的预设模板来源

<!-- 由 devpace 自动检测和记录，手动编辑前请阅读 devpace context 文档 -->
