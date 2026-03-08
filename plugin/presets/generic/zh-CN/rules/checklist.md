# PR Review 检查清单

> **职责**: PR Review 检查清单的**单一真实源**，涵盖架构、代码风格、安全、测试等检查项。

---

## 架构

<!-- {{AI_GENERATED:checklist_architecture}}
  根据项目实际架构生成架构检查项，格式示例:
  - [ ] 核心层没有外部框架依赖
  - [ ] 依赖方向正确（单向、无循环）
  - [ ] 模块间通信使用规定方式
  - [ ] 公开导出仅包含必要接口
-->

详见 [architecture.md](architecture.md)

---

## 代码风格

<!-- {{AI_GENERATED:checklist_code_style}}
  根据项目实际语言生成代码风格检查项，格式示例:
  - [ ] 所有公共接口都有类型标注
  - [ ] 没有使用 any/Any 逃逸类型
  - [ ] 命名符合项目规范
  - [ ] 没有通配符导入
-->

详见 [code-style.md](code-style.md)

---

## 安全

- [ ] 没有硬编码的密钥或密码
- [ ] 所有用户输入都经过验证
- [ ] 敏感信息不会写入日志
- [ ] 错误响应不暴露内部信息

<!-- {{AI_GENERATED:checklist_security_extra}}
  根据项目特点补充额外安全检查项，格式示例:
  - [ ] 使用参数化查询，没有 SQL 拼接
  - [ ] 没有使用 eval/exec 等危险函数
  - [ ] 密码使用安全哈希算法存储
-->

详见 [security.md](security.md)

---

## 测试

- [ ] 新功能有对应测试
- [ ] AAA 模式 + 清晰命名
- [ ] Mock 仅边界依赖 + 可独立运行
- [ ] 覆盖率达标

<!-- {{AI_GENERATED:checklist_testing_extra}}
  根据项目特点补充额外测试检查项，格式示例:
  - [ ] 使用测试标记（unit/integration/e2e）
  - [ ] 测试在规定目录下
-->

详见 [testing.md](testing.md)

---

## 项目结构

- [ ] 新文件放置在正确目录
- [ ] 无临时文件被提交

<!-- {{AI_GENERATED:checklist_structure_extra}}
  根据项目特点补充额外结构检查项，格式示例:
  - [ ] 测试镜像源码目录结构
  - [ ] 新模块包含必要的初始化文件
-->

详见 [project-structure.md](project-structure.md)

---

## 预提交一键验证

<!-- {{AI_GENERATED:pre_commit_command}}
  生成一行可执行的预提交命令，串联所有检查步骤，格式示例:
  ```bash
  npm run lint && npm run typecheck && npm run test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
  ```
-->
