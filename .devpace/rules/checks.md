# 项目质量检查

> **职责**：定义本项目特有的质量检查。请根据项目实际情况填写检查项和检查方式。

## developing → verifying

<!-- 命令检查（bash 执行，exit code 判定） -->
- [ ] **预设模板验证**：验证所有预设模板的结构完整性和格式正确性
      检查方式：`scripts/validate-presets.sh`

- [ ] **脚本可执行性**：确保所有 shell 脚本具有执行权限
      检查方式：`find scripts/ -name "*.sh" -type f ! -perm -u+x | wc -l | grep -q "^0$"`

<!-- 意图检查（自然语言，Claude 判定）——用自然语言描述质量期望 -->
- [ ] **文档双语完整性**：新增或修改的文档同时提供中英文版本
      检查方式：Claude 检查 zh-CN 和 en 目录下对应文件存在且内容同步

<!-- devpace 内置检查（不可删除） -->
- [ ] **需求完整性**：CR 意图 section 与变更复杂度匹配
      检查方式：Claude 检查意图字段填充度（简单=用户原话；标准=+范围+验收条件；复杂=全部字段）

## verifying → in_review

<!-- 命令检查（bash 执行，exit code 判定） -->
- [ ] **初始化脚本测试**：在 Linux 和 macOS 上测试初始化脚本功能
      检查方式：`scripts/test-init.sh`

- [ ] **Markdown 链接检查**：验证所有 Markdown 文件中的相对链接有效性
      检查方式：`scripts/check-links.sh`

<!-- 意图检查（自然语言，Claude 判定）——用自然语言描述质量期望 -->
- [ ] **模板变量一致性**：所有模板文件使用统一的变量占位符格式
      检查方式：Claude 检查模板变量格式符合 docs/template-variables.md 规范

<!-- devpace 内置检查（不可删除） -->
- [ ] **意图一致性**：实际变更与 CR 意图 section 的范围和验收条件一致
      检查方式：Claude 对比 git diff 与意图 section，标注偏差
