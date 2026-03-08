# 技术栈定义

> **职责**: 技术栈版本约束的**单一真实源 (SSoT)**，包括语言、框架、工具链等核心依赖版本。

---

## 0. 速查卡片

### 版本要求矩阵

<!-- {{AI_GENERATED:version_matrix}}
  根据项目实际技术栈生成版本矩阵表格，格式示例:
  | 类别 | 技术 | 最低版本 | 推荐版本 |
  |------|------|---------|---------|
  | **语言** | Python / TypeScript / Go ... | >=x.y | x.y+ |
  | **框架** | FastAPI / React / Gin ... | >=x.y | x.y+ |
  | **数据库** | PostgreSQL / MySQL / MongoDB ... | x.y+ | x.y |
  | **包管理** | uv / npm / pnpm / go mod ... | - | 最新 |
  | **代码检查** | Ruff / ESLint / golangci-lint ... | - | 最新 |
  | **类型检查** | MyPy / TypeScript / - ... | - | 最新 |
  | **测试** | pytest / Jest / go test ... | >=x.y | x.y |
-->

### 关键约束

<!-- {{AI_GENERATED:key_constraints}}
  列出项目的关键技术约束，格式示例:
  - **包管理器**: 仅使用 xxx，禁止 yyy
  - **代码检查**: 仅使用 xxx，禁止 yyy
  - **类型检查**: 启用 strict 模式
-->

### 快速验证命令

<!-- {{AI_GENERATED:version_check_commands}}
  生成验证关键版本的命令，格式示例:
  ```bash
  # 检查核心版本
  node --version && npm --version
  # 检查依赖版本
  npm list react typescript
  ```
-->

---

## 工具链配置

<!-- {{AI_GENERATED:toolchain_config}}
  描述关键工具的配置方式和配置文件位置，格式示例:
  | 工具 | 配置文件 | 说明 |
  |------|---------|------|
  | Linter | .eslintrc.js / ruff.toml | 代码风格检查 |
  | Formatter | .prettierrc / pyproject.toml | 代码格式化 |
  | TypeChecker | tsconfig.json / mypy.ini | 类型检查 |
-->

---

## 升级策略

- **主版本升级**: 需团队评审，评估破坏性变更影响
- **次版本升级**: 在开发周期间定期更新
- **补丁版本**: 安全补丁立即应用
- **锁文件**: 使用锁文件固定依赖版本，确保构建可重复

---

## 相关文档

| 文档 | 说明 |
|------|------|
| [CLAUDE.md](../CLAUDE.md) | 技术栈概述和开发命令 |
| [testing.md](testing.md) | 测试规范 |
| [code-style.md](code-style.md) | 代码风格规范 |
