# Claude Context Templates

## 响应语言
**所有对话和文档必须（Must）使用中文。**
**除非有特殊说明，请用中文回答。** (Unless otherwise specified, please respond in Chinese.)

### 强制要求

- 所有对话必须使用中文
- 代码注释使用中文
- 文档内容使用中文
- Git 提交信息使用中文

### 例外情况

以下内容保持英文:
- 代码变量名、函数名、类名
- 技术术语 (如 API, SDK, TDD)
- 第三方库/框架名称
- 错误信息和日志 (可选)

---

## 项目概述

Claude Context Templates — 为 Claude Code 提供结构化、可复用的上下文管理模板，通过 `init.sh` 脚本为项目快速生成 `.claude/` 目录。

- **核心内容**: 预设模板 (presets) + 初始化脚本 (init.sh) + 完整示例 (examples)
- **支持模式**: Monorepo 多子项目 | 单项目 | 双语 (zh-CN / en)

---

## 会话协议

> **每次会话开始时建议阅读 [docs/project-strategy.md](../docs/project-strategy.md)**，了解项目方向和发展规划。

---

## Git 分支

```
feat/{module-name} → main
```

功能分支直接从 main 创建，完成后合并回 main。提交规范见 `.claude/rules/common.md`。

---

## 常用命令

```bash
# 运行初始化脚本（为目标项目生成 .claude/ 目录）
./init.sh

# 验证预设模板结构完整性
./scripts/validate-presets.sh

# 检查文档链接有效性
./scripts/check-links.sh

# 测试 init.sh 脚本功能
./scripts/test-init.sh
```

---

## 项目模块

| 模块 | 路径 | 说明 |
|------|------|------|
| 预设模板 | `presets/` | python-fastapi, react-typescript, aws-cdk |
| 完整示例 | `examples/` | monorepo-taskmanager, single-project-python |
| 脚本工具 | `scripts/` | CI/CD 和验证脚本 |
| 项目文档 | `docs/` | 设计原则、定制指南、模板变量 |

> 完整目录树见 `.claude/rules/common.md` 的 "Monorepo 结构概览" 章节（单一真实源）。

---

## 相关文档

| 文档 | 说明 |
|------|------|
| [通用规则](rules/common.md) | Git 提交规范、代码审查、文档规范、目录结构 |
| [设计原则](../docs/design-principles.md) | 模板系统的 6 条核心设计原则 |
| [定制指南](../docs/customization-guide.md) | 创建和贡献新预设模板 |
| [贡献指南](../CONTRIBUTING.md) | 项目贡献流程和规范 |

---

<!-- devpace-start -->
# Claude Context Templates

> 为 Claude Code 提供结构化、可复用的上下文管理模板

## 研发协作

本项目使用 `.devpace/` 管理迭代研发。行为规则由 devpace Plugin 的 `rules/devpace-rules.md` 自动注入，此处不重复。

### .devpace/ 文件参考

| 文件 | 何时读 |
|------|--------|
| `state.md` | 每次会话开始（必读） |
| `backlog/CR-*.md` | 推进模式 |
| `project.md` | 变更分析 或 用户要求看全景 |
| `rules/workflow.md` | 推进模式（状态机定义） |
| `rules/checks.md` | 推进模式（质量检查定义） |
| `iterations/current.md` | 查进度 或 变更分析 |
| `metrics/dashboard.md` | /pace-retro 或 /pace-status metrics |

## 业务目标

（首次 `/pace-retro` 或讨论业务目标时引导定义）
<!-- devpace-end -->
