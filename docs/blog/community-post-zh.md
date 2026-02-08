# 开源：claude-context-templates —— Claude Code 的 `.claude/` 目录模板系统

分享一个刚发布的开源项目：**claude-context-templates**，为 Claude Code 项目提供结构化的 `.claude/` 目录模板。

## 背景

使用 Claude Code 开发时，`.claude/` 目录中的 CLAUDE.md 和 rules 文件直接影响 Claude 理解项目的能力。但目前没有标准化的搭建方式——每个项目都从零开始，质量参差不齐。

## 这个项目做什么

- **3 个技术栈预设**：Python/FastAPI、React/TypeScript、AWS CDK
- **交互式初始化**：运行 `./init.sh`，选择预设和语言，自动生成完整 `.claude/` 目录
- **支持 Monorepo 和单项目**两种模式
- **中英双语**模板

每个预设包含：入口文件、项目配置模板、架构/测试/安全/代码风格等话题规则文件。

## 设计特点

模板基于 6 个设计原则（从真实生产项目提炼）：
- **单一事实来源**：每个概念只定义一次，其他地方通过链接引用
- **Section 0 快速参考**：每个规则文件开头放表格/决策树，让 Claude 优先获取关键信息
- **分层架构**：根级 → 子项目 → 话题，层次清晰
- **双向链接**：文档间互相引用，形成 Claude 可遍历的知识网络

## 快速体验

```bash
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates
./init.sh
```

## 期望反馈

- 模板结构和设计原则的改进建议
- 新预设贡献（Go、Java、Vue 等）
- 真实项目的使用体验报告

GitHub: https://github.com/arch-team/claude-context-templates

MIT 许可证，欢迎 Star、Fork 和贡献。
