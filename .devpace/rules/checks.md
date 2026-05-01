# 质量检查清单

> **职责**：定义本项目的质量门禁。按 workflow.md 状态机执行。

## 质量检查

### Gate 1：代码质量（developing → verifying）

#### 命令检查
- [ ] **验证脚本测试**：`./scripts/test-init.sh`
- [ ] **Preset 结构验证**：`./scripts/validate-presets.sh`
- [ ] **文档链接检查**：`./scripts/check-links.sh`

#### 意图检查
- [ ] **模板变量一致性**：Claude 检查"所有 preset 模板中的占位符格式符合 docs/template-variables.md 规范"
- [ ] **双语同步**：Claude 检查"新增的 preset 包含 zh-CN 和 en 两个语言版本"
- [ ] **分层完整性**：Claude 检查"plugin/ 目录不含对 .claude/、docs/、scripts/ 的运行时依赖"

### Gate 2：集成验证（verifying → in_review）

#### 命令检查
- [ ] **Plugin 加载测试**：`claude --plugin-dir ./plugin --version`（验证 plugin.json 格式）
- [ ] **Git 状态清洁**：`git status --porcelain` 输出为空（所有变更已提交）

#### 意图检查
- [ ] **文档同步**：Claude 检查"CLAUDE.md、README.md 已更新以反映变更内容"
- [ ] **CHANGELOG 更新**：Claude 检查"CHANGELOG.md 包含本次变更的记录（如需发版）"

### Gate 3：人类审批（in_review → approved）
- [ ] 人类审批：Code Review 通过

<!-- 自动检测来源：GitHub Actions, Shell Scripts -->
