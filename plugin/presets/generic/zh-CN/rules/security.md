# 安全规范

> **职责**: 安全设计原则、标准和具体安全检测命令。

> 跨技术栈的安全通用原则见 `_common/rules/principles/security.md`

---

## 0. 速查卡片

<!-- {{AI_GENERATED:security_quick_ref}}
  根据项目语言/框架生成安全速查表，格式示例:
  | 规则 | ❌ 禁止 | ✅ 正确 |
  |------|--------|--------|
  | 硬编码密钥 | `API_KEY = "sk-xxx"` | 环境变量读取 |
  | SQL 注入 | 字符串拼接 SQL | 参数化查询 |
  | 命令注入 | 直接执行用户输入 | 参数化或白名单 |
  | 敏感日志 | 记录密码/Token | 仅记录非敏感信息 |
-->

---

## 密钥管理

- ❌ 禁止硬编码密钥、API Key、密码等敏感信息
- ✅ 使用环境变量或密钥管理服务
- ✅ .gitignore 包含所有敏感配置文件（.env, *.pem, *.key）
- ✅ 使用 .env.example 记录环境变量模板（不含真实值）

---

## 输入验证

- 所有外部输入必须验证后再使用
- 验证应在系统边界进行（API 入口、用户输入处理）
- 采用白名单策略优先于黑名单
- 使用框架提供的验证机制，避免手写验证逻辑

---

## 敏感信息处理

- 日志中禁止输出密码、Token、密钥等
- 错误响应中禁止暴露内部实现细节（堆栈、SQL 语句等）
- PII（个人身份信息）需加密或脱敏

---

## 安全扫描

<!-- {{AI_GENERATED:security_scanning}}
  根据项目语言/工具链生成安全扫描命令，格式示例:
  ```bash
  # 完整安全检查
  xxx audit && xxx scan

  # 按类别检测
  grep -rE "(password|secret|key|token)\s*=\s*['\"][^'\"]+['\"]" src/  # 硬编码密钥
  grep -rE "\beval\s*\(|\bexec\s*\(" src/  # 危险函数
  ```
-->

---

## 认证授权指南

<!-- {{AI_GENERATED:auth_guidelines}}
  根据项目实际认证方案生成指南，格式示例:
  - 认证模型: OAuth2 / JWT / Session / API Key
  - 授权模型: RBAC / ABAC
  - 密码存储: bcrypt / argon2
  - 会话管理: Token 过期策略、刷新机制
-->

---

## 依赖安全

- 定期更新依赖，及时修补安全漏洞
- 使用锁文件固定依赖版本
- 定期运行依赖漏洞扫描

---

## 最小权限原则

- 组件/服务只授予完成任务所需的最小权限
- 定期审查权限配置
- 避免使用通配符权限

---

## 相关文档

- [checklist.md](checklist.md) §安全 - PR Review 检查清单
- [architecture.md](architecture.md) - 架构分层与依赖隔离
