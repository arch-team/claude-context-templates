# 跨项目通用规则 (Common Rules)

> **职责**：语言、Git 提交、命名、审查规范。适用于 claude-context-templates 仓库所有模块。

## §0 速查卡片

### 语言规则

| 类别 | 语言 | 例外 |
|------|------|------|
| 对话/文档/注释/Git 提交 | 中文 | — |
| 变量名/函数名/类名 | 英文 | — |
| 技术术语 | 英文原文 | API, SDK, TDD 等 |
| 第三方库名 | 英文原文 | — |

### Git 提交速查

格式：`<类型>(<范围>): <简短描述>`

类型：`feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore`

范围：`presets` | `plugin` | `examples` | `scripts` | `docs` | `*`

### 命名规则

| 文件类型 | 规范 | 示例 |
|---------|------|------|
| Claude Code 入口 | `CLAUDE.md` | 框架约定 |
| 项目说明 | `README.md` | GitHub 约定 |
| 其他所有文档 | `kebab-case.md` | `dev-workflow.md` |

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
| `plugin` | Plugin 组件（commands、skills、plugin.json） |
| `examples` | 示例项目 |
| `scripts` | 脚本工具 |
| `docs` | 文档 |
| `*` | 多个子项目 |

### 示例

```bash
feat(presets): 添加 Go 语言预设模板
feat(plugin): 新增 init Skill
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

### Plugin 检查项

- [ ] Plugin 命令可正常加载
- [ ] Skill description 符合 CSO 规则（见 `plugin-dev-spec.md` §3）
- [ ] plugin.json 与文件系统同步
- [ ] 新增文件放置位置正确（见 `project-structure.md` §0）

---

## 文档规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 主规范 | `CLAUDE.md` | 各子项目入口（Claude Code 框架约定） |
| 专题规范 | `rules/{topic}.md` | `rules/dev-workflow.md`, `rules/plugin-dev-spec.md` |
| 参考文档 | `references/{topic}.md` | `references/component-reference.md` |
| 项目说明 | `README.md` | 项目根目录说明 |

**命名原则**: 除 `CLAUDE.md`（Claude Code 框架约定）和 `README.md` 外，所有文档统一使用 `kebab-case.md`

### 文档语言

- 所有文档内容使用中文
- 代码示例保持原始语言

---

## 项目结构

> 完整目录树和分层归属详见 `project-structure.md`（单一真实源）。
