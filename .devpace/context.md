# 技术上下文

## 技术栈

- **核心语言**: Shell Script（项目初始化）, Markdown（模板和文档）
- **构建工具**: Bash scripts（验证和构建流程）
- **版本管理**: 语义化版本 (当前 v1.3.1)

## 架构约束

- **Plugin 分发**: Claude Code Plugin 系统
- **模板系统**: 基于占位符的文件生成
- **目录结构**: 产品层（plugin/）与开发层（.claude/, docs/, scripts/）分离

## 开发流程

- **分支策略**: trunk-based（main + feature 分支）
- **版本发布**: 手动标签 + CHANGELOG 维护
- **CI/CD**: GitHub Actions（自动测试，手动发布）

## 编码规范

- **文档命名**: kebab-case.md（框架文件除外如 CLAUDE.md, README.md）
- **Git 提交**: 约定式提交（type(scope): description）
- **双语支持**: zh-CN + en 并行维护
