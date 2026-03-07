# Claude Context Templates

> 为 Claude Code 提供结构化、可复用的上下文管理模板，通过 init.sh 脚本快速生成 .claude/ 目录

## 业务目标

（随开发自然生长 — 首次 `/pace-retro` 或讨论业务目标时引导定义）

## 实施路径

（首次 `/pace-plan` 时规划）

## 范围

（首次 /pace-change 或讨论项目范围时填充）

## 项目原则

（首次 /pace-retro 或讨论技术/产品决策时积累）

## 价值功能树

```
OBJ-001（模板系统）
├── BR-001：预设模板管理
│   ├── PF-001：Python + FastAPI 预设 ✅
│   ├── PF-002：React + TypeScript 预设 ✅
│   ├── PF-003：AWS CDK 预设 ✅
│   └── PF-013：AWS CDK code-style.md 补全 ✅        <!-- CR-002, PF-2.5 -->
├── BR-002：示例项目展示
│   ├── PF-004：Monorepo 示例 ✅
│   ├── PF-005：单项目示例 ✅
│   └── PF-014：示例项目 rules/ 目录补全 ✅          <!-- CR-002, PF-2.1 -->
├── BR-003：工具脚本
│   ├── PF-006：初始化脚本 (init.sh) ✅
│   ├── PF-007：验证脚本 (validate-presets.sh) ✅
│   ├── PF-008：测试脚本 (test-init.sh) ✅
│   ├── PF-009：链接检查 (check-links.sh) ✅
│   ├── PF-015：init.sh Bug 修复集 ✅                <!-- CR-001, PF-1.1 -->
│   ├── PF-016：init.sh Ctrl+C 退出与确认摘要 ✅    <!-- CR-001, PF-1.2 -->
│   ├── PF-017：Monorepo 子项目去重与空描述提示 ✅   <!-- CR-001, PF-1.4 -->
│   ├── PF-018：--help 和 --dry-run 参数 ✅          <!-- CR-002, PF-2.2 -->
│   ├── PF-019：可选规则描述说明 ✅                  <!-- CR-002, PF-2.3 -->
│   ├── PF-020：生成后验证脚本 ✅                    <!-- CR-003, PF-3.2 -->
│   └── PF-021：远程执行支持 ✅                      <!-- CR-003, PF-3.3 -->
└── BR-004：项目文档
    ├── PF-010：设计原则文档 ✅
    ├── PF-011：定制指南 ✅
    ├── PF-012：模板变量说明 ✅
    ├── PF-022：template-variables.md 修正 ✅         <!-- CR-001, PF-1.3 -->
    ├── PF-023：README TL;DR 快速认知 ✅              <!-- CR-002, PF-2.4 -->
    └── PF-024：核心文档中文版 ✅                     <!-- CR-003, PF-3.1 -->
```
