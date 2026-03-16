# claude-context-templates

> 为 Claude Code 提供结构化、可复用的上下文管理模板，几秒钟内为你的项目生成完善的 `.claude/` 目录

## 业务目标

- OBJ-1: 上下文生成能力 — 让用户通过多种路径（Shell/Plugin/Skill）快速生成生产级 .claude/ 目录
  - MoS: init.sh 在 macOS/Linux 上成功率 100%（CI 验证）; Plugin /init-context 可正常安装和运行
- OBJ-2: 预设模板生态 — 提供多技术栈、双语、可组合的高质量模板资产
  - MoS: Preset 数量 >=4; 每个 preset required files 覆盖率 100%; 双语 (zh-CN/en) 一致性 100%
- OBJ-3: 质量保障 — 通过自动化验证和 CI 确保模板完整性和跨平台兼容
  - MoS: CI 4 jobs 全部 pass; 文档链接 0 断链; 模板变量替换准确率 100%
- OBJ-4: 社区分发与文档 — 降低发现和使用门槛，建立社区贡献通道
  - MoS: >=1 个确认的外部使用报告; GitHub Template Repository 启用; 博客文章已发布

> 北极星指标: GitHub Stars + Forks 组合值 (详见 docs/project-strategy.md)

## 实施路径

### Phase 1.5 → Phase 2 过渡计划

- **Phase 1.5 收尾**：M1.5.4（端到端外部用户安装测试）— 需外部用户参与
- **Phase 2 并行启动**：不必等 M1.5.4 完成，可先推进 M2.2 和 M2.3
- **建议启动顺序**：M2.2（新 preset，快速价值） → M2.3（社区通道） → M2.1（组合机制） → M2.4（版本追踪）

## 范围

### Phase 2 范围（v2.0）

| 里程碑 | 内容 | 依赖 | 优先级 |
|--------|------|------|--------|
| M2.1 | Preset 组合机制（rule 级别继承，_common 共享） | 无 | P1 |
| M2.2 | 新增 ≥2 个 preset（Go, Next.js/Vue） | 无 | P0 |
| M2.3 | 社区贡献工作流（审核标准、贡献指南） | 无 | P0 |
| M2.4 | Preset 版本追踪机制 | M2.1 | P2 |

## 项目原则

<!-- source: alignment-review, 2026-03-15 -->

- **lite 模式优先**：Phase 1~2 维持 OBJ→BR→PF 三层结构，不引入 Epic/Opportunity 层。理由：个人维护项目，需求复杂度不足以证明额外管理层的成本。Phase 3+ 如有社区贡献者加入再评估。
- **并行优于串行**：Phase 过渡期允许并行启动下一阶段独立任务，不必等前一阶段 100% 完成。
- **外部验证优先**：功能完成度 < 外部使用反馈。北极星指标的核心是"确认使用报告"而非功能数量。

## 价值功能树

<!-- source: claude, inferred from codebase -->

```
OBJ-1 上下文生成能力
├── BR-001 Shell 脚本路径
│   ├── PF-001 交互式初始化脚本 (init.sh)
│   ├── PF-002 远程一键安装 (install.sh)
│   └── ~~PF-028~~ generic preset 仅限 Plugin 路径（有意设计，非技术债务）
├── BR-002 Plugin 路径
│   ├── PF-003 /init-context 命令
│   ├── PF-004 /audit-context 命令
│   └── PF-005 context-setup Skill
└── BR-003 规范体系
    └── PF-006 规范类型体系 (context-schema.yaml)

OBJ-2 预设模板生态
├── BR-004 技术栈预设
│   ├── PF-007 Python + FastAPI 预设 (27 files, zh-CN/en)
│   ├── PF-008 React + TypeScript 预设 (27 files, zh-CN/en)
│   ├── PF-009 AWS CDK 预设 (25 files, zh-CN/en)
│   ├── PF-010 Generic 通用预设 (19 files, zh-CN/en)
│   ├── PF-031 Next.js + TypeScript 预设 (zh-CN/en) — Phase 2, P0
│   └── PF-032 Go 通用预设 (zh-CN/en) — Phase 2, P1
└── BR-005 公共基础
    ├── PF-011 公共工程原则 _common (4 principles, zh-CN/en)
    └── PF-012 Preset 版本清单 (manifest.json)

OBJ-3 质量保障
├── BR-006 验证脚本
│   ├── PF-013 Preset 结构验证 (validate-presets.sh)
│   ├── PF-014 init.sh 烟雾测试 (test-init.sh)
│   ├── PF-015 生成结果验证 (validate-generated.sh)
│   └── PF-016 Markdown 链接检查 (check-links.sh)
├── BR-007 构建发布
│   ├── PF-017 Plugin 构建 + 发布 (build-plugin.sh + release-plugin.sh)
│   ├── PF-018 Manifest 生成 (generate-manifest.sh)
│   └── PF-029 plugin.json 与 manifest.json 版本对齐（技术债务）→ CR-001 ✅
└── BR-008 持续集成
    ├── PF-019 GitHub Actions CI (4 jobs)
    └── PF-020 Skill 效果评估 (context-setup-workspace)

OBJ-4 社区分发与文档
├── BR-009 示例项目
│   ├── PF-021 Monorepo 示例 (monorepo-taskmanager)
│   └── PF-022 单项目示例 (single-project-python)
├── BR-010 文档与推广
│   ├── PF-023 项目文档体系 (docs/)
│   ├── PF-024 博客文章 (docs/blog/, 4 篇, zh-CN/en)
│   ├── PF-025 双语 README
│   └── PF-030 project-strategy.md 更新 audit-context 状态（技术债务）→ CR-002 ✅
└── BR-011 社区基础设施
    ├── PF-026 社区协作模板 (.github/ Issue/PR 模板 + CONTRIBUTING.md)
    └── PF-027 Plugin marketplace 配置
```
