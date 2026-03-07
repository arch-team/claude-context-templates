# 技术约定

> Claude Context Templates 的技术约定 — 仅记录非显而易见的规则

## 技术栈

- **核心语言**: Shell (Bash)
- **文档格式**: Markdown
- **版本控制**: Git
- **CI/CD**: GitHub Actions

## 编码规范

- **Shell 脚本**: 使用 bash shebang，遵循 ShellCheck 规则
- **文档**: 使用 CommonMark 规范的 Markdown
- **命名约定**: 所有文档文件使用 `kebab-case.md` 格式（除 CLAUDE.md 和 README.md）

## 项目约定

- **双语支持**: 所有预设模板必须包含 zh-CN 和 en 两个语言版本
- **目录结构**: 预设模板按技术栈分类（presets/），示例项目独立存放（examples/）
- **模板变量**: 使用 `{{VARIABLE_NAME}}` 格式的占位符，详见 docs/template-variables.md

## 开发流程

- **Git 策略**: trunk-based（基于 main 分支的特性分支工作流）
- **分支命名**: `feat/`, `fix/`, `docs/` 等前缀
- **提交规范**: 遵循 .claude/rules/common.md 中定义的提交信息格式

## 架构约束

（随开发自然积累 — 发现重要约束时由 Claude 或用户添加）
