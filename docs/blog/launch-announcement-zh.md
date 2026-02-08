# Claude Context Templates：为每个项目提供生产级 `.claude/` 上下文管理

## 问题

如果你使用 Claude Code 辅助开发，你一定接触过 `.claude/` 目录 —— Claude Code 通过读取其中的 `CLAUDE.md` 和 `rules/` 文件来理解你的项目。上下文组织得越好，Claude 生成的代码质量越高、建议越准确。

但问题是：**搭建一个高质量的 `.claude/` 目录没有标准化的方法。**

大多数开发者要么从零开始写（耗时且质量不稳定），要么从别人的项目复制（技术栈不匹配）。每个新项目都在重复这个过程。

## 解决方案

**claude-context-templates** 提供生产级的、可复用的 `.claude/` 目录模板。你可以把它理解为 Claude Code 版的 `.editorconfig` —— 一个编码了最佳实践的标准化起点。

### 核心特性

- **3 个技术栈预设**：Python FastAPI、React TypeScript、AWS CDK
- **中英双语**：所有模板提供中文和英文版本
- **交互式初始化**：运行 `init.sh`，按提示选择即可生成完整结构
- **Monorepo + 单项目**：两种模式都支持

### 每个预设包含

| 文件 | 作用 |
|------|------|
| `CLAUDE.md` | 子项目入口，技术栈概览和开发命令 |
| `project-config.md` | 项目配置填写模板（需要你填入项目具体信息） |
| `rules/architecture.md` | 架构模式和依赖规则 |
| `rules/code-style.md` | 编码规范 |
| `rules/testing.md` | 测试方法论 |
| `rules/security.md` | 安全检查清单 |
| ... | 更多话题规则 |

## 6 大设计原则

这不只是一堆 Markdown 文件的集合。模板系统基于 6 个核心设计原则，从真实的生产级 Monorepo 项目中提炼而来：

1. **单一事实来源（SSoT）**—— 每个概念只在一个文件中定义，其他文件通过链接引用。避免重复，避免信息漂移。

2. **Section 0 快速参考卡片** —— 每个 rules 文件以快速查阅区（表格、决策树、速查表）开头，让 Claude 优先获取关键信息。

3. **分层架构** —— 根级规则 → 子项目规则 → 话题规则，层次分明、职责清晰。

4. **双向链接** —— 文档之间通过相对路径互相引用，形成 Claude 可以遍历的知识网络。

5. **依赖矩阵** —— 用表格定义架构层之间的依赖规则，给 Claude 明确的边界。

6. **kebab-case 命名** —— 统一的文件命名约定。

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates

# 2. 运行交互式初始化脚本
./init.sh

# 3. 按提示选择预设、语言、项目模式
# 4. 将生成的 .claude/ 目录复制到你的项目中
```

`init.sh` 会自动处理变量替换（`{{PROJECT_NAME}}`、`{{PROJECT_SLUG}}` 等）、语言选择和项目模式配置。

## 定位

**这是一个起点，不是一个框架。** 生成的文件完全属于你，可以自由修改、添加、删除。模板提供结构化的基础和最佳实践参考——你在此基础上按团队约定定制即可。

## 期待你的反馈

这是项目的首次公开发布，我们最需要的是真实使用反馈：

- **给项目 Star**：[github.com/arch-team/claude-context-templates](https://github.com/arch-team/claude-context-templates)
- **提交使用报告**：使用 Issue 模板中的 "Usage Report" 分享你的使用体验——这是最有价值的反馈
- **贡献新预设**：为你的技术栈（Go、Java、Vue 等）创建预设
- **报告问题**：任何不好用的地方都欢迎提 Issue

项目采用 MIT 许可证，欢迎贡献。
