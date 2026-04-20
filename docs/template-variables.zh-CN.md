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

### 标准变量：`{{VARIABLE_NAME}}`

标准变量使用双花括号，变量名采用 UPPER_SNAKE_CASE 格式。

- 变量名采用 UPPER_SNAKE_CASE 格式
- 变量在初始化时由 `sed`（init.sh）或 AI（init-context 命令）替换
- 未替换的变量保持原样输出（便于手动定制）

### AI 生成占位符：`{{AI_GENERATED:xxx}}`

> **仅用于 generic preset 模板**。内置 preset（python-fastapi 等）不使用此占位符。

AI 生成占位符标记需由 `/init-context` 命令的 AI 引擎根据项目分析结果动态生成的内容区域。

**CLAUDE.md**（6 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:tech_stack_summary}}` | 基于检测依赖的技术栈概览 |
| `{{AI_GENERATED:dev_commands}}` | 开发命令（lint、test、run） |
| `{{AI_GENERATED:core_principles}}` | 对应技术栈的核心开发原则 |
| `{{AI_GENERATED:coverage_table}}` | 按架构层级的覆盖率要求表 |
| `{{AI_GENERATED:pre_commit_one_liner}}` | 单行预提交命令（lint + typecheck + test） |
| `{{AI_GENERATED:gotchas}}` | 常见坑和注意事项 |

**rules/architecture.md**（5 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:architecture_pattern}}` | 架构模式描述 |
| `{{AI_GENERATED:layer_structure}}` | 各层职责表 |
| `{{AI_GENERATED:dependency_direction}}` | 依赖方向 ASCII 图 |
| `{{AI_GENERATED:module_principles}}` | 模块设计原则表 |
| `{{AI_GENERATED:communication_pattern}}` | 模块间通信模式 |

**rules/tech-stack.md**（4 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:version_matrix}}` | 版本矩阵表 |
| `{{AI_GENERATED:key_constraints}}` | 关键技术约束 |
| `{{AI_GENERATED:version_check_commands}}` | 版本快速校验命令 |
| `{{AI_GENERATED:toolchain_config}}` | 工具链配置表 |

**rules/code-style.md**（5 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:code_style_quick_ref}}` | 代码风格速查卡片 |
| `{{AI_GENERATED:naming_conventions}}` | 命名规范 |
| `{{AI_GENERATED:import_rules}}` | Import 排序规则 |
| `{{AI_GENERATED:type_annotations}}` | 类型标注要求 |
| `{{AI_GENERATED:do_dont_examples}}` | DO / DON'T 代码示例 |

**rules/testing.md**（3 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:test_layering}}` | 测试分层表 |
| `{{AI_GENERATED:coverage_requirements}}` | 覆盖率要求 |
| `{{AI_GENERATED:test_commands}}` | 测试命令速查 |

**rules/security.md**（3 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:security_quick_ref}}` | 安全速查卡片 |
| `{{AI_GENERATED:security_scanning}}` | 安全扫描命令 |
| `{{AI_GENERATED:auth_guidelines}}` | 认证/鉴权规范 |

**rules/checklist.md**（6 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:checklist_architecture}}` | 架构检查项 |
| `{{AI_GENERATED:checklist_code_style}}` | 代码风格检查项 |
| `{{AI_GENERATED:checklist_security_extra}}` | 附加安全检查项 |
| `{{AI_GENERATED:checklist_testing_extra}}` | 附加测试检查项 |
| `{{AI_GENERATED:checklist_structure_extra}}` | 附加项目结构检查项 |
| `{{AI_GENERATED:pre_commit_command}}` | 完整预提交校验命令 |

**rules/project-structure.md**（4 个占位符）：

| 占位符 | 说明 |
|--------|------|
| `{{AI_GENERATED:directory_tree}}` | 项目目录树 |
| `{{AI_GENERATED:config_files}}` | 配置文件速查表 |
| `{{AI_GENERATED:naming_rules}}` | 文件命名规范 |
| `{{AI_GENERATED:new_module_template}}` | 新模块模板 |

**合计：9 个文件中共 36 个独立占位符。**

**行为**：
- `/init-context` 走 generic 路径时，AI 读取 `context-schema.yaml` 的生成提示，为每个占位符生成对应技术栈的内容
- 使用 `context-schema.yaml` 中的质量标准对生成内容进行自检
- 生成内容遵循内置 preset 的同等格式风格（表格、代码块、Section 0 速查卡片）

## 添加自定义变量

如果自定义预置模板需要额外变量：

1. 在 `preset.yaml` 的 `variables` 部分定义变量
2. 在模板文件中使用 `{{YOUR_VARIABLE}}`
3. 更新 `init.sh` 以提示输入并替换新变量
