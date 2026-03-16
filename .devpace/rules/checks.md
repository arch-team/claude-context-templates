# 质量检查

> **职责**：定义本项目的质量门禁。可根据项目实际情况调整。

## Gate 1：代码质量（developing → verifying）

- [ ] **Preset 结构验证**：`./scripts/validate-presets.sh`
- [ ] **代码规范**：Claude 检查"修改的文件遵循项目命名规范（kebab-case.md for docs, UPPERCASE.md for framework files）"
- [ ] **文档同步**：Claude 检查"如修改 presets/ 则 README.md 和 docs/ 相关说明已同步更新"

## Gate 2：集成验证（verifying → in_review）

- [ ] **Init 脚本测试**：`./scripts/test-init.sh`
- [ ] **文档链接检查**：`./scripts/check-links.sh`
- [ ] **示例项目验证**：Claude 检查"如修改 preset 模板，相应的 examples/ 示例项目已同步更新"

## Gate 3：人类审批（in_review → approved）

- [ ] **Code Review 通过**：人类审批

<!-- 可选安全检查（取消注释启用）
- [ ] **Shell 脚本安全检查**：`shellcheck scripts/*.sh`
-->
