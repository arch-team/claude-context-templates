# 项目质量检查

> **职责**：定义本项目特有的质量检查。请根据项目实际情况填写检查项和检查方式。

## developing → verifying

<!-- 命令检查（bash 执行，exit code 判定） -->
- [ ] **预设结构验证**：验证预设模板目录结构完整性
      检查方式：`scripts/validate-presets.sh`

- [ ] **初始化脚本测试**：测试 init.sh 脚本功能
      检查方式：`scripts/test-init.sh`

<!-- 意图检查（自然语言，Claude 判定）——用自然语言描述质量期望 -->
- [ ] **文档完整性**：确保文档链接有效且内容完整
      检查方式：Claude 检查 docs/ 目录下的文档结构和交叉引用

<!-- devpace 内置检查（不可删除） -->
- [ ] **需求完整性**：CR 意图 section 与变更复杂度匹配
      检查方式：Claude 检查意图字段填充度（简单=用户原话；标准=+范围+验收条件；复杂=全部字段）

## verifying → in_review

<!-- 命令检查（bash 执行，exit code 判定） -->
- [ ] **链接检查**：检查 Markdown 文件中的相对链接有效性
      检查方式：`scripts/check-links.sh`

<!-- 意图检查（自然语言，Claude 判定）——用自然语言描述质量期望 -->
- [ ] **模板变量使用**：确保模板文件中使用正确的占位符格式
      检查方式：Claude 检查模板变量格式符合 docs/template-variables.md 规范

<!-- devpace 内置检查（不可删除） -->
- [ ] **意图一致性**：实际变更与 CR 意图 section 的范围和验收条件一致
      检查方式：Claude 对比 git diff 与意图 section，标注偏差
