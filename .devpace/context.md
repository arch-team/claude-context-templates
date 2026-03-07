# 技术约定

> claude-context-templates 的技术约定 — 仅记录非显而易见的规则

## 技术栈

- **主要语言**: Shell 脚本（Bash）
- **项目类型**: 文档管理 + 模板系统
- **构建工具**: GitHub Actions + 自定义脚本（scripts/）

## 编码规范

- Shell 脚本采用 POSIX 兼容语法
- 所有脚本必须通过 shellcheck 静态检查
- 文档使用中文（zh-CN）和英文（en）双语版本

## 开发流程

- **Git 策略**: trunk-based（仅 main 分支）
- **CI/CD**: GitHub Actions（push/PR 触发）
  - validate-presets: 验证预设模板结构
  - test-init: 跨平台测试初始化脚本
  - build-plugin: 构建和验证 Plugin
  - check-links: 检查 Markdown 链接

## 项目约定

- 预设模板必须同时提供 zh-CN 和 en 两个语言版本
- 所有 shell 脚本必须添加执行权限（chmod +x）
- 模板变量使用 `{{VAR_NAME}}` 格式

## 架构约束

（随开发自然积累 — 发现重要约束时由 Claude 或用户添加）
