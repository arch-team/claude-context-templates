---
paths:
  - "**/hooks/**"
  - "**/commands/**"
  - "**/scripts/**"
---

# 入口层（L5）编写规范

> 入口层只做触发路由和质量门禁，不含任何方法论逻辑。

## Command 编写规则（P0）

> **本架构体系内约束**：Anthropic 官方不限制 Command/Skill body 行数（官方上限 500 行）。下面的 2-5 行约束是 L5 入口层的本地纪律，目的是强制方法论逻辑下沉到 L3 Skill。

- 每个 Command 作为 L5 入口只做路由，**2-5 行执行流**（本规范约束，非官方要求）
- 禁止包含方法论逻辑 —— 方法论归 L3 Skill
- description 必须包含触发短语（英文）

## Hook 编写规则（P0）

Hook 按用途分两类，遵循不同阻断语义：

**规范验收类 Hook**（默认，用于结构校验、前置依赖、Schema 合规）：
- 输出警告但不阻断操作（`sys.exit(0)` 即便 error）
- 禁止包含方法论判断逻辑，只做结构校验
- 典型场景：`validate-prereq.py`、`validate-schema.py`、`doc-quality-check.py`

**安全类 Hook**（用于阻止高危操作，参照官方 Exit 2 语义）：
- `PreToolUse` / `UserPromptSubmit` 等事件可使用 `sys.exit(2)` 阻断
- 只用于防止真正的安全风险（如危险命令、敏感数据泄漏），不用于规范约束
- 典型场景：`block-dangerous-commands.sh`、`prevent-secret-leak.py`

**共同规则**：
- 多个 Hook 并行执行，互不依赖
- 每个 Hook 职责单一，一个脚本检查一个维度

### Hook 脚本组织

Hook 脚本位于 `hooks/scripts/`，由 hooks.json 注册、事件触发。

**命名约定（P1）**：`validate-<维度>.py` 或 `<维度>-check.py`。

**常见检查维度**（按需选取，非强制全部实现）：

| 检查维度 | 命名示例 | 说明 |
|---------|---------|------|
| 前置依赖 | `validate-prereq.py` | 上游阶段产出是否存在 |
| 文档结构 | `doc-quality-check.py` | 必填章节、内容完整性 |
| Schema 合规 | `validate-schema.py` | 产出是否符合 contracts/ 定义的结构 |
| 命名规范 | `validate-naming.py` | 文件名、目录名是否合规 |

**Hook 脚本输出（P1）**：JSON 格式，必含 `status`（success/warning/error）和 `summary`；warning/error 时必含 `next_actions`（根因 + 安全重试指令 + 停止条件）；可选 `artifacts`（相关文件路径）。

## Script 编写规则

### update-context.py（状态管理）

脚本位于 `scripts/update-context.py`（非 Hook 脚本），是 project-context.md 的**唯一合法写入者**，由 Skill 通过 Bash 工具主动调用：

```bash
# init: 项目初始化 | complete: Skill 产出生成后标记阶段完成
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/update-context.py <project-root> init --name "项目名称"
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/update-context.py <project-root> complete --stage <name> --output <path> --summary <text>
```

### 语言规范（P1）

- 默认 Python 3 标准库（`#!/usr/bin/env python3`）；bash 仅限 <20 行简单文件检查；TS/JS 仅当目标项目已有 Node.js 运行时且需复用项目模块
- **禁止**（P0 硬约束）：运行时脚本引入第三方依赖（pip / npm），插件须零安装即可运行

### 测试规范（P2）

- 超过 100 行的 Python 脚本应当有对应的测试文件
- 测试文件命名：`tests/test-<脚本名>.py`
- 允许使用 `pytest`（开发阶段依赖，不影响插件运行时）
- 测试覆盖重点：状态写入的正确性、边界条件、错误恢复路径

