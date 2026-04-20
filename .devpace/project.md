# Claude Context Templates

> 结构化、可复用的 Claude Code 上下文管理模板。为项目快速生成组织良好的 `.claude/` 目录。

## 业务目标

（随开发自然生长 — 首次 `/pace-retro` 或讨论业务目标时引导定义）

## 实施路径

（首次 `/pace-plan` 时规划）

## 范围

**做**：
- Claude Code Plugin 分发
- 多技术栈 preset 模板（Python/FastAPI, React/TypeScript, AWS CDK）
- 初始化和审计命令

**不做**：
- 其他 AI 工具集成
- IDE 特定配置

## 项目原则

（首次 /pace-retro 或讨论技术/产品决策时积累）

## 价值功能树

```
Claude Context Templates
├── Plugin 分发系统 (已实现)
├── Preset 模板库 (已实现)
│   ├── generic (通用模板) <!-- source: claude, dir-structure -->
│   ├── python-fastapi (Python + FastAPI) <!-- source: claude, dir-structure -->
│   ├── react-typescript (React + TypeScript) <!-- source: claude, dir-structure -->
│   └── aws-cdk (AWS CDK) <!-- source: claude, dir-structure -->
├── 命令工具 (已实现)
│   ├── init-context (项目初始化) <!-- source: claude, dir-structure -->
│   └── audit-context (上下文审计) <!-- source: claude, dir-structure -->
├── Skills (已实现)
│   └── context-setup (自动检测) <!-- source: claude, dir-structure -->
└── 文档系统 (已实现) <!-- source: claude, dir-structure -->
```
