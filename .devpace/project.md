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

```
（功能树随工作自动生长 — 开始做第一个功能时自动出现）
```
