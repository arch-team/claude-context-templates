# 代码风格规范

> **职责**: 代码风格设计原则和具体规范。

> **相关规范**: [tech-stack.md](tech-stack.md) (工具链配置)

> 跨技术栈的代码质量通用原则见 `_common/rules/principles/code-quality.md`

---

## 0. 速查卡片

<!-- {{AI_GENERATED:code_style_quick_ref}}
  生成代码风格速查卡片，应包含:
  - 类型提示速查表（规则 + 示例）
  - 命名速查表（元素 + 样式 + 示例）
  - Linter/Formatter 自动处理项
-->

---

## 命名规范

<!-- {{AI_GENERATED:naming_conventions}}
  根据项目语言生成命名规范表格，格式示例:
  | 元素 | 样式 | 原则 |
  |------|------|------|
  | 函数/方法 | snake_case / camelCase | 动词开头 |
  | 类/接口 | PascalCase | 名词 |
  | 常量 | UPPER_SNAKE | 全大写 |
  | 文件/模块 | kebab-case / snake_case | 清晰描述 |
-->

### 通用命名原则

- 布尔值使用 is/has/can/should 前缀
- 函数命名应体现动作（动词开头）
- 变量命名应体现含义（名词/形容词）
- 集合命名使用复数形式
- 清晰优于简洁

---

## 导入/引用排序

<!-- {{AI_GENERATED:import_rules}}
  根据项目语言生成导入排序规则，格式示例:
  1. 标准库/内置模块
  2. 第三方库
  3. 本地模块
  - 组间空行分隔
  - 禁止通配符导入
  包含正确/错误示例
-->

---

## 类型标注

<!-- {{AI_GENERATED:type_annotations}}
  根据项目语言生成类型标注规范，格式示例:
  - 所有公共接口必须有类型标注
  - 禁止使用 any/Any 逃逸类型
  - 使用语言推荐的类型语法
  包含正确/错误示例
-->

---

## 注释与文档

- 优先通过清晰命名和结构表达意图
- 注释用于解释 WHY，不解释 WHAT
- 避免过时或误导性注释
- 类型即文档：好的类型提示 + 好的命名 = 自解释代码

---

## DO / DON'T 示例

<!-- {{AI_GENERATED:do_dont_examples}}
  根据项目语言生成 DO/DON'T 代码示例，每组包含:
  ```language
  // ❌ DON'T: 说明原因
  错误代码示例

  // ✅ DO: 说明原因
  正确代码示例
  ```
  应覆盖: 命名、类型、导入、异步/并发（如适用）
-->

---

## 检查清单

完整检查清单见 [checklist.md](checklist.md) §代码风格
