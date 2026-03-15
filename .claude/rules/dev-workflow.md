# 开发工作流规则

> **职责**：定义开发本项目时 Claude 必须遵循的会话生命周期规则。覆盖会话启动、任务执行、质量检查、会话结束和跨会话连续性。

## §0 速查卡片

### 会话生命周期

```
§1 开始 → §2 执行 → §3 质检 → §4 结束 → (下一会话) §1
中断恢复: §5 → §2
```

### 各阶段速查

| 阶段 | 核心动作 | 关键产出 |
|------|---------|---------|
| §1 开始 | 读 state.md + project-strategy.md | 1 句话报告 |
| §2 执行 | 确认范围 → 遵循设计原则 → 分层约束 → commit | 代码/文档变更 |
| §3 质检 | 自动脚本 + 手动 checklist | 检查通过 |
| §4 结束 | 更新 state.md → 3 行摘要 → commit | 恢复点 |
| §5 恢复 | 读 state.md → 定位中断点 | 继续上次任务 |

## §1 会话开始协议

1. 读 `.devpace/state.md`：定位当前迭代、进行中的 CR 和项目状态
2. 读 `docs/project-strategy.md`：了解项目方向和发展规划
3. 用 1 句话报告：当前进度 + 下一步建议
4. 等待用户指令

## §2 任务执行

1. **确认范围**：与用户确认任务目标和边界，避免范围蔓延
2. **遵循设计原则**：实现时参照 `references/design-principles.md` 的 6 条核心原则（SSoT、Section 0、分层架构、依赖矩阵、双向链接、kebab-case）
3. **分层约束**：产品层（`plugin/`）不引用开发层（`.claude/`、`docs/`、`scripts/`），详见 `project-structure.md` §3
4. 每完成一个有意义的工作单元，git commit（遵循 `common.md` 提交规范）

## §3 质量检查

任务完成前必须通过以下检查：

### 自动检查脚本

| 脚本 | 检查内容 | 运行方式 |
|------|---------|---------|
| `scripts/validate-presets.sh` | Preset 模板结构完整性 | `./scripts/validate-presets.sh` |
| `scripts/check-links.sh` | 文档链接有效性 | `./scripts/check-links.sh` |
| `scripts/test-init.sh` | init.sh 脚本功能 | `./scripts/test-init.sh` |

### 手动检查 checklist

- [ ] 代码/文档符合 `common.md` 规范（语言、Git、命名）
- [ ] 新增文件放置位置正确（对照 `project-structure.md` §0 决策树）
- [ ] 分层完整性：`grep -r "\.claude/\|docs/\|scripts/" plugin/` 返回空结果
- [ ] 设计原则对齐：SSoT、§0 速查卡片、分层、表格、双向链接、kebab-case
- [ ] 模板变量使用正确占位符格式（见 `docs/template-variables.md`）

### Plugin 验证（修改 plugin/ 时）

- [ ] Plugin 命令可正常加载：`claude --plugin-dir ./plugin` 无报错
- [ ] Skill description 符合 CSO 规则（只写触发条件，不写行为）
- [ ] plugin.json 与文件系统同步（新增/删除组件后立即更新）

## §4 会话结束协议

1. 更新 `.devpace/state.md`（若使用 devpace 管理）
2. 输出 3 行摘要：完成了什么 / 未完成什么 / 下次建议从哪开始
3. git commit（若有未提交变更）

## §5 跨会话连续性

- `.devpace/state.md` = 唯一恢复点，不需要额外状态文件
- 恢复顺序：
  1. 读 `state.md` 定位当前迭代和进行中的 CR
  2. 读 `project-strategy.md` 确认项目方向
  3. 定位中断点，继续上次未完成的工作
