# Claude Context Templates

> 为 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 提供结构化、可复用的上下文管理模板。几秒钟内为你的项目生成完善的 `.claude/` 目录。

[English](README.md)

## 为什么需要这个？

Claude Code 通过读取 `CLAUDE.md` 文件和 `.claude/rules/` 目录来理解你的项目。一个结构良好的上下文目录能显著提升 Claude 对代码库的理解——带来更好的代码生成、更一致的代码审查和更智能的建议。

**本项目提供生产级模板**，基于真实 Monorepo 项目中经过验证的模式，让你无需从零构建上下文管理体系。

## 快速开始

```bash
# 1. 克隆模板仓库
git clone https://github.com/arch-team/claude-context-templates.git
cd claude-context-templates

# 2. 运行交互式初始化脚本
./init.sh

# 3. 按照提示生成 .claude/ 目录结构
```

脚本会询问你的项目信息，然后生成完整的 `.claude/` 目录结构，适配你选择的技术栈。

## 可用预置模板

| 预置模板 | 技术栈 | 规范文件数 | 说明 |
|---------|--------|:---------:|------|
| `python-fastapi` | Python + FastAPI + SQLAlchemy | 11 | DDD + 整洁架构、TDD、API 设计 |
| `react-typescript` | React + TypeScript + Vite | 11 | FSD 分层设计、状态管理、无障碍 |
| `aws-cdk` | AWS CDK + TypeScript | 9 | Construct 模式、安全默认、成本优化 |

每个预置模板包含：
- **CLAUDE.md** — 子项目入口（技术栈、开发命令、导航）
- **project-config.md** — 项目特定配置（填空模板）
- **rules/*.md** — 专题规范（架构、测试、安全等）

## 生成的目录结构

### Monorepo 模式

```
your-project/
├── .claude/
│   ├── CLAUDE.md              # 全局入口
│   └── rules/
│       └── common.md          # 跨项目通用规则（Git、文档、结构）
├── backend/.claude/
│   ├── CLAUDE.md              # 后端入口
│   ├── project-config.md      # <- 编辑此文件填入项目信息
│   └── rules/
│       ├── architecture.md    # DDD + 整洁架构
│       ├── api-design.md      # RESTful API 规范
│       ├── code-style.md      # Python 编码规范
│       ├── testing.md         # TDD 方法论
│       ├── security.md        # 安全检查清单
│       └── ...                # 更多专题规范
├── frontend/.claude/
│   └── ...                    # React + TypeScript 规范
└── infra/.claude/
    └── ...                    # AWS CDK 规范
```

### 单项目模式

```
your-project/
└── .claude/
    ├── CLAUDE.md              # 项目入口
    ├── project-config.md      # <- 编辑此文件填入项目信息
    └── rules/
        ├── architecture.md
        ├── code-style.md
        ├── testing.md
        └── ...
```

## 设计原则

本模板系统基于 6 大核心设计原则：

| 原则 | 说明 |
|------|------|
| **单一真实源 (SSoT)** | 每个概念只在一个文件中定义，其他文件通过链接引用 |
| **Section 0 速查卡片** | 每个规范文件以快速查阅区开头（表格、决策树、速查表） |
| **分层架构** | 根级 -> 子项目 -> 专题规范，层次清晰 |
| **依赖矩阵** | 用表格表示架构层间的依赖关系 |
| **双向链接** | 文档间通过相对链接互相引用，形成知识网络 |
| **kebab-case 命名** | 除 `CLAUDE.md` 和 `README.md` 外统一使用 `kebab-case.md` |

详见 [docs/design-principles.md](docs/design-principles.md)。

## 定制化

### 添加自定义规范

在 `rules/` 目录中创建新文件：

```bash
# 示例：添加国际化规范
touch backend/.claude/rules/i18n.md
```

然后在 `CLAUDE.md` 中添加链接。

### 修改现有规范

所有生成的文件都可以自由编辑。模板只是起点——请根据团队的约定进行定制。

### 创建新的预置模板

参见 [docs/customization-guide.md](docs/customization-guide.md) 了解如何创建和贡献新模板。

## 双语支持

模板提供**英文**和**中文**两个版本。在初始化时选择你偏好的语言。

## 示例

查看 [examples/](examples/) 目录获取完整的、即用型配置：

- **[monorepo-taskmanager](examples/monorepo-taskmanager/)** — 完整的 Monorepo（后端 + 前端 + 基础设施）
- **[single-project-python](examples/single-project-python/)** — 独立 Python 项目

## 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解指南。

### 贡献方式

- **新预置模板** — 添加 Go、Java Spring Boot、Vue、Terraform 等模板
- **翻译** — 添加更多语言支持
- **改进** — 用更好的实践增强现有规范
- **问题反馈** — 报告模板或初始化脚本的问题

## 模板变量

使用 init 脚本时，以下占位符会被自动替换：

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `{{PROJECT_NAME}}` | 项目显示名称 | My Awesome App |
| `{{PROJECT_SLUG}}` | 项目标识（kebab-case） | my-awesome-app |
| `{{PROJECT_DESCRIPTION}}` | 项目描述 | 一个现代 Web 应用 |
| `{{SUBPROJECT_NAME}}` | 子项目名称 | backend |
| `{{SUBPROJECT_TABLE}}` | Monorepo 子项目表格 | （自动生成） |
| `{{MONOREPO_STRUCTURE}}` | 目录结构树 | （自动生成） |

完整参考见 [docs/template-variables.md](docs/template-variables.md)。

## 许可证

[MIT](LICENSE)
