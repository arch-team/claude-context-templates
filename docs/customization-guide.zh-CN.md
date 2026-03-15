[English](customization-guide.md)

# 定制指南

本指南说明如何定制生成的模板以及如何创建新的预置模板。

## 定制生成的文件

运行 `init.sh` 后，所有生成的文件均可自由编辑。以下是常见的定制场景：

### 添加自定义规范文件

1. 在 `rules/` 目录中创建文件：
   ```bash
   touch backend/.claude/rules/i18n.md
   ```

2. 遵循标准结构：
   ```markdown
   # 国际化规范 (i18n)

   > **职责**: 国际化和本地化规范 SSoT

   ---

   ## 0. 速查卡片

   ### 关键规则
   | 规则 | 说明 |
   |------|------|
   | ... | ... |

   ---

   ## 1. 详细规范
   ...
   ```

3. 在 `CLAUDE.md` 中添加链接：
   ```markdown
   | 国际化 | [rules/i18n.md](rules/i18n.md) |
   ```

### 修改 project-config.md

`project-config.md` 文件设计为填空模板。将所有 `<!-- TODO: ... -->` 标记替换为实际内容：

```markdown
<!-- 修改前 -->
| <!-- TODO: 模块名 --> | <!-- TODO: 说明 --> | <!-- TODO: 核心实体 --> |

<!-- 修改后 -->
| `auth` | 用户认证与授权 | `User`, `Role`, `Permission` |
```

### 移除可选规范

直接删除不需要的规范文件，并移除 `CLAUDE.md` 中对应的链接即可。

## 创建新的预置模板

### 步骤 1: 创建目录结构

```bash
mkdir -p plugin/presets/your-preset/zh-CN/rules
mkdir -p plugin/presets/your-preset/en/rules
```

### 步骤 2: 创建 preset.yaml

```yaml
name: your-preset
display_name: "你的技术栈名称"
description: "简短描述"
version: "1.0.0"

defaults:
  package_manager: your-pkg-manager
  linter: your-linter
  test_runner: your-test-framework
  source_root: src
  architecture_pattern: "你的架构模式"
  coverage_minimum: 80

files:
  required:
    - CLAUDE.md
    - project-config.md
    - rules/architecture.md
    - rules/tech-stack.md
    - rules/code-style.md
    - rules/testing.md
    - rules/security.md
    - rules/checklist.md
    - rules/project-structure.md
  optional:
    - rules/your-optional-topic.md

variables:
  - name: PROJECT_NAME
    prompt: "项目名称"
    required: true
  - name: YOUR_CUSTOM_VAR
    prompt: "自定义变量"
    default: "default-value"
```

### 步骤 3: 编写模板文件

从以下必需文件开始：

1. **CLAUDE.md** -- 子项目入口
2. **project-config.md** -- 带 TODO 标记的填空模板
3. **rules/architecture.md** -- 技术栈对应的架构模式
4. **rules/tech-stack.md** -- 版本要求矩阵
5. **rules/code-style.md** -- 编码规范
6. **rules/testing.md** -- 测试方法论
7. **rules/security.md** -- 安全检查清单
8. **rules/checklist.md** -- PR Review 检查清单
9. **rules/project-structure.md** -- 目录结构

### 步骤 4: 遵循设计模式

- 每个规范文件以 **Section 0 速查卡片** 开头
- 速查区使用**表格而非散文**
- 在相关文件间添加**双向链接**
- 明确标注 SSoT 文档
- 使用 `{{VARIABLE}}` 作为项目特定内容的占位符
- 在 project-config.md 中使用 `<!-- TODO: ... -->` 标记用户需填写的部分

### 步骤 5: 注册预置模板

有两条初始化路径，注册方式不同：

> **`init.sh`（Shell 脚本路径）**
>
> 编辑 `init.sh` 第 17-18 行，将你的 preset 添加到两个数组中：
> ```bash
> PRESET_IDS=("python-fastapi" "react-typescript" "aws-cdk" "your-preset")
> PRESET_DISPLAY_NAMES=("Python + FastAPI" "React + TypeScript" "AWS CDK (TypeScript)" "你的技术栈")
> ```
>
> **`/init-context`（Plugin 命令路径）**
>
> 无需注册。该命令通过读取 `plugin/presets/` 下每个目录的 `preset.yaml` 自动发现所有预置模板。

### 步骤 6: 测试

```bash
# 测试单项目模式
./init.sh
# 选择你的预置模板并验证输出

# 测试 Monorepo 模式
./init.sh
# 添加一个使用你的预置模板的子项目并验证
```

## 使用 Generic 预置模板

`generic` 预置模板通过 AI 驱动的内容生成支持**任意技术栈**。当 `/init-context` 检测到项目不匹配任何内置预置模板时，会自动选择 generic。

### 何时使用 Generic

| 场景 | 路径 |
|------|------|
| 已有项目含 FastAPI → 匹配 `python-fastapi` | 内置预置模板（快速通道） |
| 已有项目含 Django → 无匹配 | Generic（AI 生成） |
| 已有项目含 Go + Gin → 无匹配 | Generic（AI 生成） |
| 空项目，用户选择 Python + FastAPI | 内置预置模板（快速通道） |
| 空项目，用户选择 Rust + Axum | Generic（AI 生成） |

### 工作原理

1. `/init-context` 执行深度项目分析（语言、框架、工具链、架构）
2. 从 `presets/generic/{lang}/` 复制骨架模板文件
3. `{{AI_GENERATED:xxx}}` 占位符根据分析结果由 AI 替换为生成内容
4. 质量自检确保生成内容满足 `context-schema.yaml` 标准

### 生成后的定制

AI 生成的内容是**起点**。生成后：

1. **检查 `rules/architecture.md`** — 验证架构描述是否与实际设计匹配
2. **检查 `rules/tech-stack.md`** — 确认版本号和约束条件
3. **填写 `project-config.md`** — 添加业务模块、导入路径等
4. **运行 `/audit-context`** — 获取质量报告和改进建议
5. **添加可选规范** — 参考 `context-schema.yaml` 了解可添加的规范

### 模板结构

Generic 模板使用两种占位符：

- `{{VARIABLE}}` — 简单文本替换（项目名、标识符等）
- `{{AI_GENERATED:xxx}}` — AI 根据项目分析结果填充

完整占位符参考见 [template-variables.zh-CN.md](template-variables.zh-CN.md)。

## 预置模板设计建议

### 基于真实场景

规范应基于实际生产经验，而非理论理想。应包含：
- 常见陷阱（使用 正确做法 / 错误做法 对比）
- 常见选择的决策树
- 开发者可直接复制的代码示例
- 设定合理目标的覆盖率要求

### 保持文件聚焦

每个规范文件应有单一、明确的职责。如果一个文件涵盖了过多主题，应将其拆分。

### 平衡详细与简洁

- Section 0: 高密度、易扫描（表格、矩阵）
- 后续章节: 带示例的详细说明
- 文件总长度: 100-300 行为最佳范围

### 考虑 Token 效率

Claude Code 会将这些文件读入上下文窗口。优化方向：
- 表格优于段落
- 代码示例优于文字描述
- 决策树优于复杂散文
- 要点列表优于叙述性文本
