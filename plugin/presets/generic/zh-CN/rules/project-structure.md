# 项目目录结构

> **职责**: 项目目录结构规范，定义文件组织和配置文件约定。

> Claude 初始化或检查项目结构时优先查阅此文档

---

## 0. 速查卡片

### 目录结构

<!-- {{AI_GENERATED:directory_tree}}
  根据项目实际结构生成目录树，格式示例:
  ```
  project-root/
  ├── .claude/                    # Claude Code 上下文 (规范文档)
  │   ├── CLAUDE.md               # 项目入口
  │   ├── project-config.md       # 项目配置
  │   └── rules/                  # 规则文档
  ├── src/                        # 源代码
  │   ├── modules/                # 业务模块
  │   └── shared/                 # 共享内核
  ├── tests/                      # 测试代码
  ├── scripts/                    # 工具脚本
  ├── docs/                       # 文档
  └── README.md
  ```
-->

### 配置文件速查

<!-- {{AI_GENERATED:config_files}}
  列出项目关键配置文件，格式示例:
  | 文件 | 用途 | 必须 |
  |------|------|:----:|
  | package.json / pyproject.toml | 项目和工具配置 | ✅ |
  | .env.example | 环境变量模板 | ✅ |
  | README.md | 项目说明 | ✅ |
-->

### 禁止事项

| 规则 | 说明 |
|------|------|
| ❌ 根目录放业务代码 | 所有业务代码必须在源码目录下 |
| ❌ 测试散落源码目录 | 测试必须在独立的测试目录中 |
| ❌ 配置文件散落各处 | 配置统一在根目录或指定位置 |
| ❌ 临时文件入版本控制 | .gitignore 必须排除 |

---

## 文件命名规范

<!-- {{AI_GENERATED:naming_rules}}
  根据项目语言生成文件命名规范，格式示例:
  | 类型 | 命名规范 | 示例 |
  |------|---------|------|
  | 组件文件 | PascalCase | UserProfile.tsx |
  | 工具文件 | kebab-case | date-utils.ts |
  | 测试文件 | xxx.test.ts / test_xxx.py | user.test.ts |
  | 样式文件 | kebab-case | user-profile.css |
-->

---

## 新增模块模板

<!-- {{AI_GENERATED:new_module_template}}
  提供新增模块时应创建的标准目录结构，格式示例:
  ```
  modules/{module-name}/
  ├── index.ts / __init__.py      # 公开 API 导出
  ├── domain/                     # 核心业务逻辑
  ├── application/                # 用例编排
  ├── infrastructure/             # 技术实现
  └── api/                        # 对外接口
  ```
  以及新增模块时的检查清单:
  - [ ] 目录结构已创建
  - [ ] 公开 API 已导出
  - [ ] project-config.md 已更新
-->

---

## 跨文档引用

| 内容 | 参考文档 |
|------|---------|
| 模块内部结构 | [architecture.md](architecture.md) |
| 测试目录结构 | [testing.md](testing.md) |
| PR Review | [checklist.md](checklist.md) §项目结构 |
