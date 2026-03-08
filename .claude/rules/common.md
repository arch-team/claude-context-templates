# 跨项目通用规则 (Common Rules)

> 适用于 claude-context-templates 仓库所有模块的通用规范

---

## Git 提交规范

### 提交信息格式

```
<类型>(<范围>): <简短描述>

<详细描述（可选）>

<关联 Issue（可选）>
```

### 类型

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 Bug |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（非新功能/修复） |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖更新 |

### 范围

| 范围 | 说明 |
|------|------|
| `presets` | 预设模板 |
| `examples` | 示例项目 |
| `scripts` | 脚本工具 |
| `docs` | 文档 |
| `*` | 多个子项目 |

### 示例

```bash
feat(presets): 添加 Go 语言预设模板
fix(scripts): 修复 init.sh 在 Linux 下的兼容性
docs(*): 更新 README 文档
chore(scripts): 更新验证脚本逻辑
```

---

## 代码审查标准

### 通用检查项

- [ ] 代码符合子项目规范
- [ ] 文档/注释使用中文
- [ ] 提交信息格式正确
- [ ] 预设模板变量使用正确占位符格式（见 `docs/template-variables.md`）
- [ ] 新增 preset 包含 zh-CN 和 en 两个语言版本
- [ ] 示例项目结构与对应 preset 一致

---

## 文档规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 主规范 | `CLAUDE.md` | 各子项目入口（Claude Code 框架约定） |
| 专题规范 | `rules/{topic}.md` | `rules/testing.md`, `rules/checklist.md` |
| 项目说明 | `README.md` | 项目根目录说明 |

**命名原则**: 除 `CLAUDE.md`（Claude Code 框架约定）和 `README.md` 外，所有文档统一使用 `kebab-case.md`

### 文档语言

- 所有文档内容使用中文
- 代码示例保持原始语言

---

## Monorepo 结构概览

> 本节是 Monorepo 结构的**单一真实源 (Single Source of Truth)**

```
claude-context-templates/        # 仓库根目录
├── .claude/                     # Claude Code 规范
│   ├── CLAUDE.md                # 全局入口（语言、项目概述、会话协议）
│   └── rules/
│       └── common.md            # 跨项目通用规则（本文件）
├── plugin/                      # Claude Code Plugin（含预设模板）
│   ├── .claude-plugin/          # Plugin 元数据
│   ├── commands/                # 命令定义
│   ├── skills/                  # Skill 定义
│   └── presets/                 # 预设模板（唯一 SSoT）
│       ├── manifest.json        # 版本清单
│       ├── _common/             # 公共模板 + 跨 preset 工程原则
│       ├── python-fastapi/      # Python + FastAPI 预设 (principles/ + practices/)
│       ├── react-typescript/    # React + TypeScript 预设 (principles/ + practices/)
│       └── aws-cdk/             # AWS CDK 预设 (principles/ + practices/)
├── examples/                    # 完整示例项目
│   ├── monorepo-taskmanager/    # Monorepo 示例
│   └── single-project-python/   # 单项目示例
├── scripts/                     # CI/CD 和验证脚本
├── docs/                        # 项目文档
│   ├── design-principles.md     # 设计原则
│   ├── customization-guide.md   # 定制指南
│   ├── template-variables.md    # 模板变量说明
│   └── project-strategy.md      # 项目战略
├── init.sh                      # 项目初始化脚本
├── CONTRIBUTING.md              # 贡献指南
├── .gitignore
└── README.md                    # 项目总说明
```

各子项目的详细目录结构请参考对应的 `project-structure.md` 文档。
