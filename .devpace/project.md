# claude-context-templates

> Structured, reusable context management templates for Claude Code

## 愿景

### 目标用户
个人 Claude Code 开发者 + 需要规范化团队上下文管理的技术 Leader

### 核心问题
- 不知道如何给 Claude 提供上下文
- 每个项目都重新搭建 .claude/ 目录
- 团队上下文不一致，代码生成质量参差不齐

### 差异化
- **基于真实 Monorepo 实践**：模板来自生产级项目经验
- **Plugin 分发更便捷**：无需克隆仓库，一条命令安装
- **多技术栈预设**：支持 Python/FastAPI, React/TS, AWS CDK 等

### 成功图景
- 成为 Claude Code 生态标准：社区推荐的上下文管理最佳实践
- 项目质量提升：用户反馈 Claude 生成代码质量显著提升

## 战略上下文

### 核心假设
- Claude Code 用户需要结构化上下文（而非自由发挥）
- Plugin 分发比 Git 克隆更友好（降低使用门槛）
- 预设模板可降低门槛（提供起点优于从零开始）

### 外部约束
- Claude Code 框架约束：必须遵循 .claude/ 目录规范
- Plugin 系统限制：Plugin manifest 和分发机制的技术约束

## 业务目标

### OBJ-1：提升用户采用率（Product, 短期）
**描述**：让更多 Claude Code 用户使用预设模板
**成效指标（MoS）**：
- GitHub Stars + Forks 组合值
- Plugin 安装量

### OBJ-2：提升代码生成质量（Product, 中期）
**描述**：通过结构化上下文提升 Claude 输出质量
**成效指标（MoS）**：
- 使用报告数（用户确认使用的数据）
- 社区反馈质量（Issue/PR 活跃度）

### OBJ-3：建立生态标准（Business, 长期）
**描述**：成为 Claude Code 上下文管理的社区标准
**成效指标（MoS）**：
- 社区引用和推荐频次
- 其他项目采用相同模式的数量

### OBJ-4：扩展技术栈覆盖（Product, 中期）
**描述**：支持更多技术栈的预设模板
**成效指标（MoS）**：
- 预设模板数量
- 覆盖的技术栈类型

### OBJ-5：提升上下文规划效率（Product, 短期）
**描述**：提升用户为新旧项目提供上下文规划的效率
**成效指标（MoS）**：
- 用户从安装到完成配置的平均时间
- 用户反馈的易用性评分

## 实施路径

（首次 `/pace-plan` 时规划）

## 范围

（首次 /pace-change 或讨论项目范围时填充）

## 项目原则

（首次 /pace-retro 或讨论技术/产品决策时积累）

## 价值功能树

<!-- source: claude, inferred from codebase -->

```
OBJ-1：提升用户采用率
├─ BR-001：上下文初始化能力
│  ├─ PF-001：初始化上下文命令（init-context）        [已实现]
│  ├─ PF-002：项目初始化脚本（init.sh）                [已实现]
│  └─ PF-003：Plugin 安装脚本（install.sh）            [已实现]
├─ BR-002：预设模板库                                   [P0] [就绪 85%] → requirements/BR-002.md
│  ├─ PF-004：通用项目模板（generic）                  [已实现]
│  ├─ PF-005：Python FastAPI 模板（python-fastapi）    [已实现]
│  ├─ PF-006：React TypeScript 模板（react-typescript）[已实现]
│  └─ PF-007：AWS CDK 模板（aws-cdk）                  [已实现]
└─ BR-003：构建与发布工具
   ├─ PF-008：Plugin 构建工具（build-plugin.sh）       [已实现]
   └─ PF-009：Plugin 发布工具（release-plugin.sh）     [已实现]

OBJ-2：提升代码生成质量
├─ BR-004：质量检查能力
│  ├─ PF-010：审计上下文质量（audit-context）          [已实现]
│  ├─ PF-011：自动检测与设置（context-setup）          [已实现]
│  └─ PF-012：工作区上下文设置（context-setup-workspace）[已实现]
└─ BR-005：质量保障工具
   ├─ PF-013：预设模板验证（validate-presets.sh）      [已实现]
   ├─ PF-014：生成结果验证（validate-generated.sh）    [已实现]
   └─ PF-015：初始化脚本测试（test-init.sh）           [已实现]

OBJ-3：建立生态标准
├─ BR-006：项目文档系统
│  ├─ PF-016：模板变量文档（template-variables.md）    [已实现]
│  ├─ PF-017：Plugin 分发架构文档（plugin-delivery-design.md）[已实现]
│  └─ PF-018：定制指南（customization-guide.md）       [已实现]
├─ BR-007：完整示例项目
│  ├─ PF-019：Monorepo 示例（monorepo-taskmanager）    [已实现]
│  └─ PF-020：单项目 Python 示例（single-project-python）[已实现]
└─ BR-008：公共模板组件
   └─ PF-021：公共模板组件（_common）                  [已实现]

OBJ-4：扩展技术栈覆盖
└─ （当前 4 个预设模板已纳入 OBJ-1/BR-002，新增技术栈时在此追加）

OBJ-5：提升上下文规划效率
└─ BR-009：自动化工具链
   ├─ PF-022：清单生成工具（generate-manifest.sh）     [已实现]
   ├─ PF-023：文档链接检查（check-links.sh）           [已实现]
   └─ PF-024：YAML 解析库（lib-yaml.sh）              [已实现]
```
