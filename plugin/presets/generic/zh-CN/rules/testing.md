# 测试规范

> **职责**: 测试的设计原则、标准和具体实现模式。

> **相关规范**: [project-structure.md](project-structure.md) (测试目录结构) | [tech-stack.md](tech-stack.md) (测试框架版本)

> 跨技术栈的测试通用原则见 `_common/rules/principles/testing.md`
> TDD 工作流见 [CLAUDE.md](../CLAUDE.md)

---

## 通用测试原则

> TDD 核心循环、测试诚信、AAA 模式、Mock 边界、测试独立性、命名规范等通用原则见 `rules/principles/testing.md`

---

## 测试分层标准

<!-- {{AI_GENERATED:test_layering}}
  根据项目实际技术栈生成测试分层表格，格式示例:
  | 层级 | 测试对象 | Mock 策略 | 速度 |
  |------|---------|----------|------|
  | **Unit** | 核心业务逻辑、工具函数 | 外部依赖 | ms |
  | **Integration** | API 端点、数据库交互 | 外部服务 | s |
  | **E2E** | 完整业务流程 | 无 Mock | min |
-->

---

## 覆盖率要求

<!-- {{AI_GENERATED:coverage_requirements}}
  根据项目架构分层生成覆盖率目标表格，格式示例:
  | 层级 | 最低覆盖率 | 目标覆盖率 |
  |------|-----------|-----------|
  | 核心业务 | 95% | 100% |
  | 应用层 | 90% | 95% |
  | **整体** | **80%** | **90%** |
-->

---

## 测试命令速查

<!-- {{AI_GENERATED:test_commands}}
  根据项目实际测试框架生成命令表格，格式示例:
  ```bash
  # 运行所有测试
  xxx test

  # 运行测试 + 覆盖率报告
  xxx test --coverage

  # 运行特定模块的测试
  xxx test path/to/module/

  # 运行标记的测试
  xxx test -m "unit"
  ```
-->

---

## 检查清单

完整检查清单见 [checklist.md](checklist.md) §测试
