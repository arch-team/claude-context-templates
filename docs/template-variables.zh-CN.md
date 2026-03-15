[English](template-variables.md)

# 模板变量参考

本文档列出模板文件中使用的所有占位符变量。这些变量在初始化时由 `init.sh` 脚本自动替换。

## 项目级变量

| 变量 | 说明 | 示例 | 使用位置 |
|------|------|------|---------|
| `{{PROJECT_NAME}}` | 项目显示名称 | `My Awesome App` | 根 CLAUDE.md, common-rules.md |
| `{{PROJECT_SLUG}}` | 项目标识符（kebab-case） | `my-awesome-app` | project-config.md, 成本标签 |
| `{{PROJECT_DESCRIPTION}}` | 项目一行描述 | `一个现代任务管理平台` | 根 CLAUDE.md |

## Monorepo 级变量

| 变量 | 说明 | 生成方式 | 使用位置 |
|------|------|---------|---------|
| `{{SUBPROJECT_TABLE}}` | 子项目 Markdown 表格 | 根据子项目列表自动生成 | 根 CLAUDE.md |
| `{{MONOREPO_STRUCTURE}}` | ASCII 目录树 | 根据子项目列表自动生成 | common-rules.md |

### SUBPROJECT_TABLE 格式

```markdown
| 子项目 | 路径 | 说明 |
|--------|------|------|
| Backend | `backend/` | Python + FastAPI |
| Frontend | `frontend/` | React + TypeScript |
| Infrastructure | `infra/` | AWS CDK |
```

### MONOREPO_STRUCTURE 格式

```
my-awesome-app/                  # Monorepo 根目录
├── .claude/                     # 根目录：通用规范
│   ├── CLAUDE.md                # 全局入口
│   └── rules/
│       └── common.md            # 跨项目规则
├── backend/                     # 后端（Python + FastAPI）
├── frontend/                    # 前端（React + TypeScript）
├── infra/                       # 基础设施（AWS CDK）
├── .gitignore
└── README.md
```

## 子项目级变量

| 变量 | 说明 | 示例 | 使用位置 |
|------|------|------|---------|
| `{{SUBPROJECT_NAME}}` | 子项目名称 | `backend` | 子项目 CLAUDE.md |
| `{{DATE}}` | 初始化日期 | `2025-03-15` | 由 init.sh 中 `date +%Y-%m-%d` 生成 |

## 预置模板特定变量

### python-fastapi

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `{{PACKAGE_MANAGER}}` | `uv` | Python 包管理器 |
| `{{COVERAGE_MIN}}` | `85` | 最低测试覆盖率 % |

### react-typescript

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `{{PACKAGE_MANAGER}}` | `pnpm` | Node.js 包管理器 |
| `{{COVERAGE_MIN}}` | `80` | 最低测试覆盖率 % |

### aws-cdk

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `{{COVERAGE_MIN}}` | `85` | 最低测试覆盖率 % |
| `{{PROJECT_SLUG}}` | （必填） | 项目标识符（kebab-case，用于标签和命名） |

> **注意**：aws-cdk 预置模板在模板中硬编码了 `pnpm`。与 react-typescript 不同，CDK 生态的工具链命令（`pnpm cdk synth`、`pnpm exec`、GitHub Actions `pnpm/action-setup`）与特定包管理器紧耦合，简单文本替换不可靠。

## 变量语法

变量使用双花括号：`{{VARIABLE_NAME}}`

- 变量名采用 UPPER_SNAKE_CASE 格式
- 变量在初始化时由 `sed` 替换
- 未替换的变量保持原样输出（便于手动定制）

## 添加自定义变量

如果自定义预置模板需要额外变量：

1. 在 `preset.yaml` 的 `variables` 部分定义变量
2. 在模板文件中使用 `{{YOUR_VARIABLE}}`
3. 更新 `init.sh` 以提示输入并替换新变量
